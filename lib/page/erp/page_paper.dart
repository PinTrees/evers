import 'package:evers/class/widget/button.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_paper_factory.dart';
import 'package:evers/page/window/window_paper_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../class/schedule.dart';
import '../../../class/system.dart';
import '../../../class/system/state.dart';
import '../../../class/widget/list.dart';
import '../../../class/widget/page.dart';
import '../../../class/widget/text.dart';
import '../../../helper/aes.dart';
import '../../../helper/dialog.dart';
import '../../../helper/firebaseCore.dart';
import '../../../helper/interfaceUI.dart';
import '../../../helper/pdfx.dart';
import '../../../ui/dialog_item.dart';
import '../../../ui/dl.dart';
import 'package:http/http.dart' as http;

import '../../../ui/ux.dart';

/// work/u 페이지 하위 시스템
///
/// 생산관리 시스템 페이지 뷰어
/// @create YM
class PagePaper extends StatelessWidget {
  TextEditingController searchInput = TextEditingController();
  var divideHeight = 6.0;

  List<FactoryD> factory_list = [];
  List<ProductD> product_list = [];

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


  Map<String, double> usedAmount = {};

  /// Main Widget Build Function
  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget, bool refresh=false  }) async {
    if(this.menu != menu) {
      sort = false; searchInput.text = '';
    }
    if(refresh) {
      clear();
      query = false; sort = false;
      pur_query = '';
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

    childrenW.clear();

    List<Widget> titleMenuList = [];
    titleMenuList.add(ButtonT.TabMenu(
        "공장일보 추가", Icons.add_box,
        onTap: () async {
          UIState.OpenNewWindow(context, WindowFactoryPaper(refresh: FunT.setRefreshMain));
        }
    ));
    titleMenuList.add(ButtonT.TabMenu(
        "생산일보 추가", Icons.add_box,
        onTap: () {
          UIState.OpenNewWindow(context, WindowProductPaper(refresh: FunT.setRefreshMain));
        }
    ));


    /// 생산일보 - 공장일보 통합 관리
    if(menu == '공장일보') {
      titleMenuList.insert(0, WidgetT.title('공장일보 목록', size: 18),);

      if(factory_list.isEmpty) factory_list = await DatabaseM.getFactory(startDate: query ? rpStartAt.microsecondsSinceEpoch : null, lastDate: query ? rpLastAt.microsecondsSinceEpoch : null,);
      List<FactoryD> data = sort ? factory_list : factory_list;

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
                      UIState.OpenNewWindow(context, WindowFactoryPaper(refresh: FunT.setRefreshMain, factoryD: fd,));
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
      titleMenuList.insert(0, WidgetT.title('생산일보 목록', size: 18),);

      if(product_list.isEmpty) product_list = await DatabaseM.getProductList(startDate: query ? rpStartAt.microsecondsSinceEpoch : null, lastDate: query ? rpLastAt.microsecondsSinceEpoch : null,);
      List<ProductD> data = sort ? product_list : product_list;

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
                      UIState.OpenNewWindow(context, WindowProductPaper(refresh: FunT.setRefreshMain, productD: fd,));
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

    titleMenuList.insert(1, SizedBox(width: 6 * 2,));
    var titleWidget = Column(
      children: [
        ListBoxT.Rows(
          spacing: 6,
          children: titleMenuList,
        ),
        titleWidgetT,
        queryMenu,
      ],
    );

    var main = PageWidget.MainPage(
      topWidget: topWidget,
      infoWidget: infoWidget,
      titleWidget: titleWidget,
      children: childrenW,
    );
    return main;
  }

  Widget build(context) {
    return Container();
  }
}