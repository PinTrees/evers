import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/helper/function.dart';
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

class WindowTsCreate extends WindowBaseMDI {
  Customer? cs;
  Function refresh;

  WindowTsCreate({ required this.cs, required this.refresh, }) { }

  @override
  _WindowTsCreateState createState() => _WindowTsCreateState();
}

class _WindowTsCreateState extends State<WindowTsCreate> {
  var dividHeight = 6.0;

  List<TS> tslistCr = [];
  Customer? cs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tslistCr.add(TS.fromDatabase({ 'transactionAt': DateTime.now().microsecondsSinceEpoch, 'type': 'PU' }));
    if(widget.cs != null) {
      var jsonString = jsonEncode(widget.cs!.toJson());
      var json = jsonDecode(jsonString);
      cs = Customer.fromDatabase(json);
    }
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
        cs: widget.cs, index: i + 1,
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
                TextT.Title(text: '거래처 정보'),
                TextT.Lit(text: cs == null ? '-' : cs!.businessName ),
                SizedBox(height: 6,),
                if(widget.cs == null)
                  ButtonT.IconText(
                    icon: Icons.search, text: "거래처 검색",
                    onTap: () async {
                      var cs = await DialogT.selectCS(context);
                      if(cs != null) this.cs = cs;
                      setState(() {});
                    }
                  ),
                SizedBox(height: dividHeight * 4,),

                TextT.Title(text: '수납추가 목록',),
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
          Row(
            children: [
              Expanded(child:TextButton(
                  onPressed: () async {
                    if(tslistCr.length < 1) { WidgetT.showSnackBar(context, text: '최소 1개 이상의 거래기록을 입력 후 시도해주세요.'); return; }
                    for(var t in tslistCr) {
                      if(t.amount < 1) { WidgetT.showSnackBar(context, text: '하나 이상의 거래데이터의 금액이 비정상 적입니다. ( 0원 )'); return; }
                      if(t.transactionAt == 0) {WidgetT.showSnackBar(context, text: '날짜를 정확히 입력해 주세요.'); return; }
                    }

                    var alert = await DialogT.showAlertDl(context, title: '수납현황' ?? 'NULL');
                    if(alert == false) {
                      WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                      return;
                    }

                    for(var ts in tslistCr) {
                      if(widget.cs != null) ts.csUid = widget.cs!.id;
                      await ts.update();
                    }

                    WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');

                    await widget.refresh();
                    widget.parent.onCloseButtonClicked!();
                  },
                  style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                  child: Container(
                      color: StyleT.accentColor.withOpacity(0.5), height: 42,
                      child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WidgetT.iconMini(Icons.check_circle),
                          Text('수납 저장', style: StyleT.titleStyle(),),
                          SizedBox(width: 6,),
                        ],
                      )
                  )
              ),),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}
