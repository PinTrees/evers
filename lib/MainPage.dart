import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/helper/dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'helper/interfaceUI.dart';
import 'helper/router.dart';
import 'helper/style.dart';
import 'route/navigator2.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }
  void initAsync() async {
  }

  @override
  void didChangeDependencies() {
    var user = FirebaseAuth.instance.currentUser;
    if(user == null) {
      context.push('/login/o');
      setState(() {});
    }
  }


  Widget main() {
    return ListView(
      children: [
        Column(
          children: [
            // 홈페이지 수정부분 - 추후 수정 / 03.16
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 512, width: double.maxFinite,
                    child: CachedNetworkImage(imageUrl:'', fit: BoxFit.cover),
                  )
                )
              ]
            ),
            
            Row(
                children: [
                Expanded(
                  child: Container(
                    height: 512, width: double.maxFinite,
                    child: Column(
                      children: [
                        
                      ]
                    )
                  )
                )
              ]
            ),
            Icon(Icons.home,),
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
