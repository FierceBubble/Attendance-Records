import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'setting/userOptions.dart';
import 'widget/record_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
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
  final _dbRef = FirebaseDatabase.instance.ref();
  final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.blueAccent[400],
  );

  List<Widget> dateFormatChoices = <Widget>[
    const Text('Simple'),
    const Text('Detail'),
  ];

  final TextEditingController _userNameInputController =
      TextEditingController();
  final TextEditingController _userPhoneInputController =
      TextEditingController();
  final TextEditingController _searchInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<bool> _selectedFormat = <bool>[true, false];
  bool isSimple = true;

  @override
  void dispose() {
    _userNameInputController.dispose();
    _userPhoneInputController.dispose();
    _searchInputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _loadUserOptions();
    _searchKeyWord();
    _scrollListener();
    super.initState();
  }

  void _loadUserOptions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSimple = (prefs.getBool('dateformat') ?? true);
      if (isSimple) {
        _selectedFormat = [true, false];
      } else {
        _selectedFormat = [false, true];
      }
    });
  }

  void _searchKeyWord() {
    _searchInputController.addListener(() {
      debugPrint(_searchInputController.text);

      setState(() {});
    });
  }

  void _scrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        setState(() {
          Builder(
            builder: (context) => const Center(
              child: Text(
                  '- - - - - You have reached the end of the list - - - - -'),
            ),
          );

          debugPrint(
              '- - - - - You have reached the end of the list - - - - -');
        });
      }
    });
  }

  Future<void> insertUserCheckIn(String name, String phone) async {
    // use ServerValue();
    // to get server timestamp
    int timeStampNow = DateTime.now().millisecondsSinceEpoch;
    int timeStampreverse = timeStampNow * -1;
    int idx = 0;
    await _dbRef.child('totalList').get().then((snapshot) {
      if (snapshot.exists) {
        idx = snapshot.value as int;
      }
    });

    await _dbRef.update({
      'totalList': idx + 1,
    });

    final newCheckIn = <String, dynamic>{
      'user': name,
      'phone': phone,
      'timestamp': timeStampNow,
      'timestampR': timeStampreverse,
    };

    await _dbRef.child('list/$idx').set(newCheckIn);
  }

  @override
  Widget build(BuildContext context) {
    Query dbRef = FirebaseDatabase.instance
        .ref()
        .child('list')
        .orderByChild('timestampR');
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
                child: Text(
                  'Check-In Now !!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: _userNameInputController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your name',
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: TextFormField(
                        controller: _userPhoneInputController,
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
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Builder(
                        builder: (context) => ElevatedButton(
                          style: buttonStyle,
                          onPressed: () {
                            if (_userNameInputController.text != '' &&
                                _userPhoneInputController.text != '') {
                              insertUserCheckIn(_userNameInputController.text,
                                  _userPhoneInputController.text);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return const AlertDialog(
                                    content: Text(
                                      'Hi,\nYour check-in has been Recorded!',
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(2.0),
                                      ),
                                    ),
                                  );
                                },
                              );
                              debugPrint(
                                  '${_userNameInputController.text} has checked-in!');
                            }
                            _userNameInputController.clear();
                            _userPhoneInputController.clear();
                            FocusManager.instance.primaryFocus
                                ?.unfocus(); // Close focus (on-screen Keyboard)
                          },
                          child: const Text('Check In!'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
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

                            if (index == 0) {
                              //isSimple = true;
                              UserOptions.setDateFormat(true);
                              setState(() {});
                              debugPrint('Simple date format shown!');
                            } else {
                              //isSimple = false;
                              UserOptions.setDateFormat(false);
                              setState(() {});
                              debugPrint('Detail date format shown!');
                            }
                          });
                        },
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        selectedBorderColor: Colors.blueAccent[700],
                        selectedColor: Colors.white,
                        fillColor: Colors.blueAccent[200],
                        color: Colors.blueAccent[400],
                        constraints: const BoxConstraints(
                          minHeight: 24.0,
                          minWidth: 80.0,
                        ),
                        isSelected: _selectedFormat,
                        children: dateFormatChoices,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: FutureBuilder(
                    future: UserOptions.getDateFormat(),
                    initialData: isSimple,
                    builder: ((context, snapshot) {
                      if (snapshot.hasData) {
                        return Record_List(
                          isSimple: snapshot.data,
                          dbRef: dbRef,
                          scrollController: _scrollController,
                        );
                      }
                      return Record_List(
                        isSimple: isSimple,
                        dbRef: dbRef,
                        scrollController: _scrollController,
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
