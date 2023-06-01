import 'package:evers/class/widget/text.dart';
import 'package:flutter/material.dart';

import '../../helper/style.dart';


/// LitTextFieldStyle 은 텍스트 필드의 스타일을 정의하는 클래스입니다.
class LitTextFieldStyle {
  final Color textColor;
  final Color color;
  final double width;
  final double height;
  final double textSize;


  /// LitTextFieldStyle의 생성자입니다.
  ///
  /// [textColor] 텍스트의 색상을 설정하는 매개변수입니다.
  /// [color] 텍스트 필드의 배경색을 설정하는 매개변수입니다.
  /// [width] 텍스트 필드의 너비를 설정하는 매개변수입니다.
  /// [height] 텍스트 필드의 높이를 설정하는 매개변수입니다.
  /// [textSize] 텍스트의 크기를 설정하는 매개변수입니다.
  LitTextFieldStyle({
    this.textColor = Colors.black,
    this.color = Colors.grey,
    this.width = 200,
    this.height = 40,
    this.textSize = 12,
  });
}




/// LitTextParams 는 텍스트 필드의 파라미터를 정의하는 클래스입니다.
class LitTextParams {
  final Function(dynamic)? onEdited;
  final String? text;
  final bool bold;
  final String? label;
  final String? value;
  final double? widthLabel;
  final double? width;
  final double? height;
  final double? textSize;
  final String? hint;
  final bool expand;
  final bool isMultiLine;


  /// LitTextParams 의 생성자입니다.
  ///
  /// [onEdited] 값이 편집될 때 호출되는 콜백 함수를 설정하는 매개변수입니다.
  /// [text] 텍스트 필드의 기본 텍스트를 설정하는 매개변수입니다.
  /// [bold] 텍스트의 굵기를 지정하는 매개변수입니다.
  /// [label] 텍스트 필드 옆에 표시될 라벨 텍스트를 설정하는 매개변수입니다.
  /// [value] 텍스트 필드의 초기 값을 설정하는 매개변수입니다.
  /// [widthLabel] 라벨의 너비를 설정하는 매개변수입니다.
  /// [width] 텍스트 필드의 너비를 설정하는 매개변수입니다.
  /// [height] 텍스트 필드의 높이를 설정하는 매개변수입니다.
  /// [textSize] 텍스트의 크기를 설정하는 매개변수입니다.
  /// [hint] 텍스트 필드의 힌트 텍스트를 설정하는 매개변수입니다.
  /// [expand] 텍스트 필드가 확장되어 가로 공간을 채울지 여부를 지정하는 매개변수입니다.
  /// [isMultiLine] 여러 줄의 텍스트를 입력받을지 여부를 지정하는 매개변수입니다.
  LitTextParams({
    this.onEdited,
    this.text,
    this.bold = false,
    this.label,
    this.value,
    this.widthLabel,
    this.width,
    this.height,
    this.textSize,
    this.hint,
    this.expand = false,
    this.isMultiLine = false,
  });
}




/// LitTextInput 은 텍스트 입력을 위한 위젯입니다.
class LitTextInput extends StatefulWidget {
  var style = LitTextFieldStyle();
  var params = LitTextParams(
    onEdited: (value) {},
    text: 'Default Text',
    label: 'Text Field:',
    expand: true,
  );


  /// LitTextInput 의 생성자입니다.
  ///
  /// [style] 텍스트 필드의 스타일을 설정하는 매개변수입니다.
  /// [params] 텍스트 필드의 파라미터를 설정하는 매개변수입니다.
  LitTextInput({required this.style, required this.params});


  @override
  _LitTextInputState createState() => _LitTextInputState();
}

/// _LitTextInputState 은 LitTextInput의 상태관리 클래스 입니다.
class _LitTextInputState extends State<LitTextInput> {
  final textInputs = TextEditingController();
  var isActive = false;

  @override
  void dispose() {
    textInputs.dispose();
    super.dispose();
  }


  /// 텍스트 입력 위젯을 생성합니다.
  ///
  /// [params] 텍스트 필드의 파라미터를 설정하는 매개변수입니다.
  /// [style] 텍스트 필드의 스타일을 설정하는 매개변수입니다.
  Widget litTextWidget(LitTextParams params, LitTextFieldStyle style) {
    isActive = true;
    textInputs.text = params.value ?? params.text ?? '';

    var textStyle = TextStyle(
      color: style.textColor.withOpacity(0.9),
      fontSize: params.textSize ?? style.textSize,
      fontWeight: params.bold ? FontWeight.w900 : FontWeight.normal,
    );

    Widget buildInputWidget() {
      return IntrinsicWidth(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: Container(
            width: params.width ?? style.width,
            height: params.height ?? style.height,
            color: style.color.withOpacity(0.15),
            child: TextFormField(
              autofocus: false,
              cursorColor: Color(0xff009fdf).withOpacity(0.7),
              cursorWidth: 2.0,
              cursorRadius: Radius.elliptical(4, 4),
              style: textStyle,
              maxLines: params.isMultiLine ? null : 1,
              textInputAction: params.isMultiLine
                  ? TextInputAction.newline
                  : TextInputAction.go,
              keyboardType: params.isMultiLine
                  ? TextInputType.multiline
                  : TextInputType.none,
              onEditingComplete: () {
                isActive = false;
                if (params.onEdited != null) {
                  params.onEdited!(textInputs.text);
                }
                setState(() {});
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
                hintText: params.hint ?? '',
                hintStyle: textStyle,
                contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 12),
              ),
              controller: textInputs,
            ),
          ),
        ),
      );
    }

    Widget w = const SizedBox();
    w = buildInputWidget();

    if (params.expand) w = Expanded(child: w);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (params.label != null)
          Text(
            params.label!,
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (params.label != null) SizedBox(width: 6),
        w,
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return litTextWidget(widget.params, widget.style);
  }
}











class LitInputStyle {
  final Color enabledBorderColor;
  Color? focusedBorderColor;
  Color? fillColor;
  final Color hintColor;
  EdgeInsets? contentPadding;
  final double borderRadius;
  final double borderWidth;
  final double hintFontSize;
  final FontWeight hintFontWeight;

  LitInputStyle({
    this.enabledBorderColor = Colors.transparent,
    this.focusedBorderColor,
    this.fillColor,
    this.hintColor = Colors.grey,
    this.contentPadding,
    this.borderRadius = 6,
    this.borderWidth = 1.4,
    this.hintFontSize = 12,
    this.hintFontWeight = FontWeight.normal,
  }) {}
}


class LitInput extends StatefulWidget {
  final Function(dynamic)? onEdited;
  final Function? setState;
  final Alignment? alignment;
  final String? text;
  final String? value;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? textSize;
  final String? hint;
  final bool expand;
  final bool isMultiLine;
  final LitInputStyle? style;

  LitInput({
        this.onEdited,
        this.setState,
        this.alignment,
        this.text,
        this.value,
        this.textColor,
        this.width,
        this.height,
        this.textSize,
        this.hint,
        this.expand = false,
        this.isMultiLine = false,
        this.style,
      });

  @override
  _LitInputState createState() => _LitInputState();
}

class _LitInputState extends State<LitInput> {
  late TextEditingController _controller;
  var isActive = false;
  var style;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (widget.value != null || widget.text != null) {
      _controller.text = widget.value ?? widget.text!;
    }

    style = widget.style;

    isActive = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    isActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Widget inputWidget = Container(
      width: widget.width ?? double.maxFinite,
      height: widget.isMultiLine ? widget.height : 28,
      child: TextFormField(
        autofocus: true,
        maxLines: widget.isMultiLine ? 10 : 1,
        textInputAction: widget.isMultiLine
            ? TextInputAction.newline
            : TextInputAction.search,
        keyboardType:
        widget.isMultiLine ? TextInputType.multiline : TextInputType.none,
        onEditingComplete: () async {
          isActive = false;
          if (widget.onEdited != null) {
            await widget.onEdited!(_controller.text);
          }
          if (widget.setState != null) {
            await widget.setState!();
          }
        },
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(style.borderRadius),
            borderSide: BorderSide(
              color: style.enabledBorderColor,
              width: style.borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(style.borderRadius),
            borderSide: BorderSide(
              color: style.focusedBorderColor ?? Colors.grey.withOpacity(0.35),
              width: style.borderWidth,
            ),
          ),
          filled: true,
          fillColor: style.fillColor,
          hintText: widget.hint ?? '',
          hintStyle: TextStyle(
            fontSize: style.hintFontSize,
            fontWeight: style.hintFontWeight,
          ),
          contentPadding: style.contentPadding,
        ),
        controller: _controller,
      ),
    );

    inputWidget = Focus(
      onFocusChange: (hasFocus) async {
        if (!hasFocus) {
          isActive = false;
          if (widget.onEdited != null) {
            await widget.onEdited!(_controller.text);
          }
        }
        if (widget.setState != null) {
          await widget.setState!();
        }
      },
      child: inputWidget,
    );

    Widget wrapperWidget = Container(
      height: widget.height ?? 28,
      width: widget.width ?? double.maxFinite,
      padding: EdgeInsets.only(left: 3, right: 3),
      child: InkWell(
        onFocusChange: (hasFocus) async {
          isActive = true;
          _controller.text = widget.value ?? widget.text ?? '';
          if (widget.setState != null) {
            await widget.setState!();
          }
        },
        onTap: () async {
          isActive = true;
          _controller.text = widget.value ?? widget.text ?? '';
          if (widget.setState != null) {
            await widget.setState!();
          }
        },
        child: Container(
          alignment: widget.alignment ?? Alignment.center,
          decoration: StyleT.inkStyle(
            color: Colors.grey.withOpacity(0.15),
            round: 8,
            stroke: 0.01,
            strokeColor: Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 4),
              TextT.Lit(
                text: widget.text != null && widget.text!.isEmpty
                    ? widget.hint ?? '텍스트 입력'
                    : widget.text!,
                color: StyleT.titleColor,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.expand) {
      wrapperWidget = Expanded(child: wrapperWidget);
      inputWidget = Expanded(child: inputWidget);
    }

    return isActive ? inputWidget : wrapperWidget;
  }
}