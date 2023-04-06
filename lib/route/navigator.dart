import 'package:evers/MainPage.dart';
import 'package:evers/NonePage.dart';
import 'package:evers/main.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

/// Never Used
/// Never Used
/// Never Used
/// Never Used
/// Never Used
/// Never Used
/// Never Used
/// Never Used
/// Never Used
/// Never Used


class NavigationState {
  final int value;
  NavigationState(this.value);
}

class HomeRoutePath {
  final String? pathName;
  final bool isUnkown;

  HomeRoutePath.home(): pathName = '', isUnkown = false;
  HomeRoutePath.otherPage(this.pathName) : isUnkown = false;
  HomeRoutePath.unKown(): pathName = null, isUnkown = true;

  bool get isHomePage => pathName == '';
  bool get isOtherPage => pathName != null;
}

class HomeRouteInformationParser extends RouteInformationParser<HomeRoutePath> {
  @override
  Future<HomeRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);

    if (uri.pathSegments.length == 0) {
      return HomeRoutePath.home();
    }

    if (uri.pathSegments.length == 1) {
      final pathName = uri.pathSegments.elementAt(0).toString();
      if (pathName == null) return HomeRoutePath.unKown();
      return HomeRoutePath.otherPage(pathName);
    }

    return HomeRoutePath.unKown();
  }

  @override
  RouteInformation restoreRouteInformation(HomeRoutePath homeRoutePath) {
    if (homeRoutePath.isUnkown) return RouteInformation(location: '/error');
    if (homeRoutePath.isHomePage) return RouteInformation(location: '');
    if (homeRoutePath.isOtherPage)
      return RouteInformation(location: '/${homeRoutePath.pathName}');

    return RouteInformation(location: '/error');
  }
}

class HomeRouterDelegate extends RouterDelegate<HomeRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<HomeRoutePath> {
  String? pathName;
  bool isError = false;

  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  @override
  HomeRoutePath get currentConfiguration {
    if (isError) return HomeRoutePath.unKown();
    if (pathName == '') return HomeRoutePath.home();
    return HomeRoutePath.otherPage(pathName);
  }
  /*void onTapped(String path) {
    pathName = path;
    print(pathName);
    notifyListeners();
  }*/

  Widget pageHandler(String path) {
    if(path == '')
      return HomePage();
    if(path == 'error')
      return Container(width: 500, height: 500, color: Colors.red,);
    if(path == 'home/error')
      return Container(width: 500, height: 500, color: Colors.redAccent,);
    if(path == 'home')
      return HomePage();
    if(path == 'work')
      return WorkPage();
    else return NonePage();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: navigatorKey,
        pages: [
          MaterialPage(
            key: ValueKey('HomePage'),
            child: HomePage(),
          ),
          /*if (isError)
            MaterialPage(key: ValueKey('UnknownPage'), child: NonePage())*/
          if (pathName != null)
            MaterialPage(
                key: ValueKey(pathName),
                child: pageHandler(pathName!,))
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;

          pathName = null;
          isError = false;
          notifyListeners();

          return true;
        });
  }

  @override
  Future<void> setNewRoutePath(HomeRoutePath homeRoutePath) async {
    if (homeRoutePath.isUnkown) {
      pathName = null;
      isError = true;
      return;
    }

    if (homeRoutePath.isOtherPage) {
      if (homeRoutePath.pathName != null) {
        pathName = homeRoutePath.pathName;
        isError = false;
        return;
      } else {
        isError = true;
        return;
      }
    } else {
      pathName = null;
    }
  }
}






class _GeneratePageRoute extends PageRouteBuilder {
  final Widget? widget;
  final String? routeName;
  _GeneratePageRoute({this.widget, this.routeName})
      : super(
      settings: RouteSettings(name: routeName),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return widget ?? Container(height: 500, width: 500, color: Colors.red,);
      },
      transitionDuration: Duration(milliseconds: 500),
      transitionsBuilder: (BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child) {
        return SlideTransition(
          textDirection: TextDirection.rtl,
          position: Tween<Offset>(
            begin: Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      });
}





















/*
class UrlHandlerInformationParser extends RouteInformationParser<NavigationState> {
  // Url to navigation state
  @override
  Future<NavigationState> parseRouteInformation(RouteInformation routeInformation) async {
    return NavigationState(int.tryParse(routeInformation.location!.substring(1)) ?? 0);
  }

  // Navigation state to url
  @override
  RouteInformation restoreRouteInformation(NavigationState navigationState) {
    return RouteInformation(location: '/${navigationState.value}');
  }
}
final GlobalKey<NavigatorState> _urlHandlerRouterDelegateNavigatorKey = GlobalKey<NavigatorState>();
class UrlHandlerRouterDelegate extends RouterDelegate<NavigationState> with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage(child: MyHomePage(count: count, increase: increase)),
      ],
      onPopPage: (_, __) {
        // We don't handle routing logic here, so we just return false
        return false;
      },
    );
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _urlHandlerRouterDelegateNavigatorKey;

  // Navigation state to app state
  @override
  Future<void> setNewRoutePath(NavigationState navigationState) {
    // If a value which is not a number has been entered,
    // navigationState.value is null so we just notifyListeners
    // without changing the app state to change the value of the url
    // to its previous value
    if (navigationState.value == null) {
      notifyListeners();
      return null;
    }

    // Get the new count, which is navigationState.value//10
    count = (navigationState.value / 10).floor();

    // If the navigationState.value was not a multiple of 10
    // the url is not equal to count*10, therefore the url isn't right
    // In that case, we notifyListener in order to get the valid NavigationState
    // from the new app state
    if (count * 10 != navigationState.value) notifyListeners();
    return null;
  }

  // App state to Navigation state, triggered by notifyListeners()
  @override
  NavigationState get currentConfiguration => NavigationState(count*10);

  void increase() {
    count++;
    notifyListeners();
  }
}*/
