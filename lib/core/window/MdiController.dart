import 'dart:math';
import 'package:evers/page/window/window_cs.dart';
import 'package:evers/page/window/window_cs_create.dart';
import 'package:evers/page/window/window_paper_product.dart';
import 'package:evers/page/window/window_process_create.dart';
import 'package:evers/page/window/window_process_info.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_pu_editor.dart';
import 'package:evers/page/window/window_re_create.dart';
import 'package:evers/page/window/window_re_create_ct.dart';
import 'package:evers/page/window/window_re_editor.dart';
import 'package:evers/page/window/window_schList_info.dart';
import 'package:evers/page/window/window_sch_create.dart';
import 'package:evers/page/window/window_sch_editor.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/page/window/window_ts_editor.dart';
import 'package:evers/page/window/window_user_create.dart';
import 'package:flutter/material.dart';

import '../../page/window/window_ct.dart';
import '../../page/window/window_paper_factory.dart';
import 'ResizableWindow.dart';


class MdiController{

  MdiController(this._onUpdate);

  List<ResizableWindow> _windows = List.empty(growable: true);

  VoidCallback _onUpdate;

  List<ResizableWindow> get windows => _windows;

  void addWindow(BuildContext context, { Widget? widget, ResizableWindow? resizableWindow, bool fixedHeight=false, }) {
    resizableWindow!.widget = widget;
    resizableWindow!.fixedHeight = fixedHeight;

    if(widget is WindowTSEditor) resizableWindow.title = '수납 개별 상세정보 수정창';
    if(widget is WindowCS) resizableWindow.title = '거래처 개별 상세정보창';
    if(widget is WindowCsCreate) resizableWindow.title = "거래처 신규 생성창";
    if(widget is WindowTsCreate) resizableWindow.title = '수납 개별 상세정보창';

    if(widget is WindowFactoryPaper) resizableWindow.title = '공장일보 생성창';
    if(widget is WindowProductPaper) resizableWindow.title = "생산일보 생성창";

    if(widget is WindowCT) resizableWindow.title = '계약 개별 상세정보창';
    if(widget is WindowPUCreateWithCS) resizableWindow.title = '거래처 매입 입력창';
    if(widget is WindowPUCreate) resizableWindow.title = '매입 입력창';
    if(widget is WindowPUEditor) resizableWindow.title = '매입 개별 상세정보창';
    if(widget is WindowReCreate) resizableWindow.title = '매출 정보 생성창';
    if(widget is WindowReEditor) resizableWindow.title = '매출 개별 상세정보창';
    if(widget is WindowSchCreate) resizableWindow.title = '일정 정보 생성창';
    if(widget is WindowSchEditor) resizableWindow.title = '일정 개별정보 수정창';
    if(widget is WindowSchListInfo) resizableWindow.title = '일정 정보 목록 상세정보창';
    if(widget is WindowReCreateWithCt) resizableWindow.title = '매출 정보 생성창 (계약)';
    if(widget is WindowUserCreate) resizableWindow.title = '계정 신규 생성창';
    if(widget is WindowUserEditor) resizableWindow.title = '계정 정보 수정창';
    if(widget is WindowItemTS) resizableWindow.title = "매입품목 공정 관리창";

    if(widget is WindowProcessOutputCreate) resizableWindow.title = "신규 생산품 생성창";
    if(widget is WindowProcessCreate) resizableWindow.title = "신규 공정 생성창";
  }

  ResizableWindow createWindow(BuildContext context, { double? pw, double? ph, }) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;

    var rng = new Random();

    if(pw != null) if(pw > w) pw = w - w * 0.12;
    if(ph != null) if(ph > h) pw = h - h * 0.12;

    ResizableWindow resizableWindow = ResizableWindow(
      startWidth: pw ?? w - w * 0.15, startHeight: ph ?? h - h * 0.15,
      x: rng.nextDouble() * 250, y: rng.nextDouble() * 250,
      title: '-',
    );

    resizableWindow.onWindowDragged = (dx,dy){
      resizableWindow.x += dx;
      resizableWindow.y += dy;

      _windows.remove(resizableWindow);
      _windows.add(resizableWindow);
      _onUpdate();
    };

    resizableWindow.onCloseButtonClicked = (){
      _windows.remove(resizableWindow);
      _onUpdate();
    };
    //Add Window to List
    _windows.add(resizableWindow);

    // Update Widgets after adding the new App
    _onUpdate();
    return resizableWindow;
  }
}