class ExceptionModel implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? data;

  ExceptionModel({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ExceptionModel.fromJson(Map<String, dynamic> json) {
    return ExceptionModel(
      statusCode: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}