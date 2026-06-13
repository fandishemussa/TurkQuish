from app.security.protected_entities import (
    BrandImpersonationFeatures,
    BrandImpersonationResult,
    ProtectedEntity,
    ProtectedEntityRegistry,
    analyze_url_brand_impersonation,
    compact_key,
    get_default_registry,
    normalize_hostname,
    normalize_turkish_text,
    parse_domain,
    validate_domain_name,
)

__all__ = [
    "BrandImpersonationFeatures",
    "BrandImpersonationResult",
    "ProtectedEntity",
    "ProtectedEntityRegistry",
    "analyze_url_brand_impersonation",
    "compact_key",
    "get_default_registry",
    "normalize_hostname",
    "normalize_turkish_text",
    "parse_domain",
    "validate_domain_name",
]

