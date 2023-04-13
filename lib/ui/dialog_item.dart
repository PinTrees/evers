import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../class/Customer.dart';
import '../class/contract.dart';
import '../class/purchase.dart';
import '../class/schedule.dart';
import '../class/system.dart';
import '../class/transaction.dart';
import '../helper/aes.dart';
import '../helper/dialog.dart';
import '../helper/firebaseCore.dart';
import '../helper/interfaceUI.dart';
import '../helper/pdfx.dart';
import 'dl.dart';
import 'package:http/http.dart' as http;
import '../class/database/item.dart';

import 'ip.dart';
import 'ux.dart';


/// 품목 관련 함수 래핑 클래스
///
///
class DialogIT extends StatelessWidget {

  static dynamic showItemDl(BuildContext context, { Item? org }) async {
    var dividHeight = 6.0;
    Item item = org ?? Item.fromDatabase({});

    if(org == null) {
      item.type =  MetaT.itemType.keys.first;
      item.group =  MetaT.itemGroup.keys.first;
    }


    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();
              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.dlColor, width: 0.35),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '품목', ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(dividHeight * 3),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            WidgetT.dropMenu(dropMenuMaps: MetaT.itemType, width: 130, label: '구분',
                              onEdite: (i, data) {
                                item.type = data;
                                print(item.type);
                              },
                              text: MetaT.itemType[item.type] ?? '',
                            ),
                            SizedBox(width: dividHeight,),
                            WidgetT.text('( 원자재 / 생산품 )', size:10),
                            WidgetT.dropMenu(dropMenuMaps: MetaT.itemGroup, width: 130, label: '품목분류',
                              onEdite: (i, data) {
                                item.group = data;
                              },
                              text: MetaT.itemGroup[item.group] ?? '',
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            WidgetT.title('표시', width: 100),
                            TextButton(
                                onPressed: () {
                                  item.display = !item.display;
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleNone(padding: 0, elevation: 0, color: Colors.transparent),
                                child: WidgetT.iconMini(item.display ? Icons.check_box : Icons.check_box_outline_blank, size: 32)),
                            WidgetT.text('( 메인화면 및 생산관리 화면 표시 )', size:10),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        WidgetT.textInput(context, '품목이름', width: 200, label: '품목이름',
                          onEdite: (i, data) { item.name = data; },
                          text: item.name,
                        ),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            WidgetT.textInput(context, '단위', width: 100, label: '단위',
                              onEdite: (i, data) { item.unit = data; },
                              text: item.unit,
                            ),
                            SizedBox(width: dividHeight,),
                            WidgetT.text('( ton / L / kg / ㎡ )', size:10),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            WidgetT.textInput(context, '단가', width: 100, label: '단가',
                              onEdite: (i, data) {
                                var a = int.tryParse(data) ?? 0;
                                item.unitPrice = a;
                              },
                              text: StyleT.krw(item.unitPrice.toString()),
                              value: item.unitPrice.toString(),
                            ),
                            WidgetT.textInput(context, '원가', width: 100, label: '원가',
                              onEdite: (i, data) {
                                var a = int.tryParse(data) ?? 0;
                                item.cost = a;
                              },
                              text: StyleT.krw(item.cost.toString()),
                              value: item.cost.toString(),
                            ),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            WidgetT.title('메모', width: 100 ),
                            Expanded(
                              child: WidgetT.textInput(context, '메모', height: 56, isMultiLine: true,
                                onEdite: (i, data) { item.memo = data; },
                                text: item.memo,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  Row(
                    children: [
                      Expanded(child:TextButton(
                          onPressed: () async {
                            if(item.name == '') { WidgetT.showSnackBar(context, text: '품목 이름을 입력해 주세요.'); return; }
                            if(item.unit == '') { WidgetT.showSnackBar(context, text: '품목 단위를 입력해 주세요.'); return; }
                            
                            // 요청사항 반영 - 품목 단가가 0원일 경우도 품목으로 인정 후 데이터베이스에 추가 
                            //if(item.unitPrice == 0) { WidgetT.showSnackBar(context, text: '품목 단가를 입력해 주세요.'); return; }

                            var alert = await DialogT.showAlertDl(context, title: item.name ?? 'NULL');
                            if(alert == false) {
                              WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                              return;
                            }

                            await DatabaseM.updateItem(item, );
                            WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                            Navigator.pop(context);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('품목 저장', style: StyleT.titleStyle(),),
                                  SizedBox(width: 6,),
                                ],
                              )
                          )
                      ),),
                    ],
                  ),
                ],
              );
            },
          );
        });

    if(aa == null) aa = false;
    return aa;
  }


  static dynamic showFdInfo(BuildContext context, { FactoryD? org }) async {
    var dividHeight = 6.0;

    Map<String, Uint8List> fileByteList = {};

    var date = DateTime.now();
    FactoryD factoryD = FactoryD.fromDatabase({});
    factoryD.date = date.microsecondsSinceEpoch;
    date = DateTime.fromMicrosecondsSinceEpoch(factoryD.date);

    if(org != null) {
      var jsonString = jsonEncode(org.toJson());
      var json = jsonDecode(jsonString);
      factoryD = FactoryD.fromDatabase(json);
      date = DateTime.fromMicrosecondsSinceEpoch(factoryD.date);
    }

    bool isPop = false;

    List<ItemFD> itemSv = [];
    List<ItemFD> itemSvC = [];

    itemSv = factoryD.itemSvPu.entries.map((entry) => ItemFD.fromDatabase({ 'id': entry.key, 'count': entry.value })).toList();
    itemSvC = factoryD.itemSvRe.entries.map((entry) => ItemFD.fromDatabase({ 'id': entry.key, 'count': entry.value })).toList();

    FactoryD? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };

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
                              Item? it = await selectItem(context, its);
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
                                Item? it = await selectItem(context, its);
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
              var gridStyle = StyleT.inkStyle(round: 8, color: Colors.black.withOpacity(0.03), stroke: 0.7, strokeColor: StyleT.titleColor.withOpacity(0.35));

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.titleColor.withOpacity(0.0), width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '공장일보', ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(dividHeight * 3), width: 768,
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            WidgetT.title('원자재 사용량',),
                            SizedBox(width: dividHeight * 2,),
                            TextButton(
                            onPressed: () {
                              itemSv.add(ItemFD.fromDatabase({}));
                              FunT.setStateDT();
                            },
                                style: StyleT.buttonStyleNone(round: 8, padding: 0, elevation: 0, color: Colors.blueAccent.withOpacity(0.1)),
                                child: Container(alignment: Alignment.center, height: 32, padding: EdgeInsets.fromLTRB(dividHeight * 2, 0, dividHeight * 2, 0), child: WidgetT.text('사용한 원자재 추가'))),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        Column(children: widgetsItemSv,),
                        dividCol,

                        Row(
                          children: [
                            WidgetT.title('생산품 생산량',),
                            SizedBox(width: dividHeight * 2,),
                            TextButton(
                                onPressed: () {
                                  itemSvC.add(ItemFD.fromDatabase({}));
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleNone(round: 8, padding: 0, elevation: 0, color: Colors.blueAccent.withOpacity(0.1)),
                                child: Container(alignment: Alignment.center, height: 32, padding: EdgeInsets.fromLTRB(dividHeight * 2, 0, dividHeight * 2, 0), child: WidgetT.text('생산된 생산품 추가'))),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        Column(children: widgetsItemSvC,),
                        dividCol,

                        Row(
                          children: [
                            WidgetT.title('공장일보 일자', width: 100),
                            TextButton(
                              onPressed: () async {
                                var selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(), // 초깃값
                                  firstDate: DateTime(2018), // 시작일
                                  lastDate: DateTime(2030), // 마지막일
                                );
                                if(selectedDate != null) {
                                  date = selectedDate;
                                }
                                FunT.setStateDT();
                              },
                              style: btnStyle,
                              child: Container( height: 28,
                                  child: Row(
                                    children: [
                                      WidgetT.iconMini(Icons.timelapse),
                                      WidgetT.title(StyleT.dateFormatAll(date),),
                                      SizedBox(width: 6,),
                                    ],
                                  )),),
                            SizedBox(width: dividHeight,),
                            TextButton(
                              onPressed: () async {
                                final TimeOfDay? timeT = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(hour: date.hour, minute: date.minute,),
                                );
                                if(timeT != null) {
                                  date = DateTime(date.year, date.month, date.day, timeT.hourOfPeriod + timeT.periodOffset, timeT.minute, );
                                }
                                FunT.setStateDT();
                              },
                              style: btnStyle,
                              child: Container( height: 28,
                                  child: Row(
                                    children: [
                                      WidgetT.iconMini(Icons.timelapse),
                                      WidgetT.title('시간선택',),
                                      SizedBox(width: 6,),
                                    ],
                                  )),),
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
                                        WidgetEX.excelTitle(width: 150, text: '메모',),
                                        WidgetT.dividViertical(),
                                        Expanded(child: WidgetTF.textTitInput(context, '메모', isMultiLine: true, textSize: 12,
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
                                                  for(int i = 0; i < factoryD.filesMap.length; i++)
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        InkWell(
                                                            onTap: () async {
                                                              var downloadUrl = factoryD.filesMap.values.elementAt(i);
                                                              var fileName = factoryD.filesMap.keys.elementAt(i);
                                                              var ens = ENAES.fUrlAES(downloadUrl);

                                                              var url = Uri.base.toString().split('/work').first + '/pdfview/$ens/$fileName';
                                                              print(url);
                                                              await launchUrl( Uri.parse(url),
                                                                webOnlyWindowName: true ? '_blank' : '_self',
                                                              );
                                                            },
                                                            child: Container(
                                                                decoration: StyleT.inkStyle(stroke: 0.35, round: 8, color: StyleT.accentLowColor.withOpacity(0.05)),
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    SizedBox(width: 6,),
                                                                    WidgetT.title(factoryD.filesMap.keys.elementAt(i),),
                                                                    TextButton(
                                                                        onPressed: () async {
                                                                          if(!await DialogT.showAlertDl(context, text: '파일을 삭제하시겠습니까?')) {
                                                                            WidgetT.showSnackBar(context, text: '파일 삭제 취소');
                                                                            return;
                                                                          }

                                                                          WidgetT.loadingBottomSheet(context, text: '삭제중');
                                                                          FunT.setStateDT();

                                                                          await factoryD.deleteFile(factoryD.filesMap.keys.elementAt(i));
                                                                          Navigator.pop(context);
                                                                          WidgetT.showSnackBar(context, text: '파일 삭제됨');

                                                                          FunT.setStateDT();
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
                                                                          FunT.setStateDT();
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
                            TextButton(onPressed: () async {
                              FilePickerResult? result;
                              try {
                                result = await FilePicker.platform.pickFiles();
                              } catch (e) {
                                WidgetT.showSnackBar(context, text: '파일선택 오류');
                                print(e);
                              }
                              FunT.setStateD = () { setStateS(() {}); };
                              if(result != null){
                                WidgetT.showSnackBar(context, text: '파일선택');
                                if(result.files.isNotEmpty) {
                                  String fileName = result.files.first.name;
                                  print(fileName);
                                  Uint8List fileBytes = result.files.first.bytes!;
                                  fileByteList[fileName] = fileBytes;
                                  print(fileByteList[fileName]!.length);
                                }
                              }
                              FunT.setStateDT();
                            },
                              style: btnStyle,
                              child: Container( height: 28,
                                  child: Row(
                                    children: [
                                      WidgetT.iconMini(Icons.file_copy_rounded),
                                      WidgetT.title('파일선택',),
                                      SizedBox(width: 6,),
                                    ],
                                  )),)
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
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

                            Navigator.pop(context);
                            WidgetT.showSnackBar(context, text: '저장됨');
                            Navigator.pop(context, factoryD);
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
              );
            },
          );
        });

    return aa;
  }


  /// 품목 선택 다이얼로그
  static dynamic selectItem(BuildContext context, List<Item> items) async {

    Item? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: StyleT.white.withOpacity(1),
            elevation: 36,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade700, width: 1.4),
                borderRadius: BorderRadius.circular(0)),
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            title: WidgetDT.dlTitle(context, title: '품목선택 창', ),
            content: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(12),
                child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for(var itemT in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: TextButton(
                            onPressed: () {
                              Navigator.pop(context, itemT);
                            },
                            style: StyleT.buttonStyleOutline(round: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 1.4, elevation: 0, padding: 0),
                            child: Container( height: 28,
                              child: Row(
                                  children: [
                                    WidgetT.text('${itemT.id}', size: 10, width: 80),
                                    WidgetT.dividViertical(),
                                    WidgetT.excelGrid(text: MetaT.itemGroup[itemT.group], width: 150, label: '분류'),
                                    WidgetT.dividViertical(),
                                    WidgetT.excelGrid(text: '${itemT.name}', width: 250, label: '품명'),
                                    WidgetT.dividViertical(),
                                    WidgetT.excelGrid(text: StyleT.krwInt(SystemT.getInventoryItemCount(itemT.id)) + itemT.unit, width: 120, label: '재고량',),
                                    WidgetT.dividViertical(),
                                    WidgetT.excelGrid(text: StyleT.krwInt(SystemT.getInventoryItemCount(itemT.id) * itemT.unitPrice) + '원' , width: 120, label: '금액',),
                                    WidgetT.dividViertical(),
                                  ]
                              ),
                            )),
                      ),
                  ],
                ),
              ),
            ),
            actionsPadding: EdgeInsets.zero,
            actions: <Widget>[
              WidgetT.dividHorizontal(color: Colors.grey.withOpacity(0.5)),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    child:
                    Row(
                      children: [
                        Container( height: 28,
                          child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: StyleT.buttonStyleOutline(padding: 0, round: 0, strock: 1.4, elevation: 8,
                                  color: Colors.redAccent.withOpacity(0.5)),
                              child: Row( mainAxisSize: MainAxisSize.min,
                                children: [
                                  WidgetT.iconMini(Icons.cancel),
                                  Text('닫기', style: StyleT.titleStyle(),),
                                  SizedBox(width: 12,),
                                ],
                              )
                          ),
                        ),
                        SizedBox(width:  8,),
                        /* Container( height: 28,
                              child: TextButton(
                                  onPressed: () async {
                                  },
                                  style: StyleT.buttonStyleOutline(padding: 0, round: 0, strock: 1.4, elevation: 8,
                                      color: StyleT.accentColor.withOpacity(0.5)),
                                  child: Row( mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.iconMini(Icons.save),
                                      Text('계약추가', style: StyleT.titleStyle(),),
                                      SizedBox(width: 12,),
                                    ],
                                  )
                              ),
                            ),*/
                      ],
                    ),
                  ),
                ],
              )
            ],
          );
        });

    print(aa?.name);
    return aa;
  }

  static dynamic showProductInfo(BuildContext context, { ProductD? org }) async {
    var dividHeight = 6.0;
    var date = DateTime.now();

    Map<String, Uint8List> fileByteList = {};
    ProductD product = ProductD.fromDatabase({});
    product.date = date.microsecondsSinceEpoch;

    if(org != null) {
      var jsonString = jsonEncode(org.toJson());
      var json = jsonDecode(jsonString);
      product = ProductD.fromDatabase(json);
      date = DateTime.fromMicrosecondsSinceEpoch(product.date);
    }

    bool isPop = false;

    List<ItemFD> itemSv = [];
    List<ItemFD> itemSvC = [];

    itemSv = product.itemSvPu.entries.map((entry) => ItemFD.fromDatabase({ 'id': entry.key, 'count': entry.value })).toList();
    itemSvC = product.itemSvRe.entries.map((entry) => ItemFD.fromDatabase({ 'id': entry.key, 'count': entry.value })).toList();

    ProductD? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };

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
                                Item? it = await selectItem(context, its);
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
                                Item? it = await selectItem(context, its);
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
              var gridStyle = StyleT.inkStyle(round: 8, color: Colors.black.withOpacity(0.03), stroke: 0.7, strokeColor: StyleT.titleColor.withOpacity(0.35));

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.titleColor.withOpacity(0.0), width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '생산일보', ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(dividHeight * 3), width: 768,
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            WidgetT.title('원자재 사용량',),
                            SizedBox(width: dividHeight * 2,),
                            TextButton(
                                onPressed: () {
                                  itemSv.add(ItemFD.fromDatabase({}));
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleNone(round: 8, padding: 0, elevation: 0, color: Colors.blueAccent.withOpacity(0.1)),
                                child: Container(alignment: Alignment.center, height: 32, padding: EdgeInsets.fromLTRB(dividHeight * 2, 0, dividHeight * 2, 0), child: WidgetT.text('사용한 원자재 추가'))),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        Column(children: widgetsItemSv,),
                        dividCol,

                        Row(
                          children: [
                            WidgetT.title('생산품 생산량',),
                            SizedBox(width: dividHeight * 2,),
                            TextButton(
                                onPressed: () {
                                  itemSvC.add(ItemFD.fromDatabase({}));
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleNone(round: 8, padding: 0, elevation: 0, color: Colors.blueAccent.withOpacity(0.1)),
                                child: Container(alignment: Alignment.center, height: 32, padding: EdgeInsets.fromLTRB(dividHeight * 2, 0, dividHeight * 2, 0), child: WidgetT.text('생산된 생산품 추가'))),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                        Column(children: widgetsItemSvC,),
                        dividCol,

                        Row(
                          children: [
                            WidgetT.title('생산일보 일자', width: 100),
                            TextButton(
                              onPressed: () async {
                                var selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(), // 초깃값
                                  firstDate: DateTime(2018), // 시작일
                                  lastDate: DateTime(2030), // 마지막일
                                );
                                if(selectedDate != null) {
                                  date = selectedDate;
                                }
                                FunT.setStateDT();
                              },
                              style: btnStyle,
                              child: Container( height: 28,
                                  child: Row(
                                    children: [
                                      WidgetT.iconMini(Icons.timelapse),
                                      WidgetT.title(StyleT.dateFormatAll(date),),
                                      SizedBox(width: 6,),
                                    ],
                                  )),),
                            SizedBox(width: dividHeight,),
                            TextButton(
                              onPressed: () async {
                                final TimeOfDay? timeT = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(hour: date.hour, minute: date.minute,),
                                );
                                if(timeT != null) {
                                  date = DateTime(date.year, date.month, date.day, timeT.hourOfPeriod + timeT.periodOffset, timeT.minute, );
                                }
                                FunT.setStateDT();
                              },
                              style: btnStyle,
                              child: Container( height: 28,
                                  child: Row(
                                    children: [
                                      WidgetT.iconMini(Icons.timelapse),
                                      WidgetT.title('시간선택',),
                                      SizedBox(width: 6,),
                                    ],
                                  )),),
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
                                        WidgetEX.excelTitle(width: 150, text: '메모',),
                                        WidgetT.dividViertical(),
                                        Expanded(child: WidgetTF.textTitInput(context, '메모', isMultiLine: true, textSize: 12,
                                          onEdite: (i, data) { product.memo = data; },
                                          text: product.memo,
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
                                                  for(int i = 0; i < product.filesMap.length; i++)
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        InkWell(
                                                            onTap: () async {
                                                              var downloadUrl = product.filesMap.values.elementAt(i);
                                                              var fileName = product.filesMap.keys.elementAt(i);
                                                              var ens = ENAES.fUrlAES(downloadUrl);

                                                              var url = Uri.base.toString().split('/work').first + '/pdfview/$ens/$fileName';
                                                              print(url);
                                                              await launchUrl( Uri.parse(url),
                                                                webOnlyWindowName: true ? '_blank' : '_self',
                                                              );
                                                            },
                                                            child: Container(
                                                                decoration: StyleT.inkStyle(stroke: 0.35, round: 8, color: StyleT.accentLowColor.withOpacity(0.05)),
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    SizedBox(width: 6,),
                                                                    WidgetT.title(product.filesMap.keys.elementAt(i),),
                                                                    TextButton(
                                                                        onPressed: () async {
                                                                          if(!await DialogT.showAlertDl(context, text: '파일을 삭제하시겠습니까?')) {
                                                                            WidgetT.showSnackBar(context, text: '파일 삭제 취소');
                                                                            return;
                                                                          }

                                                                          WidgetT.loadingBottomSheet(context, text: '삭제중');
                                                                          FunT.setStateDT();

                                                                          await product.deleteFile(product.filesMap.keys.elementAt(i));
                                                                          Navigator.pop(context);
                                                                          WidgetT.showSnackBar(context, text: '파일 삭제됨');

                                                                          FunT.setStateDT();
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
                                                                          FunT.setStateDT();
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
                            TextButton(onPressed: () async {
                              FilePickerResult? result;
                              try {
                                result = await FilePicker.platform.pickFiles();
                              } catch (e) {
                                WidgetT.showSnackBar(context, text: '파일선택 오류');
                                print(e);
                              }
                              FunT.setStateD = () { setStateS(() {}); };
                              if(result != null){
                                WidgetT.showSnackBar(context, text: '파일선택');
                                if(result.files.isNotEmpty) {
                                  String fileName = result.files.first.name;
                                  print(fileName);
                                  Uint8List fileBytes = result.files.first.bytes!;
                                  fileByteList[fileName] = fileBytes;
                                  print(fileByteList[fileName]!.length);
                                }
                              }
                              FunT.setStateDT();
                            },
                              style: btnStyle,
                              child: Container( height: 28,
                                  child: Row(
                                    children: [
                                      WidgetT.iconMini(Icons.file_copy_rounded),
                                      WidgetT.title('파일선택',),
                                      SizedBox(width: 6,),
                                    ],
                                  )),)
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  Row(
                    children: [
                      Expanded(child:TextButton(
                          onPressed: () async {
                            var alert = await DialogT.showAlertDl(context, title: product.memo ?? 'NULL');
                            if(alert == false) {
                              WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                              return;
                            }

                            WidgetT.loadingBottomSheet(context, text: '저장중');
                            FunT.setStateDT();

                            product.itemSvPu = Map.fromIterable(itemSv, key: (item) => item.id, value: (item) => item.count);
                            product.itemSvRe = Map.fromIterable(itemSvC, key: (item) => item.id, value: (item) => item.count);
                            //print(factoryD.itemSvPu);
                            //print(factoryD.itemSvRe);

                            product.date = date.microsecondsSinceEpoch;
                            await DatabaseM.updateProductDWithFile(product, files: fileByteList);

                            Navigator.pop(context);
                            WidgetT.showSnackBar(context, text: '저장됨');
                            Navigator.pop(context, product);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('생산일보 저장', style: StyleT.titleStyle(),),
                                  SizedBox(width: 6,),
                                ],
                              )
                          )
                      ),),
                    ],
                  ),
                ],
              );
            },
          );
        });

    return aa;
  }

  Widget build(context) {
    return Container();
  }
}
