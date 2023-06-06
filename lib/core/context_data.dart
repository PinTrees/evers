

import 'package:flutter/cupertino.dart';

class ContextData {
  static var width = 0.0;
  static var height = 0.0;
  static var isMobile = false;
  static BuildContext? _context;

  ContextData({ BuildContext? context }) {
    if(context != null) _context = context;
    Init();
  }

  static void Init() {
    if(_context == null) return;

    width = MediaQuery.of(_context!).size.width;
    height = MediaQuery.of(_context!).size.height;

    isMobile = width < 800;
  }

  static double getPlatformContainerSize({ BuildContext? context }) {
    if(_context == null) {
      if(_context == null) return 0;
      else _context = context;
      Init();
    }

    if(isMobile) return width * 0.5;
    else return width * 0.9;
  }

  static double getPlatformPadding(BuildContext context) {

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    if(width < 800) return width * 0.07;
    else return width * 0.2;
  }
}