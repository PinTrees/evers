


import 'package:evers/helper/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helper/interfaceUI.dart';

class InputWidget {
  static Widget textSearch({ Function(String)? search, TextEditingController? controller }) {
    if(controller == null) {
      return SizedBox();
    }
    var w = Row(
      children: [
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
}