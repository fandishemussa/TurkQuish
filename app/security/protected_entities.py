from __future__ import annotations

import ipaddress
import json
import logging
import os
import re
import unicodedata
from dataclasses import dataclass, field
from functools import lru_cache
from pathlib import Path
from typing import Any
from urllib.parse import urlsplit

logger = logging.getLogger(__name__)

SUPPORTED_CATEGORIES = {
    "bank",
    "fintech",
    "government",
    "ministry",
    "municipality",
    "police",
    "university",
    "hospital",
    "healthcare",
    "telecom",
    "ecommerce",
    "delivery",
    "cargo",
    "retail",
    "travel",
    "crypto",
    "streaming",
    "media",
    "ngo",
    "public_service",
    "education",
    "insurance",
    "energy",
    "aviation",
    "transport",
    "sports",
    "brand",
    "other",
}

DEFAULT_CRITICAL_CATEGORIES = {
    "bank",
    "fintech",
    "government",
    "ministry",
    "police",
    "hospital",
    "healthcare",
    "university",
    "municipality",
    "telecom",
    "cargo",
    "crypto",
}

COMMON_HOST_PREFIXES = {
    "www",
    "m",
    "mobil",
    "mobile",
    "secure",
    "login",
    "account",
    "auth",
    "destek",
    "yardim",
    "online",
}

HIGH_RISK_WORDS = {
    "login",
    "giris",
    "guvenli",
    "hesap",
    "online",
    "sube",
    "banka",
    "odeme",
    "destek",
    "yardim",
    "randevu",
    "basvuru",
    "burs",
    "sonuc",
    "belge",
    "fatura",
    "takip",
    "kargo",
    "teslimat",
    "iade",
    "kampanya",
    "dogrulama",
    "aktivasyon",
    "verify",
    "secure",
    "account",
    "payment",
    "update",
    "reset",
    "claim",
    "prim",
    "borc",
    "borcu",
    "emlak",
    "vergi",
    "tahlil",
    "doktor",
    "muayene",
    "hasta",
    "medikal",
    "medical",
    "akademik",
    "obs",
    "ogrenci",
    "mezun",
    "yemekhane",
    "form",
    "formu",
    "gov",
    "govtr",
}

SUSPICIOUS_TLDS = {
    "com",
    "net",
    "org",
    "info",
    "biz",
    "xyz",
    "site",
    "online",
    "top",
    "club",
    "shop",
    "store",
    "link",
    "click",
    "live",
    "icu",
    "ru",
    "cn",
}

KNOWN_PUBLIC_SUFFIXES = tuple(
    sorted(
        {
            "com.tr",
            "net.tr",
            "org.tr",
            "gov.tr",
            "edu.tr",
            "bel.tr",
            "k12.tr",
            "av.tr",
            "pol.tr",
            "tsk.tr",
            "gen.tr",
            "web.tr",
            "info.tr",
            "biz.tr",
            "name.tr",
            "tv.tr",
            "dr.tr",
            "kep.tr",
            "com",
            "net",
            "org",
            "edu",
            "gov",
            "io",
            "app",
            "dev",
            "info",
            "biz",
            "xyz",
            "site",
            "online",
            "top",
            "club",
            "store",
            "shop",
            "me",
            "tv",
            "cloud",
            "link",
            "click",
            "live",
            "icu",
            "cc",
            "co",
            "co.uk",
            "uk",
            "de",
            "fr",
            "nl",
            "es",
            "it",
            "us",
            "ru",
            "cn",
        },
        key=lambda value: (value.count("."), len(value)),
        reverse=True,
    )
)

CONFIDENCE_RANK = {
    "none": 0,
    "low": 1,
    "medium": 2,
    "high": 3,
    "critical": 4,
}

CONFIDENCE_RISK_FLOOR = {
    "none": 0.0,
    "low": 0.25,
    "medium": 0.55,
    "high": 0.78,
    "critical": 0.93,
}

_MOJIBAKE_TO_ASCII = {
    "Ã‡": "c",
    "Ã§": "c",
    "Äž": "g",
    "ÄŸ": "g",
    "Ä±": "i",
    "Ä°": "i",
    "Ã–": "o",
    "Ã¶": "o",
    "Åž": "s",
    "ÅŸ": "s",
    "Ãœ": "u",
    "Ã¼": "u",
}

_TURKISH_TO_ASCII = str.maketrans(
    {
        "ç": "c",
        "ğ": "g",
        "ı": "i",
        "İ": "i",
        "ö": "o",
        "ş": "s",
        "ü": "u",
        "Ç": "c",
        "Ğ": "g",
        "I": "i",
        "Ö": "o",
        "Ş": "s",
        "Ü": "u",
    }
)

_HOMOGLYPH_TO_ASCII = str.maketrans(
    {
        "0": "o",
        "1": "i",
        "3": "e",
        "4": "a",
        "5": "s",
        "7": "t",
        "8": "b",
        "9": "g",
    }
)


def default_registry_path() -> Path:
    configured = os.getenv("PROTECTED_ENTITY_REGISTRY_PATH")
    if configured:
        return Path(configured)
    return Path(__file__).resolve().parents[1] / "data" / "turkish_protected_brands.json"


def detection_enabled() -> bool:
    return _env_bool("ENABLE_PROTECTED_ENTITY_DETECTION", True)


def min_similarity_from_env() -> float:
    raw = os.getenv("BRAND_IMPERSONATION_MIN_SIMILARITY", "0.86")
    try:
        return float(raw)
    except ValueError:
        logger.warning("Invalid BRAND_IMPERSONATION_MIN_SIMILARITY=%r; using 0.86", raw)
        return 0.86


def critical_categories_from_env() -> set[str]:
    raw = os.getenv("BRAND_IMPERSONATION_CRITICAL_CATEGORIES")
    if not raw:
        return set(DEFAULT_CRITICAL_CATEGORIES)
    return {normalize_turkish_text(item).strip() for item in raw.split(",") if item.strip()}


def normalize_turkish_text(value: Any) -> str:
    text = "" if value is None else str(value)
    for source, replacement in _MOJIBAKE_TO_ASCII.items():
        text = text.replace(source, replacement)
    text = text.translate(_TURKISH_TO_ASCII).casefold()
    text = unicodedata.normalize("NFKD", text)
    text = "".join(char for char in text if not unicodedata.combining(char))
    return text.translate(_TURKISH_TO_ASCII)


def compact_key(value: Any) -> str:
    normalized = normalize_turkish_text(value)
    return re.sub(r"[^a-z0-9]+", "", normalized)


def loose_text(value: Any) -> str:
    normalized = normalize_turkish_text(value)
    normalized = re.sub(r"[_\-.]+", " ", normalized)
    normalized = re.sub(r"[^a-z0-9\s]+", " ", normalized)
    return re.sub(r"\s+", " ", normalized).strip()


def homoglyph_key(value: Any) -> str:
    return compact_key(value).translate(_HOMOGLYPH_TO_ASCII)


def collapse_repeated_characters(value: str) -> str:
    return re.sub(r"(.)\1+", r"\1", value)


def normalize_hostname(hostname: Any) -> str:
    host = _extract_hostname(hostname)
    if not host:
        return ""
    decoded_labels = []
    for label in host.strip(".").split("."):
        if not label:
            continue
        decoded_labels.append(_decode_idna_label(label))
    decoded = ".".join(decoded_labels)
    decoded = normalize_turkish_text(decoded)
    decoded = re.sub(r"[^a-z0-9._-]+", "", decoded)
    decoded = re.sub(r"\.+", ".", decoded)
    return decoded.strip(".")


def strip_common_host_prefixes(hostname: str) -> str:
    labels = [label for label in hostname.split(".") if label]
    while len(labels) > 2 and labels[0] in COMMON_HOST_PREFIXES:
        labels.pop(0)
    return ".".join(labels)


def parse_domain(value: Any) -> "DomainParts":
    try:
        hostname = normalize_hostname(value)
    except Exception:
        logger.exception("Failed to normalize hostname for protected entity analysis.")
        hostname = ""
    hostname_without_prefixes = strip_common_host_prefixes(hostname)
    labels = tuple(label for label in hostname.split(".") if label)
    if not hostname:
        return DomainParts(
            raw=str(value or ""),
            hostname="",
            hostname_without_prefixes="",
            registrable_domain="",
            domain_label="",
            suffix="",
            labels=(),
            is_ip=False,
        )

    is_ip = _is_ip_address(hostname)
    if is_ip or len(labels) <= 1:
        return DomainParts(
            raw=str(value),
            hostname=hostname,
            hostname_without_prefixes=hostname_without_prefixes,
            registrable_domain=hostname,
            domain_label=hostname,
            suffix="",
            labels=labels,
            is_ip=is_ip,
        )

    for suffix in KNOWN_PUBLIC_SUFFIXES:
        suffix_labels = tuple(suffix.split("."))
        if len(labels) <= len(suffix_labels):
            continue
        if labels[-len(suffix_labels) :] == suffix_labels:
            domain_label = labels[-len(suffix_labels) - 1]
            registrable = ".".join(labels[-len(suffix_labels) - 1 :])
            return DomainParts(
                raw=str(value),
                hostname=hostname,
                hostname_without_prefixes=hostname_without_prefixes,
                registrable_domain=registrable,
                domain_label=domain_label,
                suffix=suffix,
                labels=labels,
                is_ip=False,
            )

    domain_label = labels[-2]
    suffix = labels[-1]
    return DomainParts(
        raw=str(value),
        hostname=hostname,
        hostname_without_prefixes=hostname_without_prefixes,
        registrable_domain=".".join(labels[-2:]),
        domain_label=domain_label,
        suffix=suffix,
        labels=labels,
        is_ip=False,
    )


def validate_domain_name(value: Any) -> bool:
    parts = parse_domain(value)
    if not parts.hostname or parts.is_ip:
        return False
    if "." not in parts.hostname:
        return False
    return all(re.fullmatch(r"[a-z0-9](?:[a-z0-9_-]{0,61}[a-z0-9])?", label) for label in parts.labels)


@dataclass(frozen=True)
class DomainParts:
    raw: str
    hostname: str
    hostname_without_prefixes: str
    registrable_domain: str
    domain_label: str
    suffix: str
    labels: tuple[str, ...]
    is_ip: bool = False

    @property
    def observed_domain(self) -> str:
        return self.registrable_domain or self.hostname


@dataclass(frozen=True)
class AliasCandidate:
    original: str
    compact: str
    homoglyph: str
    collapsed: str
    source: str = "alias"

    @classmethod
    def from_value(cls, value: Any, source: str = "alias") -> "AliasCandidate | None":
        original = str(value or "").strip()
        compact = compact_key(original)
        if len(compact) < 2:
            return None
        return cls(
            original=original,
            compact=compact,
            homoglyph=compact.translate(_HOMOGLYPH_TO_ASCII),
            collapsed=collapse_repeated_characters(compact),
            source=source,
        )


@dataclass(frozen=True)
class ProtectedEntity:
    name: str
    category: str
    aliases: tuple[str, ...]
    official_domains: tuple[str, ...]
    alias_candidates: tuple[AliasCandidate, ...]

    @property
    def high_value(self) -> bool:
        return self.category in DEFAULT_CRITICAL_CATEGORIES

    def official_match(self, parts: DomainParts) -> tuple[bool, bool, str | None]:
        for official_domain in self.official_domains:
            if not official_domain:
                continue
            if parts.hostname == official_domain:
                return True, False, official_domain
            if parts.hostname.endswith(f".{official_domain}"):
                return True, True, official_domain
            if parts.registrable_domain == official_domain:
                return True, parts.hostname != official_domain, official_domain
        return False, False, None


@dataclass(frozen=True)
class BrandImpersonationFeatures:
    protected_entity_match: bool = False
    protected_entity_name: str | None = None
    protected_entity_category: str | None = None
    protected_entity_official_domain: str | None = None
    protected_entity_alias_matched: str | None = None
    is_official_domain: bool = False
    is_official_subdomain: bool = False
    alias_in_unofficial_domain: bool = False
    lookalike_similarity: float = 0.0
    edit_distance: int | None = None
    phishing_keyword_near_alias: bool = False
    suspicious_tld_for_entity: bool = False
    impersonation_confidence: str = "none"

    def to_dict(self) -> dict[str, Any]:
        return {
            "protected_entity_match": self.protected_entity_match,
            "protected_entity_name": self.protected_entity_name,
            "protected_entity_category": self.protected_entity_category,
            "protected_entity_official_domain": self.protected_entity_official_domain,
            "protected_entity_alias_matched": self.protected_entity_alias_matched,
            "is_official_domain": self.is_official_domain,
            "is_official_subdomain": self.is_official_subdomain,
            "alias_in_unofficial_domain": self.alias_in_unofficial_domain,
            "lookalike_similarity": round(self.lookalike_similarity, 4),
            "edit_distance": self.edit_distance,
            "phishing_keyword_near_alias": self.phishing_keyword_near_alias,
            "suspicious_tld_for_entity": self.suspicious_tld_for_entity,
            "impersonation_confidence": self.impersonation_confidence,
        }


@dataclass(frozen=True)
class BrandImpersonationResult:
    detected: bool
    entity: str | None
    category: str | None
    matched_alias: str | None
    official_domains: tuple[str, ...]
    observed_domain: str
    confidence: str
    reason: str | None
    features: BrandImpersonationFeatures
    debug: dict[str, Any] = field(default_factory=dict)

    @property
    def risk_score_floor(self) -> float:
        return CONFIDENCE_RISK_FLOOR.get(self.confidence, 0.0)

    def to_api(self, debug: bool = False) -> dict[str, Any]:
        payload: dict[str, Any] = {
            "detected": self.detected,
            "entity": self.entity,
            "category": self.category,
            "matched_alias": self.matched_alias,
            "official_domains": list(self.official_domains),
            "observed_domain": self.observed_domain,
            "confidence": self.confidence,
            "reason": self.reason,
        }
        if debug and self.debug:
            payload["debug"] = self.debug
        return payload


@dataclass(frozen=True)
class _CandidateMatch:
    entity: ProtectedEntity
    alias: AliasCandidate
    match_type: str
    confidence: str
    similarity: float
    edit_distance: int | None
    phishing_keyword_near_alias: bool
    suspicious_tld_for_entity: bool
    token: str

    @property
    def rank(self) -> tuple[int, float, int]:
        edit_rank = 99 if self.edit_distance is None else -self.edit_distance
        return (CONFIDENCE_RANK[self.confidence], self.similarity, edit_rank)


class ProtectedEntityRegistry:
    def __init__(
        self,
        entities: list[ProtectedEntity],
        *,
        source_path: str | Path | None = None,
        warnings: list[str] | None = None,
        enabled: bool | None = None,
        min_similarity: float | None = None,
        critical_categories: set[str] | None = None,
    ) -> None:
        self.entities = tuple(entities)
        self.source_path = Path(source_path) if source_path else None
        self.warnings = tuple(warnings or [])
        self.enabled = detection_enabled() if enabled is None else enabled
        self.min_similarity = min_similarity_from_env() if min_similarity is None else min_similarity
        self.critical_categories = (
            critical_categories_from_env() if critical_categories is None else set(critical_categories)
        )

    @classmethod
    def load(cls, path: str | Path | None = None) -> "ProtectedEntityRegistry":
        registry_path = Path(path) if path else default_registry_path()
        with registry_path.open("r", encoding="utf-8") as handle:
            payload = json.load(handle)
        entries = payload.get("entities", payload) if isinstance(payload, dict) else payload
        if not isinstance(entries, list):
            raise ValueError("Protected entity registry must be a list or an object with an 'entities' list.")

        warnings: list[str] = []
        entities: list[ProtectedEntity] = []
        for index, raw_entity in enumerate(entries):
            entity = _parse_entity(raw_entity, index=index, warnings=warnings)
            entities.append(entity)
        return cls(entities, source_path=registry_path, warnings=warnings)

    def analyze_url(self, url: Any, *, debug: bool = False) -> BrandImpersonationResult:
        parts = parse_domain(url)
        base_debug = {"hostname": parts.hostname, "registrable_domain": parts.registrable_domain} if debug else {}

        try:
            if not self.enabled:
                return _no_detection(parts, debug=base_debug)
            if not parts.hostname:
                return _no_detection(parts, debug=base_debug)

            official = self._find_official_entity(parts)
            if official is not None:
                entity, is_subdomain, official_domain = official
                features = BrandImpersonationFeatures(
                    protected_entity_match=True,
                    protected_entity_name=entity.name,
                    protected_entity_category=entity.category,
                    protected_entity_official_domain=official_domain,
                    is_official_domain=True,
                    is_official_subdomain=is_subdomain,
                    impersonation_confidence="none",
                )
                return BrandImpersonationResult(
                    detected=False,
                    entity=None,
                    category=None,
                    matched_alias=None,
                    official_domains=(),
                    observed_domain=parts.observed_domain,
                    confidence="none",
                    reason=None,
                    features=features,
                    debug=base_debug,
                )

            best_match: _CandidateMatch | None = None
            keyword_hits = _keyword_hits(parts)
            for entity in self.entities:
                candidate = self._best_match_for_entity(entity, parts, keyword_hits)
                if candidate is None:
                    continue
                if best_match is None or candidate.rank > best_match.rank:
                    best_match = candidate

            if best_match is None or best_match.confidence == "none":
                return _no_detection(parts, debug=base_debug)

            features = BrandImpersonationFeatures(
                protected_entity_match=True,
                protected_entity_name=best_match.entity.name,
                protected_entity_category=best_match.entity.category,
                protected_entity_official_domain=best_match.entity.official_domains[0]
                if best_match.entity.official_domains
                else None,
                protected_entity_alias_matched=best_match.alias.original,
                is_official_domain=False,
                is_official_subdomain=False,
                alias_in_unofficial_domain=best_match.match_type in {"exact_alias", "alias_substring"},
                lookalike_similarity=best_match.similarity,
                edit_distance=best_match.edit_distance,
                phishing_keyword_near_alias=best_match.phishing_keyword_near_alias,
                suspicious_tld_for_entity=best_match.suspicious_tld_for_entity,
                impersonation_confidence=best_match.confidence,
            )
            reason = _build_reason(best_match, parts)
            debug_payload = dict(base_debug)
            if debug:
                debug_payload.update(
                    {
                        "match_type": best_match.match_type,
                        "match_token": best_match.token,
                        "keyword_hits": sorted(keyword_hits),
                        "similarity": round(best_match.similarity, 4),
                        "edit_distance": best_match.edit_distance,
                    }
                )
            return BrandImpersonationResult(
                detected=True,
                entity=best_match.entity.name,
                category=best_match.entity.category,
                matched_alias=best_match.alias.original,
                official_domains=best_match.entity.official_domains,
                observed_domain=parts.observed_domain,
                confidence=best_match.confidence,
                reason=reason,
                features=features,
                debug=debug_payload,
            )
        except Exception:
            logger.exception("Protected entity analysis failed; returning neutral impersonation signal.")
            if debug:
                base_debug = dict(base_debug)
                base_debug["internal_error"] = "protected_entity_analysis_failed"
            return _no_detection(parts, debug=base_debug)

    def _find_official_entity(
        self, parts: DomainParts
    ) -> tuple[ProtectedEntity, bool, str] | None:
        for entity in self.entities:
            is_official, is_subdomain, official_domain = entity.official_match(parts)
            if is_official and official_domain:
                return entity, is_subdomain, official_domain
        return None

    def _best_match_for_entity(
        self,
        entity: ProtectedEntity,
        parts: DomainParts,
        keyword_hits: set[str],
    ) -> _CandidateMatch | None:
        best: _CandidateMatch | None = None
        tokens = _domain_tokens(parts)
        token_compacts = {token.compact for token in tokens if token.compact}
        token_homoglyphs = {token.homoglyph for token in tokens if token.homoglyph}
        host_compact = compact_key(parts.hostname_without_prefixes)
        host_homoglyph = host_compact.translate(_HOMOGLYPH_TO_ASCII)
        suspicious_tld = _suspicious_tld_for_entity(entity, parts)

        for alias in entity.alias_candidates:
            exact = _exact_alias_match(alias, tokens, token_compacts, token_homoglyphs, host_compact, host_homoglyph)
            if exact is not None:
                match_type, token = exact
                confidence = _confidence_for_exact(
                    entity,
                    alias,
                    has_keyword=bool(keyword_hits),
                    suspicious_tld=suspicious_tld,
                    critical_categories=self.critical_categories,
                    match_type=match_type,
                )
                if confidence != "none":
                    candidate = _CandidateMatch(
                        entity=entity,
                        alias=alias,
                        match_type=match_type,
                        confidence=confidence,
                        similarity=1.0,
                        edit_distance=0,
                        phishing_keyword_near_alias=bool(keyword_hits),
                        suspicious_tld_for_entity=suspicious_tld,
                        token=token,
                    )
                    best = _choose_better(best, candidate)

            fuzzy = _fuzzy_alias_match(alias, tokens, self.min_similarity)
            if fuzzy is not None:
                token, similarity, edit_distance = fuzzy
                confidence = _confidence_for_fuzzy(
                    entity,
                    alias,
                    token=token,
                    similarity=similarity,
                    edit_distance=edit_distance,
                    has_keyword=bool(keyword_hits),
                    suspicious_tld=suspicious_tld,
                    critical_categories=self.critical_categories,
                )
                if confidence != "none":
                    candidate = _CandidateMatch(
                        entity=entity,
                        alias=alias,
                        match_type="lookalike",
                        confidence=confidence,
                        similarity=similarity,
                        edit_distance=edit_distance,
                        phishing_keyword_near_alias=bool(keyword_hits),
                        suspicious_tld_for_entity=suspicious_tld,
                        token=token,
                    )
                    best = _choose_better(best, candidate)

        return best


def get_default_registry(*, reload: bool = False) -> ProtectedEntityRegistry:
    if reload:
        _get_default_registry_cached.cache_clear()
    return _get_default_registry_cached(str(default_registry_path()))


@lru_cache(maxsize=4)
def _get_default_registry_cached(path: str) -> ProtectedEntityRegistry:
    return ProtectedEntityRegistry.load(path)


def analyze_url_brand_impersonation(url: Any, *, debug: bool = False) -> BrandImpersonationResult:
    return get_default_registry().analyze_url(url, debug=debug)


def _parse_entity(raw_entity: Any, *, index: int, warnings: list[str]) -> ProtectedEntity:
    if not isinstance(raw_entity, dict):
        raise ValueError(f"Entity #{index} must be an object.")

    required_types = {
        "name": str,
        "category": str,
        "aliases": list,
        "official_domains": list,
    }
    for field_name, expected_type in required_types.items():
        if field_name not in raw_entity:
            raise ValueError(f"Entity #{index} is missing required field '{field_name}'.")
        if not isinstance(raw_entity[field_name], expected_type):
            raise ValueError(f"Entity #{index} field '{field_name}' must be {expected_type.__name__}.")

    name = raw_entity["name"].strip()
    raw_category = normalize_turkish_text(raw_entity["category"]).strip()
    category = raw_category if raw_category in SUPPORTED_CATEGORIES else "other"
    if category != raw_category:
        message = f"Entity '{name}' has unknown category '{raw_entity['category']}', loaded as 'other'."
        warnings.append(message)
        logger.warning(message)

    aliases = tuple(_require_string_list(raw_entity["aliases"], field_name=f"{name}.aliases"))
    official_domains = tuple(
        dict.fromkeys(
            normalized
            for domain in _require_string_list(raw_entity["official_domains"], field_name=f"{name}.official_domains")
            if (normalized := _normalize_official_domain(domain))
        )
    )

    alias_values: list[tuple[str, str]] = [(alias, "alias") for alias in aliases]
    alias_values.append((name, "name"))
    for official_domain in official_domains:
        official_parts = parse_domain(official_domain)
        if official_parts.domain_label:
            alias_values.append((official_parts.domain_label, "official_domain_label"))
        alias_values.append((official_domain, "official_domain"))

    seen_aliases: set[str] = set()
    alias_candidates: list[AliasCandidate] = []
    for alias_value, source in alias_values:
        candidate = AliasCandidate.from_value(alias_value, source=source)
        if candidate is None or candidate.compact in seen_aliases:
            continue
        seen_aliases.add(candidate.compact)
        alias_candidates.append(candidate)

    return ProtectedEntity(
        name=name,
        category=category,
        aliases=aliases,
        official_domains=official_domains,
        alias_candidates=tuple(alias_candidates),
    )


def _require_string_list(values: list[Any], *, field_name: str) -> list[str]:
    result: list[str] = []
    for index, value in enumerate(values):
        if not isinstance(value, str):
            raise ValueError(f"{field_name}[{index}] must be a string.")
        cleaned = value.strip()
        if cleaned:
            result.append(cleaned)
    return result


def _normalize_official_domain(value: Any) -> str:
    host = normalize_hostname(value)
    return strip_common_host_prefixes(host)


def _domain_tokens(parts: DomainParts) -> tuple[AliasCandidate, ...]:
    suffix_labels = set(parts.suffix.split(".")) if parts.suffix else set()
    values: list[tuple[str, str]] = [
        (parts.domain_label, "registered_domain_label"),
        (parts.registrable_domain, "registered_domain"),
        (parts.hostname_without_prefixes, "hostname"),
    ]
    for label in parts.hostname_without_prefixes.split("."):
        if not label or label in suffix_labels:
            continue
        values.append((label, "hostname_label"))
        for item in re.split(r"[-_]+", label):
            if item and item not in suffix_labels:
                values.append((item, "hostname_label_part"))

    seen: set[str] = set()
    tokens: list[AliasCandidate] = []
    for value, source in values:
        candidate = AliasCandidate.from_value(value, source=source)
        if candidate is None or candidate.compact in seen:
            continue
        seen.add(candidate.compact)
        tokens.append(candidate)
    return tuple(tokens)


def _keyword_hits(parts: DomainParts) -> set[str]:
    compact_host = compact_key(parts.hostname_without_prefixes)
    homoglyph_host = compact_host.translate(_HOMOGLYPH_TO_ASCII)
    return {
        keyword
        for keyword in _HIGH_RISK_KEYS()
        if keyword and (keyword in compact_host or keyword in homoglyph_host)
    }


@lru_cache(maxsize=1)
def _HIGH_RISK_KEYS() -> tuple[str, ...]:
    return tuple(sorted({compact_key(word) for word in HIGH_RISK_WORDS}, key=len, reverse=True))


def _exact_alias_match(
    alias: AliasCandidate,
    tokens: tuple[AliasCandidate, ...],
    token_compacts: set[str],
    token_homoglyphs: set[str],
    host_compact: str,
    host_homoglyph: str,
) -> tuple[str, str] | None:
    if len(alias.compact) < 3:
        return None
    if alias.compact in token_compacts or alias.homoglyph in token_homoglyphs:
        return "exact_alias", alias.compact

    if len(alias.compact) <= 3:
        return None

    for token in tokens:
        token_values = {token.compact, token.homoglyph}
        alias_values = {alias.compact, alias.homoglyph}
        for token_value in token_values:
            if not token_value:
                continue
            for alias_value in alias_values:
                if alias_value and alias_value in token_value:
                    if len(alias_value) <= 4:
                        length_gap = len(token_value) - len(alias_value)
                        if token_value.startswith(alias_value) or token_value.endswith(alias_value):
                            if 0 <= length_gap <= 2:
                                return "alias_substring", token.compact
                        continue
                    return "alias_substring", token.compact

    if len(alias.compact) >= 5 and (alias.compact in host_compact or alias.homoglyph in host_homoglyph):
        return "alias_substring", alias.compact
    return None


def _fuzzy_alias_match(
    alias: AliasCandidate,
    tokens: tuple[AliasCandidate, ...],
    min_similarity: float,
) -> tuple[str, float, int] | None:
    if len(alias.compact) < 4:
        return None

    best: tuple[str, float, int] | None = None
    alias_values = {alias.compact, alias.homoglyph, alias.collapsed}
    for token in tokens:
        token_values = {token.compact, token.homoglyph, token.collapsed}
        if token.compact in _HIGH_RISK_KEYS():
            continue
        for token_value in token_values:
            if not token_value:
                continue
            for alias_value in alias_values:
                if not alias_value or token_value == alias_value:
                    continue
                if abs(len(token_value) - len(alias_value)) > max(3, len(alias_value) // 2):
                    continue
                edit_distance = levenshtein_distance(token_value, alias_value)
                jw_similarity = jaro_winkler_similarity(token_value, alias_value)
                edit_similarity = 1.0 - (edit_distance / max(len(token_value), len(alias_value)))
                similarity = max(jw_similarity, edit_similarity)

                short_alias_inserted = (
                    len(alias_value) <= 4
                    and alias_value in token_value
                    and 0 < len(token_value) - len(alias_value) <= 2
                )
                same_start = token_value[0] == alias_value[0]
                medium_or_long_close = len(alias_value) > 4 and same_start and (
                    edit_distance <= 2
                    and edit_similarity >= 0.75
                    and similarity >= min_similarity
                )
                short_close = len(alias_value) <= 4 and (
                    similarity >= 0.90 or edit_distance <= 1 or short_alias_inserted
                )
                if not (medium_or_long_close or short_close):
                    continue
                candidate = (token.compact, similarity, edit_distance)
                if best is None or (candidate[1], -candidate[2]) > (best[1], -best[2]):
                    best = candidate
    return best


def _confidence_for_exact(
    entity: ProtectedEntity,
    alias: AliasCandidate,
    *,
    has_keyword: bool,
    suspicious_tld: bool,
    critical_categories: set[str],
    match_type: str,
) -> str:
    critical_category = entity.category in critical_categories
    short_alias = len(alias.compact) <= 4
    public_institution = entity.category in {"government", "ministry", "police", "public_service"}
    sensitive = entity.category in {"bank", "fintech", "hospital", "healthcare", "municipality", "cargo", "crypto"}

    if has_keyword:
        return "critical"
    if public_institution and (not short_alias or suspicious_tld):
        return "critical"
    if sensitive and suspicious_tld:
        return "critical"
    if critical_category and not short_alias:
        return "high"
    if critical_category and short_alias:
        return "medium" if match_type == "exact_alias" or suspicious_tld else "low"
    if short_alias:
        return "low"
    return "high"


def _confidence_for_fuzzy(
    entity: ProtectedEntity,
    alias: AliasCandidate,
    *,
    token: str,
    similarity: float,
    edit_distance: int,
    has_keyword: bool,
    suspicious_tld: bool,
    critical_categories: set[str],
) -> str:
    critical_category = entity.category in critical_categories
    sensitive = entity.category in {"government", "ministry", "police", "bank", "fintech", "hospital", "healthcare"}
    short_alias = len(alias.compact) <= 4
    strong = similarity >= 0.90 or edit_distance <= 1
    inserted_short_alias = short_alias and alias.compact in token and 0 < len(token) - len(alias.compact) <= 2

    if short_alias and not (inserted_short_alias or has_keyword or suspicious_tld or strong):
        return "none"
    if sensitive and (has_keyword or suspicious_tld or strong):
        return "critical"
    if sensitive:
        return "high"
    if critical_category and (has_keyword or suspicious_tld or strong or inserted_short_alias):
        return "high"
    if critical_category:
        return "medium"
    if strong:
        return "high"
    return "medium"


def _suspicious_tld_for_entity(entity: ProtectedEntity, parts: DomainParts) -> bool:
    if not parts.suffix:
        return False
    official_suffixes = {parse_domain(domain).suffix for domain in entity.official_domains if domain}
    if official_suffixes and parts.suffix not in official_suffixes:
        return True
    return parts.suffix in SUSPICIOUS_TLDS and entity.category in DEFAULT_CRITICAL_CATEGORIES


def _build_reason(match: _CandidateMatch, parts: DomainParts) -> str:
    official = match.entity.official_domains[0] if match.entity.official_domains else "the entity registry"
    if match.match_type in {"exact_alias", "alias_substring"} and match.phishing_keyword_near_alias:
        if match.entity.category in {"government", "ministry", "police", "public_service"}:
            return (
                "Government or public-service alias appears in an unofficial domain "
                "with application/login/payment-related wording."
            )
        return (
            "Protected entity alias appears in an unofficial domain with phishing-related wording."
        )
    if match.match_type in {"exact_alias", "alias_substring"}:
        return "Protected entity alias appears in a domain that is not an official domain or subdomain."
    return (
        f"Observed domain is not an official domain but is highly similar to protected alias/domain {official}."
    )


def _no_detection(parts: DomainParts, *, debug: dict[str, Any] | None = None) -> BrandImpersonationResult:
    return BrandImpersonationResult(
        detected=False,
        entity=None,
        category=None,
        matched_alias=None,
        official_domains=(),
        observed_domain=parts.observed_domain,
        confidence="none",
        reason=None,
        features=BrandImpersonationFeatures(),
        debug=debug or {},
    )


def _choose_better(
    current: _CandidateMatch | None, candidate: _CandidateMatch
) -> _CandidateMatch:
    if current is None or candidate.rank > current.rank:
        return candidate
    return current


def levenshtein_distance(left: str, right: str) -> int:
    if left == right:
        return 0
    if not left:
        return len(right)
    if not right:
        return len(left)
    if len(left) < len(right):
        left, right = right, left
    previous = list(range(len(right) + 1))
    for left_index, left_char in enumerate(left, start=1):
        current = [left_index]
        for right_index, right_char in enumerate(right, start=1):
            insertion = current[right_index - 1] + 1
            deletion = previous[right_index] + 1
            substitution = previous[right_index - 1] + (left_char != right_char)
            current.append(min(insertion, deletion, substitution))
        previous = current
    return previous[-1]


def jaro_winkler_similarity(left: str, right: str) -> float:
    if left == right:
        return 1.0
    if not left or not right:
        return 0.0

    match_distance = max(len(left), len(right)) // 2 - 1
    left_matches = [False] * len(left)
    right_matches = [False] * len(right)

    matches = 0
    for left_index, left_char in enumerate(left):
        start = max(0, left_index - match_distance)
        end = min(left_index + match_distance + 1, len(right))
        for right_index in range(start, end):
            if right_matches[right_index] or left_char != right[right_index]:
                continue
            left_matches[left_index] = True
            right_matches[right_index] = True
            matches += 1
            break

    if matches == 0:
        return 0.0

    transpositions = 0
    right_index = 0
    for left_index, left_matched in enumerate(left_matches):
        if not left_matched:
            continue
        while not right_matches[right_index]:
            right_index += 1
        if left[left_index] != right[right_index]:
            transpositions += 1
        right_index += 1
    transpositions /= 2

    jaro = (
        (matches / len(left))
        + (matches / len(right))
        + ((matches - transpositions) / matches)
    ) / 3
    prefix = 0
    for left_char, right_char in zip(left, right, strict=False):
        if left_char != right_char:
            break
        prefix += 1
        if prefix == 4:
            break
    return jaro + (0.1 * prefix * (1 - jaro))


def _extract_hostname(value: Any) -> str:
    raw = "" if value is None else str(value).strip()
    if not raw:
        return ""
    parse_target = raw if "://" in raw else f"//{raw}"
    try:
        parsed = urlsplit(parse_target)
    except ValueError:
        try:
            parsed = urlsplit(f"//{raw.replace(' ', '')}")
        except ValueError:
            cleaned = raw.replace(" ", "").split("/", 1)[0].split("?", 1)[0].rsplit("@", 1)[-1]
            return cleaned.strip("[]").strip(".")
    host = parsed.hostname
    if not host:
        host = raw.split("/", 1)[0].split("?", 1)[0].rsplit("@", 1)[-1].split(":", 1)[0]
    return host.strip("[]").strip(".")


def _decode_idna_label(label: str) -> str:
    try:
        if label.startswith("xn--"):
            return label.encode("ascii").decode("idna")
        return label.encode("idna").decode("idna")
    except UnicodeError:
        return label


def _is_ip_address(hostname: str) -> bool:
    try:
        ipaddress.ip_address(hostname)
    except ValueError:
        return False
    return True


def _env_bool(name: str, default: bool) -> bool:
    raw = os.getenv(name)
    if raw is None:
        return default
    return raw.strip().casefold() in {"1", "true", "yes", "on"}
