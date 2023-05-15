
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

class VersionInfo {
  var name = '';
  var info = '';
  var updateAt = 0;
  VersionInfo.fromDatabase(Map<dynamic, dynamic> json) {
    name = json['name'] ?? '';
    info = json['info'] ?? '';
    updateAt = json['updateAt'] ?? 0;
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'info': info,
      'updateAt': updateAt,
    };
  }
}

class Version {
  static var thisVersion = '0.7.0';
  static var current = '';
  static var release = '';

  Version.fromDatabase(Map<dynamic, dynamic> json) {
    current = json['current'] ?? '';
    release = json['release'] ?? '';
  }
  static bool checkVersion() {
    if(current == '') return true;

    else if(current != thisVersion)  {
      var c = int.tryParse(current.replaceAll('.', '')) ?? 0;
      var t = int.tryParse(thisVersion.replaceAll('.', '')) ?? 0;
      if(c > t) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  }
}
