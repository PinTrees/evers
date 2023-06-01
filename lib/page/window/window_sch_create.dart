import 'dart:typed_data';

import 'package:evers/class/component/comp_re.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/style.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import '../../class/contract.dart';
import '../../class/revenue.dart';
import '../../class/schedule.dart';
import '../../class/system.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/text.dart';
import '../../helper/dialog.dart';
import '../../helper/interfaceUI.dart';
import '../../helper/pdfx.dart';
import '../../ui/ip.dart';




/// 이 윈도우 클래스는 일정추가를 위한 위젯을 렌더링 합니다.
class WindowSchCreate extends WindowBaseMDI {
  Function refresh;
  Contract? ct;
  DateTime? dateTime;

  WindowSchCreate({ required this.ct, required this.refresh, this.dateTime }) { }

  @override
  _WindowSchCreateState createState() => _WindowSchCreateState();
}
class _WindowSchCreateState extends State<WindowSchCreate> {
  var dividHeight = 6.0;
  var heightSize = 36.0;

  Schedule schedule = Schedule.fromDatabase({});
  Contract? ct;

  Map<String, Uint8List> fileByteList = {};
  var date = DateTime.now();
  var time = TimeOfDay.now();
  var selectType = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /// 최초 실행시
    if(widget.dateTime != null) date = widget.dateTime!;
    else date = DateTime.now();

    if(widget.ct != null) ct = widget.ct;

    schedule = Schedule.fromDatabase({});
    if(ct != null) schedule.ctUid = ct!.id;
    schedule.date = date.microsecondsSinceEpoch;

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

    var contractWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "계약정보", ),
        TextT.Lit(text: ct == null ? '-' : "${ct!.csName} / ${ct!.ctName}" ),

        /// 계약 정보가 포함된 상태라면 계약선택 기능 비활성화
        if(widget.ct == null)
          ButtonT.IconText(
          icon: Icons.content_paste_search, text: "계약 검색",
          onTap: () async {
             var tmpCt = await DialogT.selectCt(context);
             if(tmpCt != null) ct = tmpCt;
             setState(() {});
          }
        )
      ],
    );

    var tagWidget = ListBoxT.Rows(
      spacing: 6, padding: EdgeInsets.only(bottom: 6),
      children: [
        TextT.SubTitle(text: "태그",),
        for(int i = 0; i < StyleT.scheduleColor.length; i++)
          ButtonT.IconText(
            icon: selectType != StyleT.scheduleColor.keys.elementAt(i) ? Icons.check_box_outline_blank : Icons.check_box,
            text: StyleT.scheduleName[StyleT.scheduleColor.keys.elementAt(i)]?? "NULL",
            onTap: () {
              schedule.type = selectType = StyleT.scheduleColor.keys.elementAt(i);
              setState(() {});
            }
          )
      ],
    );

    var titleWidget = ListBoxT.Rows(
      spacing: 6,  padding: EdgeInsets.only(bottom: 6),
      children: [
        TextT.SubTitle(text: "일정 시각"),
        ButtonT.IconText(
          icon: Icons.calendar_month,
          text: StyleT.dateFormatYYYYMD_(date),
          onTap: () async {
            var selectedDate = await showDatePicker(
              context: context,
              initialDate: date, // 초깃값
              firstDate: DateTime(2018), // 시작일
              lastDate: DateTime(2030), // 마지막일
            );
            if(selectedDate != null) date = selectedDate;
            setState(() {});
          }
        ),
        ButtonT.IconText(
            icon: Icons.timelapse,
            text: StyleT.dateFormatHM(date),
            onTap: () async {
              final TimeOfDay? timeT = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: date.hour, minute: date.minute,),
              );
              if(timeT != null)
                date = DateTime(date.year, date.month, date.day, timeT.hourOfPeriod + timeT.periodOffset, timeT.minute, );
              setState(() {});
            }
        ),
      ],
    );

    var inputWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputWidget.LitText(context, "${widget.parent.key}::sch::메모",
          label: "메모", expand: true, isMultiLine: true,
          setState: () { setState(() {}); },
          onEdited: (i, data) { schedule.memo = data; },
          text: schedule.memo,
        ),
        SizedBox(height: dividHeight,),
        InputWidget.LitText(
          context, "${widget.parent.key}::sch::작성자",
          width: 150, label: "작성자",
          setState: () { setState(() {}); },
          onEdited: (i, data) { schedule.writer = data; },
          text: schedule.writer,
        ),
      ],
    );

    var fileWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "첨부파일 목록",),
        SizedBox(height: 6,),
        Container(
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                        padding: EdgeInsets.all(dividHeight),
                        child: Wrap(
                          runSpacing: dividHeight, spacing: dividHeight * 3,
                          children: [
                            for(int i = 0; i < schedule.filesMap.length; i++)
                              ButtonT.IconText(
                                icon: Icons.cloud_done, text: schedule.filesMap.keys.elementAt(i),
                                onTap: () async {
                                  var downloadUrl = schedule.filesMap.values.elementAt(i);
                                  var fileName = schedule.filesMap.keys.elementAt(i);
                                  PdfManager.OpenPdf(downloadUrl, fileName);
                                },
                                leaging: ButtonT.Icont(
                                  icon: Icons.delete,
                                    onTap: () {
                                      WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
                                      setState(() {});
                                    },
                                ),
                              ),
                            for(int i = 0; i < fileByteList.length; i++)
                              ButtonT.IconText(
                                icon: Icons.file_copy_rounded, text: fileByteList.keys.elementAt(i),
                                onTap: () async {
                                  PDFX.showPDFtoDialog(context, data: fileByteList.values.elementAt(i), name: fileByteList.keys.elementAt(i));
                                },
                                leaging: ButtonT.Icont(
                                  icon: Icons.delete,
                                  onTap: () {
                                    fileByteList.remove(fileByteList.keys.elementAt(i));
                                    setState(() {});
                                  },
                                ),
                              ),
                          ],
                        ),
                      )
                  ),
                ],
              ),
            )
        ),
        SizedBox(height: 6,),
        ButtonT.IconText(
            icon: Icons.add_box, text: "첨부파일추가",
            onTap: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null && result.files.isNotEmpty) {
                String fileName = result.files.first.name;
                fileByteList[fileName] = result.files.first.bytes!;
              }
              setState(() {});
            }
        ),
      ],
    );

    return Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(18),
            child: ListBoxT.Columns(
              spacing: dividHeight * 4,
              children: [

                contractWidget,
                tagWidget,
                titleWidget,
                inputWidget,
                fileWidget,
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
        Expanded(child:TextButton(
            onPressed: () async {
              if(schedule.memo == '') { WidgetT.showSnackBar(context, text: '메모는 비워둘 수 없습니다.'); return; }
              if(schedule.type == '') { WidgetT.showSnackBar(context, text: '태그는 비워둘 수 없습니다.'); return; }

              var alt = await DialogT.showAlertDl(context, text: "일정을 저장하시겠습니까?");
              if(!alt) { WidgetT.showSnackBar(context, text: '취소됨'); return; }

              WidgetT.loadingBottomSheet(context);
              /// (***)
              schedule.date = date.microsecondsSinceEpoch;
              await schedule.update(files: fileByteList);

              Navigator.pop(context);
              WidgetT.showSnackBar(context, text: '저장됨');

              widget.refresh();
              widget.parent.onCloseButtonClicked!();
            },
            style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
            child: Container(
                color: StyleT.accentColor.withOpacity(0.5), height: 42,
                child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WidgetT.iconMini(Icons.check_circle),
                    Text('일정 추가', style: StyleT.titleStyle(),),
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



