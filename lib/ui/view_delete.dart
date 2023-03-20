import 'dart:convert';
import 'dart:ui';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/dialog_revenue.dart';
import 'package:evers/ui/dialog_transration.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../class/Customer.dart';
import '../class/contract.dart';
import '../class/purchase.dart';
import '../class/revenue.dart';
import '../class/schedule.dart';
import '../class/system.dart';
import '../class/transaction.dart';
import '../helper/dialog.dart';
import '../helper/firebaseCore.dart';
import '../helper/interfaceUI.dart';
import '../helper/pdfx.dart';
import 'cs.dart';
import 'dialog_contract.dart';
import 'dl.dart';
import 'package:http/http.dart' as http;

import 'ux.dart';

class View_Delete extends StatelessWidget {
  TextEditingController searchInput = TextEditingController();
  var st_sc_vt = ScrollController();
  var st_sc_hr = ScrollController();
  var divideHeight = 6.0;

  List<Revenue> rev_list = [];
  List<Purchase> pur_list = [];
  List<Customer> cs_list = [];

  bool sort = false;

  var rpmenuRp = [ '매입만', '매출만' ], rpmenuDt = [ '최근 1주일', '최근 1개월', '최근 3개월' ];
  var crRpmenuRp = '', crRrpmenuDt = '';
  DateTime rpStartAt = DateTime.now();
  DateTime rpLastAt = DateTime.now();

  dynamic init() async {

  }
  String menu = '';

  void clear() {
    cs_list.clear();
  }
  void search(String search) async {
    FunT.setStateMain();
  }

  var menuStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.15), );
  var menuSelectStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.35), );
  var menuPadding = EdgeInsets.fromLTRB(6 * 4, 6 * 1, 6 * 4, 6 * 1);

  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget,  }) async {
    WidgetT.loadingBottomSheet(context!,);

    if(this.menu != menu) {
      sort = false; searchInput.text = '';
    }
    this.menu = menu;

    if(pur_list.isEmpty) {
      pur_list = await FireStoreT.getPurchaseDelete();
    }
    if(rev_list.isEmpty) {
      rev_list = await FireStoreT.getRevDelete();
    }
    if(cs_list.isEmpty) {
      cs_list = await FireStoreT.getCustomerDelete();
    }

    List<Widget> childrenW = [];

    childrenW.add(WidgetT.title('매입 삭제 목록', size: 18));
    childrenW.add(SizedBox(height: divideHeight,));
    for(var pur in pur_list) {
      var w = InkWell(
        onTap: () {

        },
        child: Container(
          height: 36,
          child: Row(
            children: [
              WidgetT.excelGrid(text: pur.item, width: 200),
            ],
          ),
        ),
      );
      childrenW.add(w);
      childrenW.add(WidgetT.dividHorizontal(size: 0.35));
    }
    childrenW.add(InkWell(
      onTap: () async {
        var data = await FireStoreT.getPurchaseDelete(startAt: pur_list.last.id);
        pur_list.addAll(data);
      },
      child: Container(
        height: 36,
        child: Row(
          children: [
            WidgetT.iconMini(Icons.add_box),
            WidgetT.title('더보기'),
          ],
        ),
      ),
    ),);

    childrenW.add(SizedBox(height: divideHeight * 8,));

    childrenW.add(WidgetT.title('매출 삭제 목록', size: 18));
    childrenW.add(SizedBox(height: divideHeight,));
    for(var rev in rev_list) {
      var w = InkWell(
        onTap: () {

        },
        child: Container(
          height: 36,
          child: Row(
            children: [
              WidgetT.excelGrid(text: rev.item, width: 200),
            ],
          ),
        ),
      );
      childrenW.add(w);
      childrenW.add(WidgetT.dividHorizontal(size: 0.35));
    }
    childrenW.add(InkWell(
      onTap: () async {
        var data = await FireStoreT.getRevDelete(startAt: rev_list.last.id);
        rev_list.addAll(data);
      },
      child: Container(
        height: 36,
        child: Row(
          children: [
            WidgetT.iconMini(Icons.add_box),
            WidgetT.title('더보기'),
          ],
        ),
      ),
    ),);

    childrenW.add(SizedBox(height: divideHeight * 8,));

    childrenW.add(WidgetT.title('거래처 삭제 목록', size: 18));
    childrenW.add(SizedBox(height: divideHeight,));
    for(var cs in cs_list) {
      var w = InkWell(
        onTap: () {

        },
        child: Container(
          height: 36,
          child: Row(
            children: [
              WidgetT.excelGrid(text: cs.businessName, width: 200),
              Expanded(child: SizedBox()),
              InkWell(
                onTap: () async {
                  WidgetT.loadingBottomSheet(context, text: '매입 삭제중');
                  var dataList = await FireStoreT.getPur_withCS(cs.id);

                  for(var data in dataList) {
                    print(data.toJson());
                    await FireStoreT.deletePu(data);
                  }

                  Navigator.pop(context);
                  WidgetT.showSnackBar(context, text: '삭제됨');
                },
                child: Row(
                  children: [
                    WidgetT.iconMini(Icons.delete, size: 36),
                    WidgetT.text('매입'),
                    SizedBox(width: divideHeight,),
                  ],
                ),
              ),
              InkWell(
                onTap: () async {

                  var data = await FireStoreT.getPur_withCS(cs.id);
                  print(data);
                },
                child: Row(
                  children: [
                    WidgetT.iconMini(Icons.delete, size: 36),
                    WidgetT.text('매출'),
                    SizedBox(width: divideHeight,),
                  ],
                ),
              ),
              InkWell(
                onTap: () async {


                  if(!await DialogT.showAlertDl(context, text: '수납정보를 삭제하시겠습니까?')) {
                    WidgetT.showSnackBar(context, text: '삭제 취소됨');
                    return;
                  }

                  WidgetT.loadingBottomSheet(context, text: '삭제중');
                  var dataList = await FireStoreT.getTransactionCs(cs.id);

                  var ret = true;
                  for(TS data in dataList) {
                     var a = await data.delete();
                     if(!a) ret = a;
                  }

                  Navigator.pop(context);

                  if(ret) WidgetT.showSnackBar(context, text: '삭제됨');
                  else WidgetT.showSnackBar(context, text: '하나 이상의 수납정보를 삭제하는데 실패했습니다. 관리자에 문의하세요.');
                },
                child: Row(
                  children: [
                    WidgetT.iconMini(Icons.delete, size: 36),
                    WidgetT.text('수납'),
                    SizedBox(width: divideHeight,),
                  ],
                ),
              ),
              SizedBox(width: divideHeight,),
            ],
          ),
        ),
      );
      childrenW.add(w);
      childrenW.add(WidgetT.dividHorizontal(size: 0.35));
    }
    childrenW.add(InkWell(
      onTap: () async {
        //var data = await FireStoreT.getRevDelete(startAt: rev_list.last.id);
        //rev_list.addAll(data);
      },
      child: Container(
        height: 36,
        child: Row(
          children: [
            WidgetT.iconMini(Icons.add_box),
            WidgetT.title('더보기'),
          ],
        ),
      ),
    ),);

    var main = Column(
      children: [
        if(topWidget != null) topWidget,
        Expanded(
          child: Row(
            children: [
              if(infoWidget != null) infoWidget,
              Expanded(
                child: Column(
                  children: [
                    WidgetT.dividHorizontal(size: 0.7),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(12),
                        children: [
                          SizedBox(height: divideHeight,),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: childrenW,),
                          SizedBox(height: 18,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
    Navigator.pop(context!);
    return main;
  }

  Widget build(context) {
    return Container();
  }
}
