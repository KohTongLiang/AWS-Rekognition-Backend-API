class CourseClass {
  int dayOfWeek;
  int evenOdd;
  String name;
  String type;
  String startTime;
  String endTime;
  List<String> students;
  String location;
  List<String> sessions;
  String ObjectId;

  CourseClass({
    this.dayOfWeek,
    this.type,
    this.evenOdd,
    this.name,
    this.startTime,
    this.endTime,
    this.students,
    this.location,
    this.sessions,
    this.ObjectId,
  });

  factory CourseClass.fromJson(Map<String, dynamic> json) {
    return CourseClass(
      dayOfWeek: json['DayOfWeek'],
      type: json['Type'],
      evenOdd: json['EvenOdd'],
      name: json['Name'],
      startTime: json['StartTime'],
      endTime: json['EndTime'],
      students: json['Students'],
      location: json['Location'],
      sessions: json['Sessions'],
    );
  }
}