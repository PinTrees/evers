import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/helper/style.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';
import '../Customer.dart';
import '../contract.dart';
import '../revenue.dart';
import '../system.dart';
import '../transaction.dart';
import '../widget/excel.dart';
import '../widget/list.dart';
import '../widget/text.dart';
import 'item.dart';




/// 품목 작업 이동 기록 데이터 클래스
///
/// @Create YM
/// @Update YM 23.04.10
/// @Version 1.1.0
class Balance {
  var startAt = 0;
  var lastAt = 0;

  /// 전체 잔고
  var allBalance = 0;

  /// 매입 매출 금액
  var puAmount = 0;
  var reAmount = 0;

  /// 금전 지출 수입 금액
  var puTsAmount = 0;
  var reTsAmount = 0;

  List<Purchase> purchaseList = [];
  List<Revenue> revenueList = [];
  List<TS> tsList = [];


  dynamic init({ int? startAt, int? lastAt }) async {
    if(startAt != null) this.startAt = startAt;
    if(lastAt != null) this.lastAt = lastAt;

    purchaseList = await DatabaseM.getPurchaseWithDate(this.startAt, this.lastAt);
    revenueList = await DatabaseM.getRevenue(startDate: this.startAt, lastDate: this.lastAt);
    tsList = await DatabaseM.getTransactionWithDate(this.startAt, this.lastAt);

    reAmount = 0;
    puAmount = 0;

    purchaseList.forEach((pu) {
      pu.init();
      puAmount += pu.totalPrice;
    });

    revenueList.forEach((re) {
      re.init();
      reAmount += re.totalPrice;
    });

    puTsAmount = 0;
    reTsAmount = 0;

    tsList.forEach((ts) {
      if(ts.type == "PU") puTsAmount += ts.amount;
      else if(ts.type == "RE") reTsAmount += ts.amount;
    });

    allBalance = 0;
    Map<String, int> account = {};

    for(var a in SystemT.accounts.values) {
      var amount = await DatabaseM.getAmountAccount(a.id,);
      Account acc = SystemT.getAccount(a.id) ?? Account.fromDatabase({});
      account[a.id] = amount + acc.balanceStartAt;
    }
    account.forEach((key, value) { allBalance += value; });
  }
  int getLastBalance() {
    return allBalance + (reTsAmount - puTsAmount);
  }
}