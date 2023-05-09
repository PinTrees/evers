import 'dart:convert';
import 'dart:ui';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/dialog_revenue.dart';
import 'package:evers/ui/dialog_transration.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../class/Customer.dart';
import '../class/contract.dart';
import '../class/purchase.dart';
import '../class/revenue.dart';
import '../class/schedule.dart';
import '../class/system.dart';
import '../class/system/search.dart';
import '../class/transaction.dart';
import '../class/widget/text.dart';
import '../helper/dialog.dart';
import '../helper/firebaseCore.dart';
import '../helper/interfaceUI.dart';
import '../helper/pdfx.dart';
import 'cs.dart';
import 'dialog_contract.dart';
import 'dialog_pu.dart';
import 'dl.dart';
import 'package:http/http.dart' as http;

import 'ux.dart';

class View_REPU extends StatelessWidget {
  TextEditingController searchInput = TextEditingController();
  var st_sc_vt = ScrollController();
  var st_sc_hr = ScrollController();
  var divideHeight = 6.0;

  var sizePrice = 80.0;
  var sizeDate = 80.0;

  List<Purchase> pur_list = [];
  List<Revenue> rev_list = [];

  List<Purchase> pur_sort_list = [];
  List<Revenue> rev__sort_list = [];

  List<TS> ts_list = [];
  List<TS> ts_sort_list = [];

  /// 검색
  bool sort = false;

  var currentView = '매입';

  var pur_sort_menu = [ '최신순',  ];
  var pur_sort_menu_date = [ '최근 1주일', '최근 1개월', '최근 3개월' ];
  var crRpmenuRp = '', pur_query = '';
  DateTime rpStartAt = DateTime.now();
  DateTime rpLastAt = DateTime.now();

  dynamic init() async {
  }
  String menu = '';

  dynamic search(String search) async {
    if(search == '') {
      sort = false;
      pur_query = '';
      pur_list.clear();
      rev_list.clear();
      ts_list.clear();

      FunT.setStateMain();
      return;
    }

    sort = true;
    if(menu == '매입매출관리') {
      if (currentView == '매입') {
        crRpmenuRp = ''; pur_query = '';
        pur_sort_list = await SystemT.searchPuMeta(search,);
      }
      else if (currentView == '매출') {
        crRpmenuRp = ''; pur_query = '';
        rev__sort_list = await SystemT.searchReMeta(search,);
        print(rev__sort_list.length);
      }
    }
    else if(menu == '수납관리') {
      await SystemT.searchTSMeta(searchInput.text,
        startAt: rpStartAt.microsecondsSinceEpoch.toString().substring(0, 8),
        lastAt: rpLastAt.microsecondsSinceEpoch.toString().substring(0, 8),
      );
      ts_sort_list = await Search.searchTS();
    }

    FunT.setStateMain();
  }
  void query_init() {
    sort = false;
    pur_list.clear();
    rev_list.clear();
    ts_list.clear();
  }
  void clear() async {
    ts_list.clear();
    rev_list.clear();
    pur_list.clear();
    await FunT.setStateMain();
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
      rev_list.clear();
      ts_list.clear();
      sort = false;
      pur_query = '';

      rpLastAt = DateTime.now();
      rpStartAt = DateTime.now().add(const Duration(days: -180));
    }

    this.menu = menu;

    Widget titleMenu = SizedBox();
    Widget bottomWidget = SizedBox();

    List<Widget> childrenW = [];
    if(menu == '매입매출관리') {
      childrenW.clear();
      titleMenu = Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () async {
                  currentView = '매입';
                  clear();
                },
                child: Container(child: (currentView == '매입') ? WidgetT.title('매입 목록', size: 18) : WidgetT.text('매입 목록', size: 18, bold: true, color: disableTextColor)),
              ),
              SizedBox(width: divideHeight * 2,),
              WidgetT.text('/', size: 12),
              SizedBox(width: divideHeight * 2,),
              InkWell(
                onTap: () async {
                  currentView = '매출';
                  clear();
                },
                child: Container(child: (currentView == '매출') ? WidgetT.title('매출 목록', size: 18) : WidgetT.text('매출 목록', size: 18,  bold: true, color: disableTextColor)),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
            child: Row(
              children: [
                for(var m in pur_sort_menu_date)
                  InkWell(
                    onTap: () async {
                      if(pur_query == m) return;
                      pur_query = m;

                      query_init();

                      rpLastAt = DateTime.now();
                      if(pur_query == pur_sort_menu_date[0]) {
                        rpStartAt = DateTime.now().add(const Duration(days: -7));
                      }
                      else if(pur_query == pur_sort_menu_date[1]) {
                        rpStartAt = DateTime.now().add(const Duration(days: -30));
                      }
                      else if(pur_query == pur_sort_menu_date[2]) {
                        rpStartAt = DateTime.now().add(const Duration(days: -90));
                      }

                      FunT.setStateMain();
                    },
                    child: Container(
                      height: 32,
                      decoration: StyleT.inkStyleNone(color: Colors.transparent),
                      padding:menuPadding,
                      child: WidgetT.text(m, size: 14, bold: true,
                          color: (m == pur_query) ? StyleT.titleColor : StyleT.textColor.withOpacity(0.5)),
                    ),
                  ),

                SizedBox(width: divideHeight * 4,),

                InkWell(
                  onTap: () async {
                    var selectedDate = await showDatePicker(
                      context: context,
                      initialDate: rpStartAt, // 초깃값
                      firstDate: DateTime(2018), // 시작일
                      lastDate: DateTime(2030), // 마지막일
                    );
                    if(selectedDate != null) {
                      if (selectedDate.microsecondsSinceEpoch < rpLastAt.microsecondsSinceEpoch) rpStartAt = selectedDate;
                      pur_query = '';
                    }
                    FunT.setStateMain();
                  },
                  child: Container(
                    height: 32,
                    padding: EdgeInsets.all(divideHeight),
                    alignment: Alignment.center,
                    decoration: StyleT.inkStyleNone(color: Colors.transparent),
                    child:WidgetT.text(StyleT.dateFormat(rpStartAt), size: 14, bold: true,
                        color: (pur_query == '기간검색') ? StyleT.titleColor : StyleT.textColor.withOpacity(0.5)),
                  ),
                ),
                WidgetT.text('~',  size: 14, color: StyleT.textColor.withOpacity(0.5)),
                InkWell(
                  onTap: () async {
                    var selectedDate = await showDatePicker(
                      context: context,
                      initialDate: rpLastAt, // 초깃값
                      firstDate: DateTime(2018), // 시작일
                      lastDate: DateTime(2030), // 마지막일
                    );
                    if(selectedDate != null) {
                      rpLastAt = selectedDate;
                      pur_query = '';
                    }
                    FunT.setStateMain();
                  },
                  child: Container(
                    height: 32,
                    padding: EdgeInsets.all(divideHeight),
                    alignment: Alignment.center,
                    decoration: StyleT.inkStyleNone(color: Colors.transparent),
                    child:WidgetT.text(StyleT.dateFormat(rpLastAt), size: 14, bold: true,
                        color: (pur_query == '기간검색') ? StyleT.titleColor : StyleT.textColor.withOpacity(0.5)),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    pur_query = '기간검색';
                    query_init();
                    FunT.setStateMain();
                  },
                  child: Container(
                    height: 32,
                    decoration: StyleT.inkStyleNone(color: Colors.transparent),
                    padding: EdgeInsets.all(divideHeight),
                    child: WidgetT.text('기간검색', size: 14, bold: true,
                        color: (pur_query == '기간검색') ? StyleT.titleColor : StyleT.textColor.withOpacity(0.5)),
                  ),
                ),
                SizedBox(width: divideHeight * 4,),
                InkWell(
                  onTap: () async {
                    pur_query = '';
                    pur_list.clear();
                    rev_list.clear();
                    FunT.setStateMain();
                  },
                  child: Container( height: 32, 
                    padding: menuPadding,
                    child: WidgetT.text('검색초기화', size: 14, bold: true,
                        color: StyleT.textColor.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              InkWell(
                  onTap: () async {
                    var result = await DialogPU.showCreateNormalPu(context);
                    if(result != null) {
                      FunT.setStateMain();
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.all(3),
                    height: 36, width: 128,
                    decoration: StyleT.inkStyleNone(round: 8, color: Colors.black.withOpacity(0.05)),
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.add_box,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('일반 매입 추가', size: 12),
                        //WidgetT.iconNormal(Icons.open_in_new,  size: 36),
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () async {
                    var result = await DialogPU.showCreateItemPu(context);
                    if(result != null) {
                      FunT.setStateMain();
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.all(3),
                    height: 36, width: 128,
                    decoration: StyleT.inkStyleNone(round: 8, color: Colors.black.withOpacity(0.05)),
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.add_box,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('품목 매입 추가', size: 12),
                        //WidgetT.iconNormal(Icons.open_in_new,  size: 36),
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () async {
                    var result = await DialogRE.showCreateRe(context);
                    if(result != null) {
                      FunT.setStateMain();
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.all(3),
                    height: 36, width: 128,
                    decoration: StyleT.inkStyleNone(round: 8, color: Colors.black.withOpacity(0.05)),
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.add_box,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('일반 매출 추가', size: 12),
                        //WidgetT.iconNormal(Icons.open_in_new,  size: 36),
                      ],
                    ),
                  )),
            ],
          )
        ],
      );

      if(currentView == '매입') {
        if(pur_list.length < 1) pur_list = await DatabaseM.getPurchase(
          startDate: rpStartAt.microsecondsSinceEpoch,
          lastDate: rpLastAt.microsecondsSinceEpoch,
        );


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
                    WidgetT.excelGrid(textSize: 8, label: '${i + 1}', width: 32),
                    WidgetT.excelGrid(textSize: 8, textLite: true, text: pu.id, width: sizeDate, ),
                    WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.dateFormatAtEpoch(pu.purchaseAt.toString()), width: sizeDate, ),
                    WidgetT.excelGrid(textSize: 10,textLite: false,text: '매입', width: 50, textColor: Colors.redAccent.withOpacity(0.5) ),

                    Expanded(
                      child: Container(
                        width: 150, alignment: Alignment.center,
                        child: (cs.businessName != '') ? RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: cs.businessName,
                                recognizer: TapGestureRecognizer()..onTapDown = (details) {
                                  DialogCS.showCustomerDialog(context, org: cs);
                                },
                                style: TextStyle(color: Colors.blue, fontSize: 10, decoration: TextDecoration.underline, fontWeight: FontWeight.w900)),
                          ]),
                        ) : Text('ㅡ', style: TextStyle(fontSize: 10, color: StyleT.textColor),),
                      ),
                    ),
                    Expanded(child: WidgetT.excelGrid(textLite: false, width: 999, text: itemName, textSize: 10)),
                    WidgetT.excelGrid(textSize: 10, textLite: true, text:item?.unit, width: 50),
                    WidgetT.excelGrid(textSize: 10, textLite: true,width: 50,  text: StyleT.krw(pu.count.toString()),),
                    WidgetT.excelGrid(textSize: 10, textLite: true,width: sizePrice,  text: StyleT.krw(pu.unitPrice.toString()),),
                    WidgetT.excelGrid(textSize: 10, textLite: true,width: sizePrice,  text: StyleT.krw(pu.supplyPrice.toString()),),
                    WidgetT.excelGrid(textSize: 10, textLite: true,width: sizePrice,  text: StyleT.krw(pu.vat.toString()), ),
                    WidgetT.excelGrid(textSize: 10, textLite: true,width: sizePrice, text: StyleT.krw(pu.totalPrice.toString()),),
                    if(pu.filesMap.length > 0)
                      WidgetT.iconMini(Icons.file_copy_rounded, size: 32),
                    if(pu.filesMap.length == 0)
                      SizedBox(height: 28,width: 28,),
                    InkWell(
                      onTap: () async {
                        var result = await DialogPU.showInfoPu(context, org: pu);
                        if(result != null) {
                          FunT.setStateMain();
                        }
                      },
                      child: WidgetT.iconMini(Icons.create, size: 32),
                    ),
                    InkWell(
                      onTap: () async {
                        var aa = await DialogT.showAlertDl(context, text: '데이터를 삭제하시겠습니까?');
                        if(aa) {
                          await DatabaseM.deletePu(pu);
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

            var list = await DatabaseM.getPurchase(
              startAt: pur_list.last.id,
              startDate: rpStartAt.microsecondsSinceEpoch,
              lastDate: rpLastAt.microsecondsSinceEpoch,
            );
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
        if(rev_list.length < 1) rev_list = await DatabaseM.getRevenue(
          startDate: rpStartAt.microsecondsSinceEpoch,
          lastDate: rpLastAt.microsecondsSinceEpoch,
        );

        var data = sort ? rev__sort_list : rev_list;
        for(int i = 0; i < data.length; i++) {
          var rev = data[i];

          Widget w = SizedBox();
          var cs = await SystemT.getCS(rev.csUid) ?? Customer.fromDatabase({});
          var ct = await SystemT.getCt(rev.ctUid) ?? Contract.fromDatabase({});

          var item = SystemT.getItem(rev.item);
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
                    WidgetT.excelGrid(textSize: 8, textLite: true, text: '${i + 1}', width: 32,),
                    WidgetT.excelGrid(textSize: 8, textLite: true, text: rev.id.toString(), width: sizeDate,),
                    WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.dateFormatAtEpoch(rev.revenueAt.toString()), width: sizeDate,),
                    WidgetT.excelGrid(textSize: 10, textLite: false, text: '매출', width: 50, textColor: Colors.blueAccent.withOpacity(0.5)),

                    /** 하이퍼링크 텍스트 위젯 함수화 변경. 추후 다른 코드 변경바람 */
                    Expanded(
                      child: TextT.OnTap(
                        context: context,
                        text: '${ cs.businessName } / ${ ct.ctName }',
                        width: 150,
                        onTap: () async {
                          var result = await DialogCT.showInfoCt(context, ct);
                          return result;
                        }
                      ),
                    ),
                    Expanded(child: WidgetT.excelGrid(textSize: 10, width: 999,  text: itemName,)),
                    WidgetT.excelGrid(textLite: true,  text:item?.unit, width: 50),
                    WidgetT.excelGrid(textSize: 10, textLite: true, width: 50,text: StyleT.krw(rev.count.toString()),),
                    WidgetT.excelGrid(textSize: 10, textLite: true, width: sizePrice, text: StyleT.krw(rev.unitPrice.toString()),),
                    WidgetT.excelGrid(textSize: 10, textLite: true, width: sizePrice,  text: StyleT.krw(rev.supplyPrice.toString()),),
                    WidgetT.excelGrid(textSize: 10, textLite: true,  width: sizePrice,  text: StyleT.krw(rev.vat.toString()), ),
                    WidgetT.excelGrid(textSize: 10, textLite: true, width: sizePrice, text: StyleT.krw(rev.totalPrice.toString()),),
                    SizedBox(height: 28,width: 32,),
                    InkWell(
                      onTap: () async {
                        var data = await DialogRE.showInfoRe(context, org: rev);
                        if(data != null) clear();
                      },
                      child: WidgetT.iconMini(Icons.create, size: 32),
                    ),
                    InkWell(
                      onTap: () async {
                        if(!await DialogT.showAlertDl(context, text: '데이터를 삭제하시겠습니까?')) {
                          WidgetT.showSnackBar(context, text: '취소됨');
                          return;
                        }
                         var task = await rev.delete();
                        if(!task) {
                          WidgetT.showSnackBar(context, text: '삭제에 실패했습니다. 나중에 다시 시도하세요.');
                          return;
                        }
                        WidgetT.showSnackBar(context, text: '매출 데이터를 삭제했습니다.');
                        clear();
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

            var list = await DatabaseM.getRevenue(
              startAt: rev_list.last.id,
              startDate: rpStartAt.microsecondsSinceEpoch,
              lastDate: rpLastAt.microsecondsSinceEpoch,
            );
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

/*      bottomWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ButtonT.IconText(text: '일반 매입 추가'),
          ButtonT.IconText(text: '재고 매입 추가'),
          ButtonT.IconText(text: '일반 매출 추가'),
        ],
      );*/
    }
    else if(menu == '수납관리') {
      childrenW.clear();
      titleMenu = Column(
        children: [
          Row(
            children: [
              WidgetT.title('수납 목록', size: 18),
              SizedBox(width: divideHeight * 2,),
              WidgetT.text('( 수납 목록, 거래 기록 )', size: 12,)
            ],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
            child: Row(
              children: [
                for(var m in pur_sort_menu_date)
                  InkWell(
                    onTap: () async {
                      if(pur_query == m) return;
                      pur_query = m;

                      query_init();

                      rpLastAt = DateTime.now();
                      if(pur_query == pur_sort_menu_date[0]) {
                        rpStartAt = DateTime.now().add(const Duration(days: -7));
                      }
                      else if(pur_query == pur_sort_menu_date[1]) {
                        rpStartAt = DateTime.now().add(const Duration(days: -30));
                      }
                      else if(pur_query == pur_sort_menu_date[2]) {
                        rpStartAt = DateTime.now().add(const Duration(days: -90));
                      }

                      FunT.setStateMain();
                    },
                    child: Container(
                      height: 32,
                      decoration: StyleT.inkStyleNone(color: Colors.transparent),
                      padding:menuPadding,
                      child: WidgetT.text(m, size: 14, bold: true,
                          color: (m == pur_query) ? StyleT.titleColor : StyleT.textColor.withOpacity(0.5)),
                    ),
                  ),

                SizedBox(width: divideHeight * 4,),

                InkWell(
                  onTap: () async {
                    var selectedDate = await showDatePicker(
                      context: context,
                      initialDate: rpStartAt, // 초깃값
                      firstDate: DateTime(2018), // 시작일
                      lastDate: DateTime(2030), // 마지막일
                    );
                    if(selectedDate != null) {
                      if (selectedDate.microsecondsSinceEpoch < rpLastAt.microsecondsSinceEpoch) rpStartAt = selectedDate;
                      pur_query = '';

                      clear();
                      mainView(context, menu);
                    }
                  },
                  child: Container(
                    height: 32,
                    padding: EdgeInsets.all(divideHeight),
                    alignment: Alignment.center,
                    decoration: StyleT.inkStyleNone(color: Colors.transparent),
                    child:WidgetT.text(StyleT.dateFormat(rpStartAt), size: 14, bold: true, color: StyleT.titleColor ),
                  ),
                ),
                WidgetT.text('~',  size: 14, color: StyleT.textColor.withOpacity(0.5)),
                InkWell(
                  onTap: () async {
                    var selectedDate = await showDatePicker(
                      context: context,
                      initialDate: rpLastAt, // 초깃값
                      firstDate: DateTime(2018), // 시작일
                      lastDate: DateTime(2030), // 마지막일
                    );
                    if(selectedDate != null) {
                      rpLastAt = selectedDate;
                      pur_query = '';

                      clear();
                      mainView(context, menu);
                    }
                  },
                  child: Container(
                    height: 32,
                    padding: EdgeInsets.all(divideHeight),
                    alignment: Alignment.center,
                    decoration: StyleT.inkStyleNone(color: Colors.transparent),
                    child:WidgetT.text(StyleT.dateFormat(rpLastAt), size: 14, bold: true,  color: StyleT.titleColor ),
                  ),
                ),
                SizedBox(width: divideHeight * 4,),
                InkWell(
                  onTap: () async {
                    pur_query = '';
                    pur_list.clear();
                    rev_list.clear();
                    ts_list.clear();
                    FunT.setStateMain();
                  },
                  child: Container( height: 32,
                    padding: menuPadding,
                    child: WidgetT.text('초기화', size: 14, bold: true,
                        color: StyleT.textColor.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

      if(ts_list.length < 1) {
        ts_list = await DatabaseM.getTransaction(
          startDate: rpStartAt.microsecondsSinceEpoch,
          lastDate: rpLastAt.microsecondsSinceEpoch,
        );
      }

      var datas = sort ? ts_sort_list : ts_list;
      for(int i = 0; i < datas.length; i++) {
        var tmpTs = datas[i];
        var cs = await SystemT.getCS(tmpTs.csUid);

        Widget w = tmpTs.OnTableUIMain(
          context: context, index: i + 1,
          setState: () { mainView(context, menu); },
          onTap: () async {
            await DialogTS.showInfoTs(context, org: tmpTs);
          },
          cs: cs,
        );

        childrenW.add(w);
        childrenW.add(WidgetT.dividHorizontal(size: 0.35));
      }

      if(!sort) {
        childrenW.add(InkWell(
          onTap: () async {
            WidgetT.loadingBottomSheet(context, text: '로딩중');

            var list = await DatabaseM.getTransaction(
                startAt: ts_list.last.id,
                startDate: rpStartAt.microsecondsSinceEpoch,
                lastDate: rpLastAt.microsecondsSinceEpoch,
            );
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
                    WidgetT.searchBar(search: (text) async {
                      WidgetT.loadingBottomSheet(context, text:'검색중');
                      await search(text);
                      Navigator.pop(context);
                    }, controller: searchInput ),
                    titleMenu,
                    //searchMenuW,
                    if(menu == '매입매출관리')
                      Container( padding: EdgeInsets.fromLTRB(divideHeight * 1, 0, divideHeight * 1, divideHeight),
                        child: WidgetUI.titleRowNone([ '순번', '거래번호', '거래일', '구분', '거래처 및 계약', '품목', '단위', '수량', '단가', '공급가액', 'VAT', '합계', '' ],
                            [ 32, sizeDate, sizeDate, 50, 999, 999, 50, 50,
                              sizePrice, sizePrice, sizePrice, sizePrice, 64 + 32, 32 ]),
                      ),
                    if(menu == '수납관리') TS.OnTableHeaderMain(),
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
                    bottomWidget,
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
