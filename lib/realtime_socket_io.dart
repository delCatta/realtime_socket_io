library realtime_socket_io;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_socket_io/response.dart';
import 'package:realtime_socket_io/socketService.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RoomManager extends StatefulWidget {
  final IO.Socket socket;
  final String roomName;
  final String subscribeString;
  final String unSubscribeString;
  final String updateString;
  final Function(Map<String, dynamic>) subAck;
  final Function(Map<String, dynamic>) unSubAck;
  final Map<String, dynamic> subData;
  final Map<String, dynamic> unSubData;
  final Map<String, dynamic> initialData;
  final bool print;
  const RoomManager({
    Key key,
    @required this.socket,
    @required this.roomName,
    @required this.updateString,
    this.subscribeString,
    this.unSubscribeString,
    this.subAck,
    this.unSubAck,
    this.subData,
    this.unSubData,
    this.initialData,
    @required this.builder,
    this.print = false,
  }) : super(key: key);
  final Widget Function(BuildContext, Response) builder;
  @override
  RoomManagerState createState() => RoomManagerState();
}

class RoomManagerState extends State<RoomManager> {
  Response response;
  String subString;
  String unSubString;

  @override
  void initState() {
    response = new Response(widget.socket, initialData: widget.initialData);
    SocketService socketService =
        Provider.of<SocketService>(context, listen: false);
    subString = widget.subscribeString ?? socketService.roomSubString;
    unSubString = widget.unSubscribeString ?? socketService.roomUnSubString;
    subscribe();
    listen();
    super.initState();
  }

  void subscribe() {
    if (widget.print) print(">> Subcribing to ${widget.roomName}");
    widget.socket.emitWithAck(
        subString, {"room": widget.roomName, "data": widget.subData ?? {}},
        ack: (Map<String, dynamic> data) {
      if (widget.print) print(">> Subscribe Ack");
      widget.subAck(data);
    });
    SocketService ss = Provider.of<SocketService>(context, listen: false);
    ss.addRoom(widget.roomName);
  }

  void listen() {
    if (widget.print) print(">> Subcribing to ${widget.updateString}");
    widget.socket.on(widget.updateString, (data) {
      if (widget.print) print("Data Received $data");
      setState(() {
        response.setData(data);
      });
    });
  }

  void unsubscribe() {
    if (widget.print) print(">> UnSubscribing from ${widget.roomName}");
    widget.socket.emitWithAck(
        unSubString, {"room": widget.roomName, "data": widget.unSubData ?? {}},
        ack: (Map<String, dynamic> data) {
      widget.unSubAck(data);
    });
  }

  @override
  void dispose() {
    unsubscribe();
    SocketService ss = Provider.of<SocketService>(context, listen: false);
    ss.removeRoom(widget.roomName);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.print) print(">>Rebuilding.");
    return widget.builder(context, response);
  }
}
