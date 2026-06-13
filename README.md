# TurkQuish Mobile Prototype

TurkQuish is a Flutter mobile app for explainable, URL-only QR phishing and quishing detection in the Turkish web ecosystem.

The app decodes QR payloads locally, validates that the payload is an `http://` or `https://` URL, sends only the decoded URL string to the configured backend, and displays the backend prediction, risk score, explanation, model metadata, and optional feedback controls.

## Run

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://your-backend.com
```

If `API_BASE_URL` is missing, the app shows a developer configuration error screen.

For local backend testing:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Use an HTTPS backend for production deployments.

## Backend API

Prediction:

```http
POST /api/v1/predict
Content-Type: application/json
```

```json
{
  "decodedUrl": "https://example.com/login",
  "clientTimestamp": "2026-06-10T12:00:00Z",
  "locale": "en",
  "appVersion": "1.0.0"
}
```

The response must include `predictionId`, `normalizedUrl`, `predictedClass`, `riskScore`, `riskLevel`, `recommendedAction`, `threshold`, `probabilities`, bilingual `explanation`, `topFeatures`, `modelVersion`, `featureSchemaVersion`, and `latencyMs`.

Feedback:

```http
POST /api/v1/feedback
Content-Type: application/json
```

```json
{
  "predictionId": "prediction-id",
  "feedbackType": "false_positive",
  "comment": "Optional comment",
  "clientTimestamp": "2026-06-10T12:00:00Z"
}
```

## Privacy Design

TurkQuish is strictly URL-only.

The app does:

- Decode QR payloads on device.
- Validate URL syntax on device.
- Submit only the decoded URL string and small client metadata to the backend.
- Store local history as domain or masked URL, timestamp, class, score, and model version.

The app does not:

- Resolve DNS.
- Query WHOIS.
- Retrieve HTML or live webpage content.
- Take screenshots.
- Use browser reputation services.
- Automatically open scanned links.

Opening a URL requires explicit user confirmation. Malicious predictions are gated behind a stronger warning.

## Quality Checks

```bash
flutter analyze
flutter test
flutter build apk --debug --dart-define=API_BASE_URL=https://example.com
```

## Project Structure

The code follows the requested Clean Architecture-style feature layout under `lib/`, with shared app configuration, network, utilities, widgets, settings, scanner, inference, history, and feedback modules.
