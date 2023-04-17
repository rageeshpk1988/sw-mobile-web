//API Response object globally used
//Map
class APIResponseMap {
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? error;
  final String? message;
  final int? status;
  final String? version;

  APIResponseMap({
    this.data,
    this.error,
    this.message,
    this.status,
    this.version,
  });

  factory APIResponseMap.fromJson(Map<String, dynamic> json) {
    return APIResponseMap(
      data: parseData(json['data']),
      error: json['error'] == null ? null : parseError(json['error']),
      message: json['message'],
      status: json['status'],
      version: json['version'],
    );
  }
  static Map<String, dynamic> parseData(dataJson) {
    Map<String, dynamic> data = Map<String, dynamic>.from(dataJson);

    return data;
  }

  static Map<String, dynamic> parseError(errorJson) {
    Map<String, dynamic> error = Map<String, dynamic>.from(errorJson);

    return error;
  }
}

//List
class APIResponse {
  final List<Map<String, dynamic>>? data;
  final Map<String, dynamic>? error;
  final String? message;
  final int? status;
  final String? version;

  APIResponse({
    this.data,
    this.error,
    this.message,
    this.status,
    this.version,
  });

  factory APIResponse.fromJson(Map<String, dynamic> json) {
    return APIResponse(
      data: parseData(json['data']),
      error: json['error'] == null ? null : parseError(json['error']),
      message: json['message'],
      status: json['status'],
      version: json['version'],
    );
  }
  static List<Map<String, dynamic>> parseData(dataJson) {
    List<Map<String, dynamic>> response =
        List<Map<String, dynamic>>.from(dataJson);
    return response;
  }

  static Map<String, dynamic> parseError(errorJson) {
    Map<String, dynamic> error = Map<String, dynamic>.from(errorJson);

    return error;
  }
}
