/* 
Custom Exception handling
 */

class NoInternetException implements Exception {
  String message;
  NoInternetException(this.message);
  @override
  String toString() {
    return message;
  }
}

class NoServiceFoundException implements Exception {
  String message;
  NoServiceFoundException(this.message);
  @override
  String toString() {
    return message;
  }
}

class NoDataFoundException implements Exception {
  String message;
  NoDataFoundException(this.message);
  @override
  String toString() {
    return message;
  }
}

class UnknownException implements Exception {
  String message;
  UnknownException(this.message);
  @override
  String toString() {
    return message;
  }
}

class AttemptsExceededException implements Exception {
  String message;
  AttemptsExceededException(this.message);
  @override
  String toString() {
    return message;
  }
}
