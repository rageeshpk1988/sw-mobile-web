class GlobalValidations {
  static bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern.toString());
    return (!regex.hasMatch(value)) ? false : true;
  }

  static bool validatePassword(String value) {
    //Length 6 char. At least one uppercase, one lower case,  one special character, and one number.
    if (value.length < 6) return false;
    if (!value.contains(RegExp(r"[a-z]"))) return false;
    if (!value.contains(RegExp(r"[A-Z]"))) return false;
    if (!value.contains(RegExp(r"[0-9]"))) return false;
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }
}
