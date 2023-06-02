import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_re.dart';
import 'package:evers/class/database/ledger.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/system/state.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/json.dart';
import 'package:evers/helper/pdfx.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_cs.dart';
import 'package:evers/page/window/window_ct.dart';
import 'package:evers/ui/dialog_item.dart';
import 'package:evers/ui/ex.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:pdf_render/pdf_render_widgets.dart';

import '../../class/Customer.dart';
import '../../class/component/comp_ts.dart';
import '../../class/contract.dart';
import '../../class/database/item.dart';
import '../../class/revenue.dart';
import '../../class/system.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/excel.dart';
import '../../class/widget/text.dart';
import '../../core/window/ResizableWindow.dart';
import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';
import '../../system/printform.dart';
import '../../ui/ux.dart';

/// 이 윈도우 클래스는 출고원장 상세보기 창 화면입니다.
class WindowLedgerReCreate extends WindowBaseMDI {
  Function refresh;
  Contract contract;

  WindowLedgerReCreate({ required this.contract, required this.refresh }) { }

  @override
  _WindowLedgerReCreateState createState() => _WindowLedgerReCreateState();
}
class _WindowLedgerReCreateState extends State<WindowLedgerReCreate> {
  var dividHeight = 6.0;

  Uint8List? pdfForm;
  Ledger ledger = Ledger.fromDatabase({});

  List<Revenue> revenueList = [];
  List<Revenue> selectRevenue = [];

  Contract ct = Contract.fromDatabase({});
  Customer cs = Customer.fromDatabase({});

  Map<String, Map<String, dynamic>> inputRevenue = {};
  Map<String, String> inputOther = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ct = widget.contract;

    initAsync();
  }


  /// 이 함수는 동기 초기화를 시도합니다.
  /// 상속구조로 재설계 되어야 합니다.
  void initAsync() async {
    revenueList = await DatabaseM.getRevenueWithCT(ct.id);
    cs = await DatabaseM.getCustomerDoc(ct.csUid);

    setState(() {});
  }


  dynamic updatePdf() async {
    pdfForm = await PrintFormT.ReleaseRevenue(ledger, revenueList: selectRevenue, inputRevenue: inputRevenue, inputOther: inputOther);
    setState(() {});
  }





  ///  이 함수는 매인 위젯을 렌더링 합니다.
  ///  상속구조로 재설계 되어야 합니디.
  Widget mainBuild() {

    /// 출고할 매출 목록
    List<Widget> revenueWidgets = [
      TextT.SubTitle(text: "출고할 매출목록 선택"),
      SizedBox(height: 6,),
      CompRE.tableHeaderSearch(),
    ];
    int index = 1;
    for(var re in revenueList) {
      if(re.isLedger) continue;
      if(selectRevenue.contains(re)) continue;

      revenueWidgets.add(CompRE.tableUISelect(context, re, ct: ct, cs: cs, index: index++,
        onTap: () {
          selectRevenue.add(re);
          inputRevenue[re.id] = {};
          setState(() {});
        },
        refresh: () { initAsync(); },
        setState: () { setState(() {}); }
      ));
      revenueWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    }


    /// 선택한 매출목록
    List<Widget> selectRevenueWidgets = [
      TextT.SubTitle(text: "선택한 매출목록"),
      SizedBox(height: 6,),
      CompRE.tableHeaderSearch(),
    ];
    index = 1;
    for(var re in selectRevenue) {
      selectRevenueWidgets.add(CompRE.tableUISelect(context, re, ct: ct, cs: cs, index: index++,
          onTap: () {
            selectRevenue.remove(re);
            inputRevenue.remove(re.id);
            setState(() {});
          },
          refresh: () { initAsync(); },
          setState: () { setState(() {}); }
      ));
      selectRevenueWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    }


    /// 추가 입력 데이터 위젯
    Widget inputWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "선택매출에 대한 출고정보 입력",),
        SizedBox(height: 6,),
        WidgetUI.titleRowNone([ '매출기록', '1박스kg', '박스수량', '총무게', '파렛트 수' ], [ 200, 200, 200, 200, 200 ], background: true, lite: true),
        SizedBox(height: 6,),

        for(var s in selectRevenue)
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    ExcelT.LitGrid(text: SystemT.getItemName(s.item), width: 200),
                    ExcelT.LitInput(context, "${s.id}::lg.kg",
                      width: 200,
                      onEdited: (index, data) {
                        inputRevenue[s.id]!['lgKg'] = data;
                      },
                      setState: () { setState(() {}); },
                      text: inputRevenue[s.id]!['lgKg'] ?? '-',
                      value: inputRevenue[s.id]!['lgKg'] ?? '',
                    ),
                    ExcelT.LitInput(context, "${s.id}::lgCount",
                      width: 200,
                      onEdited: (index, data) {
                        inputRevenue[s.id]!['lgCount'] = data;
                      },
                      setState: () { setState(() {}); },
                      text: inputRevenue[s.id]!['lgCount'] ?? '-',
                      value: inputRevenue[s.id]!['lgCount'] ?? '',
                    ),
                    ExcelT.LitInput(context, "${s.id}::lgResultKg",
                      width: 200,
                      onEdited: (index, data) {
                        inputRevenue[s.id]!['lgResultKg'] = data;
                      },
                      setState: () { setState(() {}); },
                      text: inputRevenue[s.id]!['lgResultKg'] ?? '-',
                      value: inputRevenue[s.id]!['lgResultKg'] ?? '',
                    ),
                    ExcelT.LitInput(context, "${s.id}::lgParteCount",
                      width: 200,
                      onEdited: (index, data) {
                        inputRevenue[s.id]!['lgParteCount'] = data;
                      },
                      setState: () { setState(() {}); },
                      text: inputRevenue[s.id]!['lgParteCount'] ?? '-',
                      value: inputRevenue[s.id]!['lgParteCount'] ?? '',
                    ),
                  ],
                ),
              ),
            ],
          ),
        WidgetT.dividHorizontal(size: 0.35),

        SizedBox(height: 6 * 4,),
        Row(
          children: [
            TextT.SubTitle(text: "출고시 필요 추가정보 입력"),
            SizedBox(width: 6,),
            TextT.Lit(text: "현장명은 거래처의 정보가 입력됩니다. 출력물이 비어있을경우 직접 입력해 주세요.", size: 10, bold: false),
          ],
        ),
        SizedBox(height: 6,),
        Row(
          children: [
            ExcelT.LitGrid(text: '현장명', width: 140),
            ExcelT.LitInput(context, "lgWorkSite",
              width: 500,
              onEdited: (index, data) {
                inputOther['lgWorkSite'] = data;
              },
              setState: () { setState(() {}); },
              text: inputOther['lgWorkSite'] ?? '',
              value: inputOther['lgWorkSite'] ?? '',
            ),
          ],
        ),
        SizedBox(height: 6,),
        Row(
          children: [
            ExcelT.LitGrid(text: '차량번호', width: 140),
            ExcelT.LitInput(context, "lgCarUid",
              width: 350,
              onEdited: (index, data) {
                inputOther['lgCarUid'] = data;
              },
              setState: () { setState(() {}); },
              text: inputOther['lgCarUid'] ?? '',
              value: inputOther['lgCarUid'] ?? '',
            ),
          ],
        ),
        SizedBox(height: 6,),
        Row(
          children: [
            ExcelT.LitGrid(text: '출고자', width: 140),
            ExcelT.LitInput(context, "lgWriter",
              width: 200,
              onEdited: (index, data) {
                inputOther['lgWriter'] = data;
                ledger.writer = data;
              },
              setState: () { setState(() {}); },
              text: inputOther['lgWriter'] ?? '',
              value: inputOther['lgWriter'] ?? '',
            ),
          ],
        ),
        SizedBox(height: 6,),
        Row(
          children: [
            ExcelT.LitGrid(text: '입고예정일 및 특이사항 기재', width: 140),
            ExcelT.LitInput(context, "lgMemo",
              width: 500, expand: true,
              onEdited: (index, data) {
                inputOther['lgMemo'] = data;
              },
              setState: () { setState(() {}); },
              text: inputOther['lgMemo'] ?? '',
              value: inputOther['lgMemo'] ?? '',
            ),
          ],
        ),
        SizedBox(height: 6,),
        WidgetT.dividHorizontal(size: 0.35),
      ],
    );


    var pdfTitleWidget = ListBoxT.Columns(
      children: [
        TextT.SubTitle(text: "출고원장 미리보기"),
        TextT.Lit(text: "출고원장의 LR- 로 시작하는 아이디는 원장을 생성할 시 시스템에서 자동으로 생성하여 기입됩니다."),
        SizedBox(height: 6,),
        ButtonT.IconText(
          icon: Icons.refresh, text: "미리보기",
          onTap: () {
            updatePdf();
          }
        )
      ]
    );

    Widget pdfWidget = Container();
    if(pdfForm != null) {
      pdfWidget = PdfViewer.openData(
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
              top += height + 8;
            }
            return rect;
          },
        ),
      );
    }



    return Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextT.SubTitle(text: '출고원장 정보'),
                  SizedBox(height: 6,),
                  TextT.Lit(text: '매출을 클릭하여 추가및 제거할 수 있습니다.'),

                  SizedBox(height: dividHeight * 4,),
                  ListBoxT.Columns(children: revenueWidgets),

                  SizedBox(height: dividHeight * 4,),
                  ListBoxT.Columns(children: selectRevenueWidgets),

                  SizedBox(height: dividHeight * 4,),
                  inputWidget,

                  SizedBox(height: dividHeight * 4,),
                  pdfTitleWidget,
                  SizedBox(height: dividHeight * 2,),
                  Container(
                    width: double.maxFinite,
                    height: 512,
                    color: Colors.black26,
                    child: pdfWidget,
                  )
                ]
              ),
            ),
          ),
          /// action
          buildAction(),
        ],
      ),
    );
  }


  /// 이 함수는 하단의 액션버튼 위젯을 렌더링 합니다.
  /// 상속구조로 재설계 되어야 합니다.
  Widget buildAction() {
    var saveAction = ButtonT.Action(context, "출고 원장 생성", icon: Icons.save,
      backgroundColor: Colors.blue.withOpacity(0.5),
      init: () {
        if(pdfForm == null) return Messege.toReturn(context, "문서 생성 오류. 원장 PDF 파일 생성에 실패했습니다.", false);
        if(ledger == null) return Messege.toReturn(context, "원장 생성 오류. 원장 정보 생성에 실패했습니다.", false);
        return true;
      },
      altText: "출고원장을 생성하면 보안상의 이유로 수정할 수 없습니다. 신중히 기입란을 확인한 후 저장을 시도해 주세요.",
      onTap: () async {
        List<String> revenueIdList = [];
        selectRevenue.forEach((e) { revenueIdList.add(e.id); });

        ledger = Ledger.fromDatabase({
          'date': selectRevenue.first.revenueAt,
          'revenueList': revenueIdList,
          'csUid': ct.csUid,
          'ctUid': ct.id,
        });
        await ledger.createUid();
        pdfForm = await PrintFormT.ReleaseRevenue(ledger, revenueList: selectRevenue, inputRevenue: inputRevenue, inputOther: inputOther);
        await ledger.update(pdfForm!);

        widget.refresh();
        widget.parent.onCloseButtonClicked!();
      }
    );

    return Column(
      children: [
        Row(children: [ saveAction ],)
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}