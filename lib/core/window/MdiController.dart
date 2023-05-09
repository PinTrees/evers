import 'dart:math';
import 'package:flutter/material.dart';

import 'ResizableWindow.dart';


class MdiController{

  MdiController(this._onUpdate);

  List<ResizableWindow> _windows = List.empty(growable: true);

  VoidCallback _onUpdate;

  List<ResizableWindow> get windows => _windows;

  /*void addWindow({ Widget? widget }) {
    _createNewWindowedApp(widget: widget);
  }*/
  void addWindow_TS({ Widget? widget, String? title }) {
    _createNewWindowedApp(widget: widget, w: 1280.0, h: 512.0, title: "수납 개별 정보창");
  }

  void _createNewWindowedApp({ Widget? widget, String? title, double? w, double? h }){
    var rng = new Random();

    ResizableWindow resizableWindow = ResizableWindow(
      startWidth: w ?? 1280, startHeight: h ?? 250,
      x: rng.nextDouble() * 250, y: rng.nextDouble() * 250,
      title: title ?? '-',
    );
    resizableWindow.widget = widget;

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