import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_re.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
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

/// 이 윈도우 클래스는 매입추가를 위한 위젯을 렌더링 합니다.
/// 거래처가 이미 정해진 매입을 추가합니다.
/// 위젯 내부에서 거래처를 접근할 수 없습니다.
class WindowProductEditor extends WindowBaseMDI {
  Function refresh;
  Revenue re;

  WindowProductEditor({ required this.re, required this.refresh }) { }

  @override
  _WindowProductEditorState createState() => _WindowProductEditorState();
}
class _WindowProductEditorState extends State<WindowProductEditor> {
  var dividHeight = 6.0;
  var heightSize = 36.0;

  var vatTypeList = [ 0, 1, ];
  var vatTypeNameList = [ '포함', '미포함', ];

  Revenue re = Revenue.fromDatabase({});
  Contract? ct;

  var isContractLinking = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var jsonString = jsonEncode(widget.re.toJson());
    var json = jsonDecode(jsonString);
    re = Revenue.fromDatabase(json);

    initAsync();
  }


  /// 이 함수는 동기 초기화를 시도합니다.
  /// 상속구조로 재설계 되어야 합니다.
  void initAsync() async {
    if (re.ctUid != '') ct = await DatabaseM.getContractDoc(re.ctUid);

    setState(() {});
  }

  ///  이 함수는 매인 위젯을 렌더링 합니다.
  ///  상속구조로 재설계 되어야 합니디.
  Widget mainBuild() {
    List<Widget> widgetReW = [];

    re.init();
    widgetReW.add(CompRE.tableHeaderEdite());
    widgetReW.add(CompRE.tableUIEditor(context, re,
        index: 1, setState: () { setState(() {}); },
    ));
    widgetReW.add(WidgetT.dividHorizontal(size: 0.35));

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
                TextT.Title(text: '매출 정보'),
                SizedBox(height: dividHeight,),
                Container(child: Column(children: widgetReW,),),
                SizedBox(height: dividHeight,),
                Row(
                  children: [
                    ButtonT.IconText(
                      icon: Icons.delete, text: "매출삭제",
                      onTap: () async {
                        var alt = await DialogT.showAlertDl(context, text: "매출정보를 삭제하시겠습니까?");
                        if(!alt) { WidgetT.showSnackBar(context, text: "취소됨"); return; }

                        await re.delete();

                        widget.refresh();
                        widget.parent.onCloseButtonClicked!();
                      }
                    ),
                    SizedBox(width: dividHeight * 8,),
                    WidgetT.title('부가세', size: 12 ),
                    SizedBox(width: dividHeight,),
                    for(var v in vatTypeList)
                      ButtonT.IconText(
                        padding: EdgeInsets.only(right: 6),
                        icon: (re.vatType == v) ? Icons.check_box : Icons.check_box_outline_blank,
                        text: vatTypeNameList[v],
                        onTap: () {
                          re.vatType = v;
                          re.fixedSup = false;
                          re.fixedVat = false;
                          setState(() {});
                        }
                      ),
                    ButtonT.IconText(
                        padding: EdgeInsets.only(right: 6),
                        icon: Icons.auto_mode,
                        text: "금액 자동계산",
                        onTap: () {
                          re.fixedSup = false;
                          re.fixedVat = false;
                          setState(() {});
                        }
                    ),
                  ],
                ),
                SizedBox(height: dividHeight,)
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
    return Row(
      children: [
        Expanded(
          child:TextButton(
              onPressed: () async {
                var alert = await DialogT.showAlertDl(context, text: "매출정보를 저장하시겠습니까?");
                if(alert == false) {
                  WidgetT.showSnackBar(context, text: '취소됨');
                  return;
                }

                var task = await re.update();
                WidgetT.showSnackBar(context, text: '저장됨');

                widget.refresh();
                widget.parent.onCloseButtonClicked!();
              },
              style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
              child: Container(
                  color: StyleT.accentColor.withOpacity(0.5), height: 42,
                  child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WidgetT.iconMini(Icons.save),
                      Text('매출 저장', style: StyleT.titleStyle(),),
                      SizedBox(width: 6,),
                    ],
                  )
              )
          ),),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}