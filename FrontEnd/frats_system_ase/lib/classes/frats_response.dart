class FratsResponse {
  bool found;
  var result;

  FratsResponse({
    this.found,
    this.result,
  });

  factory FratsResponse.fromJson(Map<String, dynamic> json) {
    return FratsResponse(
      found: json['found'],
      result: json['result'],
    );
  }
  factory FratsResponse.fromJsonNew(Map<String, dynamic> json) {
    return FratsResponse(
      result: json['message'],
    );
  }
}
