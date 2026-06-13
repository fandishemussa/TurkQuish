from __future__ import annotations

import csv
import tempfile
import unittest
from pathlib import Path

from tools.benchmark_runtime import (
    BenchmarkResult,
    DEFAULT_URLS,
    PROBLEMATIC_EXAMPLE_URL,
    STABLE_SYNTHETIC_SUSPICIOUS_URL,
    load_urls,
    write_runtime_summary,
)


class BenchmarkRuntimeTests(unittest.TestCase):
    def test_default_urls_use_stable_synthetic_suspicious_url(self) -> None:
        self.assertIn(STABLE_SYNTHETIC_SUSPICIOUS_URL, DEFAULT_URLS)
        self.assertNotIn(PROBLEMATIC_EXAMPLE_URL, DEFAULT_URLS)

    def test_summary_excludes_failed_requests_from_timing_rows(self) -> None:
        results = [
            BenchmarkResult(
                index=1,
                url="https://ktun.edu.tr",
                status_code=200,
                success=True,
                error_message="",
                api_request_response_ms=100.0,
                backend_latency_ms=95.0,
                timing_ms={
                    "total_backend": 10.0,
                    "feature_extraction": 1.0,
                    "brand_analysis": 1.5,
                    "histgb_inference": 2.0,
                    "url_transformer_inference": 3.0,
                    "decision_fusion": 4.0,
                },
            ),
            BenchmarkResult(
                index=2,
                url="https://rate-limited.test",
                status_code=429,
                success=False,
                error_message="Too many requests",
                api_request_response_ms=999.0,
                backend_latency_ms=None,
                timing_ms={
                    "total_backend": 999.0,
                    "feature_extraction": 999.0,
                    "brand_analysis": 999.0,
                },
            ),
            BenchmarkResult(
                index=3,
                url="https://error.test",
                status_code=500,
                success=False,
                error_message="Internal error",
                api_request_response_ms=888.0,
                backend_latency_ms=None,
                timing_ms={},
            ),
        ]

        with tempfile.TemporaryDirectory() as tmp_dir:
            summary_path = Path(tmp_dir) / "runtime_summary.csv"
            write_runtime_summary(summary_path, results)
            with summary_path.open(encoding="utf-8") as handle:
                rows = list(csv.DictReader(handle))

        requests_row = next(row for row in rows if row["metric"] == "requests")
        self.assertEqual(requests_row["total_requests"], "3")
        self.assertEqual(requests_row["success_count"], "1")
        self.assertEqual(requests_row["failure_count"], "2")

        total_backend_row = next(row for row in rows if row["metric"] == "timingMs.total_backend")
        self.assertEqual(total_backend_row["summary_scope"], "measured_successes_only")
        self.assertEqual(total_backend_row["count"], "1")
        self.assertEqual(total_backend_row["mean_ms"], "10.0000")

        backend_latency_row = next(row for row in rows if row["metric"] == "backend_latency_ms")
        self.assertEqual(backend_latency_row["count"], "1")
        self.assertEqual(backend_latency_row["mean_ms"], "95.0000")

        brand_analysis_row = next(row for row in rows if row["metric"] == "timingMs.brand_analysis")
        self.assertEqual(brand_analysis_row["count"], "1")
        self.assertEqual(brand_analysis_row["mean_ms"], "1.5000")

        status_429_row = next(row for row in rows if row["metric"] == "status_code" and row["status_code"] == "429")
        status_500_row = next(row for row in rows if row["metric"] == "status_code" and row["status_code"] == "500")
        self.assertEqual(status_429_row["count"], "1")
        self.assertEqual(status_500_row["count"], "1")

    def test_url_file_loader_skips_blank_lines_and_comments(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            urls_path = Path(tmp_dir) / "urls.txt"
            urls_path.write_text(
                "\n# comment\nhttps://ktun.edu.tr\n\nhttps://mhrs.gov.tr\n",
                encoding="utf-8",
            )
            self.assertEqual(load_urls(str(urls_path)), ["https://ktun.edu.tr", "https://mhrs.gov.tr"])


if __name__ == "__main__":
    unittest.main()
