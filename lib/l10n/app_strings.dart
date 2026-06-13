import 'package:flutter/widgets.dart';

import '../core/network/api_exception.dart';
import '../core/utils/url_validator.dart';
import '../features/inference/domain/entities/prediction_class.dart';
import '../features/inference/domain/entities/risk_level.dart';
import '../features/inference/domain/entities/top_feature.dart';

class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('tr')];

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ??
        const AppStrings(Locale('en'));
  }

  static const _values = <String, Map<String, String>>{
    'en': {
      'about': 'About',
      'aboutDescription':
          'URL-only inference with explainable Turkish web ecosystem features.',
      'allowCamera': 'Allow camera',
      'all': 'All',
      'analyzeUrl': 'Analyze URL',
      'analyzingUrl': 'Analyzing URL',
      'apiBaseUrl': 'API base URL',
      'apiConfigMessage':
          'Start the app with --dart-define=API_BASE_URL=https://your-backend.com. TurkQuish will not scan until a backend endpoint is configured.',
      'apiConfigRequired': 'API configuration required',
      'apiErrorBackendUnavailable': 'Backend unavailable.',
      'apiErrorHttp': 'The backend returned HTTP {statusCode}.',
      'apiErrorInvalidUrl': 'The backend rejected this URL as invalid.',
      'apiErrorMalformedResponse':
          'The backend returned an unexpected response.',
      'apiErrorOffline':
          'No network connection or the backend could not be reached.',
      'apiErrorRateLimited': 'Too many requests. Try again shortly.',
      'apiErrorServer': 'The backend returned a server error.',
      'apiErrorTimeout': 'The backend request timed out.',
      'apiErrorUnexpected': 'An unexpected network error occurred.',
      'apiFailureBackendUnavailable': 'Backend unavailable',
      'apiFailureDeveloperConfig': 'Developer configuration missing',
      'apiFailureInvalidUrl': 'Invalid URL',
      'apiFailureMalformedResponse': 'Unexpected response',
      'apiFailureOffline': 'No internet connection',
      'apiFailureRateLimited': 'Too many requests',
      'apiFailureServerError': 'Server error',
      'apiFailureTimeout': 'Request timed out',
      'apiFailureUnexpected': 'Analysis failed',
      'appLogoSemanticLabel': 'TurkQuish logo',
      'appTagline': 'Explainable QR URL Threat Detection',
      'appVersion': 'App version',
      'back': 'Back',
      'backToScanner': 'Back to scanner',
      'backend': 'Backend',
      'backendOnline': 'Backend online',
      'backendOffline': 'Backend unavailable',
      'backendStatus': 'Backend status',
      'backendStatusBody': 'API reachability, model readiness, and latency.',
      'backendInferenceWorkflow': 'Backend inference workflow',
      'cameraBlocked':
          'Camera access is blocked. Enable it from app settings to scan QR codes.',
      'cameraPermissionRationale':
          'TurkQuish needs camera access to scan QR codes for URL threat analysis.',
      'cameraPermissionRequired': 'Camera permission required',
      'cancel': 'Cancel',
      'classProbabilities': 'Class probabilities',
      'clear': 'Clear',
      'clearHistory': 'Clear history',
      'clearLocalHistoryMessage':
          'This removes locally stored scan history from this device.',
      'clearLocalHistoryTitle': 'Clear local history?',
      'clientResponse': 'Client response',
      'continue': 'Continue',
      'copyResult': 'Copy result',
      'copyJson': 'Copy JSON',
      'copyReport': 'Copy report',
      'copyUrl': 'Copy URL',
      'decodedWebUrl': 'Decoded web URL',
      'decisionThreshold': 'Decision threshold',
      'delete': 'Delete',
      'deleteScan': 'Delete scan?',
      'deleteScanMessage': 'This removes the selected scan from local history.',
      'english': 'English',
      'exportHistory': 'Export history',
      'errorHostRequired': 'The URL must include a host or domain.',
      'errorHttpOnly': 'Only http:// and https:// URLs can be analyzed.',
      'errorValidWebUrlRequired':
          'This QR code does not contain a valid web URL.',
      'explanation': 'Explanation',
      'featureGroupAdversarialBrand': 'Adversarial / brand',
      'featureGroupGraphInfrastructure': 'Graph infrastructure',
      'featureGroupLexicalStructural': 'Lexical / structural',
      'featureGroupOther': 'Other',
      'featureGroupTurkishLinguistic': 'Turkish linguistic',
      'featureDirectionBenign': 'lowers risk',
      'featureDirectionMalicious': 'raises risk',
      'featureDirectionUnknown': 'unknown direction',
      'featureSchema': 'Feature schema',
      'featureCount': 'Feature count',
      'feedbackCorrect': 'Correct result',
      'feedbackFalseNegative': 'False negative',
      'feedbackFalsePositive': 'False positive',
      'feedbackOptionalComment': 'Optional comment',
      'feedbackSent': 'Feedback sent',
      'feedbackUnsure': 'Unsure',
      'generatedAt': 'Generated at',
      'history': 'History',
      'historyCleared': 'History cleared',
      'historyExported': 'History copied',
      'highRiskOpenMessage':
          'The model recommends caution or blocking. Opening this URL can expose you to phishing, malware, scam, or other malicious behavior.',
      'highRiskUrl': 'High-risk URL',
      'host': 'Host',
      'brandImpersonation': 'Brand impersonation',
      'brandImpersonationDetected': 'Impersonation detected',
      'brandImpersonationNotDetected': 'No impersonation detected',
      'brandRisk': 'Brand risk',
      'brandScore': 'Brand score',
      'detectedBrands': 'Detected brands',
      'similarBrands': 'Similar brands',
      'signals': 'Signals',
      'registeredDomain': 'Registered domain',
      'maskedUrl': 'Masked URL',
      'urlSummary': 'URL summary',
      'decisionSource': 'Decision source',
      'primaryModel': 'Primary model',
      'fallbackModel': 'Fallback model',
      'modelUsed': 'Used',
      'modelNotUsed': 'Not used',
      'confidence': 'Confidence',
      'margin': 'Margin',
      'urlOnly': 'URL only',
      'uncertainty': 'Uncertainty',
      'yes': 'Yes',
      'no': 'No',
      'inferenceLatency': 'Inference latency',
      'invalidQrPayload': 'Invalid QR payload',
      'invalidUrl': 'Invalid URL',
      'last7Days': 'Last 7 days',
      'language': 'Language',
      'lastResult': 'Last result',
      'localHistory': 'Local history',
      'localHistoryBody':
          'Stores domain or masked URL, class, risk score, timestamp, and model version by default.',
      'manualUrl': 'Manual URL',
      'manualUrlInput': 'Manual URL input',
      'maskUrlQueryParameters': 'Mask URL query parameters',
      'missingApiBaseUrl': 'Missing API_BASE_URL',
      'modelInfoDescription':
          'Displayed per prediction from the backend response.',
      'modelInformation': 'Model information',
      'modelLoaded': 'Model loaded',
      'modelClasses': 'Model classes',
      'modelTrust': 'Model trust',
      'modelTrustBody':
          'Scores are calibrated model estimates. Use the explanation, threshold, and recommended action together.',
      'modelVersion': 'Model version',
      'neverPerformedBody':
          'DNS, WHOIS, HTML retrieval, screenshots, browser reputation, and third-party security lookups.',
      'neverPerformedTitle': 'Never performed on device',
      'noFeatureAttribution':
          'No feature attribution was returned by the backend.',
      'noHostDetected': 'No host detected',
      'noLocalHistory': 'No local history',
      'noLocalHistoryBody':
          'Scans appear here only when local history is enabled.',
      'noQrInImage': 'No QR code was found in the selected image.',
      'normalizedUrl': 'Normalized URL',
      'onlyDecodedUrlSubmitted':
          'Only the decoded URL string will be submitted. TurkQuish does not fetch pages, resolve DNS, query WHOIS, take screenshots, or ask reputation services.',
      'open': 'Open',
      'openAnyway': 'Open anyway',
      'openExternalUrl': 'Open external URL?',
      'openSettings': 'Open settings',
      'openUrl': 'Open URL',
      'openUrlWithConfirmation': 'Open URL with confirmation',
      'preferences': 'Preferences',
      'preview': 'Preview',
      'privacy': 'Privacy',
      'privacyDetails': 'Privacy details',
      'probabilisticNotice':
          'Prediction is probabilistic, not an absolute safety guarantee.',
      'productionUseHttps': 'Production should use HTTPS',
      'quickScanMode': 'Quick scan mode',
      'quickScanModeBody': 'Submit valid QR URLs immediately after detection.',
      'qrFromGallery': 'QR from gallery',
      'qrImageError': 'The selected image could not be analyzed.',
      'qrImageUnsupported':
          'QR image analysis is not supported on this device or platform.',
      'refresh': 'Refresh',
      'recommendedBlock': 'Block',
      'recommendedBlockSummary': 'Do not open this URL.',
      'recommendedCaution': 'Use caution',
      'recommendedCautionSummary':
          'Use caution and verify the destination independently.',
      'recommendedActionLabel': 'Recommended action',
      'recommendedProceed': 'Proceed',
      'recommendedProceedSummary': 'Proceed only if you trust the source.',
      'recommendedReport': 'Report',
      'recommendedReportSummary':
          'Report this QR or link to the appropriate security team.',
      'reportFeedback': 'Report feedback',
      'resultCopied': 'Result copied',
      'reportCopied': 'Report copied',
      'resultUnavailable': 'Result unavailable',
      'resultUnavailableMessage':
          'The prediction result could not be restored.',
      'retry': 'Retry',
      'riskScore': 'Risk score',
      'riskToneBenign': 'Benign',
      'riskToneHigh': 'High risk',
      'riskToneLow': 'Low risk',
      'riskToneMedium': 'Medium risk',
      'riskToneUnknown': 'Unknown risk',
      'safeOpenMessage':
          'TurkQuish never opens scanned URLs automatically. Continue only if you trust the source.',
      'safetyCheck': 'Safety check',
      'scan': 'Scan',
      'scanAnother': 'Scan another QR',
      'scanHistory': 'Scan history',
      'scanReport': 'Scan report',
      'scannerStatusDetected': 'QR detected',
      'scannerStatusError': 'Scanner error',
      'scannerStatusPoint': 'Point camera at QR code',
      'scannerStatusReady': 'Ready for preview',
      'scannerStatusSubmitting': 'Sending to backend',
      'searchDomainOrMaskedUrl': 'Search domain or masked URL',
      'sendFeedback': 'Send feedback',
      'sentToBackend': 'Sent to backend',
      'sentToBackendBody': 'Decoded URL, timestamp, locale, and app version.',
      'settings': 'Settings',
      'settingsTheme': 'Theme',
      'status': 'Status',
      'storeLocalHistory': 'Store local history',
      'switchCamera': 'Switch camera',
      'system': 'System',
      'systemDefault': 'System default',
      'themeDark': 'Dark',
      'themeLight': 'Light',
      'topContributingUrlFeatures': 'Top contributing URL features',
      'torch': 'Torch',
      'turkish': 'Turkish',
      'today': 'Today',
      'allDates': 'All dates',
      'unexpectedAnalysisError':
          'An unexpected error occurred during analysis.',
      'urlCopied': 'URL copied',
      'urlOnlyPrivacyBody':
          'TurkQuish decodes QR payloads locally, validates whether the payload is a web URL, and sends only that decoded URL string to the configured backend for inference.',
      'urlOnlyPrivacyTitle': 'URL-only privacy design',
      'urlTransformer': 'URL-Transformer',
      'waitingBackendNoFetch':
          'Waiting for the configured backend. No webpage content is fetched by the app.',
      'warningEmptyHost': 'Empty host',
      'warningMissingScheme': 'Missing scheme',
      'warningNonHttpScheme': 'Non-http/https scheme',
      'warningSuspiciouslyLong': 'Suspiciously long URL',
      'warningUnsupportedScheme': 'Unsupported scheme',
      'analysisStepPayload': 'QR payload decoded',
      'analysisStepNormalization': 'URL normalization',
      'analysisStepFeatures': 'URL-only feature extraction',
      'analysisStepGraph': 'Inductive graph projection',
      'analysisStepModel': 'Model inference',
      'analysisStepDecision': 'Decision layer',
      'analysisStepExplanation': 'Explanation generation',
      'predictionBenign': 'Benign',
      'predictionMalware': 'Malware',
      'predictionOtherMalicious': 'Other malicious',
      'predictionPhishing': 'Phishing',
      'predictionScam': 'Scam',
    },
    'tr': {
      'about': 'Hakkında',
      'aboutDescription':
          'Türk web ekosistemi özellikleriyle açıklanabilir, yalnızca URL tabanlı çıkarım.',
      'allowCamera': 'Kameraya izin ver',
      'all': 'Tümü',
      'analyzeUrl': "URL'yi analiz et",
      'analyzingUrl': 'URL analiz ediliyor',
      'apiBaseUrl': 'API temel URL',
      'apiConfigMessage':
          "Uygulamayı --dart-define=API_BASE_URL=https://backend-adresiniz.com ile başlatın. Backend uç noktası yapılandırılana kadar TurkQuish tarama yapmaz.",
      'apiConfigRequired': 'API yapılandırması gerekli',
      'apiErrorBackendUnavailable': 'Backend kullanılamıyor.',
      'apiErrorHttp': 'Backend HTTP {statusCode} döndürdü.',
      'apiErrorInvalidUrl': "Backend bu URL'yi geçersiz olarak reddetti.",
      'apiErrorMalformedResponse': 'Backend beklenmeyen bir yanıt döndürdü.',
      'apiErrorOffline':
          'Ağ bağlantısı yok veya backend sunucusuna ulaşılamıyor.',
      'apiErrorRateLimited':
          'Çok fazla istek gönderildi. Kısa süre sonra tekrar deneyin.',
      'apiErrorServer': 'Backend bir sunucu hatası döndürdü.',
      'apiErrorTimeout': 'Backend isteği zaman aşımına uğradı.',
      'apiErrorUnexpected': 'Beklenmeyen bir ağ hatası oluştu.',
      'apiFailureBackendUnavailable': 'Backend kullanılamıyor',
      'apiFailureDeveloperConfig': 'Geliştirici yapılandırması eksik',
      'apiFailureInvalidUrl': 'Geçersiz URL',
      'apiFailureMalformedResponse': 'Beklenmeyen yanıt',
      'apiFailureOffline': 'İnternet bağlantısı yok',
      'apiFailureRateLimited': 'Çok fazla istek',
      'apiFailureServerError': 'Sunucu hatası',
      'apiFailureTimeout': 'İstek zaman aşımına uğradı',
      'apiFailureUnexpected': 'Analiz başarısız',
      'appLogoSemanticLabel': 'TurkQuish logosu',
      'appTagline': 'Açıklanabilir QR URL Tehdit Tespiti',
      'appVersion': 'Uygulama sürümü',
      'back': 'Geri',
      'backToScanner': 'Tarayıcıya dön',
      'backend': 'Backend',
      'backendOnline': 'Backend çevrimiçi',
      'backendOffline': 'Backend kullanılamıyor',
      'backendStatus': 'Backend durumu',
      'backendStatusBody':
          'API erişilebilirliği, model hazır olma durumu ve gecikme.',
      'backendInferenceWorkflow': 'Backend çıkarım akışı',
      'cameraBlocked':
          'Kamera erişimi engellenmiş. QR kod taramak için uygulama ayarlarından etkinleştirin.',
      'cameraPermissionRationale':
          'TurkQuish, URL tehdit analizi için QR kodları taramak amacıyla kamera erişimine ihtiyaç duyar.',
      'cameraPermissionRequired': 'Kamera izni gerekli',
      'cancel': 'Vazgeç',
      'classProbabilities': 'Sınıf olasılıkları',
      'clear': 'Temizle',
      'clearHistory': 'Geçmişi temizle',
      'clearLocalHistoryMessage':
          'Bu işlem, bu cihazda saklanan yerel tarama geçmişini siler.',
      'clearLocalHistoryTitle': 'Yerel geçmiş temizlensin mi?',
      'clientResponse': 'İstemci yanıtı',
      'continue': 'Devam et',
      'copyResult': 'Sonucu kopyala',
      'copyJson': 'JSON kopyala',
      'copyReport': 'Raporu kopyala',
      'copyUrl': "URL'yi kopyala",
      'decodedWebUrl': 'Çözümlenen web URL',
      'decisionThreshold': 'Karar eşiği',
      'delete': 'Sil',
      'deleteScan': 'Tarama silinsin mi?',
      'deleteScanMessage': 'Bu işlem seçili taramayı yerel geçmişten siler.',
      'english': 'İngilizce',
      'exportHistory': 'Geçmişi dışa aktar',
      'errorHostRequired': 'URL bir ana makine veya alan adı içermelidir.',
      'errorHttpOnly':
          'Yalnızca http:// ve https:// URL adresleri analiz edilebilir.',
      'errorValidWebUrlRequired':
          'Bu QR kod geçerli bir web URL adresi içermiyor.',
      'explanation': 'Açıklama',
      'featureGroupAdversarialBrand': 'Yanıltıcı / marka',
      'featureGroupGraphInfrastructure': 'Graf altyapısı',
      'featureGroupLexicalStructural': 'Sözcüksel / yapısal',
      'featureGroupOther': 'Diğer',
      'featureGroupTurkishLinguistic': 'Türkçe dilsel',
      'featureDirectionBenign': 'riski azaltır',
      'featureDirectionMalicious': 'riski artırır',
      'featureDirectionUnknown': 'yön bilinmiyor',
      'featureSchema': 'Özellik şeması',
      'featureCount': 'Özellik sayısı',
      'feedbackCorrect': 'Doğru sonuç',
      'feedbackFalseNegative': 'Yanlış negatif',
      'feedbackFalsePositive': 'Yanlış pozitif',
      'feedbackOptionalComment': 'İsteğe bağlı yorum',
      'feedbackSent': 'Geri bildirim gönderildi',
      'feedbackUnsure': 'Emin değilim',
      'generatedAt': 'Oluşturulma zamanı',
      'history': 'Geçmiş',
      'historyCleared': 'Geçmiş temizlendi',
      'historyExported': 'Geçmiş kopyalandı',
      'highRiskOpenMessage':
          "Model dikkatli olmayı veya engellemeyi öneriyor. Bu URL'yi açmak kimlik avı, kötü amaçlı yazılım, dolandırıcılık veya başka zararlı davranışlara maruz bırakabilir.",
      'highRiskUrl': 'Yüksek riskli URL',
      'host': 'Ana makine',
      'brandImpersonation': 'Marka taklidi',
      'brandImpersonationDetected': 'Taklit tespit edildi',
      'brandImpersonationNotDetected': 'Taklit tespit edilmedi',
      'brandRisk': 'Marka riski',
      'brandScore': 'Marka skoru',
      'detectedBrands': 'Tespit edilen markalar',
      'similarBrands': 'Benzer markalar',
      'signals': 'Sinyaller',
      'registeredDomain': 'Kayıtlı alan adı',
      'maskedUrl': 'Maskelenmiş URL',
      'urlSummary': 'URL özeti',
      'decisionSource': 'Karar kaynağı',
      'primaryModel': 'Birincil model',
      'fallbackModel': 'Yedek model',
      'modelUsed': 'Kullanıldı',
      'modelNotUsed': 'Kullanılmadı',
      'confidence': 'Güven',
      'margin': 'Marj',
      'urlOnly': 'Yalnızca URL',
      'uncertainty': 'Belirsizlik',
      'yes': 'Evet',
      'no': 'Hayır',
      'inferenceLatency': 'Çıkarım gecikmesi',
      'invalidQrPayload': 'Geçersiz QR içeriği',
      'invalidUrl': 'Geçersiz URL',
      'last7Days': 'Son 7 gün',
      'language': 'Dil',
      'lastResult': 'Son sonuç',
      'localHistory': 'Yerel geçmiş',
      'localHistoryBody':
          'Varsayılan olarak alan adı veya maskelenmiş URL, sınıf, risk skoru, zaman damgası ve model sürümünü saklar.',
      'manualUrl': 'Manuel URL',
      'manualUrlInput': 'Manuel URL girişi',
      'maskUrlQueryParameters': 'URL sorgu parametrelerini maskele',
      'missingApiBaseUrl': 'API_BASE_URL eksik',
      'modelInfoDescription': 'Backend yanıtından her tahmin için gösterilir.',
      'modelInformation': 'Model bilgisi',
      'modelLoaded': 'Model yüklendi',
      'modelClasses': 'Model sınıfları',
      'modelTrust': 'Model güveni',
      'modelTrustBody':
          'Skorlar kalibre edilmiş model tahminleridir. Açıklama, eşik ve önerilen eylemi birlikte değerlendirin.',
      'modelVersion': 'Model sürümü',
      'neverPerformedBody':
          'DNS, WHOIS, HTML alma, ekran görüntüsü, tarayıcı itibarı ve üçüncü taraf güvenlik sorguları.',
      'neverPerformedTitle': 'Cihazda asla yapılmaz',
      'noFeatureAttribution': 'Backend özellik katkısı döndürmedi.',
      'noHostDetected': 'Ana makine algılanmadı',
      'noLocalHistory': 'Yerel geçmiş yok',
      'noLocalHistoryBody':
          'Taramalar yalnızca yerel geçmiş etkin olduğunda burada görünür.',
      'noQrInImage': 'Seçilen görselde QR kod bulunamadı.',
      'normalizedUrl': 'Normalize edilmiş URL',
      'onlyDecodedUrlSubmitted':
          'Yalnızca çözümlenen URL metni gönderilir. TurkQuish sayfa getirmez, DNS çözmez, WHOIS sorgulamaz, ekran görüntüsü almaz veya itibar servislerine başvurmaz.',
      'open': 'Aç',
      'openAnyway': 'Yine de aç',
      'openExternalUrl': 'Harici URL açılsın mı?',
      'openSettings': 'Ayarları aç',
      'openUrl': "URL'yi aç",
      'openUrlWithConfirmation': "Onayla URL'yi aç",
      'preferences': 'Tercihler',
      'preview': 'Önizle',
      'privacy': 'Gizlilik',
      'privacyDetails': 'Gizlilik ayrıntıları',
      'probabilisticNotice':
          'Tahmin olasılıksaldır; mutlak güvenlik garantisi değildir.',
      'productionUseHttps': 'Üretimde HTTPS kullanılmalı',
      'quickScanMode': 'Hızlı tarama modu',
      'quickScanModeBody':
          'Geçerli QR URL adreslerini algılandıktan hemen sonra gönder.',
      'qrFromGallery': 'Galeriden QR',
      'qrImageError': 'Seçilen görsel analiz edilemedi.',
      'qrImageUnsupported':
          'QR görsel analizi bu cihaz veya platformda desteklenmiyor.',
      'refresh': 'Yenile',
      'recommendedBlock': 'Engelle',
      'recommendedBlockSummary': "Bu URL'yi açmayın.",
      'recommendedCaution': 'Dikkatli ol',
      'recommendedCautionSummary':
          'Dikkatli olun ve hedefi bağımsız olarak doğrulayın.',
      'recommendedActionLabel': 'Önerilen eylem',
      'recommendedProceed': 'Devam et',
      'recommendedProceedSummary':
          'Yalnızca kaynağa güveniyorsanız devam edin.',
      'recommendedReport': 'Bildir',
      'recommendedReportSummary':
          'Bu QR kodu veya bağlantıyı uygun güvenlik ekibine bildirin.',
      'reportFeedback': 'Geri bildirim bildir',
      'resultCopied': 'Sonuç kopyalandı',
      'reportCopied': 'Rapor kopyalandı',
      'resultUnavailable': 'Sonuç kullanılamıyor',
      'resultUnavailableMessage': 'Tahmin sonucu geri yüklenemedi.',
      'retry': 'Tekrar dene',
      'riskScore': 'Risk skoru',
      'riskToneBenign': 'Zararsız',
      'riskToneHigh': 'Yüksek risk',
      'riskToneLow': 'Düşük risk',
      'riskToneMedium': 'Orta risk',
      'riskToneUnknown': 'Bilinmeyen risk',
      'safeOpenMessage':
          "TurkQuish taranan URL'leri hiçbir zaman otomatik açmaz. Yalnızca kaynağa güveniyorsanız devam edin.",
      'safetyCheck': 'Güvenlik kontrolü',
      'scan': 'Tara',
      'scanAnother': 'Başka QR tara',
      'scanHistory': 'Tarama geçmişi',
      'scanReport': 'Tarama raporu',
      'scannerStatusDetected': 'QR algılandı',
      'scannerStatusError': 'Tarayıcı hatası',
      'scannerStatusPoint': 'Kamerayı QR koda doğrultun',
      'scannerStatusReady': 'Önizleme hazır',
      'scannerStatusSubmitting': "Backend'e gönderiliyor",
      'searchDomainOrMaskedUrl': 'Alan adı veya maskelenmiş URL ara',
      'sendFeedback': 'Geri bildirim gönder',
      'sentToBackend': "Backend'e gönderilir",
      'sentToBackendBody':
          'Çözümlenen URL, zaman damgası, dil ve uygulama sürümü.',
      'settings': 'Ayarlar',
      'settingsTheme': 'Tema',
      'status': 'Durum',
      'storeLocalHistory': 'Yerel geçmişi sakla',
      'switchCamera': 'Kamerayı değiştir',
      'system': 'Sistem',
      'systemDefault': 'Sistem varsayılanı',
      'themeDark': 'Koyu',
      'themeLight': 'Açık',
      'topContributingUrlFeatures': 'En çok katkı yapan URL özellikleri',
      'torch': 'Fener',
      'turkish': 'Türkçe',
      'today': 'Bugün',
      'allDates': 'Tüm tarihler',
      'unexpectedAnalysisError':
          'Analiz sırasında beklenmeyen bir hata oluştu.',
      'urlCopied': 'URL kopyalandı',
      'urlOnlyPrivacyBody':
          "TurkQuish QR içeriğini yerel olarak çözümler, içeriğin web URL olup olmadığını doğrular ve çıkarım için yalnızca bu çözümlenen URL metnini yapılandırılmış backend'e gönderir.",
      'urlOnlyPrivacyTitle': 'Yalnızca URL tabanlı gizlilik tasarımı',
      'urlTransformer': 'URL-Transformer',
      'waitingBackendNoFetch':
          'Yapılandırılmış backend bekleniyor. Uygulama hiçbir web sayfası içeriği getirmez.',
      'warningEmptyHost': 'Boş ana makine',
      'warningMissingScheme': 'Şema eksik',
      'warningNonHttpScheme': 'HTTP/HTTPS dışı şema',
      'warningSuspiciouslyLong': 'Şüpheli derecede uzun URL',
      'warningUnsupportedScheme': 'Desteklenmeyen şema',
      'analysisStepPayload': 'QR içeriği çözümlendi',
      'analysisStepNormalization': 'URL normalizasyonu',
      'analysisStepFeatures': 'Yalnızca URL özellik çıkarımı',
      'analysisStepGraph': 'İndüktif graf izdüşümü',
      'analysisStepModel': 'Model çıkarımı',
      'analysisStepDecision': 'Karar katmanı',
      'analysisStepExplanation': 'Açıklama üretimi',
      'predictionBenign': 'Zararsız',
      'predictionMalware': 'Kötü amaçlı yazılım',
      'predictionOtherMalicious': 'Diğer zararlı',
      'predictionPhishing': 'Kimlik avı',
      'predictionScam': 'Dolandırıcılık',
    },
  };

  static const _brandSignalNames = <String, Map<String, String>>{
    'at_symbol_host_trick': {
      'en': '@ symbol host trick',
      'tr': '@ işaretiyle alan adı hilesi',
    },
    'brand_in_path': {'en': 'Brand in path', 'tr': 'Marka URL yolunda'},
    'brand_in_path_or_query': {
      'en': 'Brand in path or query',
      'tr': 'Marka URL yolu veya sorgusunda',
    },
    'brand_in_subdomain': {
      'en': 'Brand in subdomain',
      'tr': 'Marka alt alanda',
    },
    'brand_mentioned': {'en': 'Brand mentioned', 'tr': 'Marka adı geçiyor'},
    'brand_not_in_domain': {
      'en': 'Brand outside domain',
      'tr': 'Marka alan adı dışında',
    },
    'brand_not_registered_domain': {
      'en': 'Brand outside registered domain',
      'tr': 'Marka kayıtlı alan adı dışında',
    },
    'brand_tld_mismatch': {
      'en': 'Brand/TLD mismatch',
      'tr': 'Marka/TLD uyumsuzluğu',
    },
    'brand_with_hyphen': {
      'en': 'Brand with hyphen',
      'tr': 'Tireli marka kullanımı',
    },
    'brand_with_suspicious_tld': {
      'en': 'Brand with suspicious TLD',
      'tr': 'Şüpheli TLD ile marka kullanımı',
    },
    'homoglyph_characters': {
      'en': 'Homoglyph characters',
      'tr': 'Benzer görünümlü karakterler',
    },
    'levenshtein_brand_lookalike': {
      'en': 'Brand lookalike by edit distance',
      'tr': 'Düzenleme mesafesine göre marka benzeri',
    },
    'protected_acronym_extra_chars_or_typosquat': {
      'en': 'Protected acronym typo pattern',
      'tr': 'Korunan kısaltmada yazım benzeri örüntü',
    },
    'protected_brand_on_unofficial_domain': {
      'en': 'Protected brand on unofficial domain',
      'tr': 'Korunan marka resmi olmayan alanda',
    },
    'punycode_domain': {'en': 'Punycode domain', 'tr': 'Punycode alan adı'},
  };

  static const _featureNameOverridesTr = <String, String>{
    'alpha_ratio': 'Alfabetik karakter oranı',
    'at_symbol_trick': '@ işareti hilesi',
    'base64_like_segment': 'Base64 benzeri segment',
    'brand_dot_in_subdomain': 'Alt alanda marka noktası',
    'brand_homoglyph': 'Marka homoglif belirtisi',
    'brand_in_path': 'Yol içinde marka',
    'brand_in_subdomain': 'Alt alanda marka',
    'brand_not_in_domain': 'Marka kayıtlı alanda değil',
    'brand_plus_keyword': 'Marka ve şüpheli anahtar kelime',
    'brand_tld_mismatch': 'Marka/TLD uyumsuzluğu',
    'brand_with_hyphen': 'Tireli marka kullanımı',
    'campaign_membership': 'Kampanya üyeliği',
    'cluster_malicious_ratio': 'Küme zararlı oranı',
    'com_in_subdomain': 'Alt alanda com',
    'contains_brand': 'Marka içeriyor',
    'deep_subdomain_nesting': 'Derin alt alan iç içeliği',
    'double_protocol': 'Çift protokol',
    'has_at_in_url': 'URL içinde @ var',
    'has_double_dot': 'Çift nokta var',
    'has_double_slash': 'Çift eğik çizgi var',
    'has_exe': 'Çalıştırılabilir dosya işareti',
    'has_hex_encoding': 'Hex kodlama var',
    'has_ip': 'IP adresi kullanımı',
    'has_php': 'PHP dosya işareti',
    'has_punycode': 'Punycode alan adı',
    'has_query': 'Sorgu parametresi var',
    'has_redirect_param': 'Yönlendirme parametresi',
    'has_url_in_url': 'URL içinde URL',
    'has_www': 'www kullanımı',
    'hash_like_segment': 'Hash benzeri segment',
    'hex_in_domain': 'Alan adında hex dizi',
    'is_free_hosting': 'Ücretsiz barındırma kullanımı',
    'is_https': 'HTTPS kullanımı',
    'is_suspicious_tld': 'Şüpheli TLD',
    'is_tr_domain': '.tr alan adı',
    'is_turkish_dominant': 'Türkçe baskınlığı',
    'is_typo_squat': 'Yazım benzeri alan adı',
    'langid_tr_confidence': 'Türkçe dil güveni',
    'long_random_path': 'Uzun rastgele yol',
    'many_path_dirs': 'Çok sayıda yol dizini',
    'min_brand_edit_dist': 'En düşük marka düzenleme mesafesi',
    'pct_encoded_ratio': 'Yüzde kodlama oranı',
    'random_looking_domain': 'Rastgele görünen alan adı',
    'short_domain_susp_tld': 'Kısa alan ve şüpheli TLD',
    'susp_tld_with_brand': 'Marka ile şüpheli TLD',
    'susp_tld_with_keyword': 'Anahtar kelime ile şüpheli TLD',
    'suspicious_file_in_path': 'Yolda şüpheli dosya',
    'tld_token_cooccur': 'TLD-belirteç birlikte görülme',
    'tr_vs_en_bigram': 'Türkçe-İngilizce bigram farkı',
    'url_len': 'URL uzunluğu',
  };

  static const _featureTokenNamesTr = <String, String>{
    'adversarial': 'yanıltıcı',
    'ampersands': '& işareti',
    'bank': 'banka',
    'bigram': 'bigram',
    'bucket': 'aralığı',
    'brand': 'marka',
    'brands': 'marka',
    'campaign': 'kampanya',
    'centrality': 'merkezilik',
    'char': 'karakter',
    'chars': 'karakter',
    'cluster': 'küme',
    'consonant': 'ünsüz',
    'count': 'sayısı',
    'degree': 'derece',
    'digit': 'rakam',
    'digits': 'rakam',
    'dirs': 'dizin',
    'domain': 'alan adı',
    'dots': 'nokta',
    'doubled': 'tekrarlanan',
    'encoded': 'kodlanmış',
    'entropy': 'entropi',
    'equals': 'eşittir işareti',
    'excessive': 'aşırı',
    'family': 'aile',
    'file': 'dosya',
    'gov': 'kamu',
    'graph': 'graf',
    'heavy': 'ağırlıklı',
    'host': 'host',
    'hub': 'merkez',
    'hyphen': 'tire',
    'hyphens': 'tire',
    'in': 'içinde',
    'keyword': 'anahtar kelime',
    'keywords': 'anahtar kelime',
    'len': 'uzunluğu',
    'like': 'benzeri',
    'malicious': 'zararlı',
    'malware': 'zararlı yazılım',
    'max': 'en yüksek',
    'mean': 'ortalama',
    'ngram': 'n-gram',
    'num': 'sayısı',
    'numeric': 'sayısal',
    'params': 'parametre',
    'path': 'yol',
    'pattern': 'örüntü',
    'percent': 'yüzde işareti',
    'phishing': 'kimlik avı',
    'query': 'sorgu',
    'random': 'rastgele',
    'rare': 'nadir',
    'ratio': 'oranı',
    'registrant': 'kayıt sahibi',
    'reuse': 'tekrar',
    'scam': 'dolandırıcılık',
    'score': 'skoru',
    'sector': 'sektör',
    'semantic': 'anlamsal',
    'segment': 'segment',
    'shared': 'paylaşılan',
    'sibling': 'kardeş',
    'slashes': 'eğik çizgi',
    'specials': 'özel karakter',
    'subdomain': 'alt alan',
    'subdomains': 'alt alan',
    'suffix': 'ek',
    'telecom': 'telekom',
    'term': 'terim',
    'template': 'şablon',
    'tld': 'TLD',
    'token': 'belirteç',
    'tokens': 'belirteç',
    'tr': 'Türkçe',
    'transliteration': 'transliterasyon',
    'turkish': 'Türkçe',
    'underscores': 'alt çizgi',
    'unicode': 'Unicode',
    'unique': 'benzersiz',
    'urgency': 'aciliyet',
    'url': 'URL',
    'vocab': 'sözlük',
    'vowel': 'ünlü',
    'www': 'www',
  };

  String text(String key) {
    return _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;
  }

  String featureDisplayName(TopFeature feature) {
    final localized = switch (locale.languageCode) {
      'tr' => feature.displayNameTr,
      'en' => feature.displayNameEn,
      _ => null,
    };
    if (localized != null && localized.trim().isNotEmpty) {
      return localized;
    }
    if (locale.languageCode == 'tr') {
      return _featureDisplayNameTr(feature.name);
    }
    return feature.displayName;
  }

  String featureDirection(String value) {
    return switch (value.toLowerCase()) {
      'malicious' => text('featureDirectionMalicious'),
      'benign' => text('featureDirectionBenign'),
      _ => text('featureDirectionUnknown'),
    };
  }

  String brandRisk(String value) {
    return switch (value.toLowerCase()) {
      'low' => text('riskToneLow'),
      'medium' => text('riskToneMedium'),
      'high' || 'critical' => text('riskToneHigh'),
      _ => text('riskToneUnknown'),
    };
  }

  String brandSignal(String value) {
    final labels = _brandSignalNames[value];
    final localized = labels?[locale.languageCode] ?? labels?['en'];
    if (localized != null) {
      return localized;
    }
    if (locale.languageCode == 'tr') {
      return _backendCodeTr(value);
    }
    return _titleCaseBackendCode(value);
  }

  String predictionClass(PredictionClass value) {
    return switch (value) {
      PredictionClass.benign => text('predictionBenign'),
      PredictionClass.phishing => text('predictionPhishing'),
      PredictionClass.malware => text('predictionMalware'),
      PredictionClass.scam => text('predictionScam'),
      PredictionClass.otherMalicious => text('predictionOtherMalicious'),
    };
  }

  String riskTone({
    required PredictionClass predictedClass,
    required RiskLevel riskLevel,
    required double riskScore,
  }) {
    if (predictedClass == PredictionClass.benign && riskScore < 0.4) {
      return text('riskToneBenign');
    }
    return switch (riskLevel) {
      RiskLevel.low => text('riskToneLow'),
      RiskLevel.medium => text('riskToneMedium'),
      RiskLevel.high || RiskLevel.critical => text('riskToneHigh'),
      RiskLevel.unknown => text('riskToneUnknown'),
    };
  }

  String recommendedAction(RecommendedAction value) {
    return switch (value) {
      RecommendedAction.proceed => text('recommendedProceed'),
      RecommendedAction.caution => text('recommendedCaution'),
      RecommendedAction.block => text('recommendedBlock'),
      RecommendedAction.report => text('recommendedReport'),
    };
  }

  String recommendedActionSummary(RecommendedAction value) {
    return switch (value) {
      RecommendedAction.proceed => text('recommendedProceedSummary'),
      RecommendedAction.caution => text('recommendedCautionSummary'),
      RecommendedAction.block => text('recommendedBlockSummary'),
      RecommendedAction.report => text('recommendedReportSummary'),
    };
  }

  String featureGroup(FeatureGroup value) {
    return switch (value) {
      FeatureGroup.lexicalStructural => text('featureGroupLexicalStructural'),
      FeatureGroup.turkishLinguistic => text('featureGroupTurkishLinguistic'),
      FeatureGroup.adversarialBrand => text('featureGroupAdversarialBrand'),
      FeatureGroup.graphInfrastructure => text(
        'featureGroupGraphInfrastructure',
      ),
      FeatureGroup.other => text('featureGroupOther'),
    };
  }

  String urlWarning(UrlWarning value) {
    return switch (value) {
      UrlWarning.missingScheme => text('warningMissingScheme'),
      UrlWarning.unsupportedScheme => text('warningUnsupportedScheme'),
      UrlWarning.emptyHost => text('warningEmptyHost'),
      UrlWarning.nonHttpScheme => text('warningNonHttpScheme'),
      UrlWarning.suspiciouslyLong => text('warningSuspiciouslyLong'),
    };
  }

  String validationError(UrlValidationResult result) {
    if (result.warnings.contains(UrlWarning.missingScheme) ||
        result.warnings.contains(UrlWarning.unsupportedScheme) ||
        result.warnings.contains(UrlWarning.nonHttpScheme)) {
      return text('errorHttpOnly');
    }
    if (result.warnings.contains(UrlWarning.emptyHost)) {
      return text('errorHostRequired');
    }
    return text('errorValidWebUrlRequired');
  }

  String apiFailureTitle(ApiFailureType type) {
    return switch (type) {
      ApiFailureType.developerConfig => text('apiFailureDeveloperConfig'),
      ApiFailureType.timeout => text('apiFailureTimeout'),
      ApiFailureType.offline => text('apiFailureOffline'),
      ApiFailureType.backendUnavailable => text('apiFailureBackendUnavailable'),
      ApiFailureType.rateLimited => text('apiFailureRateLimited'),
      ApiFailureType.serverError => text('apiFailureServerError'),
      ApiFailureType.malformedResponse => text('apiFailureMalformedResponse'),
      ApiFailureType.invalidUrl => text('apiFailureInvalidUrl'),
      ApiFailureType.unexpected => text('apiFailureUnexpected'),
    };
  }

  String apiFailureMessage(ApiException error) {
    return switch (error.type) {
      ApiFailureType.developerConfig => text('apiConfigMessage'),
      ApiFailureType.timeout => text('apiErrorTimeout'),
      ApiFailureType.offline => text('apiErrorOffline'),
      ApiFailureType.backendUnavailable when error.statusCode != null => text(
        'apiErrorHttp',
      ).replaceAll('{statusCode}', error.statusCode.toString()),
      ApiFailureType.backendUnavailable => text('apiErrorBackendUnavailable'),
      ApiFailureType.rateLimited => text('apiErrorRateLimited'),
      ApiFailureType.serverError => text('apiErrorServer'),
      ApiFailureType.malformedResponse => text('apiErrorMalformedResponse'),
      ApiFailureType.invalidUrl => text('apiErrorInvalidUrl'),
      ApiFailureType.unexpected => text('apiErrorUnexpected'),
    };
  }

  static String _featureDisplayNameTr(String name) {
    final normalized = name.trim().toLowerCase().replaceAll('-', '_');
    final override = _featureNameOverridesTr[normalized];
    if (override != null) {
      return override;
    }

    if (normalized.startsWith('has_')) {
      return '${_featurePhraseTr(normalized.substring(4))} var';
    }
    if (normalized.startsWith('is_')) {
      return _capitalize(_featurePhraseTr(normalized.substring(3)));
    }
    if (normalized.startsWith('num_')) {
      return '${_featurePhraseTr(normalized.substring(4))} sayısı';
    }
    if (normalized.endsWith('_ratio')) {
      return '${_featurePhraseTr(_withoutSuffix(normalized, '_ratio'))} oranı';
    }
    if (normalized.endsWith('_score')) {
      return '${_featurePhraseTr(_withoutSuffix(normalized, '_score'))} skoru';
    }
    if (normalized.endsWith('_count')) {
      return '${_featurePhraseTr(_withoutSuffix(normalized, '_count'))} sayısı';
    }
    if (normalized.endsWith('_len')) {
      return '${_featurePhraseTr(_withoutSuffix(normalized, '_len'))} uzunluğu';
    }

    return _capitalize(_featurePhraseTr(normalized));
  }

  static String _featurePhraseTr(String value) {
    final words = value
        .split('_')
        .where((word) => word.trim().isNotEmpty)
        .map((word) => _featureTokenNamesTr[word] ?? word)
        .toList(growable: false);
    return words.join(' ');
  }

  static String _backendCodeTr(String value) {
    return _capitalize(
      _featurePhraseTr(value.toLowerCase().replaceAll('-', '_')),
    );
  }

  static String _titleCaseBackendCode(String value) {
    final words = value
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .map((word) => _capitalize(word.toLowerCase()))
        .toList(growable: false);
    return words.join(' ');
  }

  static String _withoutSuffix(String value, String suffix) {
    return value.substring(0, value.length - suffix.length);
  }

  static String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => AppStrings.supportedLocales
      .map((supported) => supported.languageCode)
      .contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}
