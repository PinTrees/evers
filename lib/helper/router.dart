import 'package:evers/MainPage.dart';
import 'package:evers/NonePage.dart';
import 'package:evers/main.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class FRouter {
  static FluroRouter router = FluroRouter();

  static const String flumeDefault = '/work';
  static const String mainPage = '/home';

  static var detailHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
        return WorkPage();
      });
  static var homeHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
        return HomePage();
      });

  static void setupRouter() {
    router.define(flumeDefault, handler: detailHandler, transitionType: TransitionType.fadeIn);
    router.define(mainPage, handler: homeHandler, transitionType: TransitionType.fadeIn);
  }
}