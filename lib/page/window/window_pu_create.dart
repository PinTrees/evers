import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/purchase.dart';
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
import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';

class WindowPUCreate extends StatefulWidget {
  Customer cs;
  ResizableWindow parent;
  Function refresh;

  WindowPUCreate({ required this.cs, required this.refresh, required this.parent }) : super(key: UniqueKey()) { }

  @override
  _WindowPUCreateState createState() => _WindowPUCreateState();
}

class _WindowPUCreateState extends State<WindowPUCreate> {
  var dividHeight = 6.0;
  var heightSize = 36.0;

  var payment = '매입';
  var payType = '';

  var vatTypeList = [ 0, 1, ];
  var vatTypeNameList = [ '포함', '미포함', ];
  var currentVatType = 0;


  List<Purchase> pus = [];

  List<Map<String, Uint8List>> fileByteList = [];
  Contract ct = Contract.fromDatabase({});
  Customer? cs;
  var isContractLinking = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //widget.parent.title = '수납 개별 상세정보 수정창';

    /// 최초 실행시 기초 품목매입 1개를 추가합니다.
    var pu = Purchase.fromDatabase({});
    pu.purchaseAt = DateTime.now().microsecondsSinceEpoch;
    pus.add(pu);
    fileByteList.add({});

    initAsync();
  }

  /// 이 함수는 동기 초기화를 시도합니다.
  /// 상속구조로 재설계 되어야 합니다.
  void initAsync() async {
    setState(() {});
  }


  ///  이 함수는 매인 위젯을 렌더링 합니다.
  ///  상속구조로 재설계 되어야 합니디.
  Widget mainBuild() {
    List<Widget> widgetsPu = [];
    widgetsPu.add(CompPU.tableHeader());
    for(int i = 0; i < pus.length; i++) {
      var pu = pus[i];
      var fileMap = fileByteList[i] as Map<String, Uint8List>;

      if(pu.state == "DEL") {
        pus.removeAt(i);
        fileByteList.removeAt(i--);
        continue;
      }

      pu.vatType = currentVatType;
      pu.init();

      var w = CompPU.tableUIInput(context, pu,
        index: i + 1,
        fileByteList: fileMap,
        setState: () { setState(() {}); }
      );
      widgetsPu.add(w);
      widgetsPu.add(WidgetT.dividHorizontal(size: 0.35));
    }

    var dividCol = Column(
      children: [
        SizedBox(height: dividHeight * 4,),
        SizedBox(height: dividHeight * 4,),
      ],
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
                WidgetT.title('등록유형', size: 16 ),
                SizedBox(height: dividHeight,),
                TextT.Title(text: "거래처 정보"),
                TextT.Lit(text: widget.cs.businessName),
                dividCol,

                TextT.Title(text: "매입 추가 목록"),
                SizedBox(height: dividHeight,),
                Container( child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgetsPu, ),),
                SizedBox(height: dividHeight,),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          var p = Purchase.fromDatabase({});
                          p.purchaseAt = DateTime.now().microsecondsSinceEpoch;
                          pus.add(p);
                          fileByteList.add({});

                          setState(() {});
                        },
                        style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                            color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                        child: Container(padding: EdgeInsets.all(0), child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container( height: 28, width: 28,
                              child: WidgetT.iconMini(Icons.add_box),),
                            WidgetT.title('매입추가'),
                            SizedBox(width: 6,),
                          ],
                        ))
                    ),
                    SizedBox(width: dividHeight,),
                    Row(
                      children: [
                        WidgetT.title('지불관련', width: 100 ),
                        for(var v in vatTypeList)
                          Container(
                            padding: EdgeInsets.only(right: dividHeight),
                            child: TextButton(
                                onPressed: () {
                                  currentVatType = v;
                                  setState(() {});
                                },
                                style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                                    color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                                child: Container(padding: EdgeInsets.all(0), child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if(currentVatType != v)
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                                    if(currentVatType == v)
                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.check_box),),
                                    WidgetT.title('부가세 ' + vatTypeNameList[v] ),
                                    SizedBox(width: 6,),
                                  ],
                                ))
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 6,),
                    WidgetT.text('품목 직접 입력시 재고 및 단가 연동 불가.   연동이 필요한 품목은 생산관리에서 추가후 입력해 주세요.', size: 10),
                  ],
                ),

                dividCol,

                TextT.Title(text: "지불관련"),
                SizedBox(height: dividHeight,),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          payment = '매입';
                          setState(() {});
                        },
                        style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                            color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if(payment != '매입')
                              Container( height: 28, width: 28,
                                child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                            if(payment == '매입')
                              Container( height: 28, width: 28,
                                child: WidgetT.iconMini(Icons.check_box),),
                            WidgetT.title('매입만'),
                            SizedBox(width: 6,),
                          ],
                        )
                    ),
                    SizedBox(width: dividHeight,),
                    TextButton(
                        onPressed: () {
                          payment = '즉시';
                          setState(() {});
                          },
                        style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                            color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if(payment != '즉시')
                              Container( height: 28, width: 28,
                                child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                            if(payment == '즉시')
                              Container( height: 28, width: 28,
                                child: WidgetT.iconMini(Icons.check_box),),
                            WidgetT.title('즉시지불'),
                            SizedBox(width: 6,),
                          ],
                        )
                    ),
                    SizedBox(width: dividHeight,),
                    if(payment == '즉시')
                      Row(
                        children: [
                          WidgetT.dropMenuMapD(dropMenuMaps: SystemT.accounts, width: 130, label: '구분',
                            onEdite: (i, data) {
                              payType = data;
                              print('select account: ' + payType);
                            },
                            text: (SystemT.accounts[payType] == null) ? '선택안됨' : SystemT.accounts[payType]!.name,
                          ),
                          SizedBox(width: dividHeight,),
                          WidgetT.text('즉시수금 시 적요는 품목명으로 추가됩니다.', size: 10),
                        ],
                      ),
                  ],
                ),
              ],
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
        ButtonT.Action("매입 추가하기",
          expend: true,
          icon: Icons.save, backgroundColor: StyleT.accentColor.withOpacity(0.5),
          onTap: () async {
            if(cs == null) { WidgetT.showSnackBar(context, text: '거래처는 비워둘 수 없습니다.'); return; }
            if(payment == '즉시' && payType == '') { WidgetT.showSnackBar(context, text: '결제방법은 비워둘 수 없습니다.'); return;  }

            var alert = await DialogT.showAlertDl(context, text: "매입정보를 저장하시겠습니까?");
            if(alert == false) {  WidgetT.showSnackBar(context, text: '취소됨'); return;   }

            for(int i = 0; i < pus.length; i++) {
              var p = pus[i]; var files = fileByteList[i] as Map<String, Uint8List>;

              p.csUid = cs!.id;
              p.vatType = currentVatType;

              /// 매입정보 추가 - 매입데이터 및 거래명세서 파일 데이터
              await p.update(files: files);
              /// 지불 정보 문서 추가
              if(payment == '즉시')
                await TS.fromPu(p, payType, now: true).update();
            }

            WidgetT.showSnackBar(context, text: '저장됨');
            widget.refresh!();
            widget.parent.onCloseButtonClicked!();
          },
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}
