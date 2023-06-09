
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/helper/style.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import '../helper/firebaseCore.dart';

// 일정 클래스
// 추후 생성자, JSON직렬화 함수 재구축
class Plan {
  var id = '';
  var ctUid = '';
  var type = '0';
  var managers = [];
  
  var tag = [];
  
  var title = '';
  var memo = '';
  
  var date = 0;
  var endDate = 0;
  
  // userUid - eyeem
  var userGroup = {};
  var filesMap = {};

  Plan.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    type = json['type'] ?? '0';
    ctUid = json['ctUid'] ?? '';
    memo = json['memo'] ?? '';
    date = json['date'] ?? 0;
    managers = json['managers'] ?? [];
    filesMap = (json['filesMap'] == null) ? {} : json['filesMap'] as Map;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'ctUid': ctUid,
      'memo': memo,
      'date': date,
      'managers': managers as List,
      'filesMap': filesMap as Map,
    };
  }

  
  
  
  
  
  
  
 /* // 추후 날짜 수정이 필요할 경우를 대비해 org 매개변수를 추가
  dynamic update({ Plan? org,  Map<String, Uint8List>? files, }) async {
    var create = false;
    if(id == '')  { id = FireStoreT.generateRandomString(16);  create = true; }
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(date));

    var orgDateId = '-';
    var orgDateQuarterId = '-';
    var orgDateIdHarp = '-';

    if(org != null) {
      orgDateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(date));
      orgDateQuarterId = DateStyle.dateYearsQuarter(date);
      orgDateIdHarp = DateStyle.dateYearsHarp(date);
    }

    var dateIdHarp = DateStyle.dateYearsHarp(date);
    var dateIdQuarter = DateStyle.dateYearsQuarter(date);
    //var searchText = await data.getSearchText();

    /// 거래명세서 파일 업로드
    if(files != null) {
      try {
        for(int i = 0; i < files.length; i++) {
          var f = files.values.elementAt(i);
          var k = files.keys.elementAt(i);

          if(filesMap[k] != null) continue;

          final mountainImagesRef = FirebaseStorage.instance.ref().child("schedule/${id}/${k}");
          await mountainImagesRef.putData(f);
          var url = await mountainImagesRef.getDownloadURL();
          if(url == null) {
            print('sch file upload failed');
            continue;
          }
          filesMap[k] = url;
        }
      } catch (e) {
        print(e);
      }
    }

    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;
    final docRef = db.collection("schedule").doc(id);
    /// 거래처 총매입 개수 읽기 효율화

    if(ctUid != '') ref['ct']  = db.collection('contract').doc(ctUid);
    if(ctUid != '') ref['ctDetail']  = db.collection('contract/$ctUid/ct-dateH-schedule').doc(dateIdHarp);
    if(ctUid != '' && org != null) ref['orgCsDetail'] = db.collection('contract/${org.ctUid}/cs-dateH-schedule').doc(orgDateIdHarp);

    await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final  docRefSn = await transaction.get(docRef);
      if(ref['ctDetail'] != null) sn['ctDetail'] = await transaction.get(ref['ctDetail']!);
      if(ref['orgCsDetail'] != null) sn['orgCsDetail'] = await transaction.get(ref['orgCsDetail']!);
      if(ref['ct'] != null) sn['ct'] = await transaction.get(ref['ct']!);

      if(org != null && sn['orgCsDetail'] != null) {
        if(sn['orgCsDetail']!.exists && dateIdHarp != orgDateIdHarp && orgDateIdHarp != '-') {
          transaction.update(ref['orgCsDetail']!, { id: FieldValue.delete(), });
        }
      }

      if(docRefSn.exists) transaction.update(docRef, toJson());
      else transaction.set(docRef, toJson());

      if(sn['ctDetail'] != null) {
        if(sn['ctDetail']!.exists)  transaction.update(ref['ctDetail']!,  {  id: toJson(), });
        else transaction.set(ref['ctDetail']!, {  id: toJson()  });
      }

      if(sn['ct'] != null) {
        if(create) transaction.update(ref['ct']!,  { 'scheduleCount': FieldValue.increment(1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});
      }
    }).then(
          (value) => print("sch successfully updated!"),
      onError: (e) => print("Error sch update() $e"),
    );
  }
  dynamic delete() async {
    if(id == '') return false;

    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(date));
    var dateIdHarp = DateStyle.dateYearsHarp(date);
    var dateIdQuarter = DateStyle.dateYearsQuarter(date);
    //var searchText = await data.getSearchText();

    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;
    final docRef = db.collection("schedule").doc(id);

    if(ctUid != '') ref['ct']  = db.collection('contract').doc(ctUid);
    if(ctUid != '') ref['ctDetail']  = db.collection('contract/$ctUid/ct-dateH-schedule').doc(dateIdHarp);

    await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final  docRefSn = await transaction.get(docRef);
      if(ref['ctDetail'] != null) sn['ctDetail'] = await transaction.get(ref['ctDetail']!);
      if(ref['ct'] != null) sn['ct'] = await transaction.get(ref['ct']!);

      if(docRefSn.exists) transaction.delete(docRef);

      if(sn['ctDetail'] != null) {
        if(sn['ctDetail']!.exists) transaction.update(ref['ctDetail']!,  {  id: FieldValue.delete(), });
      }

      if(sn['ct'] != null) {
        if(sn['ct']!.exists) transaction.update(ref['ct']!,  { 'scheduleCount': FieldValue.increment(-1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});
      }
    }).then(
          (value) => print("sch successfully delete!"),
      onError: (e) => print("Error sch delete() $e"),
    );

    return true;
  }*/
}
