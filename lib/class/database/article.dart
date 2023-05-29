import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/helper/style.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';
import '../Customer.dart';
import '../contract.dart';
import '../revenue.dart';
import '../system.dart';
import '../widget/excel.dart';
import '../widget/list.dart';
import '../widget/text.dart';
import 'item.dart';




/// 품목 작업 이동 기록 데이터 클래스
///
/// @Create YM
/// @Update YM 23.04.10
/// @Version 1.1.0
class Article {
  var id = '';
  var state = '';
  var type = '';

  var title = '';
  var desc = '';

  var url = '';
  var thumbnail = '';

  var writer = '';
  var updateAt = 0;
  var createAt = 0;

  Article.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    state = json['state'] ?? '';
    type = json['type'] ?? '';

    title = json["title"] ?? "";
    desc = json["desc"] ?? "";

    url = json["url"] ?? '';
    thumbnail = json["thumbnail"] ?? '';

    writer = json['writer'] ?? '';
    updateAt = json['updateAt'] ?? 0;
    createAt = json['createAt'] ?? 0;
  }
  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'state' : state,       // D,
      'type' : type,       // P 매입, R 매출, F 동결,

      "title": title,
      "desc": desc,

      "url": url,
      "thumbnail": thumbnail,

      "writer": writer,
      "updateAt": updateAt,
      "createAt": createAt,
    };
  }


  /// 매우 엄격한 유일성 검사 중요도 낮음
  /// 무작위 16바이트 문자열
  dynamic createUID() async {
    if(id == '') {
      id = SystemT.generateRandomString(16);
    }
  }

  dynamic update({ required String data }) async {
    var create = false;

    if(id == '')  { create = true; }
    if(create) await createUID();
    if(id == '') return false;

    var url = await StorageHub.updateFile("contents/$type/article", "ATC", utf8.encoder.convert(data), id + ".json");
    if(url != null) this.url = url;

    var imageList = data.split("<img src=\"data:image/webp;base64,");
    if(imageList.length > 1) {
      var thumbData = imageList[1].split('">').first;
      var thumb = await StorageHub.updateFile("contents/$type/article", "ATC_THUMB", base64Decode(thumbData), id + ".png");
      if(thumb != null) this.thumbnail = thumb;
    }

    /// 테스트 필요
    /// 메인문서 기록
    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;
    final docRef = db.collection("contents/$type/article").doc(id);

    /// 매입 트랜잭션을 수행합니다.
    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final docRefSn = await transaction.get(docRef);

      /// 트랜잭션 내부
      if(create && docRefSn.exists) return false;
      if(docRefSn.exists) transaction.update(docRef, toJson());
      else transaction.set(docRef, toJson());
    }).then(
            (value) { print("DocumentSnapshot successfully updated!"); return true; },
        onError: (e) { print("Error update article() $e"); return false; }
    );
  }
}