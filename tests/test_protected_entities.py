from __future__ import annotations

import unittest

from app.security.prediction_postprocessing import apply_brand_impersonation_postprocessing
from app.security.protected_entities import (
    ProtectedEntityRegistry,
    get_default_registry,
    normalize_turkish_text,
)


class ProtectedEntityRegistryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.registry: ProtectedEntityRegistry = get_default_registry(reload=True)

    def test_registry_loads_seed_entities(self) -> None:
        self.assertGreaterEqual(len(self.registry.entities), 40)
        categories = {entity.category for entity in self.registry.entities}
        self.assertIn("bank", categories)
        self.assertIn("government", categories)
        self.assertIn("university", categories)
        self.assertIn("hospital", categories)
        self.assertIn("municipality", categories)

    def test_turkish_and_mojibake_normalization(self) -> None:
        self.assertEqual(normalize_turkish_text("giriş güvenli ödeme"), "giris guvenli odeme")
        self.assertEqual(normalize_turkish_text("giriÅŸ gÃ¼venli Ã¶deme"), "giris guvenli odeme")

    def test_official_domains_are_not_flagged(self) -> None:
        official_urls = [
            "https://ktun.edu.tr",
            "https://obs.ktun.edu.tr",
            "https://turkiye.gov.tr",
            "https://enabiz.gov.tr",
            "https://mhrs.gov.tr",
            "https://ziraatbank.com.tr",
            "https://garanti.com.tr",
            "https://trendyol.com",
            "https://login.ziraatbank.com.tr",
        ]

        for url in official_urls:
            with self.subTest(url=url):
                result = self.registry.analyze_url(url)
                self.assertFalse(result.detected)
                self.assertEqual(result.confidence, "none")
                self.assertTrue(result.features.is_official_domain)

    def test_suspicious_domains_are_flagged(self) -> None:
        cases = {
            "https://kkktun.edu.tr": ("Konya Technical University", "high"),
            "https://ktun-login.com": ("Konya Technical University", "critical"),
            "https://ziraat-bankasi-login.com": ("Ziraat Bankasi", "critical"),
            "https://garanti-guvenli.com": ("Garanti BBVA", "critical"),
            "https://turkiye-gov-tr.com": ("e-Devlet Kapisi", "critical"),
            "https://edevlet-basvuru.net": ("e-Devlet Kapisi", "critical"),
            "https://enabiz-sonuc.com": ("e-Nabiz", "critical"),
            "https://mhrs-randevu.org": ("MHRS", "critical"),
            "https://ptt-kargo-takip.net": ("PTT", "critical"),
            "https://trendyol-iade-formu.com": ("Trendyol", "critical"),
            "https://vakifbank-dogrulama.com": ("VakifBank", "critical"),
            "https://sgk-prim-borcu.net": ("Sosyal Guvenlik Kurumu", "critical"),
            "https://webtapu-randevu.com": ("Web Tapu", "critical"),
            "https://belediye-odeme.com": ("Turkish Municipality Services", "critical"),
        }

        for url, (entity, minimum_confidence) in cases.items():
            with self.subTest(url=url):
                result = self.registry.analyze_url(url)
                self.assertTrue(result.detected)
                self.assertEqual(result.entity, entity)
                self.assertGreaterEqual(_confidence_rank(result.confidence), _confidence_rank(minimum_confidence))
                self.assertTrue(result.reason)

    def test_fuzzy_lookalikes_are_flagged(self) -> None:
        cases = {
            "https://ziraatbanka.com": "Ziraat Bankasi",
            "https://trndyol.com": "Trendyol",
            "https://garantibvva.com": "Garanti BBVA",
            "https://turkiyeg0v.com": "e-Devlet Kapisi",
            "https://enabizz.com": "e-Nabiz",
        }

        for url, entity in cases.items():
            with self.subTest(url=url):
                result = self.registry.analyze_url(url)
                self.assertTrue(result.detected)
                self.assertEqual(result.entity, entity)
                self.assertIn(result.confidence, {"high", "critical"})

    def test_short_ambiguous_aliases_need_context(self) -> None:
        false_positive_urls = [
            "https://sgkitchen.example",
            "https://egmotion.example",
            "https://pttools.example",
            "https://ordinary-market.example",
            "https://trendline.example",
            "https://good.edu.tr",
        ]

        for url in false_positive_urls:
            with self.subTest(url=url):
                result = self.registry.analyze_url(url)
                self.assertFalse(result.detected)

    def test_api_shape_contains_brand_impersonation_explanation(self) -> None:
        result = self.registry.analyze_url("https://edevlet-basvuru.net", debug=True)
        payload = result.to_api(debug=True)

        self.assertEqual(
            set(payload),
            {
                "detected",
                "entity",
                "category",
                "matched_alias",
                "official_domains",
                "observed_domain",
                "confidence",
                "reason",
                "debug",
            },
        )
        self.assertTrue(payload["detected"])
        self.assertEqual(payload["category"], "government")
        self.assertEqual(payload["confidence"], "critical")
        self.assertEqual(payload["observed_domain"], "edevlet-basvuru.net")

    def test_postprocessing_preserves_existing_response_and_adds_signal(self) -> None:
        response = {
            "predictionId": "abc",
            "normalizedUrl": "https://ziraat-bankasi-login.com",
            "predictedClass": "benign",
            "riskScore": 0.1,
            "features": {"existing": 1},
        }

        updated = apply_brand_impersonation_postprocessing(response, registry=self.registry)

        self.assertEqual(updated["predictionId"], "abc")
        self.assertEqual(updated["features"], {"existing": 1})
        self.assertEqual(updated["predictedClass"], "phishing")
        self.assertGreaterEqual(updated["riskScore"], 0.93)
        self.assertTrue(updated["brand_impersonation"]["detected"])
        self.assertTrue(updated["brand_impersonation_features"]["protected_entity_match"])

    def test_problematic_suspicious_url_returns_normal_brand_result(self) -> None:
        url = "https://ziraat-bankasi-guvenli-giris.example/login"

        result = self.registry.analyze_url(url)

        self.assertTrue(result.detected)
        self.assertEqual(result.entity, "Ziraat Bankasi")
        self.assertEqual(result.confidence, "critical")

    def test_malformed_url_does_not_raise_from_brand_analysis(self) -> None:
        result = self.registry.analyze_url("https://[broken-host/login", debug=True)

        self.assertFalse(result.detected)
        self.assertEqual(result.confidence, "none")

    def test_postprocessing_logs_and_preserves_prediction_if_brand_analysis_fails(self) -> None:
        response = {
            "predictionId": "abc",
            "normalizedUrl": "https://example.test",
            "predictedClass": "benign",
            "riskScore": 0.1,
        }

        with self.assertLogs("app.security.prediction_postprocessing", level="ERROR"):
            updated = apply_brand_impersonation_postprocessing(
                response,
                registry=_FailingRegistry(),
            )

        self.assertEqual(updated["predictedClass"], "benign")
        self.assertEqual(updated["riskScore"], 0.1)
        self.assertFalse(updated["brand_impersonation"]["detected"])
        self.assertFalse(updated["brand_impersonation_features"]["protected_entity_match"])


def _confidence_rank(value: str) -> int:
    return {"none": 0, "low": 1, "medium": 2, "high": 3, "critical": 4}[value]


class _FailingRegistry:
    def analyze_url(self, *args, **kwargs):
        raise RuntimeError("simulated analyzer failure")


if __name__ == "__main__":
    unittest.main()
