
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
  static var thisVersion = '1.5.6';
  static var current = '';
  static var release = '';

  Version.fromDatabase(Map<dynamic, dynamic> json) {
    current = json['current'] ?? '';
    release = json['release'] ?? '';
  }
  static bool checkVersion() {
    if(current == '') return true;

    else if(current != thisVersion)  {
      var low = current.split('.');
      var cur = thisVersion.split('.');

      for(int i = 0; i < cur.length; i++) {
        var c = int.tryParse(low[i]) ?? 0;
        var t = int.tryParse(cur[i]) ?? 0;
        if(c > t) {
          return false;
        }
      }
      return true;
    }
    return true;
  }
}
