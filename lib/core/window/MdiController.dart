import 'dart:math';
import 'package:flutter/material.dart';

import 'ResizableWindow.dart';


class MdiController{

  MdiController(this._onUpdate);

  List<ResizableWindow> _windows = List.empty(growable: true);

  VoidCallback _onUpdate;

  List<ResizableWindow> get windows => _windows;

  void addWindow(BuildContext context, { Widget? widget, ResizableWindow? resizableWindow, String? title, bool fixedHeight=false, }) {
    resizableWindow!.widget = widget;
    resizableWindow!.fixedHeight = fixedHeight;
    resizableWindow!.title = title ?? '정보창';
  }

  void addWindow_TS({ Widget? widget, String? title }) {
    _createNewWindowedApp(widget: widget, w: 1280.0, h: 512.0, title: "수납 개별 정보창");
  }
  void addWindow_CS(BuildContext context, { Widget? widget, ResizableWindow? resizableWindow, String? title }) {
    resizableWindow!.widget = widget;
    resizableWindow!.fixedHeight = true;
    resizableWindow!.title = title ?? '거래처 개별 상세정보 창';
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

  void _createNewWindowedApp({ Widget? widget, String? title, double? w, double? h, bool fixedHeight=false,}){
    var rng = new Random();

    ResizableWindow resizableWindow = ResizableWindow(
      startWidth: w ?? 1280, startHeight: h ?? 250,
      x: rng.nextDouble() * 250, y: rng.nextDouble() * 250,
      title: title ?? '-',
    );


    resizableWindow.widget = widget;
    resizableWindow.fixedHeight = fixedHeight;

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
  }
}