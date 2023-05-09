
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/system.dart';
import 'package:evers/class/transaction.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/dialog/dialog_itemInventory.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/ui/dialog_pu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helper/aes.dart';
import '../helper/interfaceUI.dart';
import '../helper/pdfx.dart';
import '../helper/style.dart';
import '../ui/dialog_revenue.dart';
import '../ui/ux.dart';
import 'Customer.dart';
import 'contract.dart';
import 'database/item.dart';
import 'package:http/http.dart' as http;


class Purchase {
  var state = '';

  var fixedVat = false;
  var fixedSup = false;

  var csUid = '';
  var ctUid = '';
  var id = '';
  var item = '';

  var count = 0;
  var unitPrice = 0;
  var supplyPrice = 0;
  var vatType = 0;        /// 0 포함, 1 미포함
  var vat = 0;
  var totalPrice = 0;
  var paymentAt = 0;
  var purchaseAt = 0;
  var updateAt = 0;

  var isItemTs = false;

  var memo = '';
  var filesMap = {};

  Purchase.fromDatabase(Map<dynamic, dynamic> json) {
    state = json['state'] ?? '';
    id = json['id'] ?? '';
    vatType = json['vatType'] ?? 0;
    ctUid = json['ctUid'] ?? '';
    csUid = json['csUid'] ?? '';
    item = json['item'] ?? '';
    count = json['count'] ?? 0;
    unitPrice = json['unitPrice'] ?? 0;
    supplyPrice = json['supplyPrice'] ?? 0;
    //vat = json['vat'] ?? 0;
    totalPrice = json['totalPrice'] ?? 0;
    paymentAt = json['paymentAt'] ?? 0;
    purchaseAt = json['purchaseAt'] ?? 0;
    updateAt = json['updateAt'] ?? 0;

    memo = json['memo'] ?? '';
    filesMap = (json['filesMap'] == null) ? {} : json['filesMap'] as Map;

    fixedVat = json['fixedVat'] ?? false;
    fixedSup = json['fixedSup'] ?? false;
    isItemTs = json['isItemTs'] ?? false;
    init();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state,
      'vatType': vatType,
      'item': item,
      'ctUid': ctUid,
      'csUid': csUid,
      'count': count,
      'unitPrice': unitPrice,
      'supplyPrice': supplyPrice,
      //'vat': vat,
      'totalPrice': totalPrice,
      'paymentAt': paymentAt,
      'purchaseAt': purchaseAt,
      'updateAt': updateAt,

      'memo': memo,
      'fixedVat': fixedVat,
      'fixedSup': fixedSup,
      'isItemTs': isItemTs,
      'filesMap': filesMap as Map,
    };
  }

  Future<String> getSearchText() async {
    var cs = (await SystemT.getCS(csUid)) ?? Customer.fromDatabase({});
    var ct = (await SystemT.getCt(ctUid)) ?? Contract.fromDatabase({});
    var it = SystemT.getItemName(item);

    var date = '';
    try {
      date = purchaseAt.toString().substring(0, 8);
    } catch (e) {
      date = '';
    }

    // 03.08 요청사항 추후 반영
    // 거래처 대표자명 검색 텍스트에 추가 - 데이터베이스 구조 변경
    return cs.businessName + '&:' + ct.ctName + '&:' + it.toString() + '&:' + memo + '&:' + date;
  }

  int getSupplyPrice() {
    var a = count * unitPrice - vat;
    return a;
  }
  int init() {
    if(!fixedSup && !fixedVat) {
      if(vatType == 0) { totalPrice = unitPrice * count;  vat = (totalPrice / 11).round(); supplyPrice = totalPrice - vat; }
      if(vatType == 1) { vat = ((unitPrice * count) / 10).round(); totalPrice = unitPrice * count + vat;  supplyPrice = unitPrice * count; }
    }
    else if(fixedSup && fixedVat) {
      if(vatType == 0) { totalPrice = supplyPrice + vat; }
      if(vatType == 1) { totalPrice = supplyPrice + vat; }
    }
    else if(fixedVat) {
      // 부가세가 변경될 경우 데이터를 보장할 수 없음
      if(vatType == 0) { supplyPrice = unitPrice * count - vat;   totalPrice = supplyPrice + vat; }
      if(vatType == 1) { totalPrice = unitPrice * count + ((unitPrice * count) / 10).round();  supplyPrice = totalPrice - vat;   }
    } else if(fixedSup) {
      // 공급가액이 변경될 경우 데이터를 보장할 수 없음 - 공식 수정 필요
      if(vatType == 0) { vat = unitPrice * count - supplyPrice;     totalPrice = supplyPrice + vat; }
      if(vatType == 1) { vat = ((unitPrice * count) / 10).round();  totalPrice = unitPrice * count + vat;   vat = totalPrice - supplyPrice;  }
    }
    return totalPrice;
  }



  dynamic getHistory() async {
    List<Purchase> history = [];
   /* await FirebaseFirestore.instance.collection('purchase/${id}/history').in.get().then((value) {
      if(value.docs == null) return;
      print(value.docs.length);

      *//*for(var a in value.docs) {
        if(a.data() == null) continue;
        var map = a.data() as Map;

        var ts = ItemTS.fromDatabase(map);
        ts.id = a.id;
        itemTs_list.add(ts);
      }*//*
    });*/
    return history;
  }

  dynamic createUid() async {
    var dateIdDay = DateStyle.dateYearMD(purchaseAt);
    var dateIdMonth = DateStyle.dateYearMM(purchaseAt);

    var db = FirebaseFirestore.instance;
    final refMeta = db.collection('meta/uid/dateM-purchase').doc(dateIdMonth);

    return await db.runTransaction((transaction) async {
      final snMeta = await transaction.get(refMeta);

      /// 개수는 100% 트랜잭션을 보장할 수 없음
      /// 고유한 형식만 보장
      /// 개수가 업데이트된 후 문서 저장에 실패할 경우 예외처리 안함
      if(snMeta.exists) {
        if((snMeta.data() as Map)[dateIdDay] != null) {
          var currentRevenueCount = (snMeta.data() as Map)[dateIdDay] as int;
          currentRevenueCount++;
          id = '$dateIdDay-$currentRevenueCount';
          transaction.update(refMeta, { dateIdDay: FieldValue.increment(1)});
        }
        else {
          id = '$dateIdDay-1';
          transaction.update(refMeta, { dateIdDay: 1});
        }
      } else {
        id = '$dateIdDay-1';
        transaction.set(refMeta, { dateIdDay: 1 });
      }
    }).then(
            (value) { print("meta/date-M/purchase UID successfully updated createUid!"); return true; },
        onError: (e) { print("Error createUid() $e"); return false; }
    );
  }

  Future<bool> update({ Map<String, Uint8List>? files, ItemTS? itemTs}) async {
    var create = false;
    var result = false;

    if(id == '') { await createUid(); create = true; }
    if(id == '') return result;

    updateAt = DateTime.now().microsecondsSinceEpoch;

    Purchase? org;
    if(!create) {
      org = await DatabaseM.getPurchaseDoc(id);
      if(org != null) org!.id = SystemT.generateRandomString(16);
    }

    var orgHistoryDate = 0;
    var orgDateId = '-';
    var orgDateQuarterId = '-';
    var orgDateIdHarp = '-';
    if(org != null) {
      orgHistoryDate = org.updateAt == 0 ? org.purchaseAt : org.updateAt;
      orgDateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(org.purchaseAt));
      orgDateQuarterId = DateStyle.dateYearsQuarter(org.purchaseAt);
      orgDateIdHarp = DateStyle.dateYearsHarp(org.purchaseAt);
    }

    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(purchaseAt));
    var dateIdHarp = DateStyle.dateYearsHarp(purchaseAt);
    var dateIdQuarter = DateStyle.dateYearsQuarter(purchaseAt);
    var searchText = await getSearchText();

    /// 거래명세서 파일 업로드
    if(files != null) {
      try {
        for(int i = 0; i < files.length; i++) {
          var f = files.values.elementAt(i);
          var k = files.keys.elementAt(i);

          if(filesMap[k] != null) continue;

          final mountainImagesRef = FirebaseStorage.instance.ref().child("purchase/${id}/${k}");
          await mountainImagesRef.putData(f);
          var url = await mountainImagesRef.getDownloadURL();
          if(url == null) {
            print('pur file upload failed');
            continue;
          }

          filesMap[k] = url;
        }
      } catch (e) {
        print(e);
      }
    }

    var db = FirebaseFirestore.instance;
    /// 메인문서 기록
    final docRef = db.collection("purchase").doc(id);
    /// 이전기록 히스토리 문서경로
    final docHistoryRef = (org != null) ? docRef.collection("history").doc(orgHistoryDate.toString()) : null;
    /// 월별 매입기록 읽기 효율화
    final dateRef = db.collection('meta/date-m/purchase').doc(dateId);
    final orgDateRef = db.collection('meta/date-m/purchase').doc(orgDateId);
    /// 거래처 총매입 개수 읽기 효율화
    final csRef = db.collection('customer').doc(csUid);
    /// 거래처 매입문서 읽기 효율화
    final csDetailRef = db.collection('customer/${csUid}/cs-dateH-purchase').doc(dateIdHarp);
    final orgCsDetailRef = db.collection('customer/${csUid}/cs-dateH-purchase').doc(orgDateIdHarp);
    /// 검색 기록 문서 경로로
    final searchRef = db.collection('meta/search/dateQ-purchase').doc(dateIdQuarter);
    final orgSearchRef = db.collection('meta/search/dateQ-purchase').doc(orgDateQuarterId);
    final itemInvenRef = db.collection('meta/itemInven/${item}').doc(dateIdQuarter);

    var itemRef = null;
    if(isItemTs) {
      if(itemTs == null) {
        itemTs = await DatabaseM.getItemTrans(id);
        if(itemTs != null) itemTs.fromPu(this);
        else itemTs = ItemTS.fromPu(this);
      }
      itemRef = db.collection('transaction-items').doc(id);
    }

    await db.runTransaction((transaction) async {
      final docRefSn = await transaction.get(docRef);
      final docHistorySn = docHistoryRef != null ? await transaction.get(docHistoryRef) : null;
      final dateRefSn = await transaction.get(dateRef);
      final orgDateRefSn = await transaction.get(orgDateRef);
      final csDetailRefSn = await transaction.get(csDetailRef);
      final searchRefSn = await transaction.get(searchRef);
      final orgSearchSn = await transaction.get(orgSearchRef);
      final orgCsDetailSn = await transaction.get(orgCsDetailRef);
      final itemInvenSn = await transaction.get(itemInvenRef);

      DocumentSnapshot<Map<String, dynamic>>? itemSn = null;
      if(itemRef != null) itemSn = await transaction.get(itemRef);


      if(org != null) {
        if(orgDateRefSn.exists && dateId != orgDateId && orgDateId != '-') {
          transaction.update(orgDateRef, {'list\.${org.id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});
        }
        if(orgSearchSn.exists && dateIdQuarter != orgDateQuarterId && orgDateQuarterId != '-') {
          transaction.update(orgSearchRef, {'list\.${org.id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});
        }
        if(orgCsDetailSn.exists && dateIdHarp != orgDateIdHarp && orgDateIdHarp != '-') {
          transaction.update(orgCsDetailRef, {'list\.${org.id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});
        }
      }

      /// 품목 UID 개별 메타데이터 하위 날짜분기 하위 거래목록으로 저장
      if(itemInvenSn.exists) transaction.update(itemInvenRef, { id: count.abs() });
      else transaction.set(itemInvenRef, { id: count.abs() });

      /// 품목 매입의 경우 매입 문서와 함께 추가
      if(itemSn != null) {
        if(itemSn!.exists) transaction.update(itemRef, itemTs!.toJson());
        else transaction.set(itemRef, itemTs!.toJson());
      }

      /// 과거 기록추가
      if(docHistorySn != null) {
        transaction.set(docHistoryRef!, org!.toJson());
      }

      /// 매입문서 기조 저장경로
      if(docRefSn.exists) {
        transaction.update(docRef, toJson());
      } else {
        transaction.set(docRef, toJson());
      }

      /// 추후 리스트내부 목록으로 저장이 아닌 필드값으로 변경
      if(dateRefSn.exists) {
        transaction.update(dateRef, {'list\.${id}': toJson(), 'updateAt': DateTime.now().microsecondsSinceEpoch,});
      } else {
        transaction.set(dateRef, {  'list': { id: toJson() }, 'updateAt': DateTime.now().microsecondsSinceEpoch, });
      }

      /// 추후 리스트내부 목록으로 저장이 아닌 필드값으로 변경
      /// 기존 모든 기록 마이그레이션 필요
      if(csDetailRefSn.exists) {
        transaction.update(csDetailRef, { 'list\.${id}': toJson(),  'updateAt': DateTime.now().microsecondsSinceEpoch, });
      } else {
        transaction.set(csDetailRef, { 'list': { id: toJson() }, 'updateAt': DateTime.now().microsecondsSinceEpoch, });
      }

      if(create) transaction.update(csRef, {'puCount': FieldValue.increment(1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});

      if(searchRefSn.exists) {
        transaction.update(searchRef, { 'list\.${id}': searchText, 'updateAt': DateTime.now().microsecondsSinceEpoch, },);
      } else {
        transaction.set(searchRef, { 'list' : { id : searchText },   'updateAt': DateTime.now().microsecondsSinceEpoch,  },);
      }
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
  dynamic delete() async {
    state = 'DEL';
    updateAt = DateTime.now().microsecondsSinceEpoch;
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(purchaseAt));
    var dateIdHarp = DateStyle.dateYearsHarp(purchaseAt);
    var dateIdQuarter = DateStyle.dateYearsQuarter(purchaseAt);
    var searchText = await getSearchText();

    ItemTS? itemTS = await DatabaseM.getItemTrans(id);
    itemTS!.state = "DEL";

    var db = FirebaseFirestore.instance;
    /// 메인문서 기록
    final docRef = db.collection("purchase").doc(id);
    /// 월별 매입기록 읽기 효율화
    final dateRef = db.collection('meta/date-m/purchase').doc(dateId);
    /// 거래처 총매입 개수 읽기 효율화
    final csRef = db.collection('customer').doc(csUid);
    /// 거래처 매입문서 읽기 효율화
    final csDetailRef = db.collection('customer/${csUid}/cs-dateH-purchase').doc(dateIdHarp);
    /// 검색 기록 문서 경로로
    final searchRef = db.collection('meta/search/dateQ-purchase').doc(dateIdQuarter);
    var itemRef = null;
    if(isItemTs) {
      itemRef = db.collection('transaction-items').doc(id);
    }
    db.runTransaction((transaction) async {
      final docRefSn = await transaction.get(docRef);
      final dateRefSn = await transaction.get(dateRef);
      final csDetailRefSn = await transaction.get(csDetailRef);
      final searchRefSn = await transaction.get(searchRef);
      DocumentSnapshot<Map<String, dynamic>>? itemSn = null;
      if(itemRef != null) itemSn = await transaction.get(itemRef);

      /// 품목 매입의 경우 매입 문서와 함께 추가
      if(itemSn != null) {
        if(itemSn!.exists) transaction.update(itemRef, itemTS!.toJson());
      }

      /// 매입문서 기조 저장경로
      if(docRefSn.exists) transaction.update(docRef, toJson());

      /// 추후 리스트내부 목록으로 저장이 아닌 필드값으로 변경
      if(dateRefSn.exists) transaction.update(dateRef, {'list\.${id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});

      /// 추후 리스트내부 목록으로 저장이 아닌 필드값으로 변경
      /// 기존 모든 기록 마이그레이션 필요
      if(csDetailRefSn.exists) transaction.update(csDetailRef, { 'list\.${id}': null,  'updateAt': DateTime.now().microsecondsSinceEpoch, });

      transaction.update(csRef, {'puCount': FieldValue.increment(-1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});

      if(searchRefSn.exists) transaction.update(searchRef, { 'list\.${id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch, },);
    }).then(
          (value) => print("DocumentSnapshot successfully updated!"),
      onError: (e) => print("Error updatePurchase() $e"),
    );
  }



  dynamic setUpdate() {
    var db = FirebaseFirestore.instance;
    final docRef = db.collection("purchase").doc(id);
    db.runTransaction((transaction) async {
      final docRefSn = await transaction.get(docRef);

      transaction.set(docRef, toJson());
    }).then(
          (value) => print("DocumentSnapshot successfully updated!"),
      onError: (e) => print("Error updatePurchase() $e"),
    );
  }

  static dynamic OnTabelHeader() {
    return WidgetUI.titleRowNone([ '순번', '매입일자', '품목', '단위', '수량', '단가', '공급가액', 'VAT', '합계', '메모', ],
        [ 28, 80, 999, 50, 80, 80, 80, 80, 80, 999 ], background: true, lite: true);
  }
  dynamic OnTableUI(BuildContext context, { Function? setState, int? index, String? itemName,
    Item? itemData,
    String? itemUnit,
    Map<String, Uint8List>? files,
    bool isInput = false,
  }) {
    var w = Column(
      children: [
        Container(
          height: 28,
          child: Row(
              children: [
                ExcelT.LitGrid(center: true, text: index == null ? "" : '${index}', width: 28),
                ExcelT.LitGrid(center: true, text: StyleT.dateInputFormatAtEpoch(purchaseAt.toString()), width: 80),
                ExcelT.LitGrid(center: true, text: itemName == null ? item : itemName == "" ? item : itemName, width: 200, expand: true),
                ExcelT.LitGrid(center: true, text: itemUnit, width: 50),
                ExcelT.LitGrid(center: true, width: 80, text: StyleT.krwInt(count),),
                ExcelT.LitGrid(center: true, width: 80, text: StyleT.krwInt(unitPrice),),
                ExcelT.LitGrid(center: true, width: 80, text: StyleT.krwInt(supplyPrice),),
                ExcelT.LitGrid(center: true, width: 80, text: StyleT.krwInt(vat),),
                ExcelT.LitGrid(center: true, width: 80, text: StyleT.krwInt(totalPrice),),
                ExcelT.LitGrid(center: true, width: 200, text: memo, expand: true),

                ButtonT.Icon(
                  icon: Icons.file_copy_rounded,
                  onTap: () async {
                    FilePickerResult? result;
                    try {
                      result = await FilePicker.platform.pickFiles();
                    } catch (e) {
                      WidgetT.showSnackBar(context, text: '파일선택 오류');
                      print(e);
                    }

                    if(result != null){
                      if(result.files.isNotEmpty) {
                        WidgetT.loadingBottomSheet(context, text: '거래명세서 파일을 시스템에 업로드 중입니다.');
                        String fileName = result.files.first.name;
                        print(fileName);
                        Uint8List fileBytes = result.files.first.bytes!;
                        await DatabaseM.updatePurchase(this, files: { fileName: fileBytes });
                        Navigator.pop(context);
                      }
                    }
                    if(setState != null) setState();
                  },
                ),
                InkWell(
                  onTap: () async {
                    Purchase? tmpPu = await DialogPU.showInfoPu(context, org: this);
                    if(setState != null) setState();
                  },
                  child: WidgetT.iconMini(Icons.create, size: 36),
                ),
                isItemTs ? ButtonT.IconText(
                  icon: Icons.account_tree,
                  text: '품목확인',
                  color: Colors.transparent,
                  onTap: () async {
                    var itemTs = await DatabaseM.getItemTrans(id);
                    if(itemTs == null) return;

                    var result = await DialogItemInven.showInfo(context, org: itemTs);
                    if(result == null) {}
                    else {}

                    if(setState != null) setState();
                  },
                )
                : SizedBox(),
              ]
          ),
        ),
        if(filesMap.isNotEmpty)
          Container(
            height: 32,
            padding: EdgeInsets.only(left: 6, bottom: 6),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Container(
                        child: Wrap(
                          runSpacing: 6 * 2, spacing: 6 * 2,
                          children: [
                            for(int i = 0; i < filesMap.length; i++)
                              InkWell(
                                  onTap: () async {
                                    var downloadUrl = filesMap.values.elementAt(i);
                                    var fileName = filesMap.keys.elementAt(i);

                                    var ens = ENAES.fUrlAES(downloadUrl);

                                    var url = Uri.base.toString().split('/work').first + '/pdfview/$ens/$fileName';
                                    print(url);
                                    await launchUrl( Uri.parse(url),
                                      webOnlyWindowName: true ? '_blank' : '_self',
                                    );
                                  },
                                  child: Container(
                                      color: Colors.grey.withOpacity(0.15),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          WidgetT.iconMini(Icons.cloud_done, size: 24),
                                          WidgetT.text(filesMap.keys.elementAt(i), size: 10),
                                          SizedBox(width: 6,)
                                        ],
                                      ))
                              ),
                          ],
                        ),)),
                ]
            ),
          ),
      ],
    );
    if(isInput && files != null) {
      w = Column(
        children: [
          Container(
            height: 28,
            child: Row(
                children: [
                  ExcelT.LitGrid(text: '${index ?? '-' }', width: 28),
                  ExcelT.LitInput(context, '${index ?? '-'}::매출일자', width: 100, index: index,
                    onEdited: (i, data) {
                      purchaseAt = StyleT.dateEpoch(data);
                    }, setState: setState,
                    text: StyleT.dateInputFormatAtEpoch(purchaseAt.toString()),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        ExcelT.LitInput(context, '${index ?? '-'}::품목', width: 200 - 28, index: index,
                          onEdited: (i, data) {
                            var item = SystemT.getItem(this.item);
                            if (item == null) { this.item = data; return; }
                            if (item.name == data) { return; }
                            this.item = data;
                          }, setState: setState,
                          expand: true,
                          text: SystemT.getItemName(this.item), value: SystemT.getItemName(this.item),
                        ),
                        SizedBox(
                          height: 28, width: 28,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              focusColor: Colors.transparent,
                              focusNode: FocusNode(),
                              autofocus: false,
                              customButton: WidgetT.iconMini(Icons.arrow_drop_down_circle_sharp),
                              items: SystemT.itemMaps.keys.map((item) => DropdownMenuItem<dynamic>(
                                value: item,
                                child: Text(
                                  SystemT.getItemName(item),
                                  style: StyleT.titleStyle(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )).toList(),
                              onChanged: (value) async {
                                var item = SystemT.getItem(value);
                                if(item != null) {
                                  this.item = item.id;
                                  unitPrice = item.unitPrice;
                                }
                                print('select item uid: ' + value);
                                if(setState != null) await setState();
                              },
                              itemHeight: 24,
                              itemPadding: const EdgeInsets.only(left: 16, right: 16),
                              dropdownWidth: 256.7,
                              dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
                              dropdownDecoration: BoxDecoration(
                                border: Border.all(
                                  width: 1.7,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                borderRadius: BorderRadius.circular(0),
                                color: Colors.white.withOpacity(0.95),
                              ),
                              dropdownElevation: 0,
                              offset: const Offset(-256 + 28, 0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ExcelT.LitGrid(text: itemUnit ?? '-', width: 50, center: true),
                  ExcelT.LitInput(context, '${index ?? '-'}::수량', width: 80, index: index,
                    onEdited: (i, data) {
                      count = int.tryParse(data) ?? 0;
                    }, setState: setState,
                      text: StyleT.krw(count.toString()), value: count.toString()
                  ),
                  ExcelT.LitInput(context, '${index ?? '-'}::단가', width: 80, index: index,
                      onEdited: (i, data) {
                        unitPrice = int.tryParse(data) ?? 0;
                      }, setState: setState,
                      text: StyleT.krwInt(unitPrice), value: unitPrice.toString()
                  ),
                  ExcelT.LitInput(context, '${index ?? '-'}::pu.supplyPrice', width: 80, index: index,
                    setState: setState,
                    onEdited: (i, data) {
                      supplyPrice = int.tryParse(data) ?? 0;
                      fixedSup = true;
                    }, text: StyleT.krwInt(supplyPrice), value: supplyPrice.toString(),
                  ),
                  ExcelT.LitInput(context, '${index ?? '-'}::pu.vat', width: 80, index: index,
                    setState: setState,
                    onEdited: (i, data) {
                      vat = int.tryParse(data) ?? 0;
                      fixedVat = true;
                    }, text: StyleT.krwInt(vat), value: vat.toString(),
                  ),

                  ExcelT.LitGrid(text: StyleT.krw(totalPrice.toString()), width: 80, center: true),
                  ExcelT.LitInput(context, '${index ?? '-'}::메모', width: 200, index: index,
                    setState: setState,
                    onEdited: (i, data) { memo  = data ?? ''; }, text: memo,
                    expand: true,
                  ),
                  InkWell(
                      onTap: () async {
                        state = "DEL";
                        if(setState != null) await setState();
                      },
                      child: Container( height: 28, width: 28,
                        child: WidgetT.iconMini(Icons.cancel),)
                  ),
                ]
            ),
          ),
          if(filesMap.length > 0 || files.length > 0)
            Container( height: 28,
              child: Row(
                  children: [
                    WidgetT.excelGrid( width: 150, label: '거래명세서 첨부파일', ),
                    Expanded(child: Container( padding: EdgeInsets.all(0),  child: Wrap(
                      runSpacing: 6 * 2, spacing: 6 * 2,
                      children: [
                        for(int i = 0; i < filesMap.length; i++)
                          InkWell(
                              onTap: () async {
                                var downloadUrl = filesMap.values.elementAt(i);
                                var fileName = filesMap.keys.elementAt(i);

                                var ens = ENAES.fUrlAES(downloadUrl);

                                var url = Uri.base.toString().split('/work').first + '/pdfview/$ens/$fileName';
                                print(url);
                                await launchUrl( Uri.parse(url),
                                  webOnlyWindowName: true ? '_blank' : '_self',
                                );
                              },
                              child: Container(
                                  color: Colors.grey.withOpacity(0.15),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.iconMini(Icons.cloud_done, size: 24),
                                      WidgetT.text(filesMap.keys.elementAt(i), size: 10),
                                      SizedBox(width: 6,)
                                    ],
                                  ))
                          ),
                        for(int i = 0; i < files.length; i++)
                          InkWell(
                              onTap: () async {
                                PDFX.showPDFtoDialog(context, data: files!.values.elementAt(i), name: files!.keys.elementAt(i));
                              },
                              child: Container(
                                  color: Colors.grey.withOpacity(0.15),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.iconMini(Icons.cloud_done, size: 24),
                                      WidgetT.text(files.keys.elementAt(i), size: 10),
                                      InkWell(
                                          onTap: () async {
                                            files.remove(files.keys.elementAt(i));
                                            if(setState != null) await setState();
                                           },
                                          child: Container( height: 28, width: 28,
                                            child: WidgetT.iconMini(Icons.cancel),)
                                      ),
                                    ],
                                  ))
                          ),
                      ],
                    ),)),
                  ]
              ),
            ),
          Container(
            height: 28,
            child: Row(
              children: [
                ButtonT.IconText(
                  icon: Icons.auto_mode,
                  text: '금액 자동계산',
                  color: Colors.transparent,
                  onTap: () async {
                    fixedVat = false;
                    fixedSup = false;
                    if(setState != null) await setState();
                  },
                ),
                ButtonT.IconText(
                  icon: Icons.file_copy_rounded,
                  text: '파일첨부',
                  color: Colors.transparent,
                  onTap: () async {
                    FilePickerResult? result;
                    try {
                      result = await FilePicker.platform.pickFiles();
                    } catch (e) {
                      WidgetT.showSnackBar(context, text: '파일선택 오류');
                      print(e);
                    }

                    if(result != null){
                      WidgetT.showSnackBar(context, text: '파일선택');
                      if(result.files.isNotEmpty) {
                        String fileName = result.files.first.name;
                        print(fileName);
                        Uint8List fileBytes = result.files.first.bytes!;
                        files[fileName] = fileBytes;
                        print(files[fileName]!.length);
                      }
                    }
                    if(setState != null) await setState();
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    return w;
  }
}
