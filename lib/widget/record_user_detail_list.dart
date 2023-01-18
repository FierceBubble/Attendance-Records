// ignore_for_file: camel_case_types
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show Platform;

import '../model/user.dart';

class Record_User_Detail_List extends StatelessWidget {
  final Query dbRef;

  const Record_User_Detail_List({
    super.key,
    required this.dbRef,
  });

  Widget listItem(
      {required String name,
      required String phone,
      required int timestamp,
      required int index}) {
    String readTimestamp(int timestamp) {
      var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      var format = DateFormat('dd MMM yyyy, h:mm a');

      return format.format(date);
    }

    return Builder(
      builder: (context) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
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
                Container(
                  width: 90,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    phone,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 10.0),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      readTimestamp(timestamp),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 10.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    _shareContactInfo(name: name, phone: phone);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _shareContactInfo({required name, required phone}) {
    Share.share('$name\n$phone');
  }

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

  @override
  Widget build(BuildContext context) {
    return FirebaseAnimatedList(
      reverse: true,
      shrinkWrap: true,
      defaultChild: loadIndicator(),
      query: dbRef,
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        final usersCheckIn =
            User.fromRTDB(Map<String, dynamic>.from(snapshot.value as Map));

        return listItem(
            name: usersCheckIn.name,
            phone: usersCheckIn.phone,
            timestamp: usersCheckIn.timestamp,
            index: index);
      },
    );
  }
}
