import 'dart:convert';
import 'dart:ui';

import 'package:evers/class/component/comp_process.dart';
import 'package:evers/class/database/process.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/dialog/dialog_itemts.dart';
import 'package:evers/dialog/dialog_tag.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_process_info.dart';
import 'package:evers/ui/dialog_revenue.dart';
import 'package:evers/ui/dialog_transration.dart';
import 'package:evers/ui/ex.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../class/Customer.dart';
import '../../../class/contract.dart';
import '../../../class/database/item.dart';
import '../../../class/purchase.dart';
import '../../../class/revenue.dart';
import '../../../class/schedule.dart';
import '../../../class/system.dart';
import '../../../class/system/state.dart';
import '../../../class/transaction.dart';
import '../../../class/widget/list.dart';
import '../../../class/widget/page.dart';
import '../../../class/widget/text.dart';
import '../../../helper/aes.dart';
import '../../../helper/dialog.dart';
import '../../../helper/firebaseCore.dart';
import '../../../helper/interfaceUI.dart';
import '../../../helper/pdfx.dart';
import '../../window/window_ct.dart';
import '../../../ui/cs.dart';
import '../../../ui/dialog_contract.dart';
import '../../../ui/dialog_item.dart';
import '../../../ui/dl.dart';
import 'package:http/http.dart' as http;

import '../../../ui/ux.dart';

/// work/u 페이지 하위 시스템
///
/// 생산관리 시스템 페이지 뷰어
/// @create YM
class ViewFactory extends StatelessWidget {
  TextEditingController searchInput = TextEditingController();
  var divideHeight = 6.0;

  List<FactoryD> factory_list = [];
  List<ProductD> product_list = [];
  List<ItemTS> itemTs_list = [];
  List<ItemTS> itemProductList = [];
  List<ProcessItem> processList = [];

  bool sort = false;
  bool query = false;

  var currentView = '매입';

  var pur_sort_menu = [ '최신순',  ];
  var pur_sort_menu_date = [ '최근 1주일', '최근 1개월', '최근 3개월' ];
  var crRpmenuRp = '', pur_query = '';
  DateTime rpStartAt = DateTime.now();
  DateTime rpLastAt = DateTime.now();

  dynamic init() async {
  }
  String menu = '';

  void search(String search) async {
    if(search == '') {
      sort = false;
      pur_query = '';
      query = false;
      factory_list.clear();
      product_list.clear();

      FunT.setStateMain();
      return;
    }

    sort = true; query = false;
    if(menu == '매입매출관리') {
  /*    if (currentView == '매입') {
        crRpmenuRp = ''; pur_query = '';
        pur_sort_list = await SystemT.searchPuMeta(search,);
      }
      else if (currentView == '매출') {
        crRpmenuRp = ''; pur_query = '';
        rev__sort_list = await SystemT.searchReMeta(search,);
      }*/
    }
    else if(menu == '수납관리') {
      //ts_sort_list = await SystemT.searchTSMeta(searchInput.text,);
    }

    FunT.setStateMain();
  }
  void query_init() {
    sort = false; query = true;
    factory_list.clear();
    product_list.clear();
  }
  void clear() async {
    product_list.clear();
    factory_list.clear();
    await FunT.setStateMain();
  }

  var menuStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.15), );
  var menuSelectStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.35), );
  var menuPadding = EdgeInsets.fromLTRB(6 * 4, 6 * 1, 6 * 4, 6 * 1);
  var disableTextColor = StyleT.titleColor.withOpacity(0.35);


  var subMenu = '생산관리';


  Map<String, double> usedAmount = {};

  /// Main Widget Build Function
  ///
  /// (***) 공장일보 및 생산일보 분리 필요
  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget, bool refresh=false  }) async {
    if(this.menu != menu) {
      sort = false; searchInput.text = '';
    }
    if(refresh) {
      clear();
      query = false; sort = false;
      pur_query = '';

      itemProductList = await DatabaseM.getItemTranListProduct();
      processList = await DatabaseM.getProcessItemGroupList();

      for(var pr in processList) {
        List<ProcessItem> outputList = await DatabaseM.getProcessItemGroupByPrUid(pr.id);
        var amount = 0.0;
        outputList.forEach((e) { amount += e.usedAmount.abs(); });
        usedAmount[pr.id] = amount;
      }
      await SystemT.initItemBalance();
    }

    this.menu = menu;

    List<Widget> childrenW = [];
    Widget titleWidgetT = SizedBox();

    var queryMenu = Column(
      children: [
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
                  query = false;

                  clear();

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
      ],
    );

    /// 생산일보 - 공장일보 통합 관리
    if(menu == '공장일보') {
      if(factory_list.length < 1) factory_list = await DatabaseM.getFactory(
          startDate: query ? rpStartAt.microsecondsSinceEpoch : null,
          lastDate: query ? rpLastAt.microsecondsSinceEpoch : null,
      );
      childrenW.clear();
      childrenW.add(
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetT.title('원자재 사용량'),
                    ],
                  ),
                )),
                SizedBox(width: divideHeight * 4,),
                Expanded(child: Container(
                    child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetT.title('생산품 생산량'),
                        ]
                    )
                )),
              ],
            ),
          )
      );

      List<ItemFD> itemSv = [];
      Map<String, dynamic> itemPu = {};

      List<FactoryD> data = sort ? factory_list : factory_list;

      for(var fd in data) {
        var a = fd.itemSvPu.entries.map((entry) => ItemFD.fromDatabase({ 'id': entry.key, 'count': entry.value })).toList();
        itemSv.addAll(a);
      }
      itemSv.forEach((e) {
        if(itemPu[e.id] == null) itemPu[e.id] = 0;
        itemPu[e.id] += e.count; });


      List<Widget> widgetsItemPu = [];
      widgetsItemPu.add(WidgetUI.titleRowNone([ '순번', '품목', '수량', '단가', '금액' ], [ 28, 150, 100, 100, 100]));
      widgetsItemPu.add(WidgetT.dividHorizontal(size: 0.7));
      for(int i = 0; i < itemPu.length; i++) {
        var count = int.tryParse(itemPu.values.elementAt(i).toString()) ?? 0;
        var item = SystemT.getItem(itemPu.keys.elementAt(i)) ?? Item.fromDatabase({});
        var w =  InkWell(
          child: Container(
            height: 32,
            child: Row(
              children: [
                WidgetEX.excelGrid(label: '${i + 1}', width: 28),
                WidgetT.excelGrid( width: 150, text: item.name,),
                WidgetT.excelGrid(width: 100, text: StyleT.krwInt(count) + item.unit,),
                WidgetT.excelGrid(textLite: true, text: StyleT.krwInt(item.unitPrice), width: 100),
                WidgetT.excelGrid(textLite: true, text: StyleT.krwInt(item.unitPrice * count) , width: 100),
              ],
            ),
          ),
        );
        widgetsItemPu.add(w);
        widgetsItemPu.add(WidgetT.dividHorizontal(size: 0.35));
      }

      childrenW.add(Row(
        children: [
          Expanded(child: Column(children: widgetsItemPu,)),
          SizedBox(width: divideHeight * 4,),
          Expanded(child: Column(children: widgetsItemPu,))
        ],
      ));
      childrenW.add(SizedBox(height: divideHeight * 8,));


      childrenW.add(WidgetT.title('공장일보 목록', size: 18),);
      childrenW.add(queryMenu);
      childrenW.add(WidgetT.dividHorizontal(size: 1.4));
      for(int i = 0; i < data.length; i++) {
        if(i >= data.length) break;
        var fd = data[i];
        Widget w = SizedBox();
        w = Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      await DialogIT.showFdInfo(context, org: fd);
                      FunT.setStateMain();
                    },
                    child: Container(
                      padding: EdgeInsets.only(bottom: divideHeight, top: divideHeight),
                      child: IntrinsicHeight(
                        child: Row( crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              WidgetT.excelGrid(label: '${fd.id}', width: 100, height: 28),
                              SizedBox(width: divideHeight,),
                              Expanded(child: WidgetT.excelGrid(textLite: true, alignment: Alignment.centerLeft, text: fd.memo.replaceAll('\n\n', '\n'),)),
                            ]
                        ),
                      ),
                    ),
                  ),
                  Container( height: 32,
                    child: Row(
                        children: [
                          WidgetT.excelGrid(label: '첨부파일', width: 100),
                          SizedBox(width: divideHeight,),
                          for(var f in fd.filesMap.keys)
                            InkWell(
                              onTap: () async {
                                var downloadUrl = fd.filesMap[f];
                                var fileName = f;
                                PdfManager.OpenPdf(downloadUrl, fileName);
                              },
                              child: Container(
                                height: 32, color: Colors.grey.withOpacity(0.15),
                                child: Row(
                                  children: [
                                    WidgetT.iconMini(Icons.file_copy_rounded),
                                    WidgetT.text(f),
                                    SizedBox(width: divideHeight,),
                                  ],
                                ),
                              ),
                            ),
                        ]
                    ),
                  ),
                  SizedBox(height: divideHeight,),
                ],
              ),
            ),
            InkWell(
              onTap: () async {
                //UIState.OpenNewWindow(context, WindowCT(org_ct: ct!));
              },
              child: WidgetT.iconMini(Icons.create, size: 28),
            ),
            InkWell(
              onTap: () async {
                if(!await DialogT.showAlertDl(context, text: '공장일보를 삭제하시겠습니까?')) {
                  WidgetT.showSnackBar(context, text: '삭제 취소됨');
                  return;
                }
                WidgetT.loadingBottomSheet(context, text: '삭제중');
                await fd.delete();
                Navigator.pop(context);

                clear();

                WidgetT.showSnackBar(context, text: '삭제됨');
                FunT.setStateMain();
              },
              child: WidgetT.iconMini(Icons.delete, size: 28),
            ),
          ],
        );
        childrenW.add(w);
        childrenW.add(WidgetT.dividHorizontal(size: 0.35));
      }

      if(!sort) {
        childrenW.add(InkWell(
          onTap: () async {
            WidgetT.loadingBottomSheet(context, text: '로딩중');

            var list = await DatabaseM.getFactory(
              startAt: (factory_list.length > 0) ? factory_list.last.id : null,
              startDate: query ? rpStartAt.microsecondsSinceEpoch : null,
              lastDate: query ? rpLastAt.microsecondsSinceEpoch : null,
            );
            factory_list.addAll(list);

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
    else if(menu == '생산일보') {
      if(product_list.length < 1) product_list = await DatabaseM.getProductList(
        startDate: query ? rpStartAt.microsecondsSinceEpoch : null,
        lastDate: query ? rpLastAt.microsecondsSinceEpoch : null,
      );

      childrenW.clear();
      childrenW.add(
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetT.title('원자재 사용량'),
                    ],
                  ),
                )),
                SizedBox(width: divideHeight * 4,),
                Expanded(child: Container(
                    child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetT.title('생산품 생산량'),
                        ]
                    )
                )),
              ],
            ),
          )
      );

      List<ItemFD> itemSv = [];
      Map<String, dynamic> itemPu = {};

      List<ProductD> data = sort ? product_list : product_list;

      for(var fd in data) {
        var a = fd.itemSvPu.entries.map((entry) => ItemFD.fromDatabase({ 'id': entry.key, 'count': entry.value })).toList();
        itemSv.addAll(a);
      }
      itemSv.forEach((e) {
        if(itemPu[e.id] == null) itemPu[e.id] = 0;
        itemPu[e.id] += e.count; });


      List<Widget> widgetsItemPu = [];
      widgetsItemPu.add(WidgetUI.titleRowNone([ '순번', '품목', '수량', '단가', '금액' ], [ 28, 150, 100, 100, 100]));
      widgetsItemPu.add(WidgetT.dividHorizontal(size: 0.7));
      for(int i = 0; i < itemPu.length; i++) {
        var count = int.tryParse(itemPu.values.elementAt(i).toString()) ?? 0;
        var item = SystemT.getItem(itemPu.keys.elementAt(i)) ?? Item.fromDatabase({});
        var w =  InkWell(
          child: Container(
            height: 32,
            child: Row(
              children: [
                WidgetEX.excelGrid(label: '${i + 1}', width: 28),
                WidgetT.excelGrid( width: 150, text: item.name,),
                WidgetT.excelGrid(width: 100, text: StyleT.krwInt(count) + item.unit,),
                WidgetT.excelGrid(textLite: true, text: StyleT.krwInt(item.unitPrice), width: 100),
                WidgetT.excelGrid(textLite: true, text: StyleT.krwInt(item.unitPrice * count) , width: 100),
              ],
            ),
          ),
        );
        widgetsItemPu.add(w);
        widgetsItemPu.add(WidgetT.dividHorizontal(size: 0.35));
      }

      childrenW.add(Row(
        children: [
          Expanded(child: Column(children: widgetsItemPu,)),
          SizedBox(width: divideHeight * 4,),
          Expanded(child: Column(children: widgetsItemPu,))
        ],
      ));
      childrenW.add(SizedBox(height: divideHeight * 8,));

      childrenW.add(WidgetT.title('생산일보 목록', size: 18),);
      childrenW.add(queryMenu);
      childrenW.add(WidgetT.dividHorizontal(size: 1.4));
      for(int i = 0; i < data.length; i++) {
        if(i >= data.length) break;
        var fd = data[i];
        Widget w = SizedBox();
        w = Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      await DialogIT.showProductInfo(context, org: fd);
                      FunT.setStateMain();
                    },
                    child: Container(
                      padding: EdgeInsets.only(bottom: divideHeight, top: divideHeight),
                      child: IntrinsicHeight(
                        child: Row( crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              WidgetT.excelGrid(label: '${fd.id}', width: 100, height: 28),
                              SizedBox(width: divideHeight,),
                              Expanded(child: WidgetT.excelGrid(textLite: true, alignment: Alignment.centerLeft, text: fd.memo.replaceAll('\n\n', '\n'),)),
                            ]
                        ),
                      ),
                    ),
                  ),
                  Container( height: 32,
                    child: Row(
                        children: [
                          WidgetT.excelGrid(label: '첨부파일', width: 100),
                          SizedBox(width: divideHeight,),
                          for(var f in fd.filesMap.keys)
                            InkWell(
                              onTap: () async {
                                var downloadUrl = fd.filesMap[f];
                                var fileName = f;
                                PdfManager.OpenPdf(downloadUrl, fileName);
                                FunT.setStateMain();
                              },
                              child: Container(
                                height: 32, color: Colors.grey.withOpacity(0.15),
                                child: Row(
                                  children: [
                                    WidgetT.iconMini(Icons.file_copy_rounded),
                                    WidgetT.text(f),
                                    SizedBox(width: divideHeight,),
                                  ],
                                ),
                              ),
                            ),
                        ]
                    ),
                  ),
                  SizedBox(height: divideHeight,),
                ],
              ),
            ),
            InkWell(
              onTap: () async {
                var data = await DialogIT.showProductInfo(context, org: fd);

                if(data != null) clear();

                FunT.setStateMain();
              },
              child: WidgetT.iconMini(Icons.create, size: 28),
            ),
            InkWell(
              onTap: () async {
                if(!await DialogT.showAlertDl(context, text: '공장일보를 삭제하시겠습니까?')) {
                  WidgetT.showSnackBar(context, text: '삭제 취소됨');
                  return;
                }
                WidgetT.loadingBottomSheet(context, text: '삭제중');
                await fd.delete();
                Navigator.pop(context);

                clear();

                WidgetT.showSnackBar(context, text: '삭제됨');
                FunT.setStateMain();
              },
              child: WidgetT.iconMini(Icons.delete, size: 28),
            ),
          ],
        );
        childrenW.add(w);
        childrenW.add(WidgetT.dividHorizontal(size: 0.35));
      }

      if(!sort) {
        childrenW.add(InkWell(
          onTap: () async {
            WidgetT.loadingBottomSheet(context, text: '로딩중');

            var list = await DatabaseM.getProductList(
              startAt: (product_list.length > 0) ? product_list.last.id : null,
              startDate: query ? rpStartAt.microsecondsSinceEpoch : null,
              lastDate: query ? rpLastAt.microsecondsSinceEpoch : null,
            );
            product_list.addAll(list);

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


    if(menu == '품목관리') {
      childrenW.clear();
      for(int i = 0; i < SystemT.itemMaps.length; i++) {
        var itemTmp = SystemT.itemMaps.values.elementAt(i);
        Widget w = SizedBox();
        w = InkWell(
          onTap: () async {
            await DialogIT.showItemDl(context, org: itemTmp);
          },
          child: Container( height: 32,
            decoration: StyleT.inkStyleNone(color: Colors.transparent),
            child: Row(
                children: [
                  WidgetT.excelGrid(label: '${i}', width: 32),
                  WidgetT.excelGrid(textLite: true, text: MetaT.itemType[itemTmp.type], width: 100,),
                  WidgetT.excelGrid(textLite: true, text: MetaT.itemGroup[itemTmp.group], width: 100,),
                  WidgetT.excelGrid(text: '${itemTmp.name}', width: 200, ),
                  WidgetT.excelGrid(textLite: true, width: 100,  text: itemTmp.unit,),
                  WidgetT.excelGrid(textLite: true, text: StyleT.krwInt(itemTmp.unitPrice), width: 120,),
                  WidgetT.excelGrid(textLite: true, text: StyleT.krwInt(itemTmp.cost), width: 120, ),
                  Expanded(child: WidgetT.excelGrid(textLite: true, width: 250, text: itemTmp.memo,),),
                  Container( height: 32, width: 32,
                    child: WidgetT.iconMini(itemTmp.display ? Icons.check_box: Icons.check_box_outline_blank),),
                  TextButton(
                      onPressed: () async {
                        await DialogIT.showItemDl(context, org: itemTmp);
                        FunT.setStateDT();
                      },
                      style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                      child: Container( height: 32, width: 32,
                        child: WidgetT.iconMini(Icons.create),)
                  ),
                  TextButton(
                      onPressed: () async {
                        if(await DialogT.showAlertDl(context, text: '"${itemTmp.name}" 품목을 데이터베이스에서 삭제하시겠습니까?')) {
                          await DatabaseM.deleteItem(itemTmp);
                        }
                        FunT.setStateDT();
                      },
                      style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                      child: Container( height: 32, width: 32,
                        child: WidgetT.iconMini(Icons.delete),)
                  ),
                ]
            ),
          ),
        );
        childrenW.add(w);
        childrenW.add(WidgetT.dividHorizontal(size: 0.35));
      }
    }



    else if(menu == "품목입출현황") {
      childrenW.add(Column(
        children: [
          Row(
            children: [
              WidgetT.title('품목 입출 목록', size: 16),
              SizedBox(width: divideHeight * 2,),
              InkWell(
                  onTap: () async {
                    WidgetT.showSnackBar(context, text: "개발중 입니다.");
                  },
                  child: Container(
                    color: Colors.grey.withOpacity(0.35),
                    child: Row(
                      children: [
                        WidgetT.iconMini(Icons.add_box, size: 24, boxSize: 28),
                        WidgetT.text('신규 입출목록 추가', size: 12,),
                        SizedBox(width: divideHeight,),
                      ],
                    ),
                  )
              )
            ],
          ),
          Container(
            child: WidgetUI.titleRowNone([ '순번', '입출일', '구분', '거래처 / 계약', '품목', '수량', '습도', '저장고', '검수자', '' ],
                [ 32, 80, 50, 999, 999, 80, 80, 80, 80, 64 ]),
          ),
          WidgetT.dividHorizontal(size: 0.7),
        ],
      ));
      if(itemTs_list.length < 1) {
        itemTs_list = await DatabaseM.getItemTranList(
          startDate: query ? rpStartAt.microsecondsSinceEpoch : null,
          lastDate: query ? rpLastAt.microsecondsSinceEpoch : null,
        );
      }

      int i = 0;
      var data = sort ? itemTs_list : itemTs_list;
      for(var itemTs in data) {
        i++;
        Widget w = SizedBox();
        var cs = await SystemT.getCS(itemTs.csUid) ?? Customer.fromDatabase({});
        var ct = await SystemT.getCt(itemTs.ctUid) ?? Contract.fromDatabase({});

        var item = SystemT.getItem(itemTs.itemUid);
        w = itemTs.OnTableUI(index: i, cs: cs, ct: ct, item: item,
            onTap: () async {
              UIState.OpenNewWindow(context, WindowItemTS(itemTS: itemTs, refresh: FunT.setRefreshMain));
            }
        );

        childrenW.add(w);
        childrenW.add(WidgetT.dividHorizontal(size: 0.35),);
      }

      if(!sort) {
        childrenW.add(InkWell(
          onTap: () async {
            WidgetT.loadingBottomSheet(context, text: '로딩중');

            var list = await DatabaseM.getItemTranList(
              startAt: (itemTs_list.length > 0) ? itemTs_list.last.id : null,
              startDate: query ? rpStartAt.microsecondsSinceEpoch : null,
              lastDate: query ? rpLastAt.microsecondsSinceEpoch : null,
            );
            itemTs_list.addAll(list);

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

    /// (***) 함수화 필요
    /// @AT - M
    else if(menu == '생산관리') {
      List<Widget> itemBalanceWidgets = [];
      itemBalanceWidgets.add(ItemTS.OnBalanceTableHeader());
      SystemT.itemMaps.forEach((k, v) {
        itemBalanceWidgets.add(Container(
          height: 28,
          child: Row(
            children: [
              ExcelT.LitGrid(text: '-', width: 28),
              ExcelT.LitGrid(text: v.name, width: 200, center: true),
              ExcelT.LitGrid(text: MetaT.itemGroup[v.group] ?? '-', width: 150, center: true),
              ExcelT.LitGrid(text: StyleT.krwInt(SystemT.getItemBalance(k)) + v.unit, width: 100, center: true),
              ExcelT.LitGrid(text: '-' + v.unit, width: 100, center: true),
            ],
          ),
        ));
        itemBalanceWidgets.add(WidgetT.dividHorizontal(size: 0.35));
      });


      List<Widget> processWidgets = [];
      processWidgets.add(CompProcess.tableHeader());

      if(processList.length > 0) {
        Purchase? pu = await DatabaseM.getPurchaseDoc(processList.first.rpUid);
        for(var e in processList) {
          var cs = await SystemT.getCS(pu == null ? e.csUid : pu.csUid);
          processWidgets.add(CompProcess.tableUI(
            context, e, usedAmount[e.id] ?? 0.0, cs: cs,
            setState: () { mainView(context, menu, refresh: true); },
          ));
          processWidgets.add(WidgetT.dividHorizontal(size: 0.35));
        }
      }

      childrenW.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextT.Title(text:'가공공정 목록'),
              SizedBox(width: divideHeight,),
              ButtonT.IconText(
                  icon: Icons.add_box,
                  text: '추가',
                  onTap: () async {
                    var result = await DialogTag.createTag(context);
                    if(result != null){
                      await MetaT.init();
                      mainView(context, menu, refresh: false);
                    }
                  }
              ),
            ],
          ),
          SizedBox(height: divideHeight,),
          TextT.Lit(text: MetaT.processType.values.join(', ')),
          SizedBox(height: divideHeight * 4,),

          TextT.Title(text:'재고현황'),
          SizedBox(height: divideHeight,),
          Column( children: itemBalanceWidgets,),
          SizedBox(height: divideHeight * 4,),

          TextT.Title(text:'가공중인 품목',),
          SizedBox(height: divideHeight,),
          Column( children: processWidgets,),

          WidgetT.dividHorizontal(size: 0.7),
        ],
      ));
      childrenW.add(SizedBox(height: divideHeight,));
    }

    childrenW.insert(0, titleWidgetT);

    var main = PageWidget.Main(
      topWidget: topWidget,
      infoWidget: infoWidget,
      children: childrenW,
    );
    return main;
  }

  Widget build(context) {
    return Container();
  }
}
