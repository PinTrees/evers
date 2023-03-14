
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/system.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import '../helper/function.dart';
import 'revenue.dart';
import 'transaction.dart';

class UserT {
  var bookmark = {};
  UserT.fromDatabase(Map<dynamic, dynamic> json) {
    bookmark = (json['bookmark'] == null) ? {} : json['bookmark'] as Map;
  }
  Map<String, dynamic> toJson() {
    return {
      'bookmark': bookmark as Map,
    };
  }
}

class UserSystem {
  static UserT user = UserT.fromDatabase({});

  static dynamic init() async {
    CollectionReference coll = await FirebaseFirestore.instance.collection('users');
    if(FirebaseAuth.instance.currentUser == null) return;

    print(FirebaseAuth.instance.currentUser!.uid);
    return coll.doc(FirebaseAuth.instance.currentUser!.uid).snapshots().listen((value) {
      print('stream user');
      if(value.data() == null) return;
      var data = value.data() as Map;
      user = UserT.fromDatabase(data);
      FunT.setStateMain();
    });
  }
  static dynamic updateUser(UserT user) async {
    if(FirebaseAuth.instance.currentUser == null) return;
    await FireStoreHub.docUpdate('users/${FirebaseAuth.instance.currentUser!.uid}', 'US.PATCH', user.toJson(),);
  }
}