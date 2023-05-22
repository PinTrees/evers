import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/system/records.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helper/function.dart';

/// 사용자의 권한 관리 목록
enum PermissionType {
  isPaymentRead('isPaymentRead', '금전출납 읽기권한', true),
  isPaymentWrite('isPaymentWrite', '금전출납 쓰기권한', true),

  isRevenueRead('isRevenueRead', '매출정보 읽기권한', true),
  isRevenueWrite('isRevenueWrite', '매출정보 쓰기권한', true),
  isPurchaseRead('isPurchaseRead', '매입정보 읽기권한', true),
  isPurchaseWrite('isPurchaseWrite', '매입정보 쓰기권한', true),

  isCustomerRead('isCustomerRead', '거래처정보 읽기권한', true),
  isCustomerWrite('isCustomerWrite', '거래처정보 쓰기권한', true),
  isContractRead('isContractRead', '계약정보 읽기권한', true),
  isContractWrite('isContractWrite', '계약정보 쓰기권한', true),

  isUserWrite('isUserWrite', '계정생성 권한', false),
  isUserRead('isUserRead', '계정수정 권한', false);

  const PermissionType(this.code, this.displayName, this.display);
  final String code;
  final String displayName;
  final bool display;

  factory PermissionType.getByCode(String code){
    return PermissionType.values.firstWhere((value) => value.code == code,
        orElse: () => PermissionType.isPaymentRead);
  }
}





/// [Database Class]
/// 이 클래스는 유저정보 데이터베이스 객체입니다.
///
/// 1.0.0
class UserData {
  var id = '';
  var name = '';
  var email = '';
  var password = '';

  var permission = {};


  /// 이 함수는 클래스 파서입니다.
  UserData.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    email = json['email'] ?? '';
    password = json['password'] ?? '';

    permission = json['permission'] == null ? {} : json['permission'] as Map;
  }


  /// 이 함수는 클래스 직렬화자 입니다.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "password": password,
      'permission': permission as Map,
    };
  }


  /// 이 함수는 생성이 완료된 유저정보에 대헤 데이터베이스 변경을 시도하고 결과를 반환합니다.
  /// Cloud Function 벡엔드로 재설계 되어야 합니다.
  dynamic update() async {
    var result = false;
    if(id == '') return false;

    var db = FirebaseFirestore.instance;

    /// 메인경로 기록
    final docRef = db.collection("users").doc(id);

    await db.runTransaction((transaction) async {
      final docRefSn = await transaction.get(docRef);

      /// 메인경로 기초 저장경로
      if(docRefSn.exists) transaction.update(docRef, toJson());
      else transaction.set(docRef, toJson());

    }).then(
          (value) {
        print("DocumentSnapshot successfully updated!");
        result = true;
      },
      onError: (e) { print("Error updatePurchase() $e");
      result = false;
      },
    );

    return result;
  }


  /// 이 함수는 제거가 완료된 유저정보에 대해 데이터베이스 제거를 시도하고 결과를 반환합니다.
  /// Cloud Function 벡엔드로 재설계 되어야 헙니다.
  dynamic delete() async {

  }


  /// 이 함수는 해당 유저의 권한 정보를 반환합니다.
  /// 프런트 UI 제어를 위해 사용되는 함수입니다.
  /// 실제 권한 관리는 백엔드 코드에서 제어되도록 설계도었습니다.
  bool isPermissioned(String code) {
    if(permission.containsKey(code)) return permission[code];
    return false;
  }
}










/// 레거시 코드
/// 이 클래스는 더이상 사용되지 않습니다.
///
/// UserData 클래스로 마이그레이션 되었습니다.
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





/// 이 클래스는 유저정보에 대한 처리 클래스입니다.
class UserSystem {
  static UserT user = UserT.fromDatabase({});
  static UserData userData = UserData.fromDatabase({});

  /// 이 함수는 현재 접속중인 유저정보를 데이터베이스에서 요청합니다.
  /// 이 과정은 반드시 동기로 이루어져야 합니다.
  static dynamic init() async {
    CollectionReference coll = await FirebaseFirestore.instance.collection('users');
    if(FirebaseAuth.instance.currentUser == null) return;

    await coll.doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
      if(!value.exists) return;
      if(value.data() == null) return;
      user = UserT.fromDatabase(value.data() as Map);
      userData = UserData.fromDatabase(value.data() as Map);
    });
    print(FirebaseAuth.instance.currentUser!.uid);
  }

  static dynamic updateUser(UserT user) async {
    if(FirebaseAuth.instance.currentUser == null) return;
    await FireStoreHub.docUpdate('users/${FirebaseAuth.instance.currentUser!.uid}', 'US.PATCH', user.toJson(),);
  }
}