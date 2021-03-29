import 'package:frats_system_ase/classes/course.dart';
import 'package:frats_system_ase/classes/course_class.dart';

class Session {
  String id;
  Course course;
  CourseClass courseClass;
  String key;
  int weekNum;
  DateTime date;
  bool isActive;
  List<String> hasAttended;

  Session({
    this.id,
    this.course,
    this.courseClass,
    this.key,
    this.weekNum,
    this.date,
    this.isActive,
    this.hasAttended,
  });

/*factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      weekNum: json['WeekNum'],
      date: DateTime.fromMillisecondsSinceEpoch(json['Date']),
      isActive: json['IsActive'],
      hasAttended: json['HasAttended'],
    );
  }*/
}