class OTPResponse {
  final String status;
  final String updateStatus;
  final latestVersion;
  final latestIOSVersion;
  final String updateIOSStatus;
  final String providerType;
  final String? remarks;
  final String? otpCode;
  final String? otpType;
  final String? authKey;
  final String? userType;
  final String? memberType;
  //final List<Management> managements ; this is not provided yet

  OTPResponse({
    required this.status,
    required this.updateStatus,
    required this.latestVersion,
    required this.latestIOSVersion,
    required this.updateIOSStatus,
    required this.providerType,
    this.remarks,
    this.otpCode,
    this.otpType,
    this.authKey,
    this.userType,
    this.memberType,
  });
  factory OTPResponse.fromJson(Map<String, dynamic> json) {
    return OTPResponse(
      status: json['status'],
      updateStatus: json['updateStatus'],
      latestVersion: json['latestVersion'],
      latestIOSVersion: json['latestIOSVersion'],
      updateIOSStatus: json['updateIOSStatus'],
      providerType: json['providerType'],
      remarks: json['remarks'],
      otpCode: json['otpCode'],
      otpType: json['otpType'],
      authKey: json['authKey'],
      userType: json['userType'],
      memberType: json['memberType'],
    );
  }
}
