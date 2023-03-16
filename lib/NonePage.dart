import 'package:evers/helper/dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';

import 'helper/interfaceUI.dart';
import 'helper/router.dart';
import 'helper/style.dart';

class NonePage extends StatefulWidget {
  const NonePage({super.key,});

  @override
  State<NonePage> createState() => _NonePageState();
}

class _NonePageState extends State<NonePage> {

  Widget main() {
    return ListView(
      children: [
        Column(
          children: [
            Row(),
            SizedBox(height: 18);
            WidgetT.text('페이지를 찾을 수 없습니다.', size: 18);
            SizedBox(height: 6 * 8 );
            Icon(Icons.close,),
            
            // 메인홈페이지로 리깅
            // 아예 페이지를 찾을 수 없을을 메시지로 표시 후 홈페이지로 리깅
            // context.go();
            // urlLauncer를 통해 Url 변경
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        titleSpacing: 0,
        backgroundColor: StyleT.accentColor,
        elevation: 18,
        automaticallyImplyLeading: false,
        toolbarHeight: 68, // Set this height
        flexibleSpace: Container(
        ),
        title: Material(
          color: StyleT.accentLowColor,
          elevation: 18,
          child: Stack(
            children: [
              Container(height: 68,),
              Positioned(
                child: Material(
                  elevation: 18, color: StyleT.accentColor,
                  child: Container(
                    height: 68, padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                    child: Row(
                      children: [
                        WidgetT.titleBig('Evers', size: 30, color: StyleT.accentOver),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: main(),
    );
  }
}
