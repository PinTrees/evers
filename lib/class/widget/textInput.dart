


import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/ip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helper/interfaceUI.dart';

class InputWidget {
  static Map<String, TextEditingController> textInputs = {};
  static Map<String, bool> isActive = {};
  static OverlayEntry? overlayEntry;

  static Widget textSearch({ Function(String)? search, TextEditingController? controller,
    List<String>? suggestions,
    BuildContext? context,
    Function? setState,
  }) {
    if(controller == null) {
      return SizedBox();
    }


    var textField = AutoCompleteTextField<String>(
      key: GlobalKey(),

      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,

      controller: controller,
      suggestions: suggestions ?? [],
      itemBuilder: (context, suggestion) => Container(
        height: 32,
        padding: EdgeInsets.all(6),
        child: Text(suggestion, style: TextStyle(fontSize: 14),),
      ),
      itemSorter: (a, b) => a.compareTo(b),
      itemFilter: (suggestion, query) => suggestion.toLowerCase().startsWith(query.toLowerCase()),
      itemSubmitted: (value) async {
        controller!.text = value;
        if(search != null) await search(controller!.text);
      },
      textChanged: (value) { if(setState != null) setState(() {}); },
      textSubmitted: (value) async {
        if(search != null) await search(controller!.text);
      },
      clearOnSubmit: false,
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
    );


    var w = Row(
      children: [
        SizedBox(height: 64,),
        Expanded(
          child: Container(
            height: 36,
            decoration: StyleT.inkStyleNone(color: Colors.grey.withOpacity(0.15), round: 10),
            child: textField,
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





  /// 플러터에서 드롭다운 버튼을 생성하는 정적 함수입니다.
  ///
  /// 파라미터:
  /// - text: 버튼에 표시될 텍스트입니다.
  /// - dropMenuMaps: 드롭다운 메뉴의 값들과 해당 값에 대응하는 항목들을 매핑한 맵입니다.
  /// - labelText: 드롭다운 버튼 옆에 표시될 라벨 텍스트입니다.
  /// - width: 드롭다운 버튼의 너비입니다.
  /// - onEditeKey: 드롭다운 메뉴의 키 값이 변경될 때 호출되는 콜백 함수입니다.
  /// - onEditeValue: 드롭다운 메뉴의 값이 변경될 때 호출되는 콜백 함수입니다.
  /// - setState: 상태 업데이트를 위한 setState 함수입니다.
  /// - index: 드롭다운 버튼의 인덱스입니다.
  /// - label: 드롭다운 버튼의 라벨입니다.
  /// - labelWidth: 라벨의 너비입니다.
  static Widget DropButtonT<T>({
    String text = '',
    required Map<dynamic, T> dropMenuMaps,
    required String Function(T) labelText,
    double? width,
    Function(int, dynamic)? onEditeKey,
    Function(int, T)? onEditeValue,
    Function? setState,
    int? index,
    String? label,
    double? labelWidth,
  }) {
    if (setState == null) return SizedBox();

    var w = TextButton(
      onFocusChange: (f) async {
        if (f) isActive.clear();
      },
      onPressed: null,
      style: StyleT.buttonStyleOutline(
        padding: 0,
        round: 6,
        elevation: 3,
        color: Colors.white,
        strock: 1.4,
        strokColor: Colors.grey.withOpacity(0.35),
      ),
      child: SizedBox(
        height: 28,
        width: width,
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
                  Text(
                    '${text ?? ''}',
                    style: StyleT.titleStyle(),
                  ),
                  Expanded(child: SizedBox()),
                ],
              ),
            ),
            items: dropMenuMaps!.values.map((item) => DropdownMenuItem<dynamic>(
                value: item,
                child: Text(
                  labelText(item),
                  style: StyleT.titleStyle(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ).toList(),

            onChanged: (value) async {
              if (dropMenuMaps != null) {
                if (onEditeValue != null)
                  await onEditeValue(index ?? 0, value);
                else if (onEditeKey != null) {
                  for (var k in dropMenuMaps.keys)
                    if (dropMenuMaps[k] == value) {
                      await onEditeKey(index ?? 0, k);
                      break;
                    }
                }
                await setState();
              } else {
                if (onEditeKey != null) await onEditeKey(index ?? 0, value);
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

    if (label != null) {
      return Row(
        children: [
          if (label != null)
            TextT.Lit(
              text: label,
              width: labelWidth ?? 100,
              color: StyleT.titleColor,
              size: 12,
              bold: true,
            ),
          if (label != null) SizedBox(width: 6),
          w,
        ],
      );
    }
    return w;
  }




  /// 주어진 텍스트를 입력받는 텍스트 필드 위젯을 생성하는 정적 함수입니다.
  ///
  /// 파라미터:
  /// - context: 빌드 컨텍스트입니다.
  /// - key: 텍스트 필드의 고유 키입니다.
  /// - index: 인덱스 값입니다.
  /// - onEdited: 값이 편집될 때 호출되는 콜백 함수입니다.
  /// - setState: 상태 업데이트를 위한 setState 함수입니다.
  /// - text: 텍스트 필드의 기본 텍스트입니다.
  /// - bold: 텍스트의 굵기를 지정합니다.
  /// - label: 텍스트 필드 옆에 표시될 라벨 텍스트입니다.
  /// - value: 텍스트 필드의 초기 값입니다.
  /// - textColor: 텍스트의 색상입니다.
  /// - color: 텍스트 필드의 배경색입니다.
  /// - widthLabel: 라벨의 너비입니다.
  /// - width: 텍스트 필드의 너비입니다.
  /// - height: 텍스트 필드의 높이입니다.
  /// - textSize: 텍스트의 크기입니다.
  /// - hint: 텍스트 필드의 힌트 텍스트입니다.
  /// - expand: 텍스트 필드가 확장되어 가로 공간을 채울지 여부를 지정합니다.
  /// - isMultiLine: 여러 줄의 텍스트를 입력받을지 여부를 지정합니다.
  static Widget LitText(BuildContext context, String key, {int? index,
    Function(int, dynamic)? onEdited,
    Function? setState,
    String? text,
    bool bold = false,
    String? label,
    String? value,
    Color? textColor,
    Color? color,
    double? widthLabel,
    double? width,
    double? height,
    double? textSize,
    String? hint,
    bool expand = false,
    bool isMultiLine = false}) {

    if (textInputs[key] == null) textInputs[key] = new TextEditingController();
    textInputs[key]!.text = value ?? text ?? '';

    if (setState == null) return SizedBox();

    var textStyle = TextStyle(
      color: textColor ?? StyleT.textColor.withOpacity(0.9),
      fontSize: textSize ?? 12,
      fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
    );

    Widget buildInputWidget() {
      return IntrinsicWidth(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: Container(
            width: width,
            color: color ?? Colors.grey.withOpacity(0.15),
            child: TextFormField(
              autofocus: false,
              cursorColor: Color(0xff009fdf).withOpacity(0.7),
              cursorWidth: 2.0,
              cursorRadius: Radius.elliptical(4, 4),
              style: textStyle,
              maxLines: isMultiLine ? null : 1,
              textInputAction:
              isMultiLine ? TextInputAction.newline : TextInputAction.search,
              keyboardType:
              isMultiLine ? TextInputType.multiline : TextInputType.none,
              onEditingComplete: () async {
                isActive[key] = false;
                if (onEdited != null) onEdited(index ?? 0, textInputs[key]!.text);
                await setState();
              },
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(color: Colors.transparent, width: 0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(color: Colors.transparent, width: 0),
                ),
                filled: true,
                isDense: true,
                fillColor: Colors.transparent,
                hintText: hint ?? '',
                hintStyle: textStyle,
                contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 12),
              ),
              controller: textInputs[key],
            ),
          ),
        ),
      );
    }
    Widget w = Focus(
        onFocusChange: (focus) async {
          if (onEdited != null) onEdited(index ?? 0, textInputs[key]!.text);
          await setState();
        },
        child: buildInputWidget(),
    );

    if (expand) w = Expanded(child: w);


    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          TextT.Lit(
            text: label,
            width: widthLabel ?? 100,
            color: StyleT.titleColor,
            size: 12,
            bold: true,
          ),
        if (label != null) SizedBox(width: 6,),
        w,
      ],
    );
  }
}