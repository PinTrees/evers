import 'package:evers/MainPage.dart';
import 'package:evers/NonePage.dart';
import 'package:evers/helper/LoginPage.dart';
import 'package:evers/login/LoginPage.dart';
import 'package:evers/main.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class Routes {
  static const HOME = '/';
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  static const WORK = '/work';
}
abstract class AppPages {
  static final pages = [
    GetPage(
      name: Routes.HOME,
      page: () => HomePage(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LogInPage(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => NonePage(),
    ),
    GetPage(
      name: Routes.WORK,
      page: () => WorkPage(),
    ),
  ];
}


class AppRouterDelegate extends GetDelegate {

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onPopPage: (route, result) => route.didPop(result),
      pages: currentConfiguration != null
          ? [currentConfiguration!.currentPage!]
          : [GetNavConfig.fromRoute(Routes.HOME)!.currentPage!],
    );
  }
}
