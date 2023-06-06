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



/*enum ArticleQuillVersion {

};*/


/// 품목 작업 이동 기록 데이터 클래스
///
/// @Create YM
/// @Update YM 23.04.10
/// @Version 1.1.0
class Article {
  var id = '';
  var state = '';
  var version='';

  var board = '';
  var type = '';

  var title = '';
  var desc = '';

  var json = '';
  var url = '';
  var thumbnail = '';

  var writer = '';
  var updateAt = 0;
  var createAt = 0;

  Article.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    state = json['state'] ?? '';
    type = json['type'] ?? '';
    board = json['board'] ?? "";
    version = json['version'] ?? '';

    title = json["title"] ?? "";
    desc = json["desc"] ?? "";

    this.json = json["json"] ?? "";
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
      'version': version,
      "board" : board,

      "title": title,
      "desc": desc,

      "json": json,
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

  dynamic update({ required String json, }) async {
    var create = false;

    if(id == '')  { create = true; }
    if(create) await createUID();
    if(id == '') return false;

    if(create) createAt = DateTime.now().microsecondsSinceEpoch;
    else updateAt = DateTime.now().microsecondsSinceEpoch;

    url = await StorageHub.updateFile("contents/board", "", Uint8List.fromList(json.codeUnits), "$id.json");
    this.json = json;

    if(json.contains("{\"image\":\"")) {
      thumbnail = json.split("{\"image\":\"").last.split("\"}").first;
    }

    /// 메인문서 기록
    var db = FirebaseFirestore.instance;
    final docRef = db.collection("contents/board/article").doc(id);

    /// 매입 트랜잭션을 수행합니다.
    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final docRefSn = await transaction.get(docRef);

      if(docRefSn.exists) transaction.update(docRef, toJson());
      else transaction.set(docRef, toJson());
    }).then(
            (value) { print("DocumentSnapshot successfully updated!"); return true; },
        onError: (e) { print("Error update article() $e"); return false; }
    );
  }




  dynamic delete() async {
    if(id == '')  { return false; }

    await StorageHub.deleteFile("contents/board", "", "$id.json");

    /// 메인문서 기록
    var db = FirebaseFirestore.instance;
    final docRef = db.collection("contents/board/article").doc(id);

    /// 매입 트랜잭션을 수행합니다.
    return await db.runTransaction((transaction) async {
      final docRefSn = await transaction.get(docRef);

      if(docRefSn.exists) transaction.delete(docRef);
    }).then(
            (value) { print("DocumentSnapshot successfully updated!"); return true; },
        onError: (e) { print("Error update article() $e"); return false; }
    );
  }
}




class PageArticle {
  var id = '';
  var state = '';
  var version='';

  var type = '';

  var title = '';
  var json = '';

  var url = '';
  var thumbnail = '';

  var writer = '';
  var updateAt = 0;
  var createAt = 0;

  PageArticle.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    state = json['state'] ?? '';
    type = json['type'] ?? '';
    version = json['version'] ?? '';

    title = json["title"] ?? "";
    this.json = json["json"] ?? "";

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
      'version': version,

      "title": title,
      "json": json,

      "url": url,
      "thumbnail": thumbnail,

      "writer": writer,
      "updateAt": updateAt,
      "createAt": createAt,
    };
  }


  dynamic update({ required String code, required String json }) async {
    url = await StorageHub.updateFile("contents/page", "", Uint8List.fromList(json.codeUnits), "$code.json");
    this.json = json;

    /// 메인문서 기록
    var db = FirebaseFirestore.instance;
    final docRef = db.collection("contents/page/article").doc(code);

    /// 매입 트랜잭션을 수행합니다.
    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final docRefSn = await transaction.get(docRef);

      if(docRefSn.exists) transaction.update(docRef, toJson());
      else transaction.set(docRef, toJson());
    }).then(
            (value) { print("DocumentSnapshot successfully updated!"); return true; },
        onError: (e) { print("Error update article() $e"); return false; }
    );
  }
}




/// 품목 작업 이동 기록 데이터 클래스
///
/// @Create YM
/// @Update YM 23.04.10
/// @Version 1.1.0
class ShopArticle {
  var id = '';
  var productId = '';
  var state = '';

  var group = '';

  var naveStoreUrl = "";
  var storeUrl = "";

  var name = '';
  var desc = '';

  var json = '';
  var url = '';
  var thumbnail = [];

  var maxBuyCount = 0;
  var price = 0;

  var writer = '';
  var updateAt = 0;
  var createAt = 0;

  ShopArticle.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    productId = json['productId'] ?? '';
    state = json['state'] ?? '';
    group = json['group'] ?? '';

    name = json["name"] ?? "";
    desc = json["desc"] ?? "";

    naveStoreUrl = json["naveStoreUrl"] ?? "";
    storeUrl = json["storeUrl"] ?? "";

    this.json = json["json"] ?? "";
    url = json["url"] ?? '';
    thumbnail = json["thumbnail"] == null ? [] : json["thumbnail"] as List;

    writer = json['writer'] ?? '';
    price = json["price"] ?? 0;
    maxBuyCount = json["maxBuyCount"] ?? 0;
    updateAt = json['updateAt'] ?? 0;
    createAt = json['createAt'] ?? 0;
  }
  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'productId' : productId,
      'state' : state,       // D,
      'group' : group,       // P 매입, R 매출, F 동결,

      "name": name,
      "desc": desc,
      "naveStoreUrl": naveStoreUrl,
      "storeUrl": storeUrl,


      "json": json,
      "url": url,
      "thumbnail": thumbnail,

      "writer": writer,
      "price": price,
      "maxBuyCount": maxBuyCount,
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

  dynamic update({ required String json }) async {
    var create = false;

    if(id == '')  { create = true; }
    if(create) await createUID();
    if(id == '') return false;

    if(create) createAt = DateTime.now().microsecondsSinceEpoch;
    else updateAt = DateTime.now().microsecondsSinceEpoch;

    url = await StorageHub.updateFile("shopItem", "", Uint8List.fromList(json.codeUnits), "$id.json");
    this.json = json;

    /// 메인문서 기록
    var db = FirebaseFirestore.instance;
    final docRef = db.collection("shopItem").doc(id);

    /// 매입 트랜잭션을 수행합니다.
    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final docRefSn = await transaction.get(docRef);

      if(docRefSn.exists) transaction.update(docRef, toJson());
      else transaction.set(docRef, toJson());
    }).then(
            (value) { print("DocumentSnapshot successfully updated!"); return true; },
        onError: (e) { print("Error update article() $e"); return false; }
    );
  }




  dynamic delete() async {
    if(id == '')  { return false; }

    await StorageHub.deleteFile("contents/board", "", "$id.json");

    /// 메인문서 기록
    var db = FirebaseFirestore.instance;
    final docRef = db.collection("contents/board/article").doc(id);

    /// 매입 트랜잭션을 수행합니다.
    return await db.runTransaction((transaction) async {
      final docRefSn = await transaction.get(docRef);

      if(docRefSn.exists) transaction.delete(docRef);
    }).then(
            (value) { print("DocumentSnapshot successfully updated!"); return true; },
        onError: (e) { print("Error update article() $e"); return false; }
    );
  }
}