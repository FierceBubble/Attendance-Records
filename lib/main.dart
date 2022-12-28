import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: const Text('Attendance Records'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Check-In Now !!!'),
              const RecordForm(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NextPage(),
                        ),
                      );
                    },
                    child: const Text('Next Page'),
                  ),
                ),
              ),
              const ListofRecords(),
            ],
          ),
        ),
      ),
    );
  }
}

class RecordForm extends StatelessWidget {
  const RecordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter your name',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter your phone number',
            ),
          ),
        ),
      ],
    );
  }
}

class ListofRecords extends StatelessWidget {
  const ListofRecords({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Expanded(flex: 1, child: Text('Name')),
              Expanded(flex: 1, child: Text('(+60) 123456789')),
              Expanded(flex: 1, child: Text('20 December 2022 10:00 am')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                flex: 1,
                child: Text('Name'),
              ),
              const Expanded(
                flex: 1,
                child: Text('(+60) 123456789'),
              ),
              const Expanded(
                flex: 1,
                child: Text('20 December 2022 10:00 am'),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          content: Text('Alert!'),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2.0))),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Expanded(flex: 1, child: Text('Name')),
              Expanded(flex: 1, child: Text('(+60) 123456789')),
              Expanded(flex: 1, child: Text('20 December 2022 10:00 am')),
            ],
          ),
        ),
      ],
    );
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: const Text('Next Page'),
      ),
    );
  }
}
