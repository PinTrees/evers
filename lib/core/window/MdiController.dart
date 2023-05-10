import 'dart:math';
import 'package:evers/page/window/window_cs.dart';
import 'package:evers/page/window/window_factory.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/page/window/window_ts_editor.dart';
import 'package:flutter/material.dart';

import '../../page/window/window_ct.dart';
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
    if(widget is WindowTS) resizableWindow.title = '수납 개별 상세정보창';
    if(widget is WindowFactoryCreate) resizableWindow.title = '공장일보 생성창';
    if(widget is WindowCT) resizableWindow.title = '계약 개별 상세정보창';
  }

  ResizableWindow createWindow(BuildContext context, { double? pw, double? ph, }) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;

    var rng = new Random();

    if(pw != null)
      if(pw > w) pw = w - w * 0.12;
    if(ph != null)
      if(ph > h) pw = h - h * 0.12;

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