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
import 'package:url_launcher/url_launcher.dart';

import '../../class/Customer.dart';
import '../../class/database/item.dart';
import '../../class/schedule.dart';
import '../../class/system.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/text.dart';
import '../../core/window/ResizableWindow.dart';
import '../../helper/aes.dart';
import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';
import '../../helper/pdfx.dart';
import '../../ui/ip.dart';
import '../../ui/ux.dart';

class WindowFactoryCreate extends StatefulWidget {
  ResizableWindow parent;
  Function refresh;

  WindowFactoryCreate({ required this.refresh, required this.parent }) : super(key: UniqueKey()) { }

  @override
  _WindowFactoryCreateState createState() => _WindowFactoryCreateState();
}

class _WindowFactoryCreateState extends State<WindowFactoryCreate> {

  var dividHeight = 6.0;
  Map<String, Uint8List> fileByteList = {};
  var date = DateTime.now();
  FactoryD factoryD = FactoryD.fromDatabase({});
  List<ItemFD> itemSv = [];
  List<ItemFD> itemSvC = [];
  bool isPop = false;

  @override
  void initState() {
    // TODO: implement initState
    widget.parent.title = '공장일보 개별 입력창';
    super.initState();
  }

  dynamic initAsync() async {
    factoryD.date = date.microsecondsSinceEpoch;
    date = DateTime.fromMicrosecondsSinceEpoch(factoryD.date);

    itemSv = factoryD.itemSvPu.entries.map((entry) => ItemFD.fromDatabase({ 'id': entry.key, 'count': entry.value })).toList();
    itemSvC = factoryD.itemSvRe.entries.map((entry) => ItemFD.fromDatabase({ 'id': entry.key, 'count': entry.value })).toList();

    setState(() {});
  }
  Widget mainBuild() {

    List<Widget> widgetsItemSv = [];
    widgetsItemSv.add(WidgetUI.titleRowNone([ '순번', '품목', '수량', '단가', '금액' ], [ 28, 150, 50, 100, 100]));
    widgetsItemSv.add(WidgetT.dividHorizontal(size: 0.7));
    for(int i = 0; i < itemSv.length; i++) {
      var sv = itemSv[i];
      var item = SystemT.getItem(sv.id) ?? Item.fromDatabase({});
      var w =  InkWell(
        child: Container(
          height: 32,
          child: Row(
            children: [
              WidgetEX.excelGrid(label: '${i + 1}', width: 28),
              WidgetT.excelInput(context, '$i::fd.품목', index: i, hint: '품목 검색', width: 150, text: item.name,
                  onEdite: (i, data) async {
                    if(data == '') return;
                    if(data == itemSv[i].id) return;

                    List<Item> its = await SystemT.searchItMeta(data);
                    if(its.length > 0 && !isPop) {
                      isPop = true;
                      Item? it = await DialogIT.selectItem(context, its);
                      isPop = false;

                      if(it != null) {
                        if(it.type != 'PU') { WidgetT.showSnackBar(context, text: '원자재 품목이 아닙니다. 다시 선택해 주세요.'); }
                        else  {
                          if(itemSv.where((e) => e.id == it.id).isNotEmpty) { WidgetT.showSnackBar(context, text: '해당 품목이 이미 선택되어 있습니다.'); }
                          else itemSv[i].id = it.id;
                        }
                      }else {
                        itemSv[i].id = '';
                      }
                    } else {
                      itemSv[i].id = '';
                    }
                  }),
              WidgetT.excelInput(context, '$i::fd.수량', index: i, hint: '수량 입력', width: 50, text: StyleT.krwInt(sv.count) + item.unit,
                  value: sv.count.toString(),
                  onEdite: (i, data) async {
                    itemSv[i].count = int.tryParse(data) ?? 0;
                  }),
              WidgetT.excelGrid(textLite: true, text: StyleT.krwInt(item.unitPrice), width: 100),
              WidgetT.excelGrid(textLite: true, text: StyleT.krwInt(item.unitPrice * sv.count) , width: 100),

              Expanded(child: SizedBox()),
              TextButton(
                onPressed: () {
                  itemSv.removeAt(i);
                  FunT.setStateDT();
                },
                style: StyleT.buttonStyleNone(padding: 0, elevation: 0, color: Colors.transparent),
                child: WidgetT.iconMini(Icons.close, size: 32),
              )
            ],
          ),
        ),
      );
      widgetsItemSv.add(w);
      widgetsItemSv.add(WidgetT.dividHorizontal(size: 0.35));
    }

    List<Widget> widgetsItemSvC = [];
    widgetsItemSvC.add(WidgetUI.titleRowNone([ '순번', '품목', '수량', '단가', '금액' ], [ 28, 150, 50, 100, 100]));
    widgetsItemSvC.add(WidgetT.dividHorizontal(size: 0.7));
    for(int i = 0; i < itemSvC.length; i++) {
      var sv = itemSvC[i];
      var item = SystemT.getItem(sv.id) ?? Item.fromDatabase({});
      var w =  InkWell(
        child: Container(
          height: 32,
          child: Row(
            children: [
              WidgetEX.excelGrid(label: '${i + 1}', width: 28),
              WidgetT.excelInput(context, '$i::fd.re.품목', index: i, hint: '품목 검색', width: 150, text: item.name,
                  onEdite: (i, data) async {
                    if(data == '') return;
                    if(data == itemSvC[i].id) return;

                    List<Item> its = await SystemT.searchItMeta(data);
                    if(its.length > 0 && !isPop) {
                      isPop = true;
                      Item? it = await DialogIT.selectItem(context, its);
                      isPop = false;

                      if(it != null) {
                        if(it.type != 'RE') { WidgetT.showSnackBar(context, text: '생상품 품목이 아닙니다. 다시 선택해 주세요.'); }
                        else  {
                          if(itemSvC.where((e) => e.id == it.id).isNotEmpty) { WidgetT.showSnackBar(context, text: '해당 품목이 이미 선택되어 있습니다.'); }
                          else itemSvC[i].id = it.id;
                        }
                      }else {
                        itemSvC[i].id = '';
                      }
                    } else {
                      itemSvC[i].id = '';
                    }
                  }),
              WidgetT.excelInput(context, '$i::fd.re.수량', index: i, hint: '수량 입력', width: 50, text: StyleT.krwInt(sv.count) + item.unit,
                  value: sv.count.toString(),
                  onEdite: (i, data) async {
                    itemSvC[i].count = int.tryParse(data) ?? 0;
                  }),
              WidgetT.excelGrid(textLite: true, text: StyleT.krwInt(item.unitPrice), width: 100),
              WidgetT.excelGrid(textLite: true, text: StyleT.krwInt(item.unitPrice * sv.count) , width: 100),

              Expanded(child: SizedBox()),
              TextButton(
                onPressed: () {
                  itemSvC.removeAt(i);
                  FunT.setStateDT();
                },
                style: StyleT.buttonStyleNone(padding: 0, elevation: 0, color: Colors.transparent),
                child: WidgetT.iconMini(Icons.close, size: 32),
              )
            ],
          ),
        ),
      );
      widgetsItemSvC.add(w);
      widgetsItemSvC.add(WidgetT.dividHorizontal(size: 0.35));
    }

    var dividCol = SizedBox(height:  dividHeight * 8,);
    var btnStyle = StyleT.buttonStyleOutline(round: 8, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7);
    var gridStyle = StyleT.inkStyle(round: 8, color: Colors.black.withOpacity(0.03),
        stroke: 1.4, strokeColor: StyleT.titleColor.withOpacity(0.15));

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(dividHeight * 3),
                  child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TextT.Title(text: '원자재 사용량',),
                          SizedBox(width: dividHeight * 2,),
                          ButtonT.IconText(
                            icon: Icons.add_box,
                            text: '사용한 원자재 추가',
                            onTap: () {
                              itemSv.add(ItemFD.fromDatabase({}));
                              setState(() { });
                            },
                          )
                        ],
                      ),

                      SizedBox(height: dividHeight,),
                      Column(children: widgetsItemSv,),
                      dividCol,

                      Row(
                        children: [
                          TextT.Title(text: '생산품 생산량',),
                          SizedBox(width: dividHeight * 2,),
                          ButtonT.IconText(
                            icon: Icons.add_box,
                            text: '생산된 생산품 추가',
                            onTap: () {
                              itemSvC.add(ItemFD.fromDatabase({}));
                              setState(() { });
                            },
                          )
                        ],
                      ),

                      SizedBox(height: dividHeight,),
                      Column(children: widgetsItemSvC,),
                      dividCol,
                      Row(
                        children: [
                          TextT.Title(text: '공장일보 일자',),
                          SizedBox(width: dividHeight * 2,),
                          ButtonT.IconText(
                            icon: Icons.timelapse,
                            text: StyleT.dateFormatAll(date),
                            onTap: () async {
                              var selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(), // 초깃값
                                firstDate: DateTime(2018), // 시작일
                                lastDate: DateTime(2030), // 마지막일
                              );
                              if(selectedDate != null) {
                                date = selectedDate;
                              }
                              setState(() {});
                            },
                          ),
                          SizedBox(width: dividHeight,),
                          ButtonT.IconText(
                            icon: Icons.timelapse,
                            text: '시간변경',
                            onTap: () async {
                              final TimeOfDay? timeT = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(hour: date.hour, minute: date.minute,),
                              );
                              if(timeT != null) {
                                date = DateTime(date.year, date.month, date.day, timeT.hourOfPeriod + timeT.periodOffset, timeT.minute, );
                              }
                              setState(() {    });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: dividHeight,),
                      Container( decoration: gridStyle,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Column(children: [
                            Container( padding: EdgeInsets.all(0),
                              child: IntrinsicHeight(
                                child: Row(
                                    children: [
                                      WidgetEX.excelTitle(width: 150, text: '내용',),
                                      WidgetT.dividViertical(),
                                      Expanded(child: WidgetTF.textTitInput(context, '내용', isMultiLine: true, textSize: 12,
                                        onEdite: (i, data) { factoryD.memo = data; },
                                        text: factoryD.memo,
                                      ),)
                                    ]
                                ),
                              ),
                            ),
                            WidgetT.dividHorizontal(size: 0.35),
                            Container(
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      SizedBox(width: dividHeight, height: 28,),
                                      WidgetT.text('첨부파일', size: 10),
                                      SizedBox(width: dividHeight,),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                            padding: EdgeInsets.all(dividHeight),
                                            child: Wrap(
                                              runSpacing: dividHeight, spacing: dividHeight * 3,
                                              children: [
                                                for(int i = 0; i < fileByteList.length; i++)
                                                  Row(
                                                    children: [
                                                      InkWell(
                                                          onTap: () {
                                                            PDFX.showPDFtoDialog(context, data: fileByteList.values.elementAt(i), name: fileByteList.keys.elementAt(i));
                                                          },
                                                          child: Container(
                                                              decoration: StyleT.inkStyle(stroke: 0.35, round: 8, color: StyleT.accentLowColor.withOpacity(0.05)),
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  SizedBox(width: 6,),
                                                                  WidgetT.title(fileByteList.keys.elementAt(i),),
                                                                  TextButton(
                                                                      onPressed: () {
                                                                        fileByteList.remove(fileByteList.keys.elementAt(i));
                                                                        setState(() { });
                                                                      },
                                                                      style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                                                      child: Container( height: 28, width: 28,
                                                                        child: WidgetT.iconMini(Icons.cancel),)
                                                                  ),
                                                                ],
                                                              ))
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),)),
                                    ],
                                  ),
                                )
                            ),
                          ],),
                        ),),
                      SizedBox(height: dividHeight,),
                      Row(
                        children: [
                          ButtonT.IconText(
                            icon: Icons.file_copy_rounded,
                            text: '파일선택',
                            onTap: () async {
                              FilePickerResult? result;
                              try {
                                result = await FilePicker.platform.pickFiles();
                              } catch (e) {
                                WidgetT.showSnackBar(context, text: '파일선택 오류');
                                print(e);
                              }
                              if(result != null){
                                WidgetT.showSnackBar(context, text: '파일선택');
                                if(result.files.isNotEmpty) {
                                  String fileName = result.files.first.name;
                                  Uint8List fileBytes = result.files.first.bytes!;
                                  fileByteList[fileName] = fileBytes;
                                }
                              }
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          /// action
          Row(
            children: [
              Expanded(child:TextButton(
                  onPressed: () async {
                    var alert = await DialogT.showAlertDl(context, title: factoryD.memo ?? 'NULL');
                    if(alert == false) {
                      WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                      return;
                    }

                    WidgetT.loadingBottomSheet(context, text: '저장중');

                    factoryD.itemSvPu = Map.fromIterable(itemSv, key: (item) => item.id, value: (item) => item.count);
                    factoryD.itemSvRe = Map.fromIterable(itemSvC, key: (item) => item.id, value: (item) => item.count);
                    //print(factoryD.itemSvPu);
                    //print(factoryD.itemSvRe);
                    factoryD.date = date.microsecondsSinceEpoch;
                    await DatabaseM.updateFactoryDWithFile(factoryD, files: fileByteList);

                    WidgetT.showSnackBar(context, text: '저장됨');
                    await widget.refresh();
                    widget.parent.onCloseButtonClicked!();
                  },
                  style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                  child: Container(
                      color: StyleT.accentColor.withOpacity(0.5), height: 42,
                      child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WidgetT.iconMini(Icons.check_circle),
                          Text('공장일보 저장', style: StyleT.titleStyle(),),
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
