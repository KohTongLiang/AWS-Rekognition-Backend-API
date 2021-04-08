class Validator {
  static RegExp _reClassName = new RegExp(r"^(([A-z])+[0-9]+(\s)?)+$");
  static RegExp _reCourseCode =
      new RegExp(r"^[A-Z|a-z^(0-9)]{2,4}([A-Z|a-z]{1})?[0-9]{2,4}$");
  static RegExp _reCourseName = new RegExp(
      r'^(([A-Za-z0-9])+(\s|[!@#<>?":_.`~;[\]\\|=+\-)(*&^%\s-])*?)+$');
  static RegExp _reAcadYear = new RegExp(r"^(A|a)(Y|y)(\d{4})(S|s)[1|2]$");
  static RegExp _reTime = new RegExp(r"^([0-1][0-9]|[2][0-3])([0-5][0-9])$");

  static RegExp _reStudentName =
      new RegExp(r'^([A-Z|a-z]+(\s|[!@#<>?":_`~;[\]\\|=+\-)(*&^%\s-])*?)+$');
  static RegExp _reMatricNo = new RegExp(r"^[UuGgNnTt][0-9]{7}[A-Z|a-z]$");
  static RegExp _reEmail = new RegExp(r"^\w+@(\w+\.)+\w+$");

  static String validateEmpty(String value) {
    return value == "" ? "This field is required." : null;
  }

  static String validateClassName(String value) {
    return !_reClassName.hasMatch(value) ? 'Enter Valid Class Name' : null;
  }

  static String validateCourseCode(String value) {
    return !_reCourseCode.hasMatch(value) ? 'Enter Valid Course Code' : null;
  }

  static String validateCourseName(String value) {
    return !_reCourseName.hasMatch(value) ? 'Enter Valid Course Name' : null;
  }

  static String validateAcadYear(String value) {
    return !_reAcadYear.hasMatch(value) ? 'Enter Valid Academic Year' : null;
  }

  static String validateTime(String value) {
    return !_reTime.hasMatch(value) ? 'Enter Valid Time' : null;
  }

  static String validateStudentName(String value) {
    return !_reStudentName.hasMatch(value) ? 'Enter Valid Student Name' : null;
  }

  static String validateMatricNo(String value) {
    return !_reMatricNo.hasMatch(value)
        ? 'Enter Valid Matriculation No.'
        : null;
  }

  static String validateEmail(String value) {
    return !_reEmail.hasMatch(value) ? 'Enter Valid Email' : null;
  }
}
