class Admin {
  String staffId;
  String password;
  String email;
  String name;
  bool authenticated;
  String result;
  String token;

  Admin({
    this.name,
    this.staffId,
    this.email,
    this.password,
    this.authenticated,
    this.result,
    this.token,
  });

  factory Admin.fromLoginJson(Map<String, dynamic> json) {
    return Admin(authenticated: json['found'], result: json['result']);
  }

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
        staffId: json['StaffID'],
        password: json['Password'],
        email: json['Email'],
        name: json['Name']);
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['staff_id'] = this.staffId;
    map['password'] = this.password;

    return map;
  }
}