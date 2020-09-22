class Response<T> {
  Status status;
  T data;
  String message;

  Response.loading(this.message) : status = Status.LOADING;
  Response.completed(this.data) : status = Status.COMPLETED;
  Response.error(this.message) : status = Status.ERROR;
  Response.empty(this.message) : status = Status.EMPTY;

  @override
  String toString() {
    return "Status $data : $status \n Message : $message \n Data : $data";
  }
}

enum Status { LOADING, COMPLETED, ERROR, EMPTY }
