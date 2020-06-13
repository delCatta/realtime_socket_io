import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService with ChangeNotifier {
  final String socketURL;
  final String roomSubString;
  final String roomUnSubString;

  IO.Socket socket;

  List<String> subscribedRooms;

  IO.Socket get getSocket => socket;

  void connect() {
    socket.connect();
    notifyListeners();
  }

  bool isConnected() => socket == null ? false : socket.connected;

  SocketService(this.socketURL, this.roomSubString, this.roomUnSubString) {
    socket = null;
    subscribedRooms = [];
    print("SocketService Creation");
  }

  void createSocket() {
    print("Creating Socket to $socketURL");
    socket = IO.io(socketURL, <String, dynamic>{
      'transports': ['websocket'],
    });
    socket.on('connect', (_) {
      print("---- Socket Connected ----");
      subscribedRooms.forEach(
          (String roomName) => socket.emit(roomSubString, {"room": roomName}));
      notifyListeners();
    });

    socket.on('disconnect', (_) {
      print('---- Socket Disconected ----');
      notifyListeners();
    });
  }

  void addRoom(String roomName) {
    if (!subscribedRooms.contains(roomName)) subscribedRooms.add(roomName);
  }

  void removeRoom(String roomName) {
    if (subscribedRooms.contains(roomName)) subscribedRooms.remove(roomName);
  }
}
