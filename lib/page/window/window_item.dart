import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_contract.dart';
import 'package:evers/class/component/comp_process.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/user.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/core/database/database_search.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/json.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_ct_create.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/ui/dialog_item.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../class/Customer.dart';
import '../../class/contract.dart';
import '../../class/database/item.dart';
import '../../class/database/process.dart';
import '../../class/purchase.dart';
import '../../class/system.dart';
import '../../class/system/state.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/text.dart';
import '../../core/window/ResizableWindow.dart';
import '../../helper/aes.dart';
import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';
import '../../helper/pdfx.dart';
import '../../ui/dialog_contract.dart';
import '../../ui/dialog_pu.dart';
import '../../ui/dialog_revenue.dart';
import '../../ui/dl.dart';
import '../../ui/ip.dart';
import '../../ui/ux.dart';


class WindowItemCreator extends WindowBaseMDI {
  Function refresh;
  Item? item;

  WindowItemCreator({
    this.item,
    required this.refresh,
  }) { }

  @override
  _WindowItemCreatorState createState() => _WindowItemCreatorState();
}

class _WindowItemCreatorState extends State<WindowItemCreator> {
  var dividHeight = 6.0;
  Item item = Item.fromDatabase({});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  void initAsync() async {
    if(widget.item != null) item = Item.fromDatabase(JsonManager.toJsonObject(widget.item));
    else {
      item.type =  MetaT.itemType.keys.first;
      item.group =  MetaT.itemGroup.keys.first;
    }

    setState(() {});
  }

  Widget main = SizedBox();

  /// 이 함수는 매인 위젯 빌더입니다.
  Widget mainBuild() {
    var titleWidget = Row(
      children: [
        InputWidget.DropButtonT<String>(dropMenuMaps: MetaT.itemType,
          labelText: (item) { return item; },
          label: "구분",
          setState: () { setState(() {}); },
          onEditeKey: (i, data) {
            item.type = data;
          },
          width: 100,
          text: MetaT.itemType[item.type] ?? "",
        ),

        SizedBox(width: dividHeight,),
        WidgetT.text('( 원자재 / 생산품 )', size:10),

        InputWidget.DropButtonT<dynamic>(dropMenuMaps: MetaT.itemGroup,
          labelText: (item) { return item.toString(); },
          label: "품목분류",
          setState: () { setState(() {}); },
          onEditeKey: (i, data) {
            item.group = data;
          },
          width: 150,
          text: MetaT.itemGroup[item.group] ?? "",
        )
      ],
    );

    var selectWidget1 =  Row(
      children: [
        WidgetT.title('표시', width: 100),
        TextButton(
            onPressed: () {
              item.display = !item.display;
              setState(() {});
            },
            style: StyleT.buttonStyleNone(padding: 0, elevation: 0, color: Colors.transparent),
            child: WidgetT.iconMini(item.display ? Icons.check_box : Icons.check_box_outline_blank, size: 32)),
        WidgetT.text('( 메인화면 및 생산관리 화면 표시 )', size:10),
      ],
    );


    var inputItemNameWidget = Row(
      children: [
        TextT.Lit(text: "품목명", size: 14, color: Colors.black, width: 100),
        ExcelT.LitInput(context, '품목이름',
          width: 200,   textSize: 10,
          onEdited: (i, data) { item.name = data; },
          setState: () { setState(() {}); },
          text: item.name,
        ),
      ],
    );


    var inputItemUnitWidget = Row(
      children: [
        TextT.Lit(text: "단위", size: 14, color: Colors.black, width: 100),
        ExcelT.LitInput(context, '단위', width: 100,
          onEdited: (i, data) { item.unit = data; },
          setState: () { setState(() {}); },
          text: item.unit,
        ),
        WidgetT.text('( ton / L / kg / ㎡ )', size:10),
      ],
    );


    var inputItemUnitPriceWidget = Row(
      children: [
        TextT.Lit(text: "금액", size: 14, color: Colors.black, width: 100),
        ExcelT.LitInput(context, '단가', width: 100,
          onEdited: (i, data) {
            var a = int.tryParse(data) ?? 0;
            item.unitPrice = a;
          },
          setState: () { setState(() {}); },
          text: StyleT.krw(item.unitPrice.toString()),
          value: item.unitPrice.toString(),
        ),

        ExcelT.LitInput(context, '원가', width: 100,
          onEdited: (i, data) {
            var a = int.tryParse(data) ?? 0;
            item.cost = a;
          },
          setState: () { setState(() {}); },
          text: StyleT.krw(item.cost.toString()),
          value: item.cost.toString(),
        ),
      ],
    );


    var inputItemMemoWidget = Row(
      children: [
        TextT.Lit(text: "메모", size: 14, color: Colors.black, width: 100),

        ExcelT.LitInput(context, '메모',
          expand: true, isMultiLine: true,
          setState: () { setState(() {}); },
          onEdited: (i, data) {
            item.memo = data;
          },
          text: item.memo,
        ),
      ],
    );


    return main = Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              padding: EdgeInsets.all(18),
              child: ListBoxT.Columns(
                spacing: 6 * 2,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextT.SubTitle(text: '품목 정보',),
                  titleWidget,
                  selectWidget1,
                  inputItemNameWidget,
                  inputItemUnitWidget,
                  inputItemUnitPriceWidget,
                  inputItemMemoWidget,
                ],)
          ),
          /// action
          buildAction(),
        ],
      ),
    );
  }


  Widget buildAction() {
    var saveWidget = ButtonT.Action(
        context, "품목 저장",
        init: () {
          if(item.name == '')  return Messege.toReturn(context, '품목 이름을 입력해 주세요.', false);
          if(item.unit == '')  return Messege.toReturn(context, '품목 단위를 입력해 주세요.', false);
          return true;
        },
        altText: "품목 정보를 저장하시겠습니까?",
        onTap: () async {
          WidgetT.loadingBottomSheet(context);

          await item.update();

          Messege.show(context, "저장됨");
          Navigator.pop(context);

          widget.refresh();
          widget.parent.onCloseButtonClicked!();
        }
    );

    return Row(   children: [  saveWidget, ],);
  }

  @override
  Widget build(BuildContext context) {
    return mainBuild();
  }
}
