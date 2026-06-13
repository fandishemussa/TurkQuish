# TurkQuish

**TurkQuish** is the mobile QR-scanning client for **TurkQuish**, an explainable URL-only QR-code phishing detection framework for the Turkish web ecosystem.

The app scans QR codes, extracts the decoded URL, previews it to the user, sends the decoded URL string to the TurkQuish backend, and displays a risk assessment with bilingual Turkish/English explanations.

## Overview

QR-code phishing, also known as **quishing**, is a growing mobile security threat. Attackers hide malicious links behind QR codes, making it difficult for users to inspect the destination before visiting it.

TurkQuish Flutter provides an interactive mobile workflow for:

* scanning QR codes
* extracting URL payloads
* validating URL syntax
* previewing decoded URLs before submission
* sending URL-only requests to the backend
* displaying class probabilities and risk scores
* showing recommended actions
* presenting bilingual Turkish/English explanations
* showing feature-based warning signals
* optionally displaying runtime/debug timings during development


## Key Features

### QR-code scanning

The app uses the mobile camera to scan QR codes and extract the encoded payload.

### URL preview before analysis

Before sending a URL to the backend, the app displays the decoded URL so that users can inspect it.

### URL-only privacy-aware workflow

The app sends only the decoded URL string and minimal metadata to the backend. The backend does not require DNS, WHOIS, HTML retrieval, screenshots, browser reputation checks, or third-party security lookups during inference.

### Risk report

The result screen may include:

* predicted class
* risk score
* risk level
* recommended action
* class probabilities
* detected suspicious signals
* top contributing features
* Turkish explanation
* English explanation

### Bilingual explanation

The app is designed to support both Turkish and English explanations so that risk feedback can be understandable to local users while remaining accessible for research and international evaluation.



## App Workflow

The typical workflow is:

```text
Open scanner
   ↓
Scan QR code
   ↓
Extract decoded URL
   ↓
Validate URL syntax
   ↓
Show URL preview
   ↓
Send decoded URL to TurkQuish backend
   ↓
Receive prediction, risk score, probabilities, and explanation
   ↓
Display bilingual risk report
```

---

## Backend Dependency

This app requires the TurkQuish backend to be running.

Default backend endpoint:

```text
POST /api/predict
```

Example local backend URL:

```text
http://127.0.0.1:8000/api/predict
```

For Android emulator, local backend may need:

```text
http://10.0.2.2:8000/api/predict
```

For a physical phone, use the local network IP address of the backend machine, for example:

```text
http://192.168.1.10:8000/api/predict
```

Make sure the phone and backend machine are on the same network.

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/TurkQuish_Flutter.git
cd TurkQuish_Flutter
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Configure backend URL

Find the API configuration file in the project, for example:

```text
lib/core/config/
```

or wherever the current backend base URL is defined.

Set the backend URL according to your environment:

```dart
const String backendBaseUrl = "http://127.0.0.1:8000";
```

For Android emulator:

```dart
const String backendBaseUrl = "http://10.0.2.2:8000";
```

For physical device testing:

```dart
const String backendBaseUrl = "http://YOUR_LOCAL_IP:8000";
```

---

## Running the App

Check connected devices:

```bash
flutter devices
```

Run the app:

```bash
flutter run
```

Build Android APK:

```bash
flutter build apk
```

Build Android app bundle:

```bash
flutter build appbundle
```

---

## Required Permissions

The app requires camera permission for QR scanning.

Android permission is usually declared in:

```text
android/app/src/main/AndroidManifest.xml
```

Expected permission:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

---

## API Request

The app sends the decoded URL to the backend.

Example request:

```json
{
  "decodedUrl": "https://www.ktun.edu.tr",
  "locale": "tr",
  "appVersion": "flutter-prototype",
  "clientTimestamp": "2026-06-13T00:00:00Z"
}
```

The exact field names should match the backend schema.

---

## API Response

The backend returns a structured risk report.

Example response fields:

```json
{
  "predictedClass": "benign",
  "riskScore": 0.12,
  "riskLevel": "low",
  "recommendedAction": "Proceed with caution",
  "probabilities": {
    "benign": 0.88,
    "phishing": 0.05,
    "malware": 0.03,
    "scam": 0.02,
    "other-malicious": 0.02
  },
  "explanation": {
    "en": "The URL shows mostly benign structural characteristics.",
    "tr": "URL çoğunlukla güvenli yapısal özellikler göstermektedir."
  },
  "timingMs": {
    "total_backend": 139.43,
    "feature_extraction": 14.98,
    "histgb_inference": 36.67
  }
}
```

---

## Runtime Debugging

During development, the app may log timing values such as:

* QR payload extraction time
* URL validation time
* API request-response time
* backend latency
* backend internal timing
* feature extraction timing
* model inference timing

Example debug logs:

```text
TurkQuishTiming qr_payload_extraction_ms=...
TurkQuishTiming url_validation_ms=...
TurkQuishTiming api_request_response_ms=...
TurkQuishTiming backend_latency_ms=...


Debug timing values should not be shown to normal users unless a debug mode is enabled.


## Screens

Recommended screenshots for the repository:

```text
docs/screenshots/onboarding.png
docs/screenshots/scanner.png
docs/screenshots/url-preview.png
docs/screenshots/result-report.png
docs/screenshots/explanation-tr-en.png
```

You can include a four-panel composite image:

```text
docs/screenshots/turkquish_mobile_prototype.png
```

Suggested Markdown:

```markdown
![TurkQuish mobile prototype](docs/screenshots/turkquish_mobile_prototype.png)
```

---

## Suggested Folder Structure

```text
lib/
├── core/
│   ├── config/
│   ├── network/
│   ├── theme/
│   └── utils/
├── features/
│   ├── scanner/
│   ├── inference/
│   ├── result/
│   ├── history/
│   └── settings/
└── main.dart
```

The exact structure may differ depending on the implementation.

---

## Design Principles

TurkQuish Flutter follows these principles:

* Preview before visiting a decoded URL
* Avoid automatic opening of scanned links
* Send only the decoded URL string to the backend
* Provide understandable risk feedback
* Support bilingual explanations
* Keep security warnings clear but not alarmist
* Separate normal user UI from developer/runtime diagnostics

---

## Limitations

TurkQuish Flutter is a research prototype. It is not a replacement for browser security, mobile operating-system protections, or enterprise security gateways.

Known limitations:

* The app depends on the backend for ML inference.
* Network latency affects response time.
* QR scanning quality depends on camera, lighting, and QR-code quality.
* The prototype has not been evaluated as a production-scale field deployment.
* The backend does not inspect webpage content, screenshots, DNS, WHOIS, or third-party reputation sources.

---

## Related Repository

Backend repository:

```text
https://github.com/fandishemussa/TurkQuish_Backend
```

Update the link after publishing the backend repository.

---

## Citation

If you use this app or the TurkQuish framework, please cite the associated manuscript.

```bibtex
@article{turkquish2026,
  title   = {TurkQuish: Explainable URL-Only Detection of QR-Code Phishing in the Turkish Web Ecosystem},
  author  = {TODO},
  journal = {TODO},
  year    = {2026}
}
```

---

## License

Add the project license here.

Recommended options:

* MIT License
* Apache-2.0 License

---

## Disclaimer

TurkQuish Flutter is a research prototype for QR-code phishing detection. It may produce false positives or false negatives. Users should not rely on it as the only security control when handling suspicious QR codes or URLs.
