import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'attendance-record---flutter',
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
    // TODO: implement dispose
    userName.dispose();
    userPhone.dispose();
    super.dispose();
  }

  Future<void> insertUserCheckIn(String name, String phone) async {
    int dateNow = DateTime.now().millisecondsSinceEpoch;
    int dateRev = dateNow*-1;
    int? idx=0;
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('totalList').get();
    if (snapshot.exists) {
      idx = snapshot.value as int?;
    }

    await ref.update({
      'totalList': idx!+1,
    });

    await ref.child('list/$idx').set({
      'user': name,
      'phone': phone,
      'checkin': dateNow,
      'reverse': dateRev
    });
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
                padding: EdgeInsets.all(8.0),
                child: Text('Check-In Now !!!'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: userName,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              Padding(
                padding: const EdgeInsets.all(8),
                child: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      if(userName.text!=''&&userPhone.text!=''){
                        insertUserCheckIn(userName.text, userPhone.text);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const AlertDialog(
                              content: Text('Check-In Recorded!'),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(2.0))),
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
              const Expanded(child: ListofRecords()),
            ],
          ),
        ),
      ),
    );
  }
}


class ListofRecords extends StatelessWidget {
  const ListofRecords({super.key});

  Widget listItem({required Map users}) {

    String readTimestamp(int timestamp) {
      var now = DateTime.now();
      var format = DateFormat('HH:mm a');
      var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      var diff = now.difference(date);
      var time = '';

      if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
        time = format.format(date);
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
    return Container(
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(users['user']),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(users['phone'].toString()),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(readTimestamp(users['checkin'])),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Query dbRef =
        FirebaseDatabase.instance.ref().child('list').orderByChild('reverse');
    return SizedBox(
      height: double.maxFinite,
      child: FirebaseAnimatedList(
        query: dbRef,
        itemBuilder: (BuildContext context, DataSnapshot snapshot,
            Animation<double> animation, int index) {
          Map users = snapshot.value as Map;
          return listItem(users: users);
        },
      ),
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
