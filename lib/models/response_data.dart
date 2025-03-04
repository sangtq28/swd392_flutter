class ResponseData<T> {
  final String? message;
  final String? status;
  final T? data;

  ResponseData({
    this.message ,
     this.status,
     this.data,
  });

  factory ResponseData.fromJson(
      Map<String, dynamic> json, T Function(Object?) fromJsonT) {
    return ResponseData(
      message: json['message'] as String? ,
      status: json['status'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'status': status,
      'message': message,
      'data': data != null ? toJsonT(data!) : null,
    };
  }
}
