import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

final ref = FirebaseDatabase.instance.ref();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }else{
    await Firebase.initializeApp(
      name: 'attendance-record---flutter',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController userName = TextEditingController();
  TextEditingController userPhone = TextEditingController();

  @override
  void dispose() {
    userName.dispose();
    userPhone.dispose();
    super.dispose();
  }

  Future<void> insertUserCheckIn(String name, String phone) async {
    int dateNow = DateTime.now().millisecondsSinceEpoch;
    int dateRev = dateNow * -1;
    int? idx = 0;
    final snapshot = await ref.child('totalList').get();
    if (snapshot.exists) {
      idx = snapshot.value as int?;
    }

    await ref.update({
      'totalList': idx! + 1,
    });

    await ref.child('list/$idx').set(
        {'user': name, 'phone': phone, 'checkin': dateNow, 'reverse': dateRev});
  }

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
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Check-In Now !!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue ,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: userName,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your name',
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: userPhone,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your phone number',
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget> [
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Builder(
                          builder: (context) => ElevatedButton(
                            onPressed: () {
                              if (userName.text != '' && userPhone.text != '') {
                                insertUserCheckIn(userName.text, userPhone.text);
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const AlertDialog(
                                      content: Text('Check-In Recorded!'),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(2.0))
                                      ),
                                    );
                                  },
                                );
                              }
                              userName.clear();
                              userPhone.clear();
                            },
                            child: const Text('Check In!'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Expanded(child: ListOfRecords()),
            ],
          ),
        ),
      ),
    );
  }
}

class ListOfRecords extends StatelessWidget {
  const ListOfRecords({super.key});

  Widget listItem({required Map users, required int index}) {
    String readTimestamp(int timestamp) {
      var now = DateTime.now();
      var format = DateFormat('HH:mm a');
      var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      var diff = now.difference(date);
      var time = '';

      if (diff.inSeconds <= 60 &&
          diff.inMinutes == 0 &&
          diff.inHours == 0 &&
          diff.inDays == 0) {
        time = format.format(date);
        if (diff.inSeconds == 1 || diff.inSeconds == 0) {
          time = '${diff.inSeconds} SECOND AGO';
        } else {
          time = '${diff.inSeconds} SECONDS AGO';
        }
      } else if (diff.inMinutes > 0 &&
          diff.inMinutes <= 60 &&
          diff.inHours == 0 &&
          diff.inDays == 0) {
        if (diff.inMinutes == 1) {
          time = '${diff.inMinutes} MINUTE AGO';
        } else {
          time = '${diff.inMinutes} MINUTES AGO';
        }
      } else if (diff.inHours > 0 && diff.inHours < 24 && diff.inDays == 0) {
        if (diff.inHours == 1) {
          time = '${diff.inHours} HOUR AGO';
        } else {
          time = '${diff.inHours} HOURS AGO';
        }
      } else if (diff.inDays > 0 && diff.inDays < 7) {
        if (diff.inDays == 1) {
          time = '${diff.inDays} DAY AGO';
        } else {
          time = '${diff.inDays} DAYS AGO';
        }
      } else {
        if (diff.inDays == 7) {
          time = '${(diff.inDays / 7).floor()} WEEK AGO';
        } else {
          time = '${(diff.inDays / 7).floor()} WEEKS AGO';
        }
      }

      return time;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          debugPrint('Card $index tapped.');
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(users['user'],
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(users['phone'].toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12.0),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(readTimestamp(users['checkin']),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 10.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Query dbRef =
        ref.child('list').orderByChild('reverse');

    int? lastItem;
    DatabaseReference checkLastItem = FirebaseDatabase.instance.ref('totalList');
    checkLastItem.onValue.listen((event) {
      lastItem = event.snapshot.value as int?;
    });

    return FirebaseAnimatedList(
      query: dbRef,
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        Map users = snapshot.value as Map;

        if (index+1==lastItem){
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              listItem(users: users, index: index),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('- - - - - You have reached the end of the list - - - - -'),
              ),
            ],
          );
        }
        return listItem(users: users, index: index);
      },
    );
  }
}

class NextPage extends StatefulWidget {
  const NextPage({super.key});

  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
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
