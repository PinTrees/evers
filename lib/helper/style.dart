
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

class StyleT {
  static var backgroundColor = new Color(0xffF2E3D5);
  static var backgroundHighColor = new Color(0xff293742);
  static var backgroundLowColor = new Color(0xffBFB3A8);

  static var accentColor = new Color(0xff012E40);
  static var accentLowColor = new Color(0xff024959);

  static var accentOver = new Color(0xffF2E3D5);
  static var tabColor = new Color(0xffe6e6e6);
  static var tabBarColor = new Color(0xffb29272);
  static var subTabBarColor = new Color(0xff222229);

  static var excelTitleColor = new Color(0xff1855a5);

  static var disableColor = new Color(0xff3CA6A6);

  static var errorColor = Colors.black;
  static var errorLowColor = new Color(0xffF2C6C2);

  static var titleColor = new Color(0xff212121);
  static var dlColor = new Color(0xff010326);

  static var redA = new Color(0xffBF1341);

  static var iconColor = new Color(0xff555555);
  static var strokAColor = new Color(0xff524437);
  static var textColor = new Color(0xff555555);
  
  static var divideHeight = 12.0;
  static var subTitleSize = 16.0;
  static var listHeight = 36.0;

  static var white = Colors.white;
  static bool isDark = false;

  static Map<String, Color> scheduleColor = {};
  static Map<String, String> scheduleName = {};

  static init() {
    scheduleColor['0'] = Color(0xff293742);
    scheduleColor['1'] = Color(0xffFFDC95);
    scheduleColor['2'] = Color(0xffD98BA0);
    scheduleColor['3'] = Color(0xff197B9A);
    scheduleColor['4'] = Color(0xff05ACF2);
    scheduleColor['5'] = Color(0xffF25A38);

    scheduleName['0'] = '기타';
    scheduleName['1'] = '운송';
    scheduleName['2'] = '개인';
    scheduleName['3'] = '발주';
    scheduleName['4'] = '통화메모';
    scheduleName['5'] = '마감';
  }

  static initBrihtsty() async {
    if(isDark) {
      initLightMode();
      isDark = false;
      await Window.setEffect(
        effect: WindowEffect.aero,
        color: Color(0xEEf0f0f0),
        //dark: InterfaceBrightness.dark,
      );
    } else {
      initDarkMode();
      isDark = true;
      await Window.setEffect(
        effect: WindowEffect.aero,
        color: Color(0xEE353540),
        //dark: InterfaceBrightness.dark,
      );
    }
  }
  static initLightMode() {
    backgroundColor = new Color(0xffE6DFD9);
    backgroundHighColor = new Color(0xff7A7067);
    backgroundLowColor = new Color(0xffBFB3A8);

    accentColor = new Color(0xfff729599);
    accentLowColor = new Color(0xffBCC5CE);

    titleColor = new Color(0xff212121);
    textColor = new Color(0xff555555);
  }
  static initDarkMode() {
    backgroundColor = new Color(0xff262626);
    backgroundHighColor = new Color(0xff0D0D0D);
    backgroundLowColor = new Color(0xff595959);

    accentColor = new Color(0xff395059);
    accentLowColor = new Color(0xff6C838C);

    titleColor = new Color(0xffD9D9D9);
    textColor = new Color(0xffA6A6A6);
  }

  static BoxDecoration dropButtonStyle() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: StyleT.textColor.withOpacity(0.5), width: 1.4),
      color: Colors.white.withOpacity(0.5),
    );
  }
  static BoxDecoration dropDownStyle() {
    return  BoxDecoration(
      borderRadius: BorderRadius.circular(0),
      border: Border.all(color: Colors.grey.shade400, width: 1.4),
      color: Colors.white.withOpacity(1),
    );
  }
  static BoxDecoration inkStyle({Color? color, double? stroke, double? round, Color? strokeColor}) {
    return BoxDecoration(color: color ?? StyleT.backgroundColor.withOpacity(0.5),
      border: Border.all(width: stroke ?? 0.35, color: strokeColor ?? StyleT.strokAColor.withOpacity(0.35),),
    borderRadius: BorderRadius.circular(round ?? 0),
    );
  }
  static BoxDecoration inkStyleNone({Color? color, double? stroke, double? round, }) {
    return BoxDecoration(color: color ?? StyleT.backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(round ?? 0)
    );
  }

  static DateTime? stringToDate(String data) {
    var dS = data.replaceAll('.', '-');
    DateTime? dD = DateTime.tryParse(dS);
    return dD;
  }

  static dynamic getSCHTag(String id) {
    return scheduleName[id] ?? id;
  }

  static ButtonStyle buttonStyleTabBar({ double? elevation, double? padding, Color? color, Color? shadowColor, double? strock }) {
    return TextButton.styleFrom(
      minimumSize: Size.zero,
      shadowColor: shadowColor ?? Colors.black.withOpacity(0.7),
      elevation: elevation ?? 0,
      padding: EdgeInsets.all(padding ?? 16),
      backgroundColor: color ?? StyleT.backgroundLowColor,
      //side: BorderSide(width: strock ?? 1, color: titleColor.withOpacity(0.5),),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
    );
  }
  static ButtonStyle buttonStyleOutline({ bool isNoHover=false, double? elevation, double? padding,
    Color? color, double? round, Color? strokColor, Color? shadowColor, double? strock }) {
    return TextButton.styleFrom(
      minimumSize: Size.zero,
      shadowColor: shadowColor ?? Colors.black.withOpacity(0.7),
      elevation: elevation ?? 12,
      padding: EdgeInsets.all(padding ?? 16),
      backgroundColor: color ?? StyleT.backgroundLowColor,
      side: BorderSide(width: strock ?? 1, color: strokColor ?? strokAColor.withOpacity(0.35),),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(round ?? 4)),
    );
  }
  static ButtonStyle buttonStyleNone({ double? elevation=0, double? padding, Color color=Colors.transparent, Color? shadowColor, double? round, double? strock }) {
    return TextButton.styleFrom(
      minimumSize: Size.zero,
      elevation: elevation ?? 0,
      padding: EdgeInsets.all(padding ?? 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(round ?? 0)),
      backgroundColor: color,
    );
  }

  static String dateFormatAll(DateTime date) {
    var str = DateFormat.yMEd().add_Hms().format(date);
    str = str.replaceAll('Sat', '토');
    str = str.replaceAll('Sun', '일');
    str = str.replaceAll('Mon', '월');
    str = str.replaceAll('Tue', '화');
    str = str.replaceAll('Wed', '수');
    str = str.replaceAll('Thu', '목');
    str = str.replaceAll('Fri', '금');
    return str;
    return DateFormat('yyyy년 M월 d일    H시 m분').format(date) ?? '';
  }
  static String dateFormatYYYYMD_(DateTime date) {
    return DateFormat('yyyy년 M월 d일').format(date) ?? '';
  }
  static String dateFormatHM(DateTime date) {
    return DateFormat('hh시 m분').format(date) ?? '';
  }

  static String dateFormat(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date) ?? '';
  }
  static String dateFormatBarAtEpoch(String epoch) {
    var epochInt = int.tryParse(epoch);
    if(epochInt == null) return ' - ';
    return DateFormat('yyyy-MM-dd').format(DateTime.fromMicrosecondsSinceEpoch(epochInt));
  }

  static String dateFormatYYMMDD(int ephoce) {
    /// yyyyMMdd
    return DateFormat('yyyyMMdd').format(DateTime.fromMicrosecondsSinceEpoch(ephoce)) ?? '';
  }
  static String dateFormatM(DateTime date) {
    return DateFormat('yyyy-MM').format(date) ?? '';
  }
  static String dateFormatAtEpoch(String epoch) {
    var epochInt = int.tryParse(epoch);
    if(epochInt == null) return ' - ';
    return DateFormat('yyyy/MM/dd').format(DateTime.fromMicrosecondsSinceEpoch(epochInt));
  }
  static String dateInputFormatAtEpoch(String? epoch) {
    var epochInt = int.tryParse(epoch ?? '');
    if(epochInt == null) return '';
    if(epochInt == 0) return '';
    return DateFormat('yyyy/MM/dd').format(DateTime.fromMicrosecondsSinceEpoch(epochInt));
  }
  static int dateEpoch(String date) {
    if(date == '') return 0;
    var dS = date.replaceAll('.', '-').replaceAll('/', '-');
    DateTime? dD = DateTime.tryParse(dS);
    if(dD == null) return 0;
    return dD.microsecondsSinceEpoch;
  }

  static TextStyle titleBigStyle({ bool bold=true, Color? color}) {
    return TextStyle(
        fontSize: 16,
        color: color ?? titleColor.withOpacity(0.7),
        fontWeight: bold ? FontWeight.w900 : FontWeight.normal
    );
  }
  static TextStyle titleNormalStyle({ bool bold=true, Color? color}) {
    var c = color ?? titleColor.withOpacity(1);
    return TextStyle(
        fontSize: 13,
        color: c,
        fontWeight: bold ? FontWeight.w900 : FontWeight.normal,

    );
  }

  static TextStyle textStyleBig({bool bold=false}) {
    return TextStyle(
        fontSize: 12, color: textColor,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal
    );
  }
  static TextStyle hintStyle({bool bold=false, double? size, bool accent=false}) {
    return TextStyle(
        fontSize: size ?? 12, color: accent ? titleColor.withOpacity(0.5) :  textColor.withOpacity(0.5),
        fontWeight: bold ? FontWeight.bold : FontWeight.normal
    );
  }

  static TextStyle titleBoldStyle({ bool bold=true, Color? color}) {
    return TextStyle(
        fontSize: 12,
        color: color ?? titleColor,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal
    );
  }


  static TextStyle titleStyle({ bool bold=false, Color? color, Color? backColor}) {
    return TextStyle(
        fontSize: 12,
        color: color ?? titleColor,
        backgroundColor: backColor,
        fontWeight: bold ? FontWeight.w900 : FontWeight.w900
    );
  }
  static TextStyle textStyle({bool bold=false}) {
    return TextStyle(
      fontSize: 10, color: textColor,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal
    );
  }

  static List<TextSpan> getSearchTextSpans(String text, String matchWord, TextStyle style) {

    List<TextSpan> spans = [];
    int spanBoundary = 0;

    do {

      // 전체 String 에서 키워드 검색
      final startIndex = text.indexOf(matchWord, spanBoundary);

      // 전체 String 에서 해당 키워드가 더 이상 없을때 마지막 KeyWord부터 끝까지의 TextSpan 추가
      if (startIndex == -1) {
        spans.add(TextSpan(text: text.substring(spanBoundary)));
        return spans;
      }

      // 전체 String 사이에서 발견한 키워드들 사이의 text에 대한 textSpan 추가
      if (startIndex > spanBoundary) {
        print(text.substring(spanBoundary, startIndex));
        spans.add(TextSpan(text: text.substring(spanBoundary, startIndex)));
      }

      // 검색하고자 했던 키워드에 대한 textSpan 추가
      final endIndex = startIndex + matchWord.length;
      final spanText = text.substring(startIndex, endIndex);
      spans.add(TextSpan(text: spanText, style: style));

      // mark the boundary to start the next search from
      spanBoundary = endIndex;

      // continue until there are no more matches
    }
    //String 전체 검사
    while (spanBoundary < text.length);

    return spans;
  }

  static String krw(String? data) {
    if(data == null) return ' - ';
    var k = int.tryParse(data);
    if(k == null) return ' - ';

    var f = NumberFormat.simpleCurrency(locale: "ko_KR", name: "", decimalDigits: 0);
    return f.format(k);
  }
  static String krwInt(int? data) {
    if(data == null) return ' - ';

    var f = NumberFormat.simpleCurrency(locale: "ko_KR", name: "", decimalDigits: 0);
    return f.format(data);
  }

  static String intNumberF(int? date) {
    if(date == null) return ' - ';
    if(date == 0) return ' - ';

    var f = NumberFormat('###,###,###,###,###,###,###');
    //print(f.format(date));
    return f.format(date);
  }
}

class DateStyle {
  static String dateYearsHarp(int ephoce) {
    var date = DateTime.fromMicrosecondsSinceEpoch(ephoce);
    var harp = 1;
    if(date.month <= 6) {
      harp = 1;
    } else {
      harp = 2;
    }

    return '${date.year}-${harp}H';
  }
  static String dateYearsQuarter(int ephoce) {
    var date = DateTime.fromMicrosecondsSinceEpoch(ephoce);
    var quarter = 1;
    if(date.month > 9) {
      quarter = 4;
    } else if(date.month > 6) {
      quarter = 3;
    } else if(date.month > 3) {
      quarter = 2;
    } else if(date.month > 0) {
      quarter = 1;
    }

    return '${date.year}-${quarter}Q';
  }
}

class ConvertT {
  static String getNowEpoch() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}