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
import '../../class/component/comp_ts.dart';
import '../../class/system.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/text.dart';
import '../../core/window/ResizableWindow.dart';
import '../../helper/dialog.dart';
import '../../helper/interfaceUI.dart';

class WindowTSEditor extends StatefulWidget {
  TS ts;
  Customer? cs;
  ResizableWindow parent;
  Function refresh;

  WindowTSEditor({ required this.ts, required this.cs, required this.refresh, required this.parent }) : super(key: UniqueKey()) { }

  @override
  _WindowTSEditorState createState() => _WindowTSEditorState();
}

class _WindowTSEditorState extends State<WindowTSEditor> {
  var dividHeight = 6.0;
  late TS ts;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.parent.title = '수납 개별 상세정보 수정창';

    var jsonString = jsonEncode(widget.ts.toJson());
    var json = jsonDecode(jsonString);
    ts = TS.fromDatabase(json);
  }

  Widget main = SizedBox();

  Widget mainBuild() {
    List<Widget> tsCW = [];

    var w = CompTS.tableUIEditor(
      context, ts,
      cs: widget.cs, index: 1,
      onClose: widget.parent.onCloseButtonClicked,
      setState: () { setState(() {}); },
      refresh: widget.refresh,
    );
    tsCW.add(w);
    tsCW.add(WidgetT.dividHorizontal(size: 0.35));

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
                TextT.Lit(text: widget.cs == null ? 'ㅡ' : widget.cs!.businessName ),
                SizedBox(height: dividHeight * 4,),

                TextT.Title(text: '수납추가 목록',),
                SizedBox(height: dividHeight,),
                TS.OnTableHeader(),
                for(var w in tsCW) w,
                SizedBox(height: dividHeight,),
              ],
            ),
          ),
          /// action
          Row(
            children: [
              Expanded(child:TextButton(
                  onPressed: () async {
                    var alert = await DialogT.showAlertDl(context, title: '수납현황' ?? 'NULL');
                    if(alert == false) {
                      WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                      return;
                    }

                    await ts.update();

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
