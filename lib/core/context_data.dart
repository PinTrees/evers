

import 'package:flutter/cupertino.dart';

class ContextData {
  var width = 0.0;
  var height = 0.0;
  var isMobile = false;
  BuildContext? context;

  ContextData({ BuildContext? context }) {
    if(context != null) this.context = context;
    Init();
  }

  void Init() {
    if(context == null) return;

    width = MediaQuery.of(context!).size.width;
    height = MediaQuery.of(context!).size.height;

    isMobile = width < 800;
  }
}