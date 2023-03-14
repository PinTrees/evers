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
            Icon(Icons.close,),
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
