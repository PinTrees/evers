import 'package:evers/class/component/comp_re.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import '../../class/contract.dart';
import '../../class/revenue.dart';
import '../../class/system.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/text.dart';
import '../../helper/dialog.dart';
import '../../helper/interfaceUI.dart';




/// 이 윈도우 클래스는 일정추가를 위한 위젯을 렌더링 합니다.
class WindowSchCreate extends WindowBaseMDI {
  Function refresh;

  WindowSchCreate({ required this.refresh }) { }

  @override
  _WindowSchCreateState createState() => _WindowSchCreateState();
}
class _WindowSchCreateState extends State<WindowSchCreate> {
  var dividHeight = 6.0;
  var heightSize = 36.0;

  var payment = '매입';
  var payType = '';

  var vatTypeList = [ 0, 1, ];
  var vatTypeNameList = [ '포함', '미포함', ];
  var currentVatType = 0;

  List<Revenue> revenueList = [];
  List<Contract> revContract = [];

  var isContractLinking = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /// 최초 실행시 기초 품목매입 1개를 추가합니다.
    revenueList.add(Revenue.fromDatabase({ 'revenueAt': DateTime.now().microsecondsSinceEpoch, }));
    revContract.add(Contract.fromDatabase({}));

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
    List<Widget> widgetReW = [];
    widgetReW.add(CompRE.tableHeaderSearch());
    for(int i = 0; i < revenueList.length; i++) {
      var re = revenueList[i];
      var ct = revContract[i];

      if(re.state == "DEL") {
        revenueList.removeAt(i);
        revContract.removeAt(i--);
        continue;
      }

      re.vatType = currentVatType;
      re.init();

      var w = CompRE.tableUIInput(context, re,
        index: i + 1, ct: ct,
        setState: () { setState(() {}); }
      );
      widgetReW.add(w);
      widgetReW.add(WidgetT.dividHorizontal(size: 0.35));
    }

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
                TextT.Title(text: '추가할 매출 목록'),
                SizedBox(height: dividHeight,),
                Container( child: Column(children: widgetReW,),),
                SizedBox(height: dividHeight,),
                Row(
                  children: [
                    ButtonT.IconText(
                      icon: Icons.add_box, text: "매출추가",
                      onTap: () {
                        revenueList.add(Revenue.fromDatabase({ 'revenueAt': DateTime.now().microsecondsSinceEpoch, }));
                        revContract.add(Contract.fromDatabase({}));
                        setState(() {});
                      }
                    ),
                    SizedBox(width: dividHeight * 8,),
                    WidgetT.title('부가세', size: 12 ),
                    SizedBox(width: dividHeight,),
                    for(var v in vatTypeList)
                      Container(
                        child: InkWell(
                            onTap: () {
                              currentVatType = v;
                              setState(() {});
                            },
                            child: Container(
                                height: 36,
                                padding: EdgeInsets.all(dividHeight), alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(width: dividHeight,),
                                    WidgetT.titleT('' + vatTypeNameList[v], size: 14,
                                      color: (currentVatType == v) ? StyleT.titleColor : StyleT.textColor.withOpacity(0.35),
                                    ),
                                    SizedBox(width: dividHeight,),
                                  ],
                                ))
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 6 * 8,),
                TextT.Title(text: '지불관련'),
                SizedBox(height: dividHeight,),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          payment = '매출';
                          setState(() {});
                        },
                        style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                            color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                        child: Container(padding: EdgeInsets.all(0), child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if(payment != '매출')
                              Container( height: 28, width: 28,
                                child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                            if(payment == '매출')
                              Container( height: 28, width: 28,
                                child: WidgetT.iconMini(Icons.check_box),),
                            WidgetT.title('매출만'),
                            SizedBox(width: 6,),
                          ],
                        ))
                    ),
                    SizedBox(width: dividHeight,),
                    TextButton(
                        onPressed: () {
                          payment = '즉시';
                          setState(() {});
                        },
                        style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0,
                            color: StyleT.backgroundColor.withOpacity(0.5), strock: 1),
                        child: Container(padding: EdgeInsets.all(0), child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if(payment != '즉시')
                              Container( height: 28, width: 28,
                                child: WidgetT.iconMini(Icons.check_box_outline_blank),),
                            if(payment == '즉시')
                              Container( height: 28, width: 28,
                                child: WidgetT.iconMini(Icons.check_box),),
                            WidgetT.title('수금추가'),
                            SizedBox(width: 6,),
                          ],
                        ))
                    ),

                    if(payment == '즉시')
                      Row(
                        children: [
                          WidgetT.dropMenuMapD(dropMenuMaps: SystemT.accounts, width: 130, label: '구분',
                            onEdite: (i, data) {
                              payType = data;
                              setState(() {});
                            },
                            text: (SystemT.accounts[payType] == null) ? '선택안됨' : SystemT.accounts[payType]!.name,
                          ),
                          SizedBox(width: dividHeight,),
                          WidgetT.text('즉시수금 시 적요는 품목명으로 추가됩니다.', size: 10),
                        ],
                      ),
                  ],
                ),
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
                for(int i = 0; i < revenueList.length; i++) {
                  if(revContract[i].ctName == '') {
                    WidgetT.showSnackBar(context, text: '거래처 및 계약은 비워둘 수 없습니다.');
                    return;
                  }
                  if(revContract[i].reactive == 0) {
                    WidgetT.showSnackBar(context, text: "날짜를 정확히 입력해 주세요.");
                    return;
                  }
                }

                if(revenueList.length < 1) { WidgetT.showSnackBar(context, text: '매출을 추가한 후 저장을 시도하세요.'); return; }
                if(payment == '즉시' && payType == '') { WidgetT.showSnackBar(context, text: "즉시결재를 선택시 결재방법을 비워둘 없습니다."); return;  }

                var alert = await DialogT.showAlertDl(context, title: 'NULL' ?? 'NULL');
                if(alert == false) {
                  WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                  return;
                }

                for(int i = 0; i < revenueList.length; i++) {
                  var revenue = revenueList[i];
                  revenue.ctUid = revContract[i].id;
                  revenue.csUid = revContract[i].csUid;
                  var task = await revenue.update();

                  if(task) {
                    if(payment == '즉시') await TS.fromRe(revenue, payType, now: true).update();
                  }
                  else {
                    WidgetT.showSnackBar(context, text: 'Database Error');
                    Navigator.pop(context);
                  }
                }

                WidgetT.showSnackBar(context, text: '저장됨');
                Navigator.pop(context);
              },
              style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
              child: Container(
                  color: StyleT.accentColor.withOpacity(0.5), height: 42,
                  child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WidgetT.iconMini(Icons.check_circle),
                      Text('신규 매출 추가', style: StyleT.titleStyle(),),
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



