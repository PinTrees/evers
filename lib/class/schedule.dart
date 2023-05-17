
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/helper/pdfx.dart';
import 'package:evers/helper/style.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helper/aes.dart';
import '../helper/firebaseCore.dart';
import '../helper/interfaceUI.dart';
import '../ui/ux.dart';


/// 일정관리 시스템로 마이그레이션이 진행중입니다.
/// 기존 manager 시스템 변경
/// 신규 writer  시스템 추가
/// 신규 history 시스템 추가
/// 신규 updateAt 시스템 추가
class Schedule {
  var id = '';
  var ctUid = '';
  var type = '';

  var memo = '';
  var date = 0;

  var managers = [];
  var writer = '';
  var updateAt = 0;

  var filesMap = {};

  Schedule.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    type = json['type'] ?? '';
    ctUid = json['ctUid'] ?? '';
    memo = json['memo'] ?? '';
    writer = json['writer'] ?? '';

    date = json['date'] ?? 0;
    updateAt = json['updateAt'] ?? 0;

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
      'writer': writer,
      'updateAt': updateAt,
      'managers': managers as List,
      'filesMap': filesMap as Map,
    };
  }
  
  DateTime? getDate() {
    var d = new DateTime.fromMicrosecondsSinceEpoch(date);
    return d;
  }


  /// 이 함수는 데이터베이스에서 신규 일정추가를 요청하고 작업결과를 반환합니다.
  ///
  /// 추후 날짜 수정이 필요할 경우를 대비해 org 매개변수를 추가
  /// 일정을 추가하려면 반드시 이 함수를 호출해야 합니다.
  dynamic update({ Schedule? org,  Map<String, Uint8List>? files, }) async {
    var create = false;
    if(id == '')  { id = DatabaseM.generateRandomString(16);  create = true; }
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

  /// 이 함수는 데이터 베이스에서 해당 일정 삭제를 요청하고 작업 결과를 반환합니다.
  /// 일정을 제거하려면 반드시 이 함수를 호출해야 합니다.
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
  }

  /// 이 함수는 컴포턴트 통함 클래스로 변경되어야 합니다.
  static Widget buildTitle() {
    return WidgetUI.titleRowNone([ '순번', '일정시간', '태그', '메모', ], [ 28, 150, 150, 999, ], background: true, lite: true);
  }

  /// 이 함수는 컴포넌트 통합 함수로 변경되어야 합니다.
  Widget buildUIAsync({ int? index, Function? onEdite, }) {
    var w = Column(
      children: [
        Container(
          child: IntrinsicHeight(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcelT.LitGrid(text: '${index ?? 0 + 1}', width: 28),
                  ExcelT.LitGrid(text: StyleT.dateFormatAtEpoch(date.toString()), width: 150),
                  ExcelT.Grid(text: StyleT.getSCHTag(type), width: 150, textSize: 10),
                  ExcelT.LitGrid(text: memo, width: 250, expand: true, multiLine: true),

                  InkWell(
                      onTap: () {
                        if(onEdite != null) onEdite();
                      },
                      child: Container( height: 28, width: 28,
                        child: WidgetT.iconMini(Icons.create),)
                  ),
                ]
            ),
          ),
        ),
        if(filesMap.isNotEmpty)
          Container(
            height: 28,
            margin: EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      for(int i = 0; i < filesMap.length; i++)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ButtonT.IconText(
                                icon: Icons.file_copy_rounded,
                                text: filesMap.keys.elementAt(i),
                                color: Colors.grey.withOpacity(0.15),
                                onTap: () async {
                                  var downloadUrl = filesMap.values.elementAt(i);
                                  var fileName = filesMap.keys.elementAt(i);
                                  PdfManager.OpenPdf(downloadUrl, fileName);
                                })
                          ],
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
      ],
    );
    return w;
  }
}

class FactoryD {
  var id = '';
  var state = '';

  var itemSvPu = {};
  var itemSvRe = {};

  var date = 0;
  var memo = '';
  var filesMap = {};

  FactoryD.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    state = json['state'] ?? '';

    memo = json['memo'] ?? '';
    filesMap = (json['filesMap'] == null) ? {} : json['filesMap'] as Map;
    date = json['date'] ?? 0;

    itemSvPu = (json['itemSvPu'] == null) ? {} : json['itemSvPu'] as Map;
    itemSvRe = (json['itemSvRe'] == null) ? {} : json['itemSvRe'] as Map;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state,
      'memo': memo,
      'date': date,
      'filesMap': filesMap as Map,
      'itemSvPu': itemSvPu as Map,
      'itemSvRe': itemSvRe as Map,
    };
  }
  String getID() {
    return StyleT.dateFormatBarAtEpoch(date.toString());
  }
  
  dynamic delete() async {
    if(id == '') return;
    state = 'DEL';
    await FireStoreHub.docUpdateDel('factory-daily/$id', 'FD-Date::DELETE', toJson(), fileMap: filesMap);
  }
  dynamic deleteFile(String key) async {
    if(key == '') return;
    await StorageHub.deleteFile('factory-daily/$id', 'FD-Date-File-$key::DELETE', key);
    filesMap.remove(key);
    await DatabaseM.updateFactoryDWithFile(this);
  }
}

class ProductD {
  var id = '';
  var state = '';

  var itemSvPu = {};
  var itemSvRe = {};

  var date = 0;
  var memo = '';
  var filesMap = {};

  ProductD.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    state = json['state'] ?? '';

    memo = json['memo'] ?? '';
    filesMap = (json['filesMap'] == null) ? {} : json['filesMap'] as Map;
    date = json['date'] ?? 0;

    itemSvPu = (json['itemSvPu'] == null) ? {} : json['itemSvPu'] as Map;
    itemSvRe = (json['itemSvRe'] == null) ? {} : json['itemSvRe'] as Map;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state,
      'memo': memo,
      'date': date,
      'filesMap': filesMap as Map,
      'itemSvPu': itemSvPu as Map,
      'itemSvRe': itemSvRe as Map,
    };
  }
  String getID() {
    return StyleT.dateFormatBarAtEpoch(date.toString());
  }

  dynamic delete() async {
    if(id == '') return;
    state = 'DEL';
    await FireStoreHub.docUpdateDel('product-daily/$id', 'PD-Date::DELETE', toJson(), fileMap: filesMap);
  }
  dynamic deleteFile(String key) async {
    if(key == '') return;
    await StorageHub.deleteFile('product-daily/$id', 'PD-Date-File-$key::DELETE', key);
    filesMap.remove(key);
    await DatabaseM.updateProductDWithFile(this);
  }
}