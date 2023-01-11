class HttpException implements Exception {
  final String messege;
  HttpException(this.messege);

  @override
  String toString() {
    return messege;
    // TODO: implement toString
    // return super.toString();
  }
}
