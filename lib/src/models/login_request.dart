class LoginRequest {
  final String buildVersion;
  final String appVersion;
  final String phoneNumber;
  final String apiVersion;
  final String? type;
  final String? downloadStatus;
  String? fcmTocken;
  final String mobileOS;

  LoginRequest({
    required this.buildVersion,
    required this.appVersion,
    required this.phoneNumber,
    required this.apiVersion,
    required this.mobileOS,
    this.type,
    this.downloadStatus,
    this.fcmTocken,
  });
}
