class Student {
  String name;
  String matricNo;
  String email;
  bool deleted;
  var faces = [];
  bool attended;
  bool ofOriginal;


  Student({this.name,
  this.matricNo,
  this.email,
  this.deleted,
  this.faces,
  this.attended,
  this.ofOriginal,});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['Name'],
      matricNo: json['MatricID'],
      email: json['Email'],
      deleted: json["Deleted"],
      faces: json['Faces'],
    );
  }

  factory Student.attendanceFromJson(Map<String, dynamic> json) {
    return Student(
      name: json['Name'],
      matricNo: json['MatricID'],
      email: json['Email'],
      deleted: json["Deleted"],
      faces: json['Faces'],
      attended: json['attended'],
    );
  }

  factory Student.fromFaceDetect(Map<String, dynamic> json) {
    return Student(
      name: json['Name'],
      matricNo: json['MatricID'],
      email: json['Email'],
      deleted: json["Deleted"],
      faces: json['Faces'],
    );
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['fullName'] = this.name;
    //map["MatricID"] = this.matricNo;
    map['emailAddress'] = this.email;
    //map["overwrite"] = false;
    //map["face"] = "";

    return map;
  }

}