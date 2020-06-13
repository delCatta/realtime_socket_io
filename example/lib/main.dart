import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_socket_io/realtime_socket_io.dart';
import 'package:realtime_socket_io/response.dart';

import 'package:realtime_socket_io/socketService.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          SocketService("http://myawesomeapi:PORT", "subRoom", "unSubRoom"),
      child: new MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SocketService socketService = Provider.of<SocketService>(context);
    if (!socketService.isConnected()) socketService.createSocket();
    print(socketService.getSocket.connected);
    return !socketService.isConnected()
        ? notConnected(socketService)
        : roomManager(socketService);
  }

  Widget notConnected(SocketService socketService) => Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.refresh),
            onPressed: () {
              socketService.connect();
            }),
        body: Center(
          child: Text("Not Connected"),
        ),
      );
  Widget roomManager(SocketService socketService) => RoomManager(
        socket: socketService.getSocket,
        roomName: "numbers",
        updateString: "numbersUpdate",
        builder: (BuildContext context, Response response) {
          return Scaffold(
              floatingActionButton: _addNumber(socketService.socketURL),
              body: Builder(
                builder: (context) {
                  if (!response.hasData)
                    return Center(
                      child: Text("Loading..."),
                    );
                  if (response.isEmpty)
                    return Center(child: Text("Empty Data"));

                  DataClass data = DataClass.fromJson(response.data);
                  return ListView.builder(
                      itemCount: data.numbers.length,
                      itemBuilder: (context, index) {
                        int number = data.numbers[index];
                        return ListTile(
                          title: Text("$number"),
                        );
                      });
                },
              ));
        },
      );
  Widget _addNumber(String url) => FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          http.post(url);
        },
      );
}

class DataClass {
  // Json Data gets parsed here.
  List<dynamic> numbers;
  DataClass.fromJson(Map<String, dynamic> data) : numbers = data['data'];
}
