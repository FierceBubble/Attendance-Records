import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'userOptions.dart' as user_options;

import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

final ref = FirebaseDatabase.instance.ref();

const List<Widget> dateFormatChoices = <Widget>[
  Text('Simple'),
  Text('Detail'),
];


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

  final List<bool> _selectedFormat = <bool>[true, false];
  final ButtonStyle buttonStyle = ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent[400],);


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
                            style: buttonStyle,
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
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ToggleButtons(
                        direction: Axis.horizontal,
                        onPressed: (int index) {
                          setState(() {
                            // The button that is tapped is set to true, and the others to false.
                            for (int i = 0; i < _selectedFormat.length; i++) {
                              _selectedFormat[i] = i == index;
                            }

                            /* TODO
                            - Changes the dateFormat when clicked
                            - Save selected format for future use*/

                            if(index==0){
                              //isSimple = true;
                              debugPrint('Simple Clicked!');
                            }else{
                              //isSimple = false;
                              debugPrint('Detail Clicked!');
                            }
                          });
                        },
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        selectedBorderColor: Colors.blueAccent[700],
                        selectedColor: Colors.white,
                        fillColor: Colors.blueAccent[200],
                        color: Colors.blueAccent[400],
                        constraints: const BoxConstraints(
                          minHeight: 36.0,
                          minWidth: 80.0,
                        ),
                        isSelected: _selectedFormat,
                        children: dateFormatChoices,
                      ),
                    ),
                  ),
                ],
              ),
              const Expanded(child: ListOfRecords(isSimple: user_options.isSimple,)),
            ],
          ),
        ),
      ),
    );
  }
}

class ListOfRecords extends StatelessWidget {
  const ListOfRecords({super.key, this.isSimple});
  final isSimple;
  Widget listItem({required Map users, required int index}) {
    String readTimestamp(int timestamp) {
      var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      var time = '';
      if(isSimple){
        var now = DateTime.now();
        var diff = now.difference(date);

        if (diff.inSeconds <= 60 &&
            diff.inMinutes == 0 &&
            diff.inHours == 0 &&
            diff.inDays == 0) {
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
      }else{
        var format = DateFormat('dd MMM yyyy, h:mm a');
        time = format.format(date);
      }

      return time;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {

          /*TODO
          Move to next page to show user's checkin activity*/

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
