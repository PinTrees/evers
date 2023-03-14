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

class View_CS extends StatelessWidget {
  TextEditingController searchInput = TextEditingController();
  var st_sc_vt = ScrollController();
  var st_sc_hr = ScrollController();
  var divideHeight = 6.0;
  List<RevPur> revpurs = [];

  List<Purchase> pur_list = [];
  List<Revenue> rev_list = [];

  List<Purchase> pur_sort_list = [];
  List<Revenue> rev__sort_list = [];

  List<TS> ts_list = [];
  List<TS> ts_sort_list = [];

  bool sort = false;

  var currentView = '매입';

  var rpmenuRp = [ '매입만', '매출만' ], rpmenuDt = [ '최근 1주일', '최근 1개월', '최근 3개월' ];
  var crRpmenuRp = '', crRrpmenuDt = '';
  DateTime rpStartAt = DateTime.now();
  DateTime rpLastAt = DateTime.now();

  dynamic init() async {
    revpurs = SystemT.revpur.toList();
  }
  String menu = '';

  void search(String search) async {
    if(search == '') {
      sort = false;
      FunT.setStateMain();
      return;
    }

    sort = true;

    if(menu == '매입매출관리') {
      if (currentView == '매입') {
        crRpmenuRp = ''; crRrpmenuDt = '';
        pur_sort_list = await SystemT.searchPuMeta(search,);
      }
      else if (currentView == '매출') {
        crRpmenuRp = ''; crRrpmenuDt = '';
        rev__sort_list = await SystemT.searchReMeta(search,);
      }
    }
    else if(menu == '수납관리') {
      ts_sort_list = await SystemT.searchTSMeta(searchInput.text,);
      //Algolia.contractSearch.query(searchInput.text);
    }

    FunT.setStateMain();
  }

  var menuStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.15), );
  var menuSelectStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.35), );
  var menuPadding = EdgeInsets.fromLTRB(6 * 4, 6 * 1, 6 * 4, 6 * 1);
  var disableTextColor = StyleT.titleColor.withOpacity(0.35);

  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget, bool refresh=false  }) async {
    if(this.menu != menu) {
      sort = false; searchInput.text = '';
    }
    if(refresh) {
      pur_list.clear();
      ts_list.clear();
    }

    this.menu = menu;

    Widget titleMenu = SizedBox();

    List<Widget> childrenW = [];
    if(menu == '매입매출관리') {
      childrenW.clear();
      titleMenu = Row(
        children: [
          InkWell(
            onTap: () async {
              currentView = '매입';
              await FunT.setStateMain();
            },
            child: Container(child: (currentView == '매입') ? WidgetT.title('매입 목록', size: 18) : WidgetT.text('매입 목록', size: 18, bold: true, color: disableTextColor)),
          ),
          Container(padding: EdgeInsets.all(divideHeight * 2), child: WidgetT.text('/', size: 12),),
          InkWell(
            onTap: () async {
              currentView = '매출';
              await FunT.setStateMain();
            },
            child: Container(child: (currentView == '매출') ? WidgetT.title('매출 목록', size: 18) : WidgetT.text('매출 목록', size: 18,  bold: true, color: disableTextColor)),
          ),
        ],
      );

      if(currentView == '매입') {
        if(pur_list.length < 1) pur_list = await FireStoreT.getPurchase();

        var data = sort ? pur_sort_list : pur_list;
        for(int i = 0; i < data.length; i++) {
          Purchase pu = data[i];

          Widget w = SizedBox();
          var cs = await SystemT.getCS(pu.csUid) ?? Customer.fromDatabase({});

          var item = SystemT.getItem(pu.item);
          var itemName = (item == null) ? pu.item : item!.name;

          w = InkWell(
            onTap: () async {
              await DialogCS.showPurInCs(context, cs);
            },
            child: Container(
              height: 36 + divideHeight,
              decoration: StyleT.inkStyleNone(color: Colors.transparent),
              child: Row(
                  children: [
                    WidgetT.excelGrid(label: '${i + 1}', width: 32),
                    WidgetT.excelGrid(textLite: true, text: StyleT.dateFormatAtEpoch(pu.purchaseAt.toString()), width: 100, ),
                    WidgetT.excelGrid(textLite: false,text: '매입', width: 80, textColor: Colors.redAccent.withOpacity(0.5) ),
                    WidgetT.excelGrid(textLite: true,text: '${cs.businessName}',  width: 200 + 28),
                    Expanded(child: WidgetT.excelGrid(textLite: false, width: 999, text: itemName,)),
                    WidgetT.excelGrid(textLite: true, text:item?.unit, width: 50),
                    WidgetT.excelGrid(textLite: true,width: 50,  text: StyleT.krw(pu.count.toString()),),
                    WidgetT.excelGrid(textLite: true,width: 100,  text: StyleT.krw(pu.unitPrice.toString()),),
                    WidgetT.excelGrid(textLite: true,width: 100,  text: StyleT.krw(pu.supplyPrice.toString()),),
                    WidgetT.excelGrid(textLite: true,width: 100,  text: StyleT.krw(pu.vat.toString()), ),
                    WidgetT.excelGrid(textLite: true,width: 100, text: StyleT.krw(pu.totalPrice.toString()),),
                    if(pu.filesMap.length > 0)
                      WidgetT.iconMini(Icons.file_copy_rounded, size: 32),
                    if(pu.filesMap.length == 0)
                      SizedBox(height: 28,width: 28,),
                    InkWell(
                      onTap: () async {
                        await DialogRE.showInfoPu(context, org: pu);
                      },
                      child: WidgetT.iconMini(Icons.create, size: 32),
                    ),
                    InkWell(
                      onTap: () async {
                        var aa = await DialogT.showAlertDl(context, text: '데이터를 삭제하시겠습니까?');
                        if(aa) {
                          await FireStoreT.deletePu(pu);
                          WidgetT.showSnackBar(context, text: '매입 데이터를 삭제했습니다.');
                        }
                      },
                      child: WidgetT.iconMini(Icons.delete, size: 32),
                    ),
                  ]
              ),
            ),
          );

          childrenW.add(w);
          childrenW.add(WidgetT.dividHorizontal(size: 0.35),);
        }

        if(!sort)
          childrenW.add(InkWell(
          onTap: () async {
            WidgetT.loadingBottomSheet(context, text: '로딩중');

            var list = await FireStoreT.getPurchase(startAt: pur_list.last.id);
            pur_list.addAll(list);

            Navigator.pop(context);
            await FunT.setStateMain();
          },
          child: Container(
            height: 36,
            child: Row(
              children: [
                WidgetT.iconMini(Icons.add_box, size: 36),
                WidgetT.title('더보기'),
              ],
            ),
          ),
        ));
      }
      else if(currentView == '매출') {
        if(rev_list.length < 1) rev_list = await FireStoreT.getRevenue();
        var data = sort ? rev__sort_list : rev_list;
        for(int i = 0; i < data.length; i++) {
          var rev = data[i];

          Widget w = SizedBox();
          var cs = await SystemT.getCS(rev.csUid) ?? Customer.fromDatabase({});
          var ct = await SystemT.getCt(rev.ctUid) ?? Contract.fromDatabase({});

          var item = SystemT.getItem(rev.item);
          var unitPrice = rev.unitPrice; // = item.unitPrice; //int.tryParse((ctl['unitPrice'] != '') ? ctl['unitPrice'] : item?.unitPrice.toString()) ?? 0;
          var itemName = (item == null) ? rev.item : item!.name;

          w = InkWell(
            onTap: () async {
              await DialogCT.showInfoCt(context, ct);
            },
            child: Container(
              height: 36 + divideHeight,
              decoration: StyleT.inkStyleNone(color: Colors.transparent),
              child: Row(
                  children: [
                    WidgetT.excelGrid(label: '${i + 1}', width: 32),
                    WidgetT.excelGrid(textLite: true, text: StyleT.dateFormatAtEpoch(rev.revenueAt.toString()), width: 100,),
                    WidgetT.excelGrid(textLite: false, text: '매출', width: 80, textColor: Colors.blueAccent.withOpacity(0.5)),
                    WidgetT.excelGrid(textLite: true, text: '${cs.businessName} / ${ct.ctName}',  width: 200),
                    InkWell(
                        onTap: () async {
                          await DialogCT.showInfoCt(context, ct);
                        },
                        child: WidgetT.iconMini(Icons.link, size: 28)
                    ),
                    Expanded(child: WidgetT.excelGrid( width: 999,  text: itemName,)),
                    WidgetT.excelGrid(textLite: true,  text:item?.unit, width: 50),
                    WidgetT.excelGrid(textLite: true, width: 50,text: StyleT.krw(rev.count.toString()),),
                    WidgetT.excelGrid(textLite: true, width: 100, text: StyleT.krw(rev.unitPrice.toString()),),
                    WidgetT.excelGrid(textLite: true, width: 100,  text: StyleT.krw(rev.supplyPrice.toString()),),
                    WidgetT.excelGrid(textLite: true,  width: 100,  text: StyleT.krw(rev.vat.toString()), ),
                    WidgetT.excelGrid(textLite: true, width: 100, text: StyleT.krw(rev.totalPrice.toString()),),
                    SizedBox(height: 28,width: 32,),
                    InkWell(
                      onTap: () async {
                        WidgetT.showSnackBar(context, text: '개발중인 기능');
                      },
                      child: WidgetT.iconMini(Icons.create, size: 32),
                    ),
                    InkWell(
                      onTap: () async {
                        var aa = await DialogT.showAlertDl(context, text: '데이터를 삭제하시겠습니까?');
                        if(aa) {
                          await FireStoreT.deleteRevenue(rev);
                          WidgetT.showSnackBar(context, text: '매출 데이터를 삭제했습니다.');
                        }
                      },
                      child: WidgetT.iconMini(Icons.delete, size: 32),
                    ),
                  ]
              ),
            ),
          );
          childrenW.add(w);
          childrenW.add(WidgetT.dividHorizontal(size: 0.35),);
        }

        if(!sort)
          childrenW.add(InkWell(
          onTap: () async {
            WidgetT.loadingBottomSheet(context, text: '로딩중');

            var list = await FireStoreT.getRevenue(startAt: rev_list.last.id);
            rev_list.addAll(list);

            Navigator.pop(context);
            await FunT.setStateMain();
          },
          child: Container(
            height: 36,
            child: Row(
              children: [
                WidgetT.iconMini(Icons.add_box, size: 36),
                WidgetT.title('더보기'),
              ],
            ),
          ),
        ));
      }
    }
    else if(menu == '수납관리') {
      childrenW.clear();
      titleMenu = Row(
        children: [
          WidgetT.title('수납 목록', size: 18),
          Container(padding: EdgeInsets.all(divideHeight * 2), child: WidgetT.text('(수납 목록)', size: 12),),
        ],
      );

      if(ts_list.length < 1) ts_list = await FireStoreT.getTransaction();

      var datas = sort ? ts_sort_list : ts_list;
      for(int i = 0; i < datas.length; i++) {
        var tmpTs = datas[i];
        Account? account = SystemT.getAccount(tmpTs.account);
        Widget w = SizedBox();

        w = InkWell(
          onTap: () async {
            await DialogTS.showInfoTs(context, org: tmpTs);
          },
          child: Container(
            height: 36 + divideHeight,
            decoration: StyleT.inkStyleNone(color: Colors.transparent),
            child: Row(
                children: [
                  WidgetT.excelGrid(label: '${i}', width: 32),
                  WidgetT.excelGrid(textLite: true, text: StyleT.dateFormatAtEpoch(tmpTs.transactionAt.toString()), width: 100, ),
                  WidgetT.excelGrid(textLite: true, text: '${SystemT.getCSName(tmpTs.csUid)}', width: 200,),
                  Expanded(child: WidgetT.excelGrid(textLite: false, text: tmpTs.summary, width: 999,)),
                  WidgetT.excelGrid(text: (tmpTs.type != 'PU') ? StyleT.krwInt(tmpTs.amount) : '', width: 100,
                      textColor: (tmpTs.type != 'PU') ? Colors.blue.withOpacity(1) : null),
                  WidgetT.excelGrid(text: (tmpTs.type != 'RE') ? StyleT.krwInt(tmpTs.amount) : '', width: 100,
                      textColor: (tmpTs.type != 'RE') ? Colors.red.withOpacity(1) : null),
                  WidgetT.excelGrid(textLite: true, text: SystemT.getAccountName(tmpTs.account), width: 200, ),
                  Expanded(child: WidgetT.excelGrid(textLite: true, text: tmpTs.memo, width: 999,)),
                  InkWell(
                      onTap: () {

                      },
                      child: WidgetT.iconMini(Icons.open_in_new, size: 36),
                  ),
                  WidgetEX.excelButtonIcon(icon: Icons.delete, onTap: () async {
                    var aa = await DialogT.showAlertDl(context, text: '데이터를 삭제하시겠습니까?');
                    if(aa) {
                      await FireStoreT.deleteTs(tmpTs);
                      WidgetT.showSnackBar(context, text: '거래 데이터를 삭제했습니다.');
                    }
                  }),
                ]
            ),
          ),
        );
        childrenW.add(w);
        childrenW.add(WidgetT.dividHorizontal(size: 0.35));
      }

      if(!sort)
        childrenW.add(InkWell(
          onTap: () async {
            WidgetT.loadingBottomSheet(context, text: '로딩중');

            var list = await FireStoreT.getTransaction(startAt: ts_list.last.id);
            ts_list.addAll(list);

            Navigator.pop(context);
            await FunT.setStateMain();
          },
          child: Container(
            height: 36,
            child: Row(
              children: [
                WidgetT.iconMini(Icons.add_box, size: 36),
                WidgetT.title('더보기'),
              ],
            ),
          ),
        ));
    }

    Widget searchMenuW = SizedBox();
    if(menu == '매입매출관리') {
      searchMenuW = Material(
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              TextButton(
                onPressed: () async {
                  WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
                },
                style: menuStyle,
                child: Container( height: 32, padding:menuPadding,
                  child:WidgetT.text('매입만', size: 12),),),
              SizedBox(width: divideHeight * 2,),
              TextButton(
                onPressed: () async {
                  WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
                },
                style: menuStyle,
                child: Container( height: 32,  padding:menuPadding,
                  child:WidgetT.text('매출만', size: 12),),),

              SizedBox(width: divideHeight * 4,),
              WidgetT.dividViertical(height: 32),
              SizedBox(width: divideHeight * 4,),

              for(var m in rpmenuDt)
                Container( padding: EdgeInsets.only(right: divideHeight * 2 ),
                  child: TextButton(
                    onPressed: () async {
                      if(crRrpmenuDt == m) return;
                      crRrpmenuDt = m;

                      sort = true;
                      revpurs.clear();
                      rpLastAt = DateTime.now();
                      if(crRrpmenuDt == rpmenuDt[0]) {
                        rpStartAt = DateTime.now().add(const Duration(days: -7));
                      }
                      else if(crRrpmenuDt == rpmenuDt[1]) {
                        rpStartAt = DateTime.now().add(const Duration(days: -30));
                      }
                      else if(crRrpmenuDt == rpmenuDt[2]) {
                        rpStartAt = DateTime.now().add(const Duration(days: -90));
                      }

                      List<Purchase> pur = await FireStoreT.getPurchaseWithDate(rpStartAt.microsecondsSinceEpoch, rpLastAt.microsecondsSinceEpoch);
                      List<Revenue> rev = await FireStoreT.getReWithDate(rpStartAt.microsecondsSinceEpoch, rpLastAt.microsecondsSinceEpoch);
                      for(var p in pur) revpurs.add(RevPur.fromDatabase(pu: p));
                      for(var r in rev) revpurs.add(RevPur.fromDatabase(re: r));
                      revpurs.sort((a, b) {
                        if(a.dateAt < b.dateAt) return 1;
                        if(a.dateAt > b.dateAt) return -1;
                        else return 0;
                      });

                      FunT.setStateMain();
                    },
                    style: (crRrpmenuDt == m) ? menuSelectStyle : menuStyle,
                    child: Container( height: 32,  padding:menuPadding,
                      child:WidgetT.text(m, size: 12),),),
                ),

              SizedBox(width: divideHeight * 2,),
              WidgetT.text('직접선택'),
              SizedBox(width: divideHeight * 2,),
              TextButton(
                onPressed: () async {
                  var selectedDate = await showDatePicker(
                    context: context,
                    initialDate: rpStartAt, // 초깃값
                    firstDate: DateTime(2018), // 시작일
                    lastDate: DateTime(2030), // 마지막일
                  );
                  if(selectedDate != null) {
                    if (selectedDate.microsecondsSinceEpoch < rpLastAt.microsecondsSinceEpoch) rpStartAt = selectedDate;
                    crRrpmenuDt = '';
                  }
                  FunT.setStateMain();
                },
                style: (crRrpmenuDt == 'CST') ? menuSelectStyle : menuStyle,
                child: Container( height: 32, padding: menuPadding,
                  child: WidgetT.text(StyleT.dateFormat(rpStartAt),),),),
              SizedBox(width: divideHeight * 2,),
              WidgetT.text('~', ),
              SizedBox(width: divideHeight * 2,),
              TextButton(
                onPressed: () async {
                  var selectedDate = await showDatePicker(
                    context: context,
                    initialDate: rpLastAt, // 초깃값
                    firstDate: DateTime(2018), // 시작일
                    lastDate: DateTime(2030), // 마지막일
                  );
                  if(selectedDate != null) {
                    rpLastAt = selectedDate;
                    crRrpmenuDt = '';
                  }
                  FunT.setStateMain();
                },
                style: (crRrpmenuDt == 'CST') ? menuSelectStyle : menuStyle,
                child: Container( height: 32, padding: menuPadding,
                  child: WidgetT.text(StyleT.dateFormat(rpLastAt),),
                ),
              ),
              SizedBox(width: divideHeight * 2,),
              TextButton(
                onPressed: () async {
                  crRpmenuRp = '';
                  crRrpmenuDt = 'CST';

                  revpurs.clear();
                  List<Purchase> pur = await FireStoreT.getPurchaseWithDate(rpStartAt.microsecondsSinceEpoch, rpLastAt.microsecondsSinceEpoch);
                  List<Revenue> rev = await FireStoreT.getReWithDate(rpStartAt.microsecondsSinceEpoch, rpLastAt.microsecondsSinceEpoch);
                  for(var p in pur) revpurs.add(RevPur.fromDatabase(pu: p));
                  for(var r in rev) revpurs.add(RevPur.fromDatabase(re: r));
                  revpurs.sort((a, b) {
                    if(a.dateAt < b.dateAt) return 1;
                    if(a.dateAt > b.dateAt) return -1;
                    else return 0;
                  });

                  sort = true;
                  FunT.setStateMain();
                },
                style: StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.15), ),
                child: Container( height: 32, width: 32,
                  child: WidgetT.iconMini(Icons.search),
                ),
              ),
              SizedBox(width: divideHeight * 2,),
              TextButton(
                onPressed: () async {
                  crRpmenuRp = '';
                  crRrpmenuDt = '';
                  sort = false;
                  FunT.setStateMain();
                },
                style: StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.redAccent.withOpacity(0.15), ),
                child: Container( height: 32, width: 32,
                  child: WidgetT.iconMini(Icons.close),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                    WidgetT.searchBar(search: search, controller: searchInput ),
                    titleMenu,
                    //searchMenuW,
                    if(menu == '매입매출관리')
                      Container( padding: EdgeInsets.fromLTRB(divideHeight * 4, 0, divideHeight * 4, divideHeight),
                        child: WidgetUI.titleRowNone([ '순번', '거래일', '구분', '거래처 및 계약', '품목', '단위', '수량', '단가', '공급가액', 'VAT', '합계', '' ],
                            [ 32, 100, 80, 200 + 28, 999, 50, 50, 100, 100, 100, 100, 64 + 32, 32 ]),
                      ),
                    if(menu == '수납관리')
                      Container( padding: EdgeInsets.fromLTRB(divideHeight * 4, 0, divideHeight * 4, divideHeight),
                        child: WidgetUI.titleRowNone([ '순번', '거래일자', '거래처', '적요', '수입', '지출', '계좌', '메모', '', ],
                            [ 32, 100, 200, 999, 100, 100, 200, 999, 64, 0,  ]),
                      ),
                    WidgetT.dividHorizontal(size: 0.7),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(12),
                        children: [
                          Column(children: childrenW,),
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
    return main;
  }

  Widget build(context) {
    return Container();
  }
}
