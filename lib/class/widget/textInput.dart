


import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/ip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helper/interfaceUI.dart';

class InputWidget {
  static Map<String, TextEditingController> textInputs = {};
  static Map<String, bool> isActive = {};


  static Widget textSearch({ Function(String)? search, TextEditingController? controller }) {
    if(controller == null) {
      return SizedBox();
    }
    var w = Row(
      children: [
        SizedBox(height: 64,),
        Expanded(
          child: Container(
            height: 36,
            decoration: StyleT.inkStyleNone(color: Colors.grey.withOpacity(0.15), round: 10),
            child: TextFormField(
              maxLines: 1,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              onEditingComplete: () async {
                if(search != null) await search(controller!.text);
              },
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.transparent, width: 0)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: Colors.transparent, width: 0),),
                filled: true,
                fillColor: Colors.white.withOpacity(0),
                suffixIcon: Icon(Icons.keyboard),
                hintText: '검색어를 입력해 주세요.',
                hintStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                contentPadding: EdgeInsets.fromLTRB(12, 6, 12, 6),
              ),
              controller: controller,
            ),
          ),
        ),
        SizedBox(width: 6 ,),
        InkWell(
          onTap: () async {
            if(search != null) await search(controller!.text);
          },
          child: Container(
            height: 36, width: 36,
            decoration: StyleT.inkStyleNone(color: Colors.grey.withOpacity(0.15), round: 10),
            child: WidgetT.iconNormal(Icons.search),
          ),
        ),
        SizedBox(width: 18,),
      ],
    );

    return Expanded(child: w);
  }




  /// 이 함수는 다중라인 입력 위젯을 반환합니다.
  static Widget TextMultiLine(BuildContext context, String key, {
    int? index, Function(int, dynamic)? onEdite,
    Function? setState,
    bool expand=false,
    String? text, String? value,
    double? textSize, double?
    height, String? hint, bool? first=false,
    String? label,
    double? labelSize}) {
    if(textInputs[key] == null) textInputs[key] = new TextEditingController();
    isActive[key] = true;
    textInputs[key]!.text = value ?? text ?? '';

    if(setState == null) return SizedBox();

    Widget w = SizedBox();
    if(isActive[key] == true) {
      w = IntrinsicWidth(
        child: Container(
          child: TextFormField(
            autofocus: false,
            cursorColor: new Color(0xff009fdf).withOpacity(0.7),
            cursorWidth: 4.0,
            cursorRadius: Radius.elliptical(8, 8),
            style: TextStyle(color: StyleT.textColor.withOpacity(0.9), fontSize: textSize ?? 12, fontWeight: FontWeight.normal),
            maxLines: null,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            onEditingComplete: () async {
              isActive[key] = false;
              if(onEdite != null) onEdite(index ?? 0, textInputs[key]!.text);
              await setState();
            },
            decoration: WidgetTF.textInputDecoration( hintText: hint ?? '...', round: 4),
            controller: textInputs[key],
          ),
        ),
      );

      w = Focus(
        onFocusChange: (hasFocus) async {
          if(!hasFocus) {
            isActive[key] = false;
            if(onEdite != null) onEdite(index ?? 0, textInputs[key]!.text);
          }
          await setState();
        },
        child: w,
      );
    }

    if(expand) w = Expanded(child: w);

    return w;
  }





  static Widget DropButton({String text='', List<dynamic>? dropMenus, Map<dynamic, dynamic>? dropMenuMaps,
    double? width, Function(int, dynamic)? onEdite,
    Function(int, dynamic)? onEditeValue,
    Function? setState,
    int? index, String? label, double? labelWidth,}) {
    if(dropMenuMaps != null && dropMenus == null) {
      dropMenus = dropMenuMaps.values.toList();
    }
    if(setState == null) return SizedBox();

    var w = TextButton(
      onFocusChange: (f) async {
        if(f) isActive.clear();
      },
      onPressed: null,
      style: StyleT.buttonStyleOutline(padding: 0, round: 6, elevation: 3, color: Colors.white, strock: 1.4, strokColor: Colors.grey.withOpacity(0.35)),
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
                    if(onEditeValue != null) await onEditeValue(index ?? 0, dropMenuMaps.values.elementAt(i));
                    else if(onEdite != null) await onEdite(index ?? 0, data);
                    break;
                  }
                }
                await setState();
              } else {
                if(onEdite != null) await onEdite(index ?? 0, value);
                await setState();
              }
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
          if(label != null) TextT.Lit(text: label, width: labelWidth ?? 100, color: StyleT.titleColor, size: 12, bold: true),
          if(label != null) SizedBox(width: 6,),
          w,
        ],
      );
    }
    return w;
  }




  /// 이 함수는 보기 및 가이드 입력의 기초 템플릿 위젯입니다.
  /// 라벨과 입력 위젯을 반환합니다.
  /// 가로 사이즈를 설정하지 않을 경우 자동으로 조절됩니다. 다중라인 입력을 지원하지 않습니다.
  static Widget Lit(BuildContext context, String key, {
    int? index,
    Function(int, dynamic)? onEdited,
    Function? setState,
    String? text,
    String? lavel,
    String? value,
    Color? textColor,
    double? widthLavel,
    double? width,
    double? height, double? textSize,
    String? hint,
    bool expand=false,
    bool isMultiLine=false}) {

    if(textInputs[key] == null) textInputs[key] = new TextEditingController();
    isActive[key] = true;
    textInputs[key]!.text = value ?? text ?? '';

    if(setState == null) return SizedBox();

    Widget inputWidget = SizedBox();
    if(isActive[key] == true) {
      inputWidget = IntrinsicWidth(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: Container(
            width: width,
            color: Colors.grey.withOpacity(0.15),
            child: TextFormField(
              autofocus: false,
              cursorColor: new Color(0xff009fdf).withOpacity(0.7),
              cursorWidth: 2.0,
              cursorRadius: Radius.elliptical(4, 4),
              style: TextStyle(color: StyleT.textColor.withOpacity(0.9), fontSize: textSize ?? 12, fontWeight: FontWeight.normal),
              maxLines: isMultiLine ? null : 1,
              textInputAction: isMultiLine ? TextInputAction.newline : TextInputAction.search,
              keyboardType: isMultiLine ? TextInputType.multiline : TextInputType.none,
              onEditingComplete: () async {
                isActive[key] = false;
                if(onEdited != null) onEdited(index ?? 0, textInputs[key]!.text);
                await setState();
              },
              decoration: WidgetTF.textInputDecoration( hintText: hint ?? '...', round: 4),
              controller: textInputs[key],
            ),
          ),
        ),
      );
      inputWidget = Focus(
        onFocusChange: (hasFocus) async {
          if(!hasFocus) {
            isActive[key] = false;
            if(onEdited != null) onEdited(index ?? 0, textInputs[key]!.text);
          }
          await setState();
        },
        child: inputWidget,
      );
    }

    if(expand) inputWidget = Expanded(child: inputWidget);

    var w = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if(lavel != null) TextT.Lit(text: lavel, width: widthLavel ?? 100, color: StyleT.titleColor, size: 12, bold: true),
        if(lavel != null) SizedBox(width: 6,),
        inputWidget,
      ],
    );

    return w;
  }
}