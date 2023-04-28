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
import '../class/purchase.dart';
import '../class/revenue.dart';
import '../class/transaction.dart';
import '../class/widget/excel.dart';
import '../ui/cs.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

  List<Revenue> selectRevenue = [];
  List<Revenue> revenueList = [];
  Uint8List? pdfForm;

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
      Widget w = await e.OnUI(
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
                        buildPForm();
                      }
                    ),


                    SizedBox(height: 18 * 2,),
                    TextT.Title(text: '원장생성 미리보기',),
                    TextT.Lit(text: '출고원장 생성하면 변경할 수 없습니다. 데이터를 꼼꼼히 확인해 주세요.',),
                    SizedBox(height: 6,),

                    if(pdfForm != null)
                      ButtonT.IconText(icon: Icons.add_box, text: "원장등록 확인",
                          padding: EdgeInsets.only(bottom: 6),
                          onTap: () async {
                            await updateReleaseRevenueForm();
                          }
                      ),

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

    for(var e in selectRevenue) {
      e.isLedger = true;
      await e.update();
    }

    await init();
    Navigator.pop(context);

    mainW();
  }


  /// 이 함수는 선택된 매출목록에 대한 출고시 원장을 생성합니다.
  ///
  /// 반환 없음
  dynamic buildPForm() async {
    pdfForm = await PrintFormT.ReleaseRevenue(revenueList: selectRevenue);
    print(pdfForm);
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
