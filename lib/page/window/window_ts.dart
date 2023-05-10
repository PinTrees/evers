import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
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
import '../../helper/dialog.dart';
import '../../helper/interfaceUI.dart';

class WindowTS extends StatefulWidget {
  Customer cs;
  ResizableWindow parent;
  Function refresh;

  WindowTS({ required this.cs, required this.refresh, required this.parent }) : super(key: UniqueKey()) { }

  @override
  _WindowTSState createState() => _WindowTSState();
}

class _WindowTSState extends State<WindowTS> {
  var dividHeight = 6.0;
  List<TS> tslistCr = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tslistCr.add(TS.fromDatabase({ 'transactionAt': DateTime.now().microsecondsSinceEpoch, 'type': 'PU' }));
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

      var w = tmpTs.OnTableUIInput(
        index: i + 1,
        context: context, cs: widget.cs,
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
                TextT.Lit(text: widget.cs.businessName ),
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
                SizedBox(height: dividHeight * 8,),
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
                      ts.csUid = widget.cs.id;
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
