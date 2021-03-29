import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:frats_system_ase/utils/globals.dart' as globals;
import 'package:frats_system_ase/classes/frats_response.dart';
import 'package:frats_system_ase/classes/student.dart';
import 'package:frats_system_ase/classes/admin.dart';
import 'package:frats_system_ase/classes/course.dart';
import 'package:frats_system_ase/classes/course_class.dart';
import 'package:frats_system_ase/classes/session.dart';

class AWSFEUtil {
  static const MODULE_URI =
      "http://ec2-54-169-105-195.ap-southeast-1.compute.amazonaws.com:5000/module";
  static const LOGIN_URI =
      "http://ec2-54-169-105-195.ap-southeast-1.compute.amazonaws.com:5000/auth/login";
  static const COURSE_URI =
      "http://ec2-54-169-105-195.ap-southeast-1.compute.amazonaws.com:5000/classList";
  static const ACTIVE_SESSIONS_URI =
      "http://ec2-54-169-105-195.ap-southeast-1.compute.amazonaws.com:5000/session/getActiveSession/active";
  static const SESSIONS_URI =
      "http://ec2-54-169-105-195.ap-southeast-1.compute.amazonaws.com:5000/session/";
  static const STUDENT_URI =
      "http://ec2-54-169-105-195.ap-southeast-1.compute.amazonaws.com:5000/student";

  static Future<FratsResponse> registerStudent(
      String matricNo, String name, String email, String face) async {
    return http.post(STUDENT_URI, headers: {
      "x-access-token": globals.adminToken
    }, body: {
      "studentMatricNo": matricNo,
      "studentEmail": email,
      "studentName": name,
      "studentYear": "2018",
      "image": face
    }).then((http.Response response) {
      //print("registerStudent: ${json.decode(response.body)}");
      return FratsResponse.fromJsonNew(json.decode(response.body));
    });
  }

  static Future<List<Student>> getStudents() async {
    List<Student> list = new List<Student>();
    Student s;
    var res = await http
        .get(STUDENT_URI, headers: {"x-access-token": globals.adminToken});
    print("Hello");
    print(res.body);
    List<dynamic> data = json.decode(res.body);

    //Map data = json.decode(res.body);
    //List<dynamic> rest = data['result']['Items'];
    int length = data.length;
    for (int x = 0; x < length; x++) {
      s = new Student();
      s.matricNo = data[x]['studentMatricNo'];
      s.name = data[x]['studentName'];
      list.add(s);
    }

    return list;
  }

  static Future<Student> getStudentInformation(String matric) async {
    Student student = new Student();
    var res = await http.get(STUDENT_URI + "/" + matric,
        headers: {"x-access-token": globals.adminToken});
    print("getStudentInformation: ${res.body}");

    Map data = json.decode(res.body);
    student.name = data['studentName'];
    student.matricNo = data['studentMatricNo'];
    student.email = data['studentEmail'];
    student.faces = data['image'];

    return student;
  }

  static Future<FratsResponse> checkIfStudentInDB(String matric) async {
    bool found = false;
    var response = await http.get(Uri.encodeFull(STUDENT_URI + "/" + matric),
        headers: {"x-access-token": globals.adminToken});
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    print("checkIfStudentInDB: ${json.decode(response.body)}");
    return FratsResponse.fromJson(json.decode(response.body));
  }

  //Expect a response from editing student.
  static Future<FratsResponse> editStudentInformation(
      Student student, String imgBase64) async {
    Map<String, dynamic> map = student.toMap();
    if (imgBase64 != null) {
      map["face"] = imgBase64;
    }
    return http.put(STUDENT_URI + "/" + student.matricNo, headers: {
      "x-access-token": globals.adminToken
    }, body: {
      "studentMatricNo": student.matricNo,
      "studentEmail": student.email,
      "studentName": student.name,
      "image": student.faces
    }).then((http.Response response) {
      return FratsResponse.fromJsonNew(json.decode(response.body));
    });
  }

  static Future<FratsResponse> deleteStudent(String matric) async {
    return http.delete(STUDENT_URI + "/" + matric, headers: {
      "x-access-token": globals.adminToken
    }).then((http.Response response) {
      print("deleteStudent: ");
      return FratsResponse.fromJsonNew(json.decode(response.body));
    });
  }

  //Expect a response from authenticating login.
  static authenticateAdminLogin(Admin admin) async {
    try {
      return http.post(LOGIN_URI,
          body: {"email": admin.staffId, "password": admin.password});
    } on HttpException catch (e) {}
    ;
  }

  static Future<Admin> getAdminInformation(String staffId) async {
    Admin admin = new Admin();
    var res = await http.get(Uri.encodeFull(LOGIN_URI + "/" + staffId));
    print("getAdminInformation: ${res.body}");
    if (res.statusCode == 200) {
      Map data = json.decode(res.body);
      admin.name = data['result']['Name'];
      admin.staffId = data['result']['StaffID'];
      admin.email = data['result']['Email'];
      admin.password = data['result']['Password'];
    }
    return admin;
  }

  static Future<FratsResponse> addCourse(Course course) {
    Map<String, dynamic> map = course.newCourseToMap();
    return http
        .post(
            Uri.encodeFull(
                COURSE_URI + "/" + course.acadYear + "/" + course.courseCode),
            body: map)
        .then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      print("addCourse: ${json.decode(response.body)}");
      return FratsResponse.fromJson(json.decode(response.body));
    });
  }

  static Future<FratsResponse> editCourse(Course course, Course editedCourse) {
    print(course.ObjectId);
    return http.put(Uri.encodeFull(MODULE_URI + "/" + course.ObjectId), body: {
      "moduleCode": editedCourse.courseCode,
      "moduleName": editedCourse.courseName,
      "acadYear": editedCourse.acadYear
    }, headers: {
      "x-access-token": globals.adminToken
    }).then((http.Response response) {
      final int statusCode = response.statusCode;
      print(statusCode);
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      print("editCourse: ${json.decode(response.body)}");
      return FratsResponse.fromJson(json.decode(response.body));
    });
  }

  static Future<Course> getCourseInformation(Course course) async {
    Course c;
    var res = await http.get(Uri.encodeFull(
        COURSE_URI + "/${course.acadYear}/${course.courseCode}"));
    print("getCourseInformation: ${json.decode(res.body)}");
    if (res.statusCode == 200) {
      Map data = json.decode(res.body);
      c.courseName = data['result']['Name'];
      c.courseCode = data['result']['CourseCode'];
      c.acadYear = data['result']['AcadYear'];
      c.completed = data['result']['CourseCompleted'];
    }
    return c;
  }

  static Future<List<Course>> getCourses() async {
    List<Course> list = new List<Course>();
    Course c;

    try {
      print("token:" + globals.adminToken);
      var res = await http
          .get(MODULE_URI, headers: {"x-access-token": globals.adminToken});
      print("getCourses: ${json.decode(res.body)}");
      List<dynamic> data = json.decode(res.body);

      if (data != null) {
        data.forEach((element) {
          c = new Course();
          c.courseName = element['moduleName'];
          c.courseCode = element['moduleCode'];
          c.acadYear = element['acadYear'];
          c.ObjectId = element['_id'];

          list.add(c);
        });
      }
    } on HttpException catch (e) {}
    ;

    return list;
  }

  static Future<FratsResponse> deleteCourse(Course course) async {
    return http
        .delete(Uri.encodeFull(
            COURSE_URI + "/${course.acadYear}/${course.courseCode}"))
        .then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      print("deleteCourse: ");
      print(json.decode(response.body));
      return FratsResponse.fromJson(json.decode(response.body));
    });
  }

  static Future<List<CourseClass>> getClasses(Course course) async {
    List<CourseClass> list = new List<CourseClass>();
    CourseClass cc;
    var res = await http.get(Uri.encodeFull(COURSE_URI),
        headers: {"x-access-token": globals.adminToken});
    print(res.statusCode);
    if (res.statusCode == 200) {
      print(json.decode(res.body));
      List<dynamic> data = json.decode(res.body);
      data.forEach((value) {
        if (value['moduleId'] == course.ObjectId) {
          cc = new CourseClass();
          cc.ObjectId = value['_id'];
          cc.dayOfWeek = value['dayOfWeek'];
          cc.type = value['classType'];
          cc.evenOdd = value['evenOdd'];
          cc.name = value['className'];
          cc.startTime = value['startTime'];
          cc.endTime = value['endTime'];
          cc.students = new List<String>();
          List<dynamic> classStudList = value['students'];
          if (classStudList != null)
            classStudList.forEach((element) {
              cc.students.add(element);
            });
          cc.location = value['location'];
          List<dynamic> classSessionList = new List<dynamic>();
          if (classSessionList != null)
            classSessionList.forEach((element) {
              cc.sessions.add(element);
            });
          list.add(cc);
        }
      });
    }
    return list;
  }

  static Future<List<Session>> getSessions(Course c, CourseClass cc) async {
    List<Session> list = new List<Session>();
    Session s;
    var res = await http.get(Uri.encodeFull(SESSIONS_URI),
        headers: {'x-access-token': globals.adminToken});
    if (res.statusCode == 200) {
      List<dynamic> data = json.decode(res.body);
      print("getSessions: $data");
      data.forEach((value) {
        if ((value['class']['id']) == cc.ObjectId) {
          s = new Session();
          s.key = value['_id'];
          s.weekNum = value['weekNo'];
          s.hasAttended = new List<String>();
          List<dynamic> classAttendedList = value['attended'];
          if (classAttendedList != null)
            classAttendedList.forEach((element) {
              s.hasAttended.add(element);
            });
          s.date = DateTime.parse(value['date']);
          s.isActive = value['active'];
          //TODO: Add HasAttended
          list.add(s);
        }
      });
    }
    return list;
  }

  static Future<FratsResponse> deleteSession(
      Course c, CourseClass cc, Session s) async {
    return http.delete(Uri.encodeFull(SESSIONS_URI + "/${s.key}"), headers: {
      "x-access-token": globals.adminToken
    }).then((http.Response response) {
      final int statusCode = response.statusCode;
      print(s.key);
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      print("startSession: ${json.decode(response.body)}");
      return FratsResponse.fromJson(json.decode(response.body));
    });
  }

  static Future<FratsResponse> startSession(
      Course c, CourseClass cc, Session s) async {
    return http.put(Uri.encodeFull(SESSIONS_URI + "/${s.key}"), body: {
      "active": '1'
    }, headers: {
      'x-access-token': globals.adminToken
    }).then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      print("startSession: ${json.decode(response.body)}");
      return FratsResponse.fromJson(json.decode(response.body));
    });
  }

  static endSession(Session s) async {
    String baseURL = SESSIONS_URI + s.id;
    try {
      return http.put(baseURL,
          headers: {"x-access-token": globals.adminToken},
          body: {"active": "false"});
    } on HttpException catch (e) {}
  }

  static Future<Map> detectFace(String face, String id) {
    Map<String, dynamic> map = {
      "photo": face,
    };

    String baseURL =
        "http://ec2-54-169-105-195.ap-southeast-1.compute.amazonaws.com:5000/session/attendance/";
    String faceURL = baseURL + id;
    return http.post(faceURL,
        headers: {"x-access-token": globals.adminToken},
        body: {"image": face}).then((response) {
      //final int statusCode = response.statusCode;

      print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
      print(face);
      print(response.body);
      //print("detectFace: ${json.decode(response.body)}");
      Map<String, dynamic> mongoOut = jsonDecode(response.body);
      return mongoOut;
    });
  }

  static Future<FratsResponse> addClass(String moduleID, String acadyear,
      String coursecode, CourseClass newClass) async {
    String students = newClass.students.toString();
    print(students);
    print(newClass.students);
    Map<dynamic, dynamic> map = {
      "className": newClass.name,
      "classType": newClass.type,
      'moduleId': moduleID,
      'acadYear': acadyear,
      //"students" : studentList,
      "students": students.substring(1, students.length - 1),
      //"students" : students,
      "evenOdd": newClass.evenOdd.toString(),
      "dayOfWeek": newClass.dayOfWeek.toString(),
      "startTime": newClass.startTime.toString(),
      "endTime": newClass.endTime.toString(),
      "location": newClass.location,
    };

    return http
        .post(Uri.encodeFull(COURSE_URI),
            headers: {'x-access-token': globals.adminToken}, body: map)
        .then((http.Response response) {
      final int statusCode = response.statusCode;
      print(response.statusCode);
      if (statusCode < 200 || statusCode > 400 || json == null) {
        print("addClass: ${json.decode(response.body)}");
        throw new Exception("Error while fetching data");
      }

      print("addClass: ${json.decode(response.body)}");

      return FratsResponse.fromJson(json.decode(response.body));
    });
  }

  static Future<FratsResponse> editClass(
      Course course, CourseClass oldClass, CourseClass newClass) async {
    String students = newClass.students.toString();
    print(students);

    Map<String, dynamic> map = {
      "className": newClass.name,
      "classType": newClass.type,
      "startTime": newClass.startTime,
      "endTime": newClass.endTime,
      "dayOfWeek": newClass.dayOfWeek.toString(),
      "evenOdd": newClass.evenOdd.toString(),
      "location": newClass.location,
      "students": students.substring(1, students.length - 1),
    };

    print(map);
    return http
        .put(Uri.encodeFull(COURSE_URI + "/${oldClass.ObjectId}"),
            headers: {"x-access-token": globals.adminToken}, body: map)
        .then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      print("editClass: ${json.decode(response.body)}");
      return FratsResponse.fromJson(json.decode(response.body));
    });
  }

  static Future<FratsResponse> deleteClass(
      Course course, CourseClass courseClass) async {
    return http
        .delete(Uri.encodeFull(COURSE_URI +
            "/${course.acadYear}/${course.courseCode}/${courseClass.type}/${courseClass.name}"))
        .then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      print("deleteClass: ");
      print(json.decode(response.body));
      return FratsResponse.fromJson(json.decode(response.body));
    });
  }

  static Future<FratsResponse> addSession(
      Course course, CourseClass courseClass, Session session) async {
    FratsResponse fr;
    int hr = int.parse(courseClass.startTime.substring(0, 2));
    int min = int.parse(courseClass.startTime.substring(3));
    print("time: $hr $min");

    DateTime date = session.date.add(Duration(hours: hr, minutes: min));
    Map<dynamic, dynamic> map = {
      // TODO: add class time base on start time (in ms)
      "date": date.millisecondsSinceEpoch.toString(),
      "weekNo": session.weekNum.toString(),
      "class": courseClass.ObjectId,
      "active": '0',
    };
    print(map);
    return http.post(Uri.encodeFull(SESSIONS_URI), body: map, headers: {
      "x-access-token": globals.adminToken
    }).then((http.Response response) {
      final int statusCode = response.statusCode;
      print(statusCode);
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      print("addSession: ${json.decode(response.body)}");

      return FratsResponse.fromJsonNew(json.decode(response.body));
    });
  }

  static Future<List<Session>> listActiveSessions() {
    List<Session> sessionList = new List<Session>();
    Map courseData, classData;
    Session s;
    Course c;
    CourseClass cc;
    String token = globals.adminToken;
    print("token: $token");
    String courseURLBase =
        "http://ec2-54-169-105-195.ap-southeast-1.compute.amazonaws.com:5000/module/";
    return http.get(ACTIVE_SESSIONS_URI,
        headers: {"x-access-token": token}).then((res) async {
      List<dynamic> data = json.decode(res.body);
      print("Hello");
      print("listActiveSessions: $data");
      int length = data.length;
      if (data.length == 0) {
      } else {
        for (int x = 0; x < length; x++) {
          s = new Session();
          s.id = data[x]['_id'];
          s.isActive = data[x]['active'];
          s.weekNum = data[x]['weekNo'];
          s.date = DateTime.parse(data[x]['date']);
          s.hasAttended = new List<String>();
          List<dynamic> classAttendedList = data[x]['attended'];
          if (classAttendedList != null)
            classAttendedList.forEach((element) {
              s.hasAttended.add(element);
            });
          classData = data[x]['class'];
          cc = new CourseClass();
          cc.dayOfWeek = classData['dayOfWeek'];
          cc.type = classData['classType'];
          cc.startTime = classData['startTime'];
          cc.endTime = classData['endTime'];
          cc.evenOdd = classData['evenOdd'];
          cc.location = classData['location'];
          cc.name = classData['className'];
          cc.students = new List<String>();
          print(classData['students'][0]);
          List<dynamic> studentList;
          studentList = classData['students'][0].split(", ");
          print(studentList[0]);
          List<dynamic> classStudList = studentList;
          if (classStudList != null)
            classStudList.forEach((element) {
              cc.students.add(element);
              print(element);
            });
          s.courseClass = cc;
          String courseURLNew = courseURLBase + classData['moduleId'];
          var val =
              await http.get(courseURLNew, headers: {"x-access-token": token});
          print(val.body);
          Map<String, dynamic> courseData = jsonDecode(val.body);
          c = new Course();
          c.courseName = courseData['moduleName'];
          c.courseCode = courseData['moduleCode'];
          c.acadYear = courseData['acadYear'];
          s.course = c;
          sessionList.add(s);
        }
      }

      return sessionList;
    });
  }
}
