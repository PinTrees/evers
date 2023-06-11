import 'dart:math';
import 'dart:ui';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/Customer.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/database/ledger.dart';
import 'package:evers/class/revenue.dart';
import 'package:evers/class/system.dart';
import 'package:evers/class/transaction.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:image/image.dart' as img;
import '../../helper/interfaceUI.dart';


class PrintFormT extends StatelessWidget {
  static var divideHeight = 6.0;

  static Map<String, TextEditingController> textInputs = {};
  static Map<String, bool> isActive = {};

  static Widget Icon({IconData? icon, Function? onTap}) {
    return InkWell(
      onTap: () async {
        if(onTap != null) return await onTap();
      },
      child: Container(
        child: Row(
          children: [
            WidgetT.iconMini(icon ?? Icons.question_mark, size: 24, boxSize: 28),
          ],
        ),
      ),
    );
  }


  static dynamic ReleaseRevenue(
      Ledger ledger,
      { List<Revenue>? revenueList, Contract? ct, Customer? cs,
        Map<String, Map<String, dynamic>>? inputRevenue,
        Map<String, String>? inputOther,
      }) async {
    if(inputRevenue == null) inputRevenue = {};
    if(inputOther == null) inputOther = {};

    if(revenueList == null) return null;
    if(revenueList.isEmpty) return null;

    final storageRef = FirebaseStorage.instance.ref();
    final mountainImagesRef = storageRef.child("tmp/stamp.png");
    var sn = await mountainImagesRef.getData();
    final image = pw.MemoryImage(sn!,);

    Customer cs = await DatabaseM.getCustomerDoc(revenueList.first.csUid);
    Contract ct = await DatabaseM.getContractDoc(revenueList.first.ctUid);

    double right = 0;
    double top = 0;
    double rot = 0;

    var doc = pw.Document();

    List<List<String>> revenueTable = [];
    revenueList.forEach((e) { revenueTable.add(e.toTable()); });

    Map<String, String> revenueNames = {};
    revenueList.forEach((e) {  revenueNames[e.id] = e.item; });


    if(image != null) {
      right = Random().nextDouble() * 30 + 365;
      top = Random().nextDouble() * 50 + 150;
      rot = Random().nextDouble() * 0.5;
    }

    doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.landscape,
        margin: const pw.EdgeInsets.all(12),
        build: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Stack(
                  alignment: pw.Alignment.center,
                  children: [
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          LitReleaseRevenue(
                            context,
                            titleName: '원장 (공급자 보급용)',
                            uid: 'LR-${ ledger.id }',
                            date: DateStyle.dateYearMonthDayHipen(revenueList.first.revenueAt),
                            csName: cs.businessName,
                            revenueNames: revenueNames,
                            revenueValues: inputRevenue,
                            workSite: inputOther!['lgWorkSite'] ?? '-',
                            phoneNum: ct.managerPhoneNumber,
                            carUid : inputOther!['lgCarUid'] ?? ' - ',
                            writer: inputOther!['lgWriter'] ?? ' - ',
                            memo: inputOther!['lgMemo'] ?? ' - ',
                          ),
                          pw.SizedBox(width: 8),
                          LitReleaseRevenue(
                            context,
                            titleName: '상 차 증 (지게차보관용)',
                            uid: 'LR-${ ledger.id }',
                            date: DateStyle.dateYearMonthDayHipen(revenueList.first.revenueAt),
                            csName: cs.businessName,
                            revenueNames: revenueNames,
                            revenueValues: inputRevenue,
                            workSite: inputOther!['lgWorkSite'] ?? '-',
                            phoneNum: ct.managerPhoneNumber,
                            carUid : inputOther!['lgCarUid'] ?? ' - ',
                            writer: inputOther!['lgWriter'] ?? ' - ',
                            memo: inputOther!['lgMemo'] ?? ' - ',
                          ),
                        ]
                    ),
                    pw.Positioned(
                        right: right, top: top,
                        child: pw.Transform(
                          alignment: pw.Alignment(0, 0),
                          transform: Matrix4.rotationZ(3.141592 / rot),
                          child: pw.SizedBox(
                            width: 64, height: 64,
                            child: pw.Image(image),
                          ),
                        )
                    )
                  ]
              )
          );
        }));


    if(image != null) {
      right = Random().nextDouble() * 30 + 365;
      top = Random().nextDouble() * 50 + 150;
      rot = Random().nextDouble() * 0.5;
    }

    doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.landscape,
        margin: const pw.EdgeInsets.all(12),
        build: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Stack(
                  alignment: pw.Alignment.center,
                  children: [
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          LitReleaseRevenue(
                            context,
                            titleName: '송 장 (받는자보관용)',
                            uid: 'LR-${ ledger.id }',
                            date: DateStyle.dateYearMonthDayHipen(revenueList.first.revenueAt),
                            csName: cs.businessName,
                            revenueNames: revenueNames,
                            revenueValues: inputRevenue,
                            workSite: inputOther!['lgWorkSite'] ?? '-',
                            phoneNum: ct.managerPhoneNumber,
                            carUid : inputOther!['lgCarUid'] ?? ' - ',
                            writer: inputOther!['lgWriter'] ?? ' - ',
                            memo: inputOther!['lgMemo'] ?? ' - ',
                            isCollection: true,
                            stamp: image,
                          ),
                          pw.SizedBox(width: 8),
                          LitReleaseRevenue(
                            context,
                            titleName: '인수증 및 검사확인증',
                            uid: 'LR-${ ledger.id }',
                            date: DateStyle.dateYearMonthDayHipen(revenueList.first.revenueAt),
                            csName: cs.businessName,
                            revenueNames: revenueNames,
                            revenueValues: inputRevenue,
                            workSite: inputOther!['lgWorkSite'] ?? '-',
                            phoneNum: ct.managerPhoneNumber,
                            carUid : inputOther!['lgCarUid'] ?? ' - ',
                            writer: inputOther!['lgWriter'] ?? ' - ',
                            memo: inputOther!['lgMemo'] ?? ' - ',
                            isCollection: true,
                            stamp: image,
                          ),
                        ]
                    ),
                    pw.Positioned(
                        right: right, top: top,
                        child: pw.Transform(
                          alignment: pw.Alignment(0, 0),
                          transform: Matrix4.rotationZ(3.141592 / rot),
                          child: pw.SizedBox(
                            width: 64, height: 64,
                            child: pw.Image(image),
                          ),
                        )
                    )
                  ]
              )
          );
        }), index: 1);

    var data = await doc.save();
    return data;
    //await Printing.layoutPdf(onLayout: (format) async => await data);
  }


  static dynamic LitReleaseRevenue(pw.Context context, {
    String uid='-',
    String date='-',
    String csName='-',
    String titleName='-',
    String carUid='-',
    String workSite='-',
    String writer='-',
    String memo='-',
    String phoneNum='-',
    Map<String, String>? revenueNames,
    Map<String, Map<String, dynamic>>? revenueValues,
    bool isCollection=false,
    pw.MemoryImage? stamp,
  }) {
    if(revenueNames == null) revenueNames = {};
    if(revenueValues == null) revenueValues = {};

    pw.Widget titleRow = pw.Row(
        children: [
          pw.SizedBox(
            width: 24,
            child: pw.Expanded(
              child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                  headerHeight: 68 + 3,
                  headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                    <String>['결\n\n재'],
                  ]),
            ),
          ),
          pw.Column(
              children: [
                pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 180,
                        child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                            headerHeight: 18,
                            defaultColumnWidth : pw.FlexColumnWidth(),
                            headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                              <String>['  담당  ', ' 부서장 ', '대표이사'],
                            ]),
                      ),
                    ]
                ),
                pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 180,
                        child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                            headerHeight: 50,
                            headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                              <String>[' ', ' ', ' '],
                            ]),
                      ),
                    ]
                )
              ]
          ),
        ]
    );

    if(isCollection) {
      titleRow = pw.Expanded(
        child: pw.Table.fromTextArray(context: context,
            cellStyle: pw.TextStyle(font: StyleT.font, fontSize: 8),
            cellHeight: 0,
            headerHeight: 68 + 3,
            headerStyle: pw.TextStyle(font: StyleT.font, fontSize: 10),
            data: <List<String>>[
              <String>[
                '사업자등록번호 : 741-87-02231\n상호 : ㈜에버스 대표이사 : 이재구\n주소 : 원주시 소초면 현촌길 108\n업태 : 제조 종목 : 동결건조식품제조'
              ],
            ]),
      );
    }

    pw.Widget w = pw.Container(
      width: 400,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
      ),
      child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10),
                headerStyle: pw.TextStyle(font: StyleT.font, fontSize: 16),
                headerPadding: pw.EdgeInsets.all(8),
                data: <List<String>>[
                  <String>[ titleName ],
                ]),
            pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                        cellHeight: 0, headerHeight: 68 + 3,
                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                          <String>['${ uid }\n${ date }\n${ csName } 귀하'],
                        ]),
                  ),
                  titleRow,
                ]
            ),
            pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                        cellHeight: 0, headerHeight: 50,
                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                          <String>['품목'],
                        ]),
                  ),
                  pw.SizedBox(
                    width: 120,
                    child: pw.Expanded(
                        child:pw.Column(
                            children: [
                              pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                  headerHeight: 25,
                                  headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                    <String>['수량'],
                                  ]),
                              pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                  headerHeight: 25,
                                  defaultColumnWidth : pw.FlexColumnWidth(),
                                  headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                    <String>['1박스kg', '박스 수량'],
                                  ]),
                            ]
                        )
                    ),
                  ),
                  pw.SizedBox(
                    width: 120,
                    child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                        headerHeight: 50,
                        defaultColumnWidth : pw.FlexColumnWidth(),
                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                          <String>[' 총무게 ', '파레트수',],
                        ]),
                  )
                ]
            ),
            for(var key in revenueNames.keys)
              pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                          cellHeight: 0, headerHeight: 25,
                          headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                            <String>[ SystemT.getItemName(revenueNames[key] ?? '-') ],
                          ]),
                    ),
                    pw.SizedBox(
                      width: 120,
                      child: pw.Expanded(
                          child:pw.Column(
                              children: [
                                pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                    headerHeight: 25,
                                    defaultColumnWidth : pw.FlexColumnWidth(),
                                    headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                      <String>[ revenueValues![key]!['lgKg'] ?? ' - ',  revenueValues![key]!['lgCount'] ?? ' - ' ] ,
                                    ]),
                              ]
                          )
                      ),
                    ),
                    pw.SizedBox(
                      width: 120,
                      child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                          headerHeight: 25,
                          defaultColumnWidth : pw.FlexColumnWidth(),
                          headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                            <String>[ revenueValues![key]!['lgResultKg'] ?? ' - ', revenueValues![key]!['lgParteCount'] ?? ' - ' ] ,
                          ]),
                    )
                  ]
              ),

            pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 80,
                    child:  pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                        headerHeight: 25,
                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                          <String>['현장명'],
                        ]),
                  ),
                  pw.Expanded(
                    child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                        cellHeight: 0, headerHeight: 25,
                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                          <String>[ workSite ],
                        ]),
                  ),
                ]
            ),
            pw.Row(
                children: [
                  pw.Expanded(
                      child: pw.Column(
                          children: [
                            pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.SizedBox(
                                    width: 80,
                                    child:  pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                        headerHeight: 25,
                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                          <String>['전화번호'],
                                        ]),
                                  ),
                                  pw.Expanded(
                                    child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                        cellHeight: 0, headerHeight: 25,
                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                          <String>[ phoneNum ],
                                        ]),
                                  ),
                                ]
                            ),
                            pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.SizedBox(
                                    width: 80,
                                    child:  pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                        headerHeight: 25,
                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                          <String>['차량번호'],
                                        ]),
                                  ),
                                  pw.Expanded(
                                    child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                        cellHeight: 0, headerHeight: 25,
                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                          <String>[ carUid ],
                                        ]),
                                  ),
                                ]
                            ),
                            pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.SizedBox(
                                    width: 80,
                                    child:  pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                        headerHeight: 25,
                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                          <String>['출고자'],
                                        ]),
                                  ),
                                  pw.Expanded(
                                    child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                        cellHeight: 0, headerHeight: 25,
                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                          <String>[ writer + ( isCollection ? ' (인)' : '' ) ],
                                        ]),
                                  ),
                                ]
                            ),
                          ]
                      )
                  ),
                  if(isCollection)
                    pw.Container(
                      width: 128,
                      child: pw.Column(
                          children: [
                            pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Expanded(
                                    child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                        cellHeight: 0, headerHeight: 25,
                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                          <String>[ '검사확인란' ],
                                        ]),
                                  ),
                                ]
                            ),
                            pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.SizedBox(
                                    width: 64,
                                    child:  pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                        headerHeight: 25,
                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                          <String>['검사일'],
                                        ]),
                                  ),
                                  pw.Expanded(
                                    child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                        cellHeight: 0, headerHeight: 25,
                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                          <String>[ "" ],
                                        ]),
                                  ),
                                ]
                            ),
                            pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.SizedBox(
                                    width: 64,
                                    child:  pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                        headerHeight: 25,
                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                          <String>['검사자'],
                                        ]),
                                  ),
                                  pw.Expanded(
                                    child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                                        cellHeight: 0, headerHeight: 25,
                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                          <String>[ writer ],
                                        ]),
                                  ),
                                ]
                            ),
                          ]
                      ),
                    )
                ]
            ),
            pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8),
                        cellHeight: 25, headerHeight: 25,
                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                          <String>['입고예정일, 특이사항기재'],
                          <String>[ memo ],
                        ]),
                  ),
                ]
            ),
          ]
      ),
    );

    /// 도장위치 랜덤 및 회전값 적용
    if (stamp != null) {
      var right = Random().nextDouble() * 18 + 0;
      var top = Random().nextDouble() * 18 + 32;
      var rot = Random().nextDouble() * 0.5;
      w = pw.Stack(
          children: [
            w,
            pw.Positioned(
                top: top, right: right,
                child: pw.SizedBox(
                    width: 64, height: 64,
                    child: pw.Transform(
                      alignment: pw.Alignment(0, 0),
                      transform: Matrix4.rotationZ(
                        3.141592 / rot,
                      ),
                      child: pw.Image(stamp),
                    )
                )
            ),
          ]
      );
    }

    return w;
  }












  static dynamic PaymentList({ required List<TS> tsList,
    required int balance,
    required Map<dynamic, int> account,

  }) async {
    var selBalanceCal = balance;
    List<List<List<String>>> tableStringList = [];
    for(int i = 0; i < (tsList.length / 35); i++) {
      tableStringList.add([]);
      for (int j = 0; j < 35; j++) {
        if ((i * 35) + j >= tsList.length) break;

        tableStringList[i].add(await tsList[(i * 35) + j].getTable(selBalanceCal));
        selBalanceCal = selBalanceCal - tsList[(i * 35) + j].getAmount();
      }
    }
    final doc = pw.Document();

    bool lastPage = false;
    for(int i = 0; i < (tsList.length / 35); i++) {
      if(i >= ((tsList.length / 35) - 1) && !(tableStringList[i].length < 24))
        lastPage = true;

      doc.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return pw.Column(
                children: [
                  if(i == 0) pw.Text('금전출납부 (에버스)', style: pw.TextStyle(font:  StyleT.font, fontSize: 18),),
                  pw.SizedBox(height: divideHeight * 4 ),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
                    ),
                    child: pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 8,),
                              headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10,), data: <List<String>>[
                                <String>['일자', '은행명', '예금주', '     수입     ', '     지출     ', '     잔고     ', '          적요 및 비고         '],
                                for(var rr in tableStringList[i])
                                  rr,
                              ]),
                        ]
                    ),
                  ),

                  if(i >= ((tsList.length / 35) - 1) && tableStringList[i].length < 24)
                    pw.Expanded(flex: 9, child: pw.SizedBox(height: divideHeight * 4 ),),
                  if(i >= ((tsList.length / 35) - 1) && tableStringList[i].length < 24)
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Container(
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
                            ),
                            child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font,
                                color: PdfColor.fromHex('#FFFFFF00'), fontSize: 8),
                                tableWidth: pw.TableWidth.min,
                                headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                  <String>['담당', '대표',],
                                  <String>['ㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\n', 'ㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\n',],
                                ]),
                          ),
                          pw.SizedBox(width: divideHeight * 4),
                          pw.Container(
                              width: 256,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
                              ),
                              child: pw.Column(
                                  mainAxisSize: pw.MainAxisSize.min,
                                  children: [
                                    pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 12),
                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                          <String>['잔고'],
                                        ]),
                                    pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10),
                                        headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                          for(var ac in account.keys)
                                            <String>[SystemT.getAccountName(ac), '￦ ' + StyleT.krwInt(account[ac])],
                                          <String>['합계', '￦ ' + StyleT.krwInt(balance)],
                                        ]),
                                  ]
                              )
                          )
                        ]
                    ),

                  pw.Expanded(flex: 1, child: pw.SizedBox(height: divideHeight * 4 ),),
                  pw.Text('${i + 1} / ${(tsList.length / 35).ceil()}', style: pw.TextStyle(font:  StyleT.font, fontSize: 8),),
                ]
            );
          }));
    }

    if(lastPage) {
      doc.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return pw.Column(
                children: [
                  pw.Expanded(child: pw.SizedBox(height: divideHeight * 4 ),),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
                          ),
                          child: pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font,
                              color: PdfColor.fromHex('#FFFFFF00'), fontSize: 8),
                              tableWidth: pw.TableWidth.min,
                              headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                <String>['담당', '대표',],
                                <String>['ㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\n', 'ㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\nㅡㅡㅡㅡㅡㅡ\n',],
                              ]),
                        ),
                        pw.SizedBox(width: divideHeight * 4),
                        pw.Container(
                            width: 256,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 2, color: PdfColor.fromHex('#000000')),
                            ),
                            child: pw.Column(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 12),
                                      headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                        <String>['잔고'],
                                      ]),
                                  pw.Table.fromTextArray(context: context, cellStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10),
                                      headerStyle: pw.TextStyle(font:  StyleT.font, fontSize: 10), data: <List<String>>[
                                        for(var ac in account.keys)
                                          <String>[SystemT.getAccountName(ac), '￦ ' + StyleT.krwInt(account[ac])],
                                        <String>['합계', '￦ ' + StyleT.krwInt(balance)],
                                      ]),
                                ]
                            )
                        )
                      ]
                  ),
                ]
            );
          }));
    }

    var data = await doc.save();
    return data;
  }

  Widget build(context) {
    return Container();
  }
}


