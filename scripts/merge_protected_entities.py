from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.security.protected_entities import (  # noqa: E402
    compact_key,
    default_registry_path,
    normalize_hostname,
    normalize_turkish_text,
    validate_domain_name,
)
from scripts.validate_protected_entities import validate_registry  # noqa: E402


DEFAULT_OUTPUT = ROOT / "app" / "data" / "turkish_protected_brands.generated.json"
DEFAULT_REPORT = ROOT / "validation_report.json"


def merge_registries(base_path: Path, input_paths: list[Path]) -> tuple[dict[str, Any], dict[str, Any]]:
    base_payload = _read_json_entities(base_path)
    merged_by_key: dict[str, dict[str, Any]] = {}
    merge_report: dict[str, Any] = {
        "base": str(base_path),
        "inputs": [str(path) for path in input_paths],
        "added_entities": 0,
        "merged_entities": 0,
        "invalid_domains": [],
    }

    for entity in base_payload["entities"]:
        normalized = _normalize_entity(entity)
        merged_by_key[_entity_key(normalized)] = normalized

    for input_path in input_paths:
        incoming_entities = _read_entities(input_path)
        for entity in incoming_entities:
            normalized = _normalize_entity(entity)
            invalid_domains = [
                domain for domain in normalized["official_domains"] if not validate_domain_name(domain)
            ]
            for domain in invalid_domains:
                merge_report["invalid_domains"].append(
                    {"entity": normalized["name"], "domain": domain, "source": str(input_path)}
                )
            key = _find_existing_key(merged_by_key, normalized) or _entity_key(normalized)
            if key in merged_by_key:
                _merge_into(merged_by_key[key], normalized)
                merge_report["merged_entities"] += 1
            else:
                merged_by_key[key] = normalized
                merge_report["added_entities"] += 1

    merged_payload = {
        "version": base_payload.get("version", 1),
        "country": base_payload.get("country", "TR"),
        "description": base_payload.get(
            "description",
            "Generated protected entity registry.",
        ),
        "entities": sorted(merged_by_key.values(), key=lambda item: compact_key(item["name"])),
    }
    return merged_payload, merge_report


def main() -> int:
    parser = argparse.ArgumentParser(description="Merge protected entity JSON/CSV files into the registry.")
    parser.add_argument("inputs", nargs="+", help="JSON or CSV files containing protected entities.")
    parser.add_argument("--base", default=str(default_registry_path()), help="Base registry JSON path.")
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT), help="Generated registry output path.")
    parser.add_argument("--report", default=str(DEFAULT_REPORT), help="Validation report output path.")
    args = parser.parse_args()

    merged_payload, merge_report = merge_registries(
        Path(args.base),
        [Path(input_path) for input_path in args.inputs],
    )
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(merged_payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    validation_report = validate_registry(output_path)
    report = {"merge": merge_report, "validation": validation_report}
    report_path = Path(args.report)
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(json.dumps({"output": str(output_path), "report": str(report_path)}, ensure_ascii=False, indent=2))
    return 0 if validation_report["valid"] else 1


def _read_entities(path: Path) -> list[dict[str, Any]]:
    suffix = path.suffix.casefold()
    if suffix == ".csv":
        return _read_csv_entities(path)
    return _read_json_entities(path)["entities"]


def _read_json_entities(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        payload = json.load(handle)
    entities = payload.get("entities", payload) if isinstance(payload, dict) else payload
    if not isinstance(entities, list):
        raise ValueError(f"{path} must be a list or an object with an 'entities' list.")
    return {
        "version": payload.get("version", 1) if isinstance(payload, dict) else 1,
        "country": payload.get("country", "TR") if isinstance(payload, dict) else "TR",
        "description": payload.get("description", "") if isinstance(payload, dict) else "",
        "entities": entities,
    }


def _read_csv_entities(path: Path) -> list[dict[str, Any]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        entities = []
        for row in reader:
            entities.append(
                {
                    "name": (row.get("name") or "").strip(),
                    "category": (row.get("category") or "other").strip(),
                    "aliases": _split_multi_value(row.get("aliases") or ""),
                    "official_domains": _split_multi_value(row.get("official_domains") or ""),
                }
            )
    return entities


def _normalize_entity(entity: dict[str, Any]) -> dict[str, Any]:
    name = str(entity.get("name", "")).strip()
    category = normalize_turkish_text(entity.get("category", "other")).strip() or "other"
    aliases = _dedupe_strings(entity.get("aliases", []))
    official_domains = _dedupe_strings(
        normalize_hostname(domain) for domain in entity.get("official_domains", [])
    )
    return {
        "name": name,
        "category": category,
        "aliases": aliases,
        "official_domains": [domain for domain in official_domains if domain],
    }


def _entity_key(entity: dict[str, Any]) -> str:
    domains = sorted(entity.get("official_domains") or [])
    if domains:
        return "domains:" + "|".join(domains)
    return "name:" + compact_key(entity["name"])


def _find_existing_key(existing: dict[str, dict[str, Any]], entity: dict[str, Any]) -> str | None:
    normalized_name = compact_key(entity["name"])
    incoming_domains = set(entity.get("official_domains") or [])
    for key, candidate in existing.items():
        if compact_key(candidate["name"]) == normalized_name:
            return key
        if incoming_domains and incoming_domains.intersection(candidate.get("official_domains") or []):
            return key
    return None


def _merge_into(base: dict[str, Any], incoming: dict[str, Any]) -> None:
    if not base.get("category") or base["category"] == "other":
        base["category"] = incoming.get("category", "other")
    base["aliases"] = _dedupe_strings([*base.get("aliases", []), *incoming.get("aliases", [])])
    base["official_domains"] = _dedupe_strings(
        [*base.get("official_domains", []), *incoming.get("official_domains", [])]
    )


def _split_multi_value(value: str) -> list[str]:
    if not value.strip():
        return []
    return [item.strip() for item in value.replace("|", ";").replace(",", ";").split(";") if item.strip()]


def _dedupe_strings(values: Any) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for value in values:
        text = str(value or "").strip()
        key = compact_key(text)
        if not text or key in seen:
            continue
        seen.add(key)
        result.append(text)
    return result


if __name__ == "__main__":
    raise SystemExit(main())

