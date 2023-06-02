import 'dart:convert';
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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

import '../../class/Customer.dart';
import '../../class/component/comp_ts.dart';
import '../../class/contract.dart';
import '../../class/database/item.dart';
import '../../class/revenue.dart';
import '../../class/system.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/text.dart';
import '../../core/window/ResizableWindow.dart';
import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';

/// 이 윈도우 클래스는 출고원장 상세보기 창 화면입니다.
class WindowLedgerRe extends WindowBaseMDI {
  Function refresh;
  Ledger ledger;

  WindowLedgerRe({ required this.ledger, required this.refresh }) { }

  @override
  _WindowLedgerReState createState() => _WindowLedgerReState();
}
class _WindowLedgerReState extends State<WindowLedgerRe> {
  var dividHeight = 6.0;

  Ledger ledger = Ledger.fromDatabase({});
  List<Revenue> revenueList = [];

  Contract ct = Contract.fromDatabase({});
  Customer cs = Customer.fromDatabase({});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ledger = Ledger.fromDatabase(JsonManager.toJsonObject(widget.ledger));

    initAsync();
  }


  /// 이 함수는 동기 초기화를 시도합니다.
  /// 상속구조로 재설계 되어야 합니다.
  void initAsync() async {
    revenueList = await DatabaseM.getRevenueList(ledger.revenueList);

    if(ledger.ctUid != "") ct = await DatabaseM.getContractDoc(ledger.ctUid);
    if(ledger.csUid != "") cs = await DatabaseM.getCustomerDoc(ledger.csUid);

    setState(() {});
  }

  ///  이 함수는 매인 위젯을 렌더링 합니다.
  ///  상속구조로 재설계 되어야 합니디.
  Widget mainBuild() {

    Widget contractWidget = ListBoxT.Rows(
      spacing: 6,
      children: [
        ButtonT.IconText(
          text: cs.businessName, icon: Icons.person,
          onTap: () {
            UIState.OpenNewWindow(context, WindowCS(org_cs: cs));
          }
        ),
        ButtonT.IconText(
          text: ct.ctName, icon: Icons.account_tree,
          onTap: () {
            UIState.OpenNewWindow(context, WindowCT(org_ct: ct));
          }
        ),
      ]
    );

    Widget pdfOpenWidget = ButtonT.IconText(
      icon: Icons.open_in_new_sharp, text: "원장 PDF 보기",
      onTap: () {
        PdfManager.OpenPdf(ledger.fileUrl, "출고원장.pdf");
      }
    );

    List<Widget> revenueWidgets = [
      TextT.SubTitle(text: "출고 매출목록"),
      SizedBox(height: 6,),
      CompRE.tableHeaderSearch(),
    ];
    int index = 1;
    for(var re in revenueList) {
      revenueWidgets.add(CompRE.tableUIMain(context, re, ct: ct, cs: cs, index: index++,
        refresh: () { initAsync(); },
        setState: () { setState(() {}); }
      ));
      revenueWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    }


    Widget deleteWidget = ButtonT.IconText(
      icon: Icons.delete, text: "원장삭제",
      onTap: () async {
        var rst = await DialogT.showAlertDl(context, text: "원장을 삭제하시겠습니까?. 삭제할 경우 기존의 연결된 매출의 출고원장을 새로 생성할 수 있습니다.");
        if(!rst) { return Messege.toReturn(context, "삭제 취소됨", false); }

        await ledger.delete();

        widget.refresh();
        widget.parent.onCloseButtonClicked!();

        return Messege.toReturn(context, "삭제됨", true);
      }
    );


    return Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextT.SubTitle(text: '출고원장 정보'),
                SizedBox(height: 6,),
                TextT.Lit(text: '출고원장은 보안상의 이유로 수정할 수 없습니다. 잘못 기입한 내용이 있을 경우 삭제하고 다시 생성해야 합니다. 이미 진행되어 삭제할 수 없는 경우 관리자에 의해서 수정될 수 있습니다.'),

                SizedBox(height: dividHeight * 4,),
                TextT.SubTitle(text: '연결된 거래처 및 계약'),
                SizedBox(height: dividHeight,),
                contractWidget,

                SizedBox(height: dividHeight * 4,),
                TextT.SubTitle(text: '원장 PDF'),
                SizedBox(height: dividHeight,),
                pdfOpenWidget,

                SizedBox(height: dividHeight * 4,),
                ListBoxT.Columns(children: revenueWidgets),

                SizedBox(height: dividHeight * 4,),
                deleteWidget,
              ]
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
    var okAction = ButtonT.Action(context, "확인", icon: Icons.check,
      backgroundColor: Colors.blue.withOpacity(0.5),
      onTap: () {
        widget.parent.onCloseButtonClicked!();
      }
    );

    return Column(
      children: [
        Row(children: [ okAction ],)
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}