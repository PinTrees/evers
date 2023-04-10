import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'dialog.dart';
import 'transition.dart';

class WidgetT extends StatelessWidget {

  static Map<String, TextEditingController> textInputs = {};
  static Map<String, bool> isActive = {};

  static Widget titleRowW(List<String> title, List<double> width, { Color? color,  bool isTitle=false, bool isM=false, List<Widget>? leaging }) {
    List<Widget> chW = [];

    for(int i = 0; i < title.length; i++) {
      if(i != 0) chW.add(WidgetT.dividViertical(height: 28));
      var w = WidgetT.excelGrid(label:title[i], width: width[i]);
      if(isTitle) w = WidgetT.excelGrid(text:title[i], width: null, alignment: Alignment.centerLeft);
      if(width[i] > 900 && isTitle == false) {
        w = Expanded(child: w);
      }
      chW.add(w);
    }

    var grc = [
      const Color(0xFF1855a5).withOpacity(0.35),
      const Color(0xFF000000).withOpacity(0.5),
    ];
    if(isM) grc = [
      const Color(0xFF1855a5).withOpacity(0.35),
      const Color(0xFF000000).withOpacity(0.5),
    ];

    if(isTitle || isM) {
      if(leaging != null) {
        chW.add(SizedBox(width: 18,));
        for(int i = 0; i < leaging.length; i++) {
          chW.add(leaging[i]);
          chW.add(SizedBox(width: 18,));
        }
      }
      return Column(
        children: [
          Container(
            decoration: StyleT.inkStyle(stroke: 0.35, color: Colors.transparent),
              child: Container( height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: grc,
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: Row(
                  children: chW,
                ),
              )
          ),
          WidgetT.dividHorizontal(size: 2)
        ],
      );
    }

    return Container(
        decoration: StyleT.inkStyle(stroke: 0.35, color: StyleT.backgroundLowColor.withOpacity(0.5)),
        child: Container( height: 28,
          child: Row(
              children: chW,
          ),
        )
    );
  }

  static Widget excelGrid({ String? text, bool textLite=false, String? value,
    double? width, double? height, String? label, Color? color, Color? textColor, double? textSize,  Alignment? alignment }) {
    var w = Container(
      width: width, height: height, alignment: alignment ?? Alignment.center,
      color: color ?? Colors.transparent,
      padding: EdgeInsets.all(6),
      child:  Row(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: (alignment == Alignment.centerLeft) ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          WidgetT.text(label ?? '', size: 10,),
          if(text != null)
            SizedBox(width: 4,),

          if(!textLite)
            WidgetT.titleT(text ?? '', color: textColor, size: textSize),
          if(textLite)
            WidgetT.text(text ?? '', size:textSize ?? 12),
        ],
      ),
    );
    return w;
  }

  static Widget textInput(BuildContext context, String key, {int? index, Function(int, dynamic)? onEdite, Function? setState,
    String? text, String? value,
    double? width, double? height, String? hint, bool? first=false, bool isMultiLine=false, String? label, double? labelSize}) {
    if(textInputs[key] == null) textInputs[key] = new TextEditingController();
    Widget w = SizedBox();
    if(isActive[key] == true) {
      w = Container(
        width: width, height: isMultiLine ? height : 28,
        child: TextFormField(
          autofocus: true,
          maxLines: isMultiLine ? 10 : 1,
          textInputAction: isMultiLine ? TextInputAction.newline : TextInputAction.search,
          keyboardType: isMultiLine ? TextInputType.multiline : TextInputType.none,
          onEditingComplete: () async {
            isActive[key] = false;
            if(onEdite != null) onEdite(index ?? 0, textInputs[key]!.text);
            await FunT.setStateDT();
          },
          decoration: WidgetT.textInputDecoration( hintText: hint ?? '...', round: 4),
          controller: textInputs[key],
        ),
      );
      w = Focus(
        onFocusChange: (hasFocus) async {
          if(!hasFocus) {
            isActive[key] = false;
            if(onEdite != null) onEdite(index ?? 0, textInputs[key]!.text);
          }
          await FunT.setStateDT();
        },
        child: w,
      );
    }
    else {
      w = TextButton(
        onFocusChange: (hasFocus) async {
          isActive[key] = true;
          textInputs[key]!.text = value ?? text ?? '';
          await FunT.setStateDT();
        },
        onPressed: () async {
          isActive[key] = true;
          textInputs[key]!.text = value ?? text ?? '';
          await FunT.setStateDT();
        },
        style: StyleT.buttonStyleOutline(elevation: 0, padding: 0, color: Colors.transparent, strock: 0.7, round: 0),
        child: Container(
          width: width, height: height ?? 28, alignment: Alignment.center,
          child:  Text('${text ?? '' }', style: StyleT.titleStyle(),),
        ),
      );
    }
    if(label != null) {
      return Row(
        children: [
          WidgetT.title(label, width: labelSize ?? 100),
          w,
        ],
      );
    }
    return w;
  }
  static Widget excelInput(BuildContext context, String key, {int? index, Function(int, dynamic)? onEdite,
    String? text, String? value, bool isMain=false,
    double? width, double? height, double? textSize, String? hint, bool? first=false, bool isMultiLine=false, String? label, double? labelSize}) {
    if(textInputs[key] == null) textInputs[key] = new TextEditingController();
    Widget w = SizedBox();
    if(isActive[key] == true) {
      w = Container(
        width: width ?? double.maxFinite, height: isMultiLine ? height : 28,
        child: TextFormField(
          autofocus: true,
          maxLines: isMultiLine ? 10 : 1,
          textInputAction: isMultiLine ? TextInputAction.newline : TextInputAction.search,
          keyboardType: isMultiLine ? TextInputType.multiline : TextInputType.none,
          onEditingComplete: () async {
            isActive[key] = false;
            if(onEdite != null) await onEdite(index ?? 0, textInputs[key]!.text);
            if(isMain) await FunT.setStateMain();
            else await FunT.setStateDT();
          },
          decoration: WidgetT.textInputDecoration( hintText: hint ?? '...', round: 4),
          controller: textInputs[key],
        ),
      );
      w = Focus(
        onFocusChange: (hasFocus) async {
          if(!hasFocus) {
            isActive[key] = false;
            if(onEdite != null) await onEdite(index ?? 0, textInputs[key]!.text);
          }
          if(isMain) await FunT.setStateMain();
          else await FunT.setStateDT();
        },
        child: w,
      );
    }
    else {
      Widget tw = SizedBox();
      if(text == null) {
        if(hint != null)
          tw = WidgetT.text(hint, size: textSize ?? 12,);
      }
      else if(text == '') {
        if(hint != null)
          tw = WidgetT.text(hint, size:textSize ?? 12,);
      }
      else {
        tw = WidgetT.title(text, size: textSize ?? 12,);
      }


      w = InkWell(
        onFocusChange: (hasFocus) async {
          isActive[key] = true;
          textInputs[key]!.text = value ?? text ?? '';
          if(isMain) await FunT.setStateMain();
          else await FunT.setStateDT();
        },
        onTap: () async {
          isActive[key] = true;
          textInputs[key]!.text = value ?? text ?? '';

          if(isMain) await FunT.setStateMain();
          else await FunT.setStateDT();
        },
        child: Container(
          width: width ?? double.maxFinite, height: height ?? 28, alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              WidgetT.text(label ?? '', size: 10,),
              SizedBox(width: 4,),
              tw,
            ],
          ),
        ),
      );
    }
    return w;
  }
  static Widget dropMenu({String text='', List<dynamic>? dropMenus, Map<dynamic, dynamic>? dropMenuMaps,
    double? width, Function(int, dynamic)? onEdite, int? index, String? label, double? labelSize,}) {
    /// 키가 진짜 갑 - 밸류가 표시되는 값 : key, value
    if(dropMenuMaps != null) {
      dropMenus = dropMenuMaps.values.toList();
    }

    var w = TextButton(
      onFocusChange: (f) async {
        if(f) isActive.clear();
        await FunT.setStateDT();
      },
      onPressed: null,
      style: StyleT.buttonStyleOutline(padding: 0, round: 0, elevation: 3, color: Colors.white, strock: 0.01,),
      child: SizedBox(
        height: 28, width: width,
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            focusColor: Colors.transparent,
            focusNode: FocusNode(),
            autofocus: false,
            customButton: Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(child: SizedBox()),
                  Text('${text ?? '' }', style: StyleT.titleStyle(),),
                  Expanded(child: SizedBox()),
                ],
              ),
            ),
            items: dropMenus?.map((item) => DropdownMenuItem<dynamic>(
              value: item,
              child: Text(
                item.toString(),
                style: StyleT.titleStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            )).toList(),
            onChanged: (value) async {
              if(dropMenuMaps != null) {
                var data = '';
                for(int i =0; i < dropMenuMaps.values.length; i++) {
                  if(dropMenuMaps.values.elementAt(i) == value) {
                    data = dropMenuMaps.keys.elementAt(i);
                    break;
                  }
                }
                if(onEdite != null) await onEdite(index ?? 0, data);
                await FunT.setStateDT();
                return;
              }

              if(onEdite != null) await onEdite(index ?? 0, value);
              await FunT.setStateDT();
            },
            itemHeight: 28,
            itemPadding: const EdgeInsets.only(left: 16, right: 16),
            dropdownWidth: width,
            dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
            dropdownDecoration: BoxDecoration(
              border: Border.all(
                width: 1.7,
                color: Colors.grey.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(0),
              color: Colors.white.withOpacity(0.95),
            ),
            dropdownElevation: 0,
            offset: const Offset(0, 0),
          ),
        ),
      ),
    );

    if(label != null) {
      return Row(
        children: [
          WidgetT.title(label, width: labelSize ?? 100),
          w,
        ],
      );
    }
    return w;
  }
  static Widget dropMenuMapD({String text='', Map<String, dynamic>? dropMenuMaps,
    double? width, Function(int, dynamic)? onEdite, int? index, String? label, double? labelSize}) {

    var w = TextButton(
      onFocusChange: (f) async {
        if(f) isActive.clear();
        await FunT.setStateDT();
      },
      onPressed: null,
      style: StyleT.buttonStyleOutline(padding: 0, round: 0, elevation: 0, color: Colors.transparent, strock: 1.4, strokColor: StyleT.accentLowColor.withOpacity(0.7)),
      child: SizedBox(
        height: 28, width: width,
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            focusColor: Colors.transparent,
            focusNode: FocusNode(),
            autofocus: false,
            customButton: Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(child: SizedBox()),
                  Text('${text ?? '' }', style: StyleT.titleStyle(),),
                  Expanded(child: SizedBox()),
                ],
              ),
            ),
            items: dropMenuMaps?.keys.map((item) => DropdownMenuItem<dynamic>(
              value: item,
              child: Text(
                dropMenuMaps[item].name,
                style: StyleT.titleStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            )).toList(),
            onChanged: (value) async {
              if(onEdite != null) await onEdite(index ?? 0, value);
              await FunT.setStateDT();
            },
            itemHeight: 28,
            itemPadding: const EdgeInsets.only(left: 16, right: 16),
            dropdownWidth: width,
            dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
            dropdownDecoration: BoxDecoration(
              border: Border.all(
                width: 1.7,
                color: Colors.grey.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(0),
              color: Colors.white.withOpacity(0.95),
            ),
            dropdownElevation: 0,
            offset: const Offset(0, 0),
          ),
        ),
      ),
    );

    if(label != null) {
      return Row(
        children: [
          WidgetT.title(label, width: labelSize ?? 100),
          w,
        ],
      );
    }
    return w;
  }

  static Widget searchBar({ Function(String)? search, TextEditingController? controller }) {
    if(controller == null) {
      if(textInputs['search'] == null) textInputs['search'] = TextEditingController();
      controller = textInputs['search'];
    }
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              const Color(0xFF009fdf).withOpacity(0.0),
              const Color(0xFF1855a5).withOpacity(0.0),
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: Row(
        children: [
          SizedBox(width: 6 * 2,),
          Expanded(flex: 1, child: SizedBox(), ),
          Expanded( flex: 8,
            child: TextButton(
              onPressed: null,
              style: StyleT.buttonStyleNone(round: 18, elevation: 6, padding: 0,),
              child: Container( height: 36,
                child: TextFormField(
                  maxLines: 1,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textInputAction: TextInputAction.search,
                  keyboardType: TextInputType.text,
                  onEditingComplete: () async {
                    if(search != null) await search(controller!.text);
                  },
                  onChanged: (text) async {
                    if(text == '')
                      if(search != null) await search(text);
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: Colors.transparent, width: 0)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: Colors.transparent, width: 0),),
                    filled: true,
                    fillColor: Colors.white.withOpacity(1),
                    suffixIcon: Icon(Icons.keyboard),
                    hintText: '',
                    contentPadding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                  ),
                  controller: controller,
                ),
              ),
            ),),
          SizedBox(width: 6 * 4,),
          TextButton(
            onPressed: () async {
            },
            style: StyleT.buttonStyleNone(round: 18, elevation: 6, padding: 0, color:Colors.white, strock: 2),
            child: Container( height: 36, width: 36,
              child: WidgetT.iconNormal(Icons.search),),),
          Expanded(flex: 1, child: SizedBox(), ),
          SizedBox(width: 6 * 2,),
        ],
      ),
    );
  }

  static InputDecoration textInputDecoration({ String? hintText, double round=0.0, Color? backColor}) {
    return  InputDecoration(
      enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(0), borderSide: BorderSide(color: StyleT.disableColor.withOpacity(0.7), width: 1)),
      focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(0), borderSide: BorderSide(color: StyleT.accentColor, width: 1.7),),
      filled: true,
      fillColor: backColor ?? StyleT.accentColor.withOpacity(0.07),
      hintText: hintText ?? '',
      hintStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
      contentPadding: EdgeInsets.fromLTRB(12, 8, 8, 8),
    );
  }

  static void openPageWithFade(BuildContext context, dynamic page, { int? time, bool? first=false}) {
    if(first!)
      Navigator.of(context).popUntil((route) => route.isFirst);

    //Navigator.push(context, MaterialPageRoute(builder: (context) => page),);
    Navigator.of(context).push(FadePageRoute(page, time ?? 0));
  }

  /// 아이콘을 사이즈 박스로 래핑한 위젯을 반환
  static Widget iconMini(IconData icon, { double? size, Color? color, double? boxSize }) {
    return SizedBox(
      height: boxSize ?? size ?? 24, width: boxSize ?? size ?? 24,
      child: Icon(
        icon, size: 16, color: color ?? StyleT.iconColor,
      ),
    );
  }
  static Widget iconNormal(IconData icon, { double? size, Color? color }) {
    return SizedBox(
      height: size ?? 30, width: size ?? 30,
      child: Icon(
        icon, size: 20, color: color ?? StyleT.titleColor.withOpacity(0.7),
      ),
    );
  }
  static Widget iconBig(IconData icon, { double? size, Color? color }) {
    return SizedBox(
      height: size ?? 28, width: size ?? 28,
      child: Icon(
        icon, size: 28, color: color ?? StyleT.iconColor,
      ),
    );
  }
  static Widget iconLager(IconData icon, { double? size, Color? color }) {
    return SizedBox(
      height: size ?? 30, width: size ?? 30,
      child: Icon(
        icon, size: 36, color: color ?? StyleT.titleColor.withOpacity(0.7),
      ),
    );
  }

  static Widget titleTabMenu(String text, { bool accent=true }) {
    Widget w = Text(text, style: TextStyle(fontFeatures: [FontFeature.proportionalFigures()], fontWeight: accent ? FontWeight.w900 : FontWeight.w700,
        fontSize: 15, color: accent ? StyleT.tabColor : StyleT.tabColor));
    w = Column(
      children: [
        w,
        SizedBox(height: 4,),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: text.length * 15, height: accent ? 4 : 0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    const Color(0xFF009fdf).withOpacity(0.9),
                    const Color(0xFF1855a5).withOpacity(0.9),
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
          ),
        ),
      ],
    );
    return w;
  }
  static Widget title(String text, { double? size, bool bold=true, double? width }) {
    var w = Text(text, style: TextStyle(fontFamily: '', fontFeatures: [FontFeature.proportionalFigures()],
        fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
        fontSize: size ?? 12, color: StyleT.titleColor));
    if(width != null)
      return Container(padding: EdgeInsets.zero, alignment: Alignment.center, width: width, child: w,);
    return w;
  }
  static Widget titleBox(String text, { double? size, bool bold=true, double? width }) {
    var w = Text(text, style: TextStyle(fontFamily: '', fontFeatures: [FontFeature.proportionalFigures()],
        fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
        fontSize: size ?? 12, color: StyleT.titleColor));
    return Container(padding: EdgeInsets.zero, alignment: Alignment.center, width: width, child: w,);
  }
  static Widget titleT(String text, { Color? color, double? size, bool bold=true, double? width }) {
    var w = Text(text, style: TextStyle(fontFamily: '', fontFeatures: [FontFeature.proportionalFigures()],
        fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
        fontSize: size ?? 12, color: color ?? StyleT.titleColor.withOpacity(1)));
    if(width != null)
      return Container(alignment: Alignment.center, width: width, child: w,);
    return w;
  }
  static Widget text(String text, { double? size, double? width, bool bold=false, Color? color}) {
    var w = Text(text, style: TextStyle(fontFamily: '', fontFeatures: [FontFeature.proportionalFigures()],
        fontWeight: bold ?  FontWeight.w900 : FontWeight.w500,
        fontSize: size ?? 12, color: color ?? StyleT.textColor.withOpacity(1)));
    if(width != null)
      return Container(padding: EdgeInsets.zero, alignment: Alignment.center, width: width, child: w,);
    return w;
  }

  static Widget textLight(String text, { double? size, bool bold=false}) {
    return  Text(text, style: TextStyle(fontFamily: '', fontFeatures: [FontFeature.proportionalFigures()],
        fontWeight: bold ?  FontWeight.w900 : FontWeight.w700,
        fontSize: size ?? 12, color: StyleT.disableColor.withOpacity(0.9)));
  }

  static Widget titleBig(String text, { double? size, Color? color }) {
    return Text(text, style: TextStyle(fontFamily: '', fontFeatures: [FontFeature.proportionalFigures()],
        fontWeight: FontWeight.w900,
        fontSize: size ?? 18, color: color ?? StyleT.titleColor.withOpacity(0.7)));
  }

  static Widget buttonTab({Function? onPressed, String text=''}) {
    return TextButton(
        onPressed: () async {
          if(onPressed != null) await onPressed();
        },
        style: StyleT.buttonStyleOutline(strock: 1.4, elevation: 8),
        child: WidgetT.text(text));
  }

  static Widget textBig(String text) {
    return Stack(
      children: <Widget>[
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontFamily: '',
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = StyleT.textColor.withOpacity(0.7),
          ),
        ),
        Text(text, style: TextStyle(fontFamily: '',
            fontWeight: FontWeight.w900,
            fontSize: 14, color: StyleT.textColor.withOpacity(0.7))),
      ],
    );
  }
  static Widget textColorT(String text, { double? size, Color? color }) {
    return  Text(text, style: TextStyle(fontFamily: '', fontFeatures: [FontFeature.proportionalFigures()],
        fontWeight: FontWeight.w500,
        fontSize: size ?? 18, color:  color ?? StyleT.textColor.withOpacity(0.7)));
  }

  static Widget dividViertical({Color? color, double? height, double? size}) {
    return Container(height: height, width: size ?? 0.7, color: color ?? StyleT.strokAColor.withOpacity(0.35),);
  }
  static Widget dividHorizontal({Color? color, double? width, double? size}) {
    return Container(height: size ?? 1.4, width: width, color: color ?? StyleT.titleColor.withOpacity(0.35),);
  }

  static dynamic showSnackBar(BuildContext context, { String? text }) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    await ScaffoldMessenger.of(context).showSnackBar(
      //SnackBar 구현하는법 context는 위에 BuildContext에 있는 객체를 그대로 가져오면 됨.
        SnackBar(
          //width: 380,
          //elevation: 18,
          //behavior: SnackBarBehavior.floating,
          //backgroundColor: Colors.redAccent,
          content: Text(text ?? 'The feature is under development.'),
          duration: Duration(seconds: 3), //올라와있는 시간
          action: SnackBarAction(
            label: 'Undo',
            onPressed: (){},
          ),
        )
    );
  }
  static dynamic loadingBottomSheet(BuildContext context, { String? text }) async {
    showModalBottomSheet(context: context,
        isDismissible: false,
        barrierColor: Colors.black.withOpacity(0.2),
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setStateManager) {
            return Container(
              color: StyleT.backgroundHighColor,
              padding: EdgeInsets.fromLTRB(0, 18, 0, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(),),
                  SizedBox(height: 8,),
                  WidgetT.titleT(text ?? '로딩중...', size: 12, color: StyleT.backgroundColor),
                ],
              ),
            );
          });
        });
  }

  static Widget loginUser(BuildContext context) {
    if(FirebaseAuth.instance.currentUser != null) {
      return TextButton(
          onPressed: () {
            DialogT.showUserInfo(context);
          },
          style: StyleT.buttonStyleNone(padding: 0, color: Colors.transparent,),
          child: Container( padding: EdgeInsets.all(6),
              child: WidgetT.iconBig(Icons.person, color: StyleT.tabColor)));
    }
    return SizedBox();
  }

  Widget build(context) {
    return Container();
  }
}
