// ignore_for_file: camel_case_types
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'dart:io' show Platform;

import '../page/user_page.dart';
import '../model/user.dart';

class Record_List extends StatelessWidget {
  final bool isSimple;
  final Query dbRef;
  final ScrollController scrollController;

  const Record_List(
      {super.key,
      required this.isSimple,
      required this.dbRef,
      required this.scrollController});

  Widget listItem(
      {required String name,
      required String phone,
      required int timestamp,
      required int index}) {
    String readTimestamp(int timestamp) {
      var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      var time = '';
      if (isSimple == true) {
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
      } else {
        var format = DateFormat('dd MMM yyyy, h:mm a');
        time = format.format(date);
      }

      return time;
    }

    return Builder(
      builder: (context) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            /*Move to next page to show user's checkin activity*/
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => User_Page(
                  name: name,
                ),
              ),
            );
            debugPrint('Card $index $name tapped.');
          },
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                Container(
                  width: 110,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    name,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      phone,
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 10.0),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      readTimestamp(timestamp),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int? lastItem;
    DatabaseReference checkLastItem =
        FirebaseDatabase.instance.ref('totalList');
    checkLastItem.onValue.listen((event) {
      lastItem = event.snapshot.value as int?;
    });

    Widget loadIndicator() {
      if (kIsWeb) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      return Center(
        child: Platform.isIOS
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(),
      );
    }

    return FirebaseAnimatedList(
      shrinkWrap: true,
      defaultChild: loadIndicator(),
      query: dbRef,
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        final usersCheckIn =
            User.fromRTDB(Map<String, dynamic>.from(snapshot.value as Map));

        if (lastItem == index + 1) {
          return Column(
            children: [
              listItem(
                  name: usersCheckIn.name,
                  phone: usersCheckIn.phone,
                  timestamp: usersCheckIn.timestamp,
                  index: index),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                    '- - - - - You have reached the end of the list - - - - -'),
              ),
            ],
          );
        }
        return listItem(
            name: usersCheckIn.name,
            phone: usersCheckIn.phone,
            timestamp: usersCheckIn.timestamp,
            index: index);
      },
    );
  }
}
