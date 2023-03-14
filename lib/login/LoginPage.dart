import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:local_notifier/local_notifier.dart';
import 'package:quick_notify/quick_notify.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import '../helper/interfaceUI.dart';
import '../helper/style.dart';

class LogInPage extends StatefulWidget {
  const LogInPage() : super();
  @override
  State<LogInPage> createState() => _LogInPageState();
}
class _LogInPageState extends State<LogInPage> {
  TextEditingController emailInput = new TextEditingController();
  TextEditingController passwordInput = new TextEditingController();
  //var menus = [ '', '통합'];
  //var menuTs = ['대표', '이사', '실장', '과장', '대리', '주임', '사원', '통합'];
  var currentMenu = null;

  @override
  void initState() {
    super.initState();
    initAsync();
  }
  void initAsync() async {
    setState(() {});
  }

  Widget main() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: SizedBox()),
        SizedBox(height: 0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: 80, child: Image(image: AssetImage('assets/icon_hor.png'))),
            //SizedBox(width: 32,),
            //WidgetT.titleT('Work Space', size: 48, color: Color(0xFF1855a5), bold: true),
          ],
        ),
        SizedBox(height: 64,),
        Container(
          width: 500,
          child: TextFormField(
            maxLines: 1,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            textInputAction: TextInputAction.none,
            keyboardType: TextInputType.emailAddress,
            onEditingComplete: () {},
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: StyleT.accentLowColor, width: 2)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide(
                    color: StyleT.accentColor, width: 2),),
              filled: true,
              fillColor: StyleT.accentColor.withOpacity(0.07),
              //suffixIcon: Icon(Icons.keyboard),
              hintText: 'EMAIL ADDRESS',
              hintStyle: StyleT.hintStyle(size: 16),
              contentPadding: EdgeInsets.all(8),
            ),
            controller: emailInput,
          ),
        ),
        SizedBox(height: 8,),
        Container(
          height: 48, width: 500,
          child: TextFormField(
            maxLines: 1,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            textInputAction: TextInputAction.none,
            keyboardType: TextInputType.text,
            onEditingComplete: () async {
              try {
                var id = '';
                UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: emailInput.text + '@evers.com',
                  password: passwordInput.text,
                );
                var currentUser = FirebaseAuth.instance.currentUser;
                print(currentUser?.email);

                if(currentUser != null) {
                  //await FirebaseAuth.instance.currentUser?.updatePassword('12345678');
                  //await FirebaseAuth.instance.currentUser?.updateEmail('taegi_0@taegi.com');
                  await WidgetT.showSnackBar(context, text: '로그인 성공',);
                  context.pop();
                  context.go('/work/u');
                }
              } on FirebaseAuthException catch (e) {
                await WidgetT.showSnackBar(context, text: '이메일 또는 패스워드를 잘못 입력했습니다. 다시 확인해주세요.',);
                if (e.code == 'user-not-found') {
                  print('No user found for that email.');
                } else if (e.code == 'wrong-password') {
                  print('Wrong password provided for that user.');
                }
              }
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: StyleT.accentLowColor, width: 2)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide(
                    color: StyleT.accentColor, width: 2),),
              filled: true,
              fillColor: StyleT.accentColor.withOpacity(0.07),
              //suffixIcon: Icon(Icons.keyboard),
              hintText: 'PASSWORD',
              hintStyle: StyleT.hintStyle(size: 16),
              contentPadding: EdgeInsets.all(8),
            ),
            controller: passwordInput,
          ),
        ),
        SizedBox(height: 18,),
        TextButton(
          onPressed: () async {
            try {
              var id = '';
              UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: emailInput.text + '@evers.com',
                password: passwordInput.text,
              );
              var currentUser = FirebaseAuth.instance.currentUser;
              print(currentUser?.email);

              if(currentUser != null) {
                //await FirebaseAuth.instance.currentUser?.updatePassword('12345678');
                //await FirebaseAuth.instance.currentUser?.updateEmail('taegi_0@taegi.com');
                await WidgetT.showSnackBar(context, text: '로그인 성공',);
                context.pop();
                context.go('/work/u');
              }
            } on FirebaseAuthException catch (e) {
              await WidgetT.showSnackBar(context, text: '이메일 또는 패스워드를 잘못 입력했습니다. 다시 확인해주세요.',);
              if (e.code == 'user-not-found') {
                print('No user found for that email.');
              } else if (e.code == 'wrong-password') {
                print('Wrong password provided for that user.');
              }
            }
          },
          style: StyleT.buttonStyleOutline(padding: 0, strock: 2, round: 8,
              color: StyleT.accentColor),
          child: Container( width: 500, height: 48, alignment: Alignment.center,
              child: WidgetT.titleT('로그인', size: 16, color: Colors.white.withOpacity(0.7)),
          ),
        ),
        SizedBox(height: 8,),
        SizedBox(height: 128,),
        Expanded(child: SizedBox()),
        Row(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: main(),
            ),
          ),
        ],
      ),
    );
  }
}