import 'dart:io';
import 'dart:convert';
import 'package:flutter_police_traffic_management_app/auth.dart';

import 'package:flutter_police_traffic_management_app/database.dart';
import 'dart:typed_data';

class NetworkService {
  final DatabaseHelper _db = DatabaseHelper.instance;
  Socket? _socket;
  Function()? onViolation;

  Future<void> connect(
    String host,
    int port,
    Function()? onViolationCallback,
  ) async {
    onViolation = onViolationCallback;
    _socket = await Socket.connect(host, port);
    _socket!.listen(_handleData, onError: _handleError, onDone: _handleDone);
  }

  Future<void> _handleData(Uint8List data) async {
    const username = 'arun';
    const place    = 'Delhi';
    const plate    = 'DL 1234';
    final time     = DateTime.now().toString();

    // fetch the current points for our hard‑coded user
    final pts = await _db.getUserPoints(username);

    // record the “violation” in your local DB
    await _db.addViolation(username, place, plate, pts, time);

    // prepare the display message
    latestMessage =
    'User $username got points deducted at $place '
        '(Plate: $plate) on $time';

    // trigger your UI callback
    if (onViolation != null) onViolation!();
  }

// Add this new field
  String? latestMessage;


  void _handleError(error) {
    print('Socket error: $error');
  }

  void _handleDone() {
    print('Server closed connection');
  }

  void dispose() {
    _socket?.close();
  }
}
