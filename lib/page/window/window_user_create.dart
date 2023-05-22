import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/user.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/json.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/dialog_item.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

import '../../class/Customer.dart';
import '../../class/component/comp_ts.dart';
import '../../class/system.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/list.dart';
import '../../class/widget/text.dart';
import '../../core/window/ResizableWindow.dart';
import '../../core/xxx/xxx.dart';
import '../../helper/dialog.dart';
import '../../helper/interfaceUI.dart';



/// 이 클래스는 계정을 생성하고 데이터베이스에 기록하는 윈도우창 위젯을 관리합니다.
/// StateFull Widget
class WindowUserCreate extends WindowBaseMDI {
  Function refresh;
  WindowUserCreate({ required this.refresh }) { }

  @override
  _WindowUserCreateState createState() => _WindowUserCreateState();
}
class _WindowUserCreateState extends State<WindowUserCreate> {
  var dividHeight = 6.0;
  UserData user = UserData.fromDatabase({});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget main = SizedBox();

  /// 상속 구조로 재설계 되어야 합니다.
  /// 이 함수는 메인 위젯 빌더입니다.
  Widget mainBuild() {
    List<Widget> tsCW = [];

    var key = widget.parent.key;

    /// 사용자 이름 입력 위젯을 생성합니다.
    var nameWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "이름 입력"),
        SizedBox(height: 6,),
        ExcelT.Input(context, '$key::user::name', width: 250,
          setState: () { setState(() {}); },
          onEdited: (i, data) { user.name = data; },
          text: user.name,
        )
      ],
    );

    /// 사용자 아이디 입력 위젯을 생성합니다.
    var emailWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "아이디 입력", more: ""),
        SizedBox(height: 6,),
        ExcelT.Input(context, '$key::user::email', width: 250,
          setState: () { setState(() {}); },
          onEdited: (i, data) { user.email = data; },
          text: user.email,
        )
      ],
    );


    /// 사용자 암호입력 위젯을 생성합니다.
    var passwordWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "비밀번호 입력", more: ""),
        SizedBox(height: 6,),
        ExcelT.Input(context, '$key::user::password', width: 250,
          setState: () { setState(() {}); },
          onEdited: (i, data) { user.password = data; },
          text: '*' * user.password.length,
          value: user.password,
        )
      ],
    );


    List<Widget> permissionWidgetList = [];
    PermissionType.values.forEach((e) {
      if(!e.display) return;

      permissionWidgetList.add(ButtonT.IconText(
        icon: user.isPermissioned(e.code) ? Icons.check_box : Icons.check_box_outline_blank,
        text: e.displayName,
        onTap: () {
          if(!user.permission.containsKey(e.code)) user.permission[e.code] = true;
          else user.permission[e.code] = !user.permission[e.code];
          setState(() {});
        }
      ));
    });


    /// 사용자 권한관리 위젯을 생성합니다.
    var permissionWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "사용자 권한 관리"),
        SizedBox(height: 6,),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: permissionWidgetList,
        ),
      ],
    );


    return main = Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(18),
            child: ListBoxT.Columns(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6 * 4,
              children: [
                nameWidget, emailWidget, passwordWidget, permissionWidget
              ],
            ),
          ),

          /// action Widget
          buildAction(),
        ],
      ),
    );
  }


  Widget buildAction() {

    var saveWidget = ButtonT.Action(
        context, "계정 생성", icon: Icons.save,
        backgroundColor: StyleT.accentColor.withOpacity(0.5),
        altText: "계정을 생성하시겠습니까?",
      init: () {
          if(user.password.length < 8) return Messege.toReturn(context, "비밀번호는 8자리 이하일 수 없습니다.", false);
          else if(user.email.length < 8) return Messege.toReturn(context, "아이디는 8자리 이하일 수 없습니다.", false);
          else if(user.name == '') return Messege.toReturn(context, "이름은 비워둘 수 없습니다.", false);

          else if(FirebaseAuth.instance.currentUser == null)  return Messege.toReturn(context, "Database Access Error", false);
          else if(FirebaseAuth.instance.currentUser!.uid != XXX.databaseAdminUserUID)  return Messege.toReturn(context, "생성 권한이 없습니다.", false);

        return true;
      },
      onTap: () async {
        try {
          var oldUid = FirebaseAuth.instance.currentUser!.uid;

          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
              email: "${user.email}@evers.com", password: user.password);

          if (userCredential.user == null)
            await WidgetT.showSnackBar(context, text: '계정 생성 실패',);
          else {
            /// 신규 유저 정보를 생성하고 저장합니다.
            /// 이 과정은 Cloud Function 벡엔드 코드로 변경되어야 합니다.
            user.id = userCredential.user!.uid;
            await user.update();

            /// 신규 계정을 생성함으로 현재 접속중인 계정이 신규계정으로 변경되었습니다.
            /// 생성을 시도한 계정의 UID를 통해 이전 계정으로 다시 로그인 합니다.
            UserData? oldUserData = await DatabaseM.getUserDataWithUID(oldUid);
            if(oldUserData == null) return;

            /// 현재 접속중인 계정의 접속을 종료합니다.
            /// 생성을 시도한 계정으로 재접속을 시도합니다.
            await FirebaseAuth.instance.signOut();
            await FirebaseAuth.instance.signInWithEmailAndPassword(email: '${ oldUserData.email }@evers.com', password: oldUserData.password);
          }
        }
        on FirebaseAuthException catch (e) {
          await WidgetT.showSnackBar(context, text: 'Database Error',);
          if (e.code == 'user-not-found') {
            await WidgetT.showSnackBar(context, text: '계정 생성 실패',);
            print('No user found for that email.');
          } else if (e.code == 'wrong-password') {
            await WidgetT.showSnackBar(context, text: '계정 생성 실패',);
            print('Wrong password provided for that user.');
          }
        }

        widget.refresh();
        widget.parent.onCloseButtonClicked!();
      }
    );

    return Column(
      children: [
        ListBoxT.Rows(
          children: [
            saveWidget,
          ]
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}





/// 이 클래스는 계정을 수정하고 데이터베이스에 기록하는 윈도우창 위젯을 관리합니다.
/// StateFull Widget
class WindowUserEditor extends WindowBaseMDI {
  Function refresh;
  UserData user;
  WindowUserEditor({ required this.user, required this.refresh }) { }

  @override
  _WindowUserEditorState createState() => _WindowUserEditorState();
}
class _WindowUserEditorState extends State<WindowUserEditor> {
  var dividHeight = 6.0;
  UserData user = UserData.fromDatabase({});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = UserData.fromDatabase(JsonManager.toJsonObject(widget.user));
  }

  Widget main = SizedBox();

  /// 상속 구조로 재설계 되어야 합니다.
  /// 이 함수는 메인 위젯 빌더입니다.
  Widget mainBuild() {
    var key = widget.parent.key;

    /// 사용자 이름 입력 위젯을 생성합니다.
    var nameWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "이름 입력"),
        SizedBox(height: 6,),
        ExcelT.Input(context, '$key::user::name', width: 250,
          setState: () { setState(() {}); },
          onEdited: (i, data) { user.name = data; },
          text: user.name,
        )
      ],
    );

    /// 사용자 아이디 입력 위젯을 생성합니다.
    var emailWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "아이디 입력", more: ""),
        SizedBox(height: 6,),
        ExcelT.Input(context, '$key::user::email', width: 250,
          setState: () { setState(() {}); },
          onEdited: (i, data) { user.email = data; },
          text: user.email,
        )
      ],
    );


    /// 사용자 암호입력 위젯을 생성합니다.
    var passwordWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "비밀번호 입력", more: ""),
        SizedBox(height: 6,),
        ExcelT.Input(context, '$key::user::password', width: 250,
          setState: () { setState(() {}); },
          onEdited: (i, data) { user.password = data; },
          text: '*' * user.password.length,
          value: user.password,
        )
      ],
    );


    List<Widget> permissionWidgetList = [];
    PermissionType.values.forEach((e) {
      permissionWidgetList.add(ButtonT.IconText(
          icon: user.isPermissioned(e.code) ? Icons.check_box : Icons.check_box_outline_blank,
          text: e.displayName,
          onTap: () {
            if(!user.permission.containsKey(e.code)) user.permission[e.code] = true;
            else user.permission[e.code] = !user.permission[e.code];
            setState(() {});
          }
      ));
    });


    /// 사용자 권한관리 위젯을 생성합니다.
    var permissionWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextT.SubTitle(text: "사용자 권한 관리"),
        SizedBox(height: 6,),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: permissionWidgetList,
        ),
      ],
    );


    return main = Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(18),
            child: ListBoxT.Columns(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6 * 4,
              children: [
                nameWidget, emailWidget, passwordWidget, permissionWidget
              ],
            ),
          ),

          /// action Widget
          buildAction(),
        ],
      ),
    );
  }


  Widget buildAction() {

    var saveWidget = ButtonT.Action(
        context, "계정 저장", icon: Icons.save,
        backgroundColor: StyleT.accentColor.withOpacity(0.5),
        altText: "계정을 저장하시겠습니까?",
        init: () {
          if(user.password.length < 8) return Messege.toReturn(context, "비밀번호는 8자리 이하일 수 없습니다.", false);
          else if(user.email.length < 8) return Messege.toReturn(context, "아이디는 8자리 이하일 수 없습니다.", false);
          else if(user.name == '') return Messege.toReturn(context, "이름은 비워둘 수 없습니다.", false);

          else if(FirebaseAuth.instance.currentUser == null)  return Messege.toReturn(context, "Database Access Error", false);
          else if(FirebaseAuth.instance.currentUser!.uid != XXX.databaseAdminUserUID)  return Messege.toReturn(context, "생성 권한이 없습니다.", false);

          return true;
        },
        onTap: () async {
          try {
            var oldUid = FirebaseAuth.instance.currentUser!.uid;

            await FirebaseAuth.instance.signInWithEmailAndPassword(email: '${ widget.user.email }@evers.com', password: widget.user.password);
            if(FirebaseAuth.instance.currentUser != null) {
              if(widget.user.email != user.email) FirebaseAuth.instance.currentUser!.updateEmail(user.email);
              if(widget.user.password != user.password) FirebaseAuth.instance.currentUser!.updateEmail(user.password);

              await user.update();
            }

            UserData? oldUserData = await DatabaseM.getUserDataWithUID(oldUid);
            if(oldUserData == null) return;

            await FirebaseAuth.instance.signOut();
            await FirebaseAuth.instance.signInWithEmailAndPassword(email: '${ oldUserData.email }@evers.com', password: oldUserData.password);
          }
          on FirebaseAuthException catch (e) {
            await WidgetT.showSnackBar(context, text: 'Database Error',);
            if (e.code == 'user-not-found') {
              await WidgetT.showSnackBar(context, text: '계정 생성 실패',);
              print('No user found for that email.');
            } else if (e.code == 'wrong-password') {
              await WidgetT.showSnackBar(context, text: '계정 생성 실패',);
              print('Wrong password provided for that user.');
            }
          }

          widget.refresh();
          widget.parent.onCloseButtonClicked!();
        }
    );

    return Column(
      children: [
        ListBoxT.Rows(
            children: [
              saveWidget,
            ]
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}