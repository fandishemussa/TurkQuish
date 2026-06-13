from __future__ import annotations

import argparse
import json
import sys
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.security.protected_entities import (  # noqa: E402
    SUPPORTED_CATEGORIES,
    compact_key,
    default_registry_path,
    normalize_turkish_text,
    validate_domain_name,
)


def validate_registry(path: Path) -> dict[str, Any]:
    errors: list[str] = []
    warnings: list[str] = []
    with path.open("r", encoding="utf-8") as handle:
        payload = json.load(handle)

    entities = payload.get("entities", payload) if isinstance(payload, dict) else payload
    if not isinstance(entities, list):
        return {
            "path": str(path),
            "entity_count": 0,
            "valid": False,
            "errors": ["Registry must be a list or an object with an 'entities' list."],
            "warnings": [],
        }

    alias_counter: Counter[str] = Counter()
    alias_entities: defaultdict[str, list[str]] = defaultdict(list)
    domain_counter: Counter[str] = Counter()
    domain_entities: defaultdict[str, list[str]] = defaultdict(list)

    for index, entity in enumerate(entities):
        label = _entity_label(entity, index)
        if not isinstance(entity, dict):
            errors.append(f"{label}: entity must be an object.")
            continue

        for field in ("name", "category", "aliases", "official_domains"):
            if field not in entity:
                errors.append(f"{label}: missing required field '{field}'.")

        name = entity.get("name")
        category = entity.get("category")
        aliases = entity.get("aliases")
        official_domains = entity.get("official_domains")

        if not isinstance(name, str) or not name.strip():
            errors.append(f"{label}: name must be a non-empty string.")
        if not isinstance(category, str) or not category.strip():
            errors.append(f"{label}: category must be a non-empty string.")
        elif normalize_turkish_text(category).strip() not in SUPPORTED_CATEGORIES:
            warnings.append(f"{label}: unknown category '{category}' will load as 'other'.")

        if not isinstance(aliases, list):
            errors.append(f"{label}: aliases must be a list of strings.")
            aliases = []
        if not isinstance(official_domains, list):
            errors.append(f"{label}: official_domains must be a list of strings.")
            official_domains = []

        if not official_domains:
            warnings.append(f"{label}: entity has no official domains.")

        for alias_index, alias in enumerate(aliases):
            if not isinstance(alias, str) or not alias.strip():
                errors.append(f"{label}: aliases[{alias_index}] must be a non-empty string.")
                continue
            normalized = compact_key(alias)
            if len(normalized) <= 2:
                warnings.append(f"{label}: alias '{alias}' is suspiciously short.")
            alias_counter[normalized] += 1
            alias_entities[normalized].append(str(name or label))

        for domain_index, domain in enumerate(official_domains):
            if not isinstance(domain, str) or not domain.strip():
                errors.append(f"{label}: official_domains[{domain_index}] must be a non-empty string.")
                continue
            normalized_domain = domain.strip().casefold()
            if not validate_domain_name(normalized_domain):
                errors.append(f"{label}: official domain '{domain}' is invalid.")
            domain_counter[normalized_domain] += 1
            domain_entities[normalized_domain].append(str(name or label))

    duplicate_aliases = {
        alias: names for alias, names in alias_entities.items() if alias_counter[alias] > 1
    }
    duplicate_domains = {
        domain: names for domain, names in domain_entities.items() if domain_counter[domain] > 1
    }
    for alias, names in sorted(duplicate_aliases.items()):
        warnings.append(f"Duplicate alias '{alias}' appears in: {', '.join(sorted(set(names)))}.")
    for domain, names in sorted(duplicate_domains.items()):
        warnings.append(f"Duplicate official domain '{domain}' appears in: {', '.join(sorted(set(names)))}.")

    return {
        "path": str(path),
        "entity_count": len(entities),
        "valid": not errors,
        "errors": errors,
        "warnings": warnings,
        "duplicate_aliases": duplicate_aliases,
        "duplicate_official_domains": duplicate_domains,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate the protected entity registry.")
    parser.add_argument("path", nargs="?", default=str(default_registry_path()))
    parser.add_argument("--report", default=None, help="Optional path for a JSON validation report.")
    args = parser.parse_args()

    report = validate_registry(Path(args.path))
    output = json.dumps(report, ensure_ascii=False, indent=2)
    if args.report:
        Path(args.report).write_text(output + "\n", encoding="utf-8")
    print(output)
    return 0 if report["valid"] else 1


def _entity_label(entity: Any, index: int) -> str:
    if isinstance(entity, dict) and entity.get("name"):
        return str(entity["name"])
    return f"Entity #{index}"


if __name__ == "__main__":
    raise SystemExit(main())

