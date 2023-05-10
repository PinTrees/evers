import 'package:evers/class/widget/excel.dart';
import 'package:flutter/material.dart';

import '../../helper/style.dart';
import '../../ui/ux.dart';
import '../contract.dart';

class CompContract {
  static dynamic tableHeader() {
     return WidgetUI.titleRowNone([ '순번', '거래처', '계약명', '담당자', '연락처', '', ],
       [ 32, 250, 250, 150, 150, 999, ], background: true, lite: true);
  }

  static dynamic tableUI(BuildContext context, Contract ct, {
    int? index,
    Function? onTap,
  }) {
    var w = InkWell(
        onTap: () async {
          if(onTap != null) await onTap();
        },
        child: Container( height: 28,
          decoration: StyleT.inkStyleNone(color: Colors.transparent),
          child: Row(
              children: [
                ExcelT.LitGrid(text: '${index ?? '-'}', width: 32, center: true),
                ExcelT.LitGrid(text: ct.csName, width: 250, center: true),
                ExcelT.LitGrid(text: ct.ctName, width: 250, center: true),
                ExcelT.LitGrid(text: ct.manager, width: 150, center: true),
                ExcelT.LitGrid(text: ct.managerPhoneNumber, width: 150, center: true),
              ]
          ),
        ));
    return w;
  }
}