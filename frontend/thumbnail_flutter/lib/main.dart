import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamListenerPage(),
    );
  }
}

class StreamListenerPage extends StatefulWidget {
  @override
  State<StreamListenerPage> createState() => _StreamListenerPageState();
}

class _StreamListenerPageState extends State<StreamListenerPage> {
  List<String> events = [];

  @override
  void initState() {
    super.initState();
    listenToStream();
  }

  void listenToStream() async {
    try {
      var request = http.Request('GET', Uri.parse('http://localhost:8000/api/jobs/abcd/stream'));
      var streamResponse = await request.send();
      
      streamResponse.stream.transform(utf8.decoder).transform(LineSplitter()).listen((line) {
        print('Received line: $line');
        if (line.isEmpty) {
          return;
        }
        if (line.startsWith('event:')) {
          print('Event type: $line');
          return;
        }
        if (line.startsWith('data:')) {
          var jsonStr = line.replaceAll('data:', '').trim();
          if (jsonStr.isNotEmpty) {
            try {
              var data = jsonDecode(jsonStr);
              setState(() {
                events.add(jsonEncode(data));
              });
              print('Added event: $data');
            } catch (e) {
              print('Error parsing: $e');
            }
          }
        }
      });
    } catch (e) {
      print('Stream error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stream Listener')),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(events[index]),
          );
        },
      ),
    );
  }
}
