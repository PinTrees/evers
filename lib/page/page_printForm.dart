import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/system.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/interfaceUI.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/system/printform.dart';
import 'package:evers/ui/ux.dart';
import 'package:excel/excel.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:evers/helper/dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:encrypt/encrypt.dart' as en;
import 'package:printing/printing.dart';

import 'dart:html' as html;
import 'dart:js' as js;

import 'package:url_launcher/url_launcher.dart';

import '../class/Customer.dart';
import '../class/database/ledger.dart';
import '../class/purchase.dart';
import '../class/revenue.dart';
import '../class/transaction.dart';
import '../class/widget/excel.dart';
import '../ui/dialog_revenue.dart';


class PFormReleaseRevenuePage extends StatefulWidget{
  String? csUid;
  PFormReleaseRevenuePage({this.csUid});

  @override
  State<PFormReleaseRevenuePage> createState() => _PFormReleaseRevenuePageState();
}

class _PFormReleaseRevenuePageState extends State<PFormReleaseRevenuePage> {
  _PFormReleaseRevenuePageState();

  late Contract ct;
  Widget main = SizedBox();
  late Ledger ledger;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller = new PdfViewerController(

    );
  }

  @override
  void didChangeDependencies() {
    var user = FirebaseAuth.instance.currentUser;
    if(user == null) {
      context.go('/login/o');
      setState(() {});
      return;
    }
    initAsync();
  }

  PdfViewerController? controller;
  List<Revenue> selectRevenue = [];
  List<Revenue> revenueList = [];
  Uint8List? pdfForm;

  Map<String, Map<String, dynamic>> inputRevenue = {};
  Map<String, String> inputOther = {};

  dynamic initAsync() async {
    WidgetT.loadingBottomSheet(context,);  setState(() {});

    await init();
    mainW();

    Navigator.pop(context);
    setState(() {});
  }

  dynamic init() async {
    StyleT.init();
    selectRevenue.clear();
    revenueList.clear();
    pdfForm = null;

    if(widget.csUid != null) {
      ct = await DatabaseM.getContractDoc(widget.csUid!);
      revenueList = await DatabaseM.getRevenueOnlyContract(ct.id);
    }

    return null;
  }

  /// 위젯 빌더입니다.
  dynamic mainW({ bool refresh = true }) async {
    main = Container();
    assert(ct != null);

    /// 화면에 표시될 매출정보 목록입니다.
    List<Widget> revenueWidgets = [];
    revenueList.forEach((e) async {
      Widget w = await e.buildUI(
          index: 0,
          onEdite: () {
          },
          state: () { mainW(); }
      );

      if(e.isLedger) {
        w = Container( color: Colors.red.withOpacity(0.1), child: w, );
        revenueWidgets.add(w);
        revenueWidgets.add(WidgetT.dividHorizontal(size: 0.35));
        return;
      }
      else {
        w = InkWell(
          onTap: () {
            if(selectRevenue.contains(e)) selectRevenue.remove(e);
            else selectRevenue.add(e);
            mainW();
          },
          child: Container(color: selectRevenue.contains(e) ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1), child: w),
        );

        revenueWidgets.add(w);
        revenueWidgets.add(WidgetT.dividHorizontal(size: 0.35));
      }
    });


    Widget pdfW = SizedBox();
    if(pdfForm != null) {
      pdfW = PdfViewer.openData(
        pdfForm!,
        params: PdfViewerParams(
          scrollDirection: Axis.horizontal,
          layoutPages: (viewSize, pages) {
            List<Rect> rect = [];
            final viewWidth = viewSize.width;
            final viewHeight = viewSize.height;
            final maxHeight = pages.fold<double>(0.0, (maxHeight, page) => max(maxHeight, page.height));
            final ratio = viewHeight / maxHeight;
            var top = 0.0;
            for (var page in pages) {
              final width = page.width * ratio;
              final height = page.height * ratio;
              final left = viewWidth > viewHeight ? (viewWidth / 2) - (width / 2) : 0.0;
              rect.add(Rect.fromLTWH(left, top, width, height));
              top += height + 8 /* padding */;
            }
            return rect;
          },
        ),
      );
    }

    Widget inputWidget = SizedBox();
    if(pdfForm != null) {
      inputWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextT.Lit(text: "매출기록에 대한 출고정보 입력", size: 16, bold: true),
          WidgetUI.titleRowNone([ '매출기록', '1박스kg', '박스수량', '총무게', '파렛트 수' ], [ 200, 200, 200, 200, 200 ], background: true, lite: true),
          for(var s in selectRevenue)
            Column(
              children: [
                Container(
                  height: 28,
                  child: Row(
                    children: [
                      ExcelT.LitGrid(text: SystemT.getItemName(s.item), width: 200),
                      ExcelT.LitInput(context, "${s.id}::lg.kg",
                        width: 200,
                        onEdited: (index, data) {
                          inputRevenue[s.id]!['lgKg'] = data;
                        },
                        setState: () { setState(() {}); mainW(); },
                        text: inputRevenue[s.id]!['lgKg'] ?? '-',
                        value: inputRevenue[s.id]!['lgKg'] ?? '',
                      ),
                      ExcelT.LitInput(context, "${s.id}::lgCount",
                        width: 200,
                        onEdited: (index, data) {
                          inputRevenue[s.id]!['lgCount'] = data;
                        },
                        setState: () { setState(() {}); mainW(); },
                        text: inputRevenue[s.id]!['lgCount'] ?? '-',
                        value: inputRevenue[s.id]!['lgCount'] ?? '',
                      ),
                      ExcelT.LitInput(context, "${s.id}::lgResultKg",
                        width: 200,
                        onEdited: (index, data) {
                          inputRevenue[s.id]!['lgResultKg'] = data;
                        },
                        setState: () { setState(() {}); mainW(); },
                        text: inputRevenue[s.id]!['lgResultKg'] ?? '-',
                        value: inputRevenue[s.id]!['lgResultKg'] ?? '',
                      ),
                      ExcelT.LitInput(context, "${s.id}::lgParteCount",
                        width: 200,
                        onEdited: (index, data) {
                          inputRevenue[s.id]!['lgParteCount'] = data;
                        },
                        setState: () { setState(() {}); mainW(); },
                        text: inputRevenue[s.id]!['lgParteCount'] ?? '-',
                        value: inputRevenue[s.id]!['lgParteCount'] ?? '',
                      ),
                    ],
                  ),
                ),
                WidgetT.dividHorizontal(size: 0.35),
              ],
            ),

          SizedBox(height: 6,),
          Row(
            children: [
              TextT.Lit(text: "출고시 필요 추가정보 입력", size: 16, bold: true),
              SizedBox(width: 6,),
              TextT.Lit(text: "현장명은 거래처의 정보가 입력됩니다. 출력물이 비어있을경우 직접 입력해 주세요.", size: 10, bold: false),
            ],
          ),
          Container(
            height: 28,
            child: Row(
              children: [
                ExcelT.LitGrid(text: '현장명', width: 140),
                ExcelT.LitInput(context, "lgWorkSite",
                  width: 500,
                  onEdited: (index, data) {
                    inputOther['lgWorkSite'] = data;
                  },
                  setState: () { setState(() {}); mainW(); },
                  text: inputOther['lgWorkSite'] ?? '',
                  value: inputOther['lgWorkSite'] ?? '',
                ),
              ],
            ),
          ),
          WidgetT.dividHorizontal(size: 0.35),
          Container(
            height: 28,
            child: Row(
              children: [
                ExcelT.LitGrid(text: '차량번호', width: 140),
                ExcelT.LitInput(context, "lgCarUid",
                  width: 500,
                  onEdited: (index, data) {
                    inputOther['lgCarUid'] = data;
                  },
                  setState: () { setState(() {}); mainW(); },
                  text: inputOther['lgCarUid'] ?? '',
                  value: inputOther['lgCarUid'] ?? '',
                ),
              ],
            ),
          ),
          WidgetT.dividHorizontal(size: 0.35),
          Container(
            height: 28,
            child: Row(
              children: [
                ExcelT.LitGrid(text: '출고자', width: 140),
                ExcelT.LitInput(context, "lgWriter",
                  width: 500,
                  onEdited: (index, data) {
                    inputOther['lgWriter'] = data;
                    ledger.writer = data;
                  },
                  setState: () { setState(() {}); mainW(); },
                  text: inputOther['lgWriter'] ?? '',
                  value: inputOther['lgWriter'] ?? '',
                ),
              ],
            ),
          ),
          WidgetT.dividHorizontal(size: 0.35),
          Container(
            height: 28,
            child: Row(
              children: [
                ExcelT.LitGrid(text: '입고예정일 및 특이사항 기재', width: 140),
                ExcelT.LitInput(context, "lgMemo",
                  width: 500,
                  onEdited: (index, data) {
                    inputOther['lgMemo'] = data;
                  },
                  setState: () { setState(() {}); mainW(); },
                  text: inputOther['lgMemo'] ?? '',
                  value: inputOther['lgMemo'] ?? '',
                ),
              ],
            ),
          ),
          WidgetT.dividHorizontal(size: 0.35),

          SizedBox(height: 6,),
          ListBoxT.Rows(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 6,
            children: [
              ButtonT.IconText(icon: Icons.refresh, text: "새로고침",
                  padding: EdgeInsets.only(bottom: 6),
                  onTap: () async {
                    await refreshLedger();
                  }
              ),
              ButtonT.IconText(icon: Icons.save, text: "원장 저장",
                  padding: EdgeInsets.only(bottom: 6),
                  onTap: () async {
                    await updateReleaseRevenueForm();
                  }
              ),
            ],
          )
        ],
      );
    }

    /// 최종 출력 위셋 빌드
    main = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 18, right: 18),
          height: 28, color: StyleT.subTabBarColor,
          child:  ListBoxT.Rows(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 18,
            children: [
              ButtonT.IconText(icon: Icons.add_box, text: "원장생성", color: Colors.transparent, textColor: Colors.white.withOpacity(0.5)),
              ButtonT.IconText(icon: Icons.add_box, text: "원장목록", color: Colors.transparent, textColor: Colors.white.withOpacity(0.5)),
            ],
          ),
        ),
        Expanded(
            child:ListView(
              padding: EdgeInsets.all(18),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(),
                    TextT.Title(text: '매출목록',),
                    TextT.Lit(text: '출고원장을 생성할 매출기록을 선택하세요.',),
                    SizedBox(height: 3,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextT.Lit(text: '선택불가',),
                        Container(height: 18, width: 18, color: Colors.red.withOpacity(0.1), ),

                        SizedBox(width: dividSize * 2,),

                        TextT.Lit(text: '선택가능',),
                        Container(height: 18, width: 18, color: Colors.blue.withOpacity(0.1), ),

                        SizedBox(width: dividSize * 2,),

                        TextT.Lit(text: '선택됨',),
                        Container(height: 18, width: 18, color: Colors.green.withOpacity(0.1), ),
                      ],
                    ),

                    SizedBox(height: 18,),
                    Column( children: revenueWidgets, ),
                    SizedBox(height: 6,),
                    ButtonT.IconText(icon: Icons.add_box, text: "선택한 목록으로 신규 원장생성",
                      onTap: () {
                        createLedger();
                      }
                    ),

                    SizedBox(height: 18 * 2,),
                    TextT.Title(text: '원장생성 미리보기',),
                    TextT.Lit(text: '출고원장 생성하면 변경할 수 없습니다. 데이터를 꼼꼼히 확인해 주세요.',),
                    SizedBox(height: 6,),

                    inputWidget,

                    Container(
                      width: double.maxFinite,
                      height: 512,
                      color: Colors.black26,
                      child: pdfW,
                    )
                  ],
                ),
              ],
            ),
        ),
      ],
    );

    setState(() {});
  }


  /// 이 함수는 매출기록에 대한 원장을 데이터베이스에 추가하고 변경사항을 기록합니다.
  dynamic updateReleaseRevenueForm() async {
    WidgetT.loadingBottomSheet(context);
    setState(() {});

    if(pdfForm == null) {
      Navigator.pop(context);
      WidgetT.showSnackBar(context, text:'문서 생성 오류');
      return;
    }

    if(ledger == null) {
      Navigator.pop(context);
      WidgetT.showSnackBar(context, text:'원장 생성 오류');
      return;
    }

    ledger.update(pdfForm!);

    await init();
    Navigator.pop(context);
    mainW();
  }


  /// 이 함수는 선택된 매출목록에 대한 출고시 원장을 생성합니다.
  ///
  /// 반환 없음
  /// 신규 원장클래스를 생성하고 CreateUID를 신규 생성합니다.
  dynamic createLedger() async {
    WidgetT.loadingBottomSheet(context);
    setState(() {});

    inputRevenue.clear();

    List<String> revenueIdList = [];
    selectRevenue.forEach((e) {
      revenueIdList.add(e.id);
      inputRevenue[e.id] = {};
    });
    ledger = Ledger.fromDatabase({
      'date': selectRevenue.first.revenueAt,
      'revenueList': revenueIdList,
      'csUid': ct.csUid,
      'ctUid': ct.id,
    });
    ledger.createUid();

    pdfForm = await PrintFormT.ReleaseRevenue(ledger, revenueList: selectRevenue, inputRevenue: inputRevenue, inputOther: inputOther);

    Navigator.pop(context);

    mainW();
  }


  /// 이 함수는 선택된 매출목록에 대한 출고시 원장을 새로고침합니다.
  dynamic refreshLedger() async {
    WidgetT.loadingBottomSheet(context);
    setState(() {});

    pdfForm = await PrintFormT.ReleaseRevenue(ledger, revenueList: selectRevenue, inputRevenue: inputRevenue, inputOther: inputOther);

    Navigator.pop(context);

    mainW();
  }

  var dividSize = 6.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 18,
        toolbarHeight: 68,
        title: Column(
          children: [
            Container(
              height: 68,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text('출고원장 작업 시스템'),
                    SizedBox(width: dividSize * 4,),
                    TextButton(
                      onPressed: () async {  },
                      style: StyleT.buttonStyleNone(color: Colors.transparent, padding:0, elevation: 0),
                      child: WidgetT.iconNormal(Icons.print, size: 48, color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () { },
                      style: StyleT.buttonStyleNone(color: Colors.transparent, padding:0, elevation: 0),
                      child: WidgetT.iconNormal(Icons.save_alt, size: 48, color: Colors.white),
                    )
                  ],
                )),

          ],
        ),
      ),
      backgroundColor: Colors.white70,
      body: main,
    );
  }
}
