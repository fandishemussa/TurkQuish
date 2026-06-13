from __future__ import annotations

import logging
from collections.abc import MutableMapping
from typing import Any

from app.security.protected_entities import (
    BrandImpersonationFeatures,
    BrandImpersonationResult,
    ProtectedEntityRegistry,
    analyze_url_brand_impersonation,
    parse_domain,
)

logger = logging.getLogger(__name__)


def apply_brand_impersonation_postprocessing(
    response: MutableMapping[str, Any],
    *,
    url: str | None = None,
    registry: ProtectedEntityRegistry | None = None,
    debug: bool = False,
) -> MutableMapping[str, Any]:
    """Add protected-entity impersonation output without removing ML fields."""

    target_url = (
        url
        or _string_value(response.get("normalizedUrl"))
        or _string_value(response.get("normalized_url"))
        or _string_value(response.get("url"))
    )
    if not target_url:
        return response

    try:
        result = (
            registry.analyze_url(target_url, debug=debug)
            if registry is not None
            else analyze_url_brand_impersonation(target_url, debug=debug)
        )
    except Exception:
        logger.exception("Brand impersonation post-processing failed; preserving prediction response.")
        response["brand_impersonation"] = _neutral_brand_impersonation(target_url)
        response["brand_impersonation_features"] = BrandImpersonationFeatures().to_dict()
        return response

    response["brand_impersonation"] = result.to_api(debug=debug)
    response["brand_impersonation_features"] = result.features.to_dict()

    if not result.detected:
        return response

    _raise_risk_floor(response, result)
    _mark_uncertainty(response)
    return response


def _raise_risk_floor(response: MutableMapping[str, Any], result: BrandImpersonationResult) -> None:
    risk_key = "riskScore" if "riskScore" in response else "risk_score"
    old_risk = _float_value(response.get(risk_key), default=0.0)
    response[risk_key] = max(old_risk, result.risk_score_floor)

    prediction_key = "predictedClass" if "predictedClass" in response else "prediction"
    prediction = _string_value(response.get(prediction_key)).casefold()
    if result.confidence in {"high", "critical"} and prediction in {"", "benign", "safe"}:
        response[prediction_key] = "phishing"

    confidence_key = "confidence"
    if confidence_key in response:
        response[confidence_key] = max(
            _float_value(response.get(confidence_key), default=0.0),
            result.risk_score_floor,
        )


def _mark_uncertainty(response: MutableMapping[str, Any]) -> None:
    uncertainty = response.get("uncertainty")
    if not isinstance(uncertainty, dict):
        uncertainty = {}
        response["uncertainty"] = uncertainty
    uncertainty["brandImpersonationDetected"] = True


def _string_value(value: Any) -> str:
    return "" if value is None else str(value)


def _float_value(value: Any, *, default: float) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def _neutral_brand_impersonation(url: str) -> dict[str, Any]:
    parts = parse_domain(url)
    return {
        "detected": False,
        "entity": None,
        "category": None,
        "matched_alias": None,
        "official_domains": [],
        "observed_domain": parts.observed_domain,
        "confidence": "none",
        "reason": None,
    }
