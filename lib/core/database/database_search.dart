import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/database/ledger.dart';
import 'package:evers/class/database/process.dart';
import 'package:evers/class/employee.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/helper/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as en;



class DatabaseSearch {

  static int MaxSearchHistory = 100;
  static int InitSearchHistory = 10;

  static Future<DocumentReference> getDocument(String path, String doc) async {
    return await FirebaseFirestore.instance.collection(path).doc(doc);
  }

  static dynamic setSearch_CS(String searchText) async {
    if(FirebaseAuth.instance.currentUser == null) return false;
    var doc = await FirebaseFirestore.instance.collection('users/${FirebaseAuth.instance.currentUser!.uid}/search').doc('customer');
    var sn = await doc.get();
    if(sn.exists) {
      var map = sn.data() as Map<String, dynamic>;

      if(map.containsValue(searchText)) {
        dynamic key = map.entries.firstWhere((entry) => entry.value == searchText,)?.key;

        doc.update({
          key.toString(): FieldValue.delete(),
          DateTime.now().microsecondsSinceEpoch.toString() : searchText,});
        return true;
      }

      if(map.length > MaxSearchHistory) {
        Map<String, dynamic> sortMap = {};

        int index = 0;
        List<String> sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
        for (var key in sortedKeys) {
          if(index++ > InitSearchHistory) break;
          sortMap[key] = map[key];
        }
        doc.set(sortMap);
      } else doc.update({DateTime.now().microsecondsSinceEpoch.toString() : searchText,});
    }
    else doc.set({DateTime.now().microsecondsSinceEpoch.toString() : searchText,});

    return true;
  }
  static dynamic setSelect_CS(String id) async {
    if(FirebaseAuth.instance.currentUser == null) return false;
    var doc = await FirebaseFirestore.instance.collection('users/${FirebaseAuth.instance.currentUser!.uid}/select').doc('customer');
    var sn = await doc.get();
    if(sn.exists) {
      var map = sn.data() as Map<String, dynamic>;

      if(map.containsValue(id)) {
        dynamic key = map.entries.firstWhere((entry) => entry.value == id,)?.key;

        doc.update({
          key.toString(): FieldValue.delete(),
          DateTime.now().microsecondsSinceEpoch.toString() : id,});
        return true;
      }

      if(map.length > MaxSearchHistory) {
        Map<String, dynamic> sortMap = {};

        int index = 0;
        List<String> sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
        for (var key in sortedKeys) {
          if(index++ > InitSearchHistory) break;
          sortMap[key] = map[key];
        }

        doc.set(sortMap);
      } else {
        doc.update({DateTime.now().microsecondsSinceEpoch.toString() : id,});
      }
    }
    else doc.set({DateTime.now().microsecondsSinceEpoch.toString() : id,});

    return true;
  }


  static dynamic getCSSearchHistory() async {
    List<String> datas = [];

    if(FirebaseAuth.instance.currentUser == null) return false;
    var doc = await getDocument('users/${FirebaseAuth.instance.currentUser!.uid}/search', "customer");

    await doc.get().then((value) {
      if(!value.exists) return;
      if(value.data() == null) return;

      var map = value.data() as Map;
      List<dynamic> sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));

      int index = 0;
      for(var key in sortedKeys) {
        if(index++ > InitSearchHistory) break;
        datas.add(map[key]);
      }
    });
    return datas;
  }
  static dynamic getCSSelectHistory() async {
    List<String> datas = [];

    if(FirebaseAuth.instance.currentUser == null) return false;
    var doc = await getDocument('users/${FirebaseAuth.instance.currentUser!.uid}/select', "customer");

    await doc.get().then((value) {
      if(!value.exists) return;
      if(value.data() == null) return;

      var map = value.data() as Map;
      List<dynamic> sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));

      int index = 0;
      for(var key in sortedKeys) {
        if(index++ > InitSearchHistory) break;
        datas.add(map[key]);
      }
    });

    return datas;
  }
}