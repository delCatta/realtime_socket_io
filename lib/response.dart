import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ResponseStatus { disconnected, listening }

class Response {
  IO.Socket socket;
  ResponseStatus responseStatus;
  Map<String, dynamic> data;

  bool get hasData => data != null;
  bool get isEmpty => data == {};
  bool get isNotEmpty => data != {};

  Response(this.socket, {Map<String, dynamic> initialData}) {
    if (initialData != null) data = initialData;
    responseStatus =
        !isConnected ? ResponseStatus.disconnected : ResponseStatus.listening;
  }

  bool get isConnected => socket.connected;

  void setData(data) {
    this.data = data;
  }
}
