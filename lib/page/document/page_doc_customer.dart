

import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/interfaceUI.dart';
import 'package:flutter/widgets.dart';

class DocumentCustomer {
  static var div = 6.0;
  static var divT = 6.0 * 8;

  static Widget build() {
    return ListView(
      padding: EdgeInsets.all(12),
      children: [
        TextT.TitleMain(text: "거래처 목록 및 팝업창 UI 문서", ),
        SizedBox(height: div,),
        TextT.Lit(text: "info", size: 12),
        SizedBox(height: divT,),

        TextT.Title(text: "거래처 세부정보"),
        SizedBox(height: div,),
        TextT.Lit(text: "info", size: 12),
        SizedBox(height: divT,),

        TextT.Title(text: "거래처 검색"),
        SizedBox(height: div,),
        TextT.Lit(text: "info", size: 12),
        SizedBox(height: divT,),

        TextT.Title(text: "거래처 검색 쿼리"),
        SizedBox(height: div,),
        TextT.Lit(text: "info", size: 12),
        SizedBox(height: divT,),
      ],
    );
  }
}