import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/widget/list.dart';
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
import '../../class/contract.dart';
import '../../class/database/item.dart';
import '../../class/system.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/text.dart';
import '../../core/window/ResizableWindow.dart';
import '../../core/window/window_base.dart';
import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';

class WindowPUEditor extends WindowBaseMDI {
  Purchase pu;
  Function refresh;

  WindowPUEditor({ required this.pu, required this.refresh,}) { }

  @override
  _WindowPUEditorState createState() => _WindowPUEditorState();
}

class _WindowPUEditorState extends State<WindowPUEditor> {
  var dividHeight = 6.0;
  late Purchase pu;

  Map<String, Uint8List> fileByteList = {};
  Contract ct = Contract.fromDatabase({});
  Customer? cs;
  var isContractLinking = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.parent.title = '수납 개별 상세정보 수정창';

    var jsonString = jsonEncode(widget.pu.toJson());
    var json = jsonDecode(jsonString);
    pu = Purchase.fromDatabase(json);

    initAsync();
  }

  void initAsync() async {
    if (pu.csUid != '') cs = await DatabaseM.getCustomerDoc(pu.csUid);
    if (pu.ctUid != '') { ct = await DatabaseM.getContractDoc(pu.ctUid); isContractLinking = true;  }

    setState(() {});
  }




  Widget mainBuild() {
    pu.init();

    List<Widget> widgetsPu = [];
    widgetsPu.add(CompPU.tableHeaderEditor());
    widgetsPu.add(CompPU.tableUIEditor(context, pu,
      fileByteList: fileByteList, cs: cs,
      setState: () { setState(() {}); },
    ));

    /// 매입 수정 UI
    var widgetPU = Column(children: widgetsPu,);


    var customerWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: '거래처'),
        TextT.Lit(text: cs == null ? '-' : cs!.businessName),
      ],
    );
    var contractWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.Title(text: '계약명'),
        SizedBox(height: dividHeight,),
        Container(
            height: 36, width: 250, alignment: Alignment.center,
            decoration: StyleT.inkStyle(color: Colors.black.withOpacity(0.02), stroke: 2, strokeColor: Colors.grey.withOpacity(0.35)),
            child: Row( mainAxisSize: MainAxisSize.min,
              children: [
                WidgetT.title(ct.ctName, width: 250),
              ],
            )),
      ],
    );

    var deleteWidget =  ButtonT.IconText(
      icon: Icons.delete_forever,
      text: "매입 삭제",
      onTap: () async {
        if(!await DialogT.showAlertDl(context, text:'삭제하시겠습니까?')) {
          WidgetT.showSnackBar(context, text: '취소됨');
          return;
        }

        WidgetT.loadingBottomSheet(context);
        await DatabaseM.deletePu(pu);
        Navigator.pop(context);

        WidgetT.showSnackBar(context, text: '삭제됨');
        widget.refresh();
        widget.parent.onCloseButtonClicked!();
        },
    );

    var fileEditeWidget =  ButtonT.IconText(
      icon: Icons.file_copy_rounded, text: "파일첨부",
      onTap: () async {
        FilePickerResult? result;
        try {
          result = await FilePicker.platform.pickFiles();
        } catch (e) {
          WidgetT.showSnackBar(context, text: '파일선택 오류');
        }
        if(result != null){
          WidgetT.showSnackBar(context, text: '파일선택');
          if(result.files.isNotEmpty) {
            String fileName = result.files.first.name;
            fileByteList[fileName] = result.files.first.bytes!;
            print(fileByteList[fileName]!.length);
          }
        }
        setState(() {});
      },
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
                customerWidget,
                SizedBox(height: dividHeight * 4,),

                TextT.SubTitle(text: '매입정보'),
                SizedBox(height: dividHeight,),
                widgetPU,
                SizedBox(height: dividHeight,),
                ListBoxT.Rows( spacing: 6, children: [fileEditeWidget,deleteWidget ],),

                SizedBox(height: dividHeight * 4,),
                TextT.SubTitle(text: '변경 기록', more: "현재 매입정보에 대한 수정기록이 표시됩니다."),
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
    return Row(
      children: [
        Expanded(child:TextButton(
            onPressed: () async {
              if(cs == null) { WidgetT.showSnackBar(context, text: '거래처를 선택해 주세요.'); return; }
              var alt = await DialogT.showAlertDl(context, text: '매입개별정보를 저장하시겠습니까?');
              if(!alt) {  WidgetT.showSnackBar(context, text: '취소됨'); return; }

              WidgetT.loadingBottomSheet(context,);

              var result = await pu.update(files: fileByteList);
              if(!result) WidgetT.showSnackBar(context, text: 'Error');
              else WidgetT.showSnackBar(context, text: '저장됨');
              WidgetT.showSnackBar(context, text: '저장됨');

              Navigator.pop(context);

              widget.refresh();
              widget.parent.onCloseButtonClicked!();
            },
            style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
            child: Container(
                color: StyleT.accentColor.withOpacity(0.5), height: 42,
                child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WidgetT.iconMini(Icons.check_circle),
                    Text('매입 저장', style: StyleT.titleStyle(),),
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
