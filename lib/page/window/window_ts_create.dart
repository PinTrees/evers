import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/json.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/dialog_item.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

import '../../class/Customer.dart';
import '../../class/system.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/text.dart';
import '../../core/window/ResizableWindow.dart';
import '../../core/window/window_base.dart';
import '../../helper/dialog.dart';
import '../../helper/interfaceUI.dart';

class WindowTsCreateCt extends WindowBaseMDI {
  Contract? ct;
  Function refresh;

  WindowTsCreateCt({ required this.ct, required this.refresh, }) { }

  @override
  _WindowTsCreateState createState() => _WindowTsCreateState();
}

class _WindowTsCreateState extends State<WindowTsCreateCt> {
  var dividHeight = 6.0;

  List<TS> tslistCr = [];
  Contract ct = Contract.fromDatabase({});
  Customer cs = Customer.fromDatabase({});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  dynamic initAsync() async {
    ct = Contract.fromDatabase(JsonManager.toJsonObject(widget.ct));
    cs = await DatabaseM.getCustomerDoc(ct.csUid);
    tslistCr.add(TS.fromDatabase({ 'transactionAt': DateTime.now().microsecondsSinceEpoch, 'type': 'PU' }));

    setState(() {});
  }

  Widget main = SizedBox();

  Widget mainBuild() {
    List<Widget> tsCW = [];
    for(int i = 0; i < tslistCr.length; i++) {
      var tmpTs = tslistCr[i];
      if(tmpTs.type == 'DEL') {
        tslistCr.removeAt(i--);
        continue;
      }

      var w = CompTS.tableUIInput(
        context, tmpTs,
        cs: cs, index: i + 1,
        setState: () { setState(() {}); },
      );
      tsCW.add(w);
      tsCW.add(WidgetT.dividHorizontal(size: 0.35));
    }

    return main = Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: dividHeight,),
                TextT.SubTitle(text: '거래처 및 계약 정보'),
                TextT.Lit(text: "${cs.businessName} / ${ct.ctName}" ),
                SizedBox(height: dividHeight * 4,),

                TextT.SubTitle(text: '수납추가 목록',),
                SizedBox(height: dividHeight,),
                TS.OnTableHeader(),
                for(var w in tsCW) w,

                SizedBox(height: dividHeight,),
                Row(
                  children: [
                    ButtonT.IconText(
                        icon: Icons.add_box,
                        text: '지급추가',
                        onTap: () {
                          tslistCr.add(TS.fromDatabase({ 'transactionAt': DateTime.now().microsecondsSinceEpoch, 'type': 'PU' }));
                          setState(() {});
                        }
                    ),
                    SizedBox(width: 6,),
                    ButtonT.IconText(
                        icon: Icons.add_box,
                        text: '수입추가',
                        onTap: () {
                          tslistCr.add(TS.fromDatabase({ 'transactionAt': DateTime.now().microsecondsSinceEpoch, 'type': 'RE' }));
                          setState(() {});
                        }
                    ),
                  ],
                ),
                SizedBox(height: dividHeight,),
              ],
            ),
          ),
          /// action
          buildAction(),
        ],
      ),
    );
  }


  Widget buildAction() {
    var saveWidget = ButtonT.Action(context, "계약 수납정보 저장", icon: Icons.save,
       altText: "수납정보를 저장하시겠습니까?",
        init: () {
          if(tslistCr.length < 1) return Messege.toReturn(context, "수납정보를 작성하세요.", false);
          for(var t in tslistCr) {
            if(t.summary == "")  return Messege.toReturn(context, "작성한 수납정보 적요를 다시 확인하세요. (적요는 비워둘 수 없습니다.)", false);
            if(t.amount < 1)  return Messege.toReturn(context, "작성한 수납정보 거래금액을 다시 확인하세요. (금액 오류)", false);
            if(t.transactionAt == 0) return Messege.toReturn(context, "작성한 수납정보 날짜를 다시 확인하세요. (날짜 오류)", false);
          }
          return true;
      },
        onTap: () async {
          for(var ts in tslistCr) {
            ts.csUid = cs.id;
            ts.ctUid = ct.id;
            await ts.update();
          }

          WidgetT.showSnackBar(context, text: '저장됨');
          await widget.refresh();
          widget.parent.onCloseButtonClicked!();
      }
    );

    return Row(
      children: [
        saveWidget,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}
