import 'package:evers/MainPage.dart';
import 'package:evers/NonePage.dart';
import 'package:evers/login/LoginPage.dart';
import 'package:evers/main.dart';
import 'package:evers/page/document/main.dart';
import 'package:evers/page/page_customer.dart';
import 'package:evers/page/page_printForm.dart';
import 'package:evers/page/page_shopingItem.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

import '../helper/pdf_view.dart';
import '../page/erp/view/homepage/view_shopitem.dart';
import '../page/homepage/page_shopItem.dart';

final GoRouter router = GoRouter(
  errorBuilder: (context, state) => Container(width: 500, height: 500, color: Colors.red,),
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return HomePage();
      },
      routes: <RouteBase>[
        GoRoute(
            path: 'home',
            builder: (BuildContext context, GoRouterState state) {
              return HomePage();
            },
            routes: [
              GoRoute(
                path: 'o',
                builder: (BuildContext context, GoRouterState state) {
                  return HomePage();
                },
              ),
            ]
        ),
        /// 깊이 설정시 새로고침 즉시 적용 안됨
        GoRoute(
          path: 'home/:id/:id1',
          builder: (BuildContext context, GoRouterState state) {
            return HomePage(url: state.pathParameters['id'] ?? "e",
              subUrl: state.pathParameters['id1'] ?? "e",);
          },
        ),
        /*GoRoute(
          path: 'shopItem/:id',
          builder: (BuildContext context, GoRouterState state) {
            return PageShopItem(id: state.pathParameters['id'] ?? "");
          },
        ),*/
        GoRoute(
            path: 'login',
            builder: (BuildContext context, GoRouterState state) {
              return SizedBox();
            },
            routes: [
              GoRoute(
                path: 'o',
                builder: (BuildContext context, GoRouterState state) {
                  return LogInPage();
                },
              ),
            ]
        ),
        GoRoute(
            path: 'work/u',
            builder: (BuildContext context, GoRouterState state) {
              return WorkPage(url: 'u',);
            },
        ),
        GoRoute(
          path: 'work/home',
          builder: (BuildContext context, GoRouterState state) {
            return WorkPage(url: 'home',);
          },
        ),
        /// 깊이 설정시 새로고침 즉시 적용 안됨
        GoRoute(
            path: 'work/:id/:id1',
            builder: (BuildContext context, GoRouterState state) {
              return WorkPage(url: state.pathParameters['id'], subUrl: state.pathParameters['id1'],);
            },
        ),
        GoRoute(
          path: 'error',
          builder: (BuildContext context, GoRouterState state) {
            return Container(width: 500, height: 500, color: Colors.red,);
          },
        ),
        GoRoute(
          path: 'pdfview/:id/:id2',
          builder: (BuildContext context, GoRouterState state) {
            return  Container(width: 500, height: 500, color: Colors.red,);
            /// PdfViewPage(url: state.pathParameters['id'], fileName: state.pathParameters['id2'],);
          },
            routes: [
              GoRoute(
                path: 'e',
                builder: (BuildContext context, GoRouterState state) {
                  return PdfViewPage(url: state.pathParameters['id'], fileName: state.pathParameters['id2'],);
                },
              ),
            ]
        ),
        GoRoute(
          path: 'customer/:id',
          builder: (BuildContext context, GoRouterState state) {
            return CustomerPage(csUid: state.pathParameters['id']);
          },
        ),
        GoRoute(path: 'printform/releaserevenue/:id',
          builder: (BuildContext context, GoRouterState state) {
            return PFormReleaseRevenuePage(csUid: state.pathParameters['id']);
          },

        ),
        GoRoute(path: 'documents/:path',
          builder: (BuildContext context, GoRouterState state) {
            return DocumentPage(path: state.pathParameters['path']);
          },
        )
      ],
    ),
  ],
);