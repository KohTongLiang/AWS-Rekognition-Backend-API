class Course {
  bool completed;
  String courseCode;
  String courseName;
  String acadYear;
  bool overwrite;
  String ObjectId;

  Course({
    //this.completed,
    this.courseCode,
    this.courseName,
    this.acadYear,
    this.overwrite = false,
    this.ObjectId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      //completed: json['CourseCompleted'],
      courseCode: json['CourseCode'],
      courseName: json['Name'],
      acadYear: json['AcadYear'],
    );
  }

  ///Use this toMap for EDITING courses.
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['name'] = this.courseName;
    map['acadyear'] = this.acadYear;
    map['coursecode'] = this.courseCode;
    map["overwrite"] = false;
    return map;
  }

  ///Use this toMap for ADDING courses.
  Map<String, dynamic> newCourseToMap() {
    var map = new Map<String, dynamic>();
    map['name'] = this.courseName;
    return map;
  }

  ///Use this toMap for ADDING courses.
  Map<String, dynamic> editCourseToMap() {
    var map = new Map<String, dynamic>();
    map['name'] = this.courseName;
    map['acadyear'] = this.acadYear;
    map['coursecode'] = this.courseCode;
    return map;
  }
}
