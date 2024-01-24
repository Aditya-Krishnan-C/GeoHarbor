import 'package:flutter/material.dart';

class NotificationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          'Notification',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Text(
          'No new notifications',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NotificationWidget(),
  ));
}
