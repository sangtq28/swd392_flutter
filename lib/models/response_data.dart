class ResponseData<T>{
  final String message;
  final String status;
  final T? data;

  ResponseData({
    required this.message,
    required this.status,
    required this.data});

  factory ResponseData.fromJson(Map<String, dynamic> json){
    return ResponseData(
      message: json['message'],
      status: json['status'],
      data: json['data']
    );
  }
  Map<String, dynamic> toJson(
      Object? Function(T value) toJsonT,
      ) {
    return {
      'status': status,
      'message': message,
      'data': data != null ? toJsonT(data!) : null,
    };
  }
}