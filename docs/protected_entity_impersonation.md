# Protected Entity Impersonation Detection

TurkQuish uses a protected-entity registry to detect Turkish brand and institution impersonation in URLs. The registry is JSON data, so new entities can be added without changing detection code.

## Registry

The default registry path is:

```text
app/data/turkish_protected_brands.json
```

It can be overridden with:

```text
PROTECTED_ENTITY_REGISTRY_PATH=app/data/turkish_protected_brands.json
```

Each entity has:

```json
{
  "name": "Ziraat Bankasi",
  "category": "bank",
  "aliases": ["ziraat", "ziraat bankasi", "ziraatbank"],
  "official_domains": ["ziraatbank.com.tr"]
}
```

Supported categories include banks, fintechs, government services, ministries, municipalities, police, universities, hospitals, healthcare, telecom, ecommerce, delivery, cargo, retail, travel, crypto, streaming, media, NGOs, public services, education, insurance, energy, aviation, transport, sports, brands, and other.

Unknown categories load as `other` with a warning instead of crashing startup.

## Normalization

The loader validates required fields and keeps original values for explanations. Matching uses normalized forms:

- Lowercase comparison.
- Turkish character folding such as `ç -> c`, `ğ -> g`, `ı -> i`, `İ -> i`, `ö -> o`, `ş -> s`, `ü -> u`.
- Common mojibake forms such as `Ã§`, `ÄŸ`, and `ÅŸ` are also folded.
- Spaces, hyphens, underscores, and dots are removed for compact alias matching.
- Repeated characters and digit lookalikes such as `0 -> o` are considered for lookalike checks.

## Official Domains

For each analyzed URL, the backend extracts the hostname, decodes IDNA/punycode labels, and derives a registrable domain with a Turkish-aware public suffix fallback for suffixes such as `gov.tr`, `edu.tr`, `com.tr`, and `bel.tr`.

A URL is treated as official only when the hostname is an official domain or a subdomain of an official domain.

Safe examples:

- `https://ktun.edu.tr`
- `https://obs.ktun.edu.tr`
- `https://turkiye.gov.tr`
- `https://ziraatbank.com.tr`

Suspicious examples:

- `https://kkktun.edu.tr`
- `https://ktun-login.com`
- `https://turkiye-gov-tr.com`
- `https://ziraat-bankasi-login.com`

## Lookalike Detection

For unofficial domains, the detector compares domain labels and hostname tokens with protected aliases using:

- Exact alias containment.
- High-risk phishing words near aliases.
- Levenshtein edit distance.
- Jaro-Winkler similarity.
- Repeated-character normalization.
- Digit lookalike replacement such as `turkiyeg0v.com`.

Very short aliases are handled more strictly. A short alias alone is usually low confidence unless it appears as a token with phishing context, a suspicious TLD, or a strong lookalike pattern.

## Scoring And API Output

The detector produces engineered features:

```json
{
  "protected_entity_match": true,
  "protected_entity_name": "Ziraat Bankasi",
  "protected_entity_category": "bank",
  "protected_entity_official_domain": "ziraatbank.com.tr",
  "protected_entity_alias_matched": "ziraat bankasi",
  "is_official_domain": false,
  "is_official_subdomain": false,
  "alias_in_unofficial_domain": true,
  "lookalike_similarity": 1.0,
  "edit_distance": 0,
  "phishing_keyword_near_alias": true,
  "suspicious_tld_for_entity": true,
  "impersonation_confidence": "critical"
}
```

The prediction response can include:

```json
{
  "brand_impersonation": {
    "detected": true,
    "entity": "e-Devlet Kapisi",
    "category": "government",
    "matched_alias": "edevlet",
    "official_domains": ["turkiye.gov.tr"],
    "observed_domain": "edevlet-basvuru.net",
    "confidence": "critical",
    "reason": "Government or public-service alias appears in an unofficial domain with application/login/payment-related wording."
  }
}
```

The rule layer does not replace the ML classifier. It can be used as engineered features, post-processing, or an explanation layer. Existing response fields such as `prediction`, `confidence`, `risk_score`, and `features` should remain present for Flutter compatibility.

## Expanding The Registry

Validate the current registry:

```bash
python scripts/validate_protected_entities.py
```

Merge new JSON or CSV sources:

```bash
python scripts/merge_protected_entities.py new_entities.csv
```

The merge script writes:

- `app/data/turkish_protected_brands.generated.json`
- `validation_report.json`

CSV columns:

```text
name,category,aliases,official_domains
```

Use semicolons, commas, or pipes to separate aliases and domains.

## Limitations

- The registry is a seed list, not an exhaustive source of all Turkish institutions and brands.
- Official domains can change and must be maintained.
- False positives are possible, especially around short abbreviations.
- This signal should be combined with ML, DNS, WHOIS, TLS, hosting, redirect, and content-based signals.

