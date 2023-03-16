import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:cell_calendar/cell_calendar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/MainPage.dart';
import 'package:evers/NonePage.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/revenue.dart';
import 'package:evers/class/schedule.dart';
import 'package:evers/class/system.dart';
import 'package:evers/helper/algolia.dart';
import 'package:evers/helper/dialog.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/route/navigator.dart';
import 'package:evers/system/product.dart';
import 'package:evers/ui/cs.dart';
import 'package:evers/ui/dialog_schedule.dart';
import 'package:evers/ui/dialog_user.dart';
import 'package:evers/ui/dl.dart';
import 'package:evers/ui/ex.dart';
import 'package:evers/ui/ip.dart';
import 'package:evers/ui/pure.dart';
import 'package:evers/ui/view_contract.dart';
import 'package:evers/ui/view_customer.dart';
import 'package:evers/ui/view_delete.dart';
import 'package:evers/ui/view_money.dart';
import 'package:evers/ui/view_product.dart';
import 'package:evers/ui/view_repu.dart';
import 'package:favicon/favicon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:url_strategy/url_strategy.dart';
//import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'class/Customer.dart';
import 'class/employee.dart';
import 'class/purchase.dart';
import 'class/transaction.dart';
import 'class/user.dart';
import 'class/version.dart';
import 'helper/aes.dart';
import 'helper/interfaceUI.dart';
import 'helper/pdfx.dart';
import 'helper/router.dart';
import 'helper/style.dart';
import 'route/navigator2.dart';
import 'route/navigator3.dart';
import 'package:http/http.dart' as http;

import 'system/system_date.dart';
import 'ui/dialog_account.dart';
import 'ui/dialog_contract.dart';
import 'ui/dialog_employee.dart';
import 'ui/dialog_item.dart';
import 'ui/dialog_revenue.dart';
import 'ui/ux.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  setPathUrlStrategy();
  //await WidgetsFlutterBinding.ensureInitialized();
  //FRouter.setupRouter();
  //await initializeDateFormatting();
  await initializeDateFormatting('ko_KR');
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "asdcdcasdcassadc",
          authDomain: "dd",
          databaseURL: "",
          projectId: "",
          storageBucket: "",
          messagingSenderId: "",
          appId: "",
          measurementId: ""
      )
  );
  //setUrlStrategy(PathUrlStrategy());
  runApp(
      MaterialApp.router(
        localizationsDelegates: <LocalizationsDelegate<Object>>[
          //GlobalMaterialLocalizations.delegate,
          MonthYearPickerLocalizations.delegate,
        ],
        supportedLocales: <Locale>[
          Locale('en', 'US'), // Engli
          //Locale('ko', 'KR'), // Korea
        ],
    debugShowCheckedModeBanner: false,
    routerConfig: router,
  ));
}

class WorkPage extends StatefulWidget {
  const WorkPage({super.key,});

  @override
  State<WorkPage> createState() => _WorkPageState();
}
class _WorkPageState extends State<WorkPage> {
  var menu = [ '고객관리', '매입매출', '인사급여', '금전출납부', '생산관리', '기초정보', '연락처' ];
  var subMenu = {
    '홈': [],
    '고객관리': [ '고객관리', '계약관리' ],
    '매입매출': [ '매입매출관리', '수납관리',],
    '인사급여': [ '사원관리', '근태관리' ],
    '생산관리': [ '공장일보', '생산일보', '품목관리', '품목입출현황', '재고현황' ],
    '금전출납부': [ '금전출납현황', '미수현황', '미지급현황' ],
    '기초정보': [],
    '연락처': [],
    '개발자': [],
    '설정': [
      '변경사항',
    ],
    '휴지통': [  ],
  };
  var currentMenu = '홈', currentSubMenu = '';

  var devMenu = [ '거래처 검색정보 마이그래에션', '계약 검색정보 마이그레이션', '매입 검색정보 마이그레이션', '매출 검색정보 마이그래이션',
    '거래기록 검색정보 마이그레이션',
  ];

  var sortMenu_FD_Date = [ '최근 1주일', '최근 1개월', '최근 3개월' ];
  var sortMenu_FD_Date_current = '';
  var sortMenu_FD = false;

  var isDev = true;

  TextEditingController searchInput = TextEditingController();

  var verticalScroll = ScrollController();
  var horizontalScroll = ScrollController();

  var st_sc_vt = ScrollController();
  var st_sc_hr = ScrollController();

  var st_sc_vt_1 = ScrollController();
  var st_sc_hr_1 = ScrollController();

  /// viewer datas
  List<Contract> contracts = [];
  List<Purchase> purchase = [];
  List<RevPur> revpurs = [];
  List<TS> searchTs = [];

  List<FactoryD> factoryD = [];

  //List<Item> items = [];

  Map<String, CalendarEvent> events = {};

  Customer? selectCs;

  int pageCount = 25, indexLimit = 10;
  /// currentPage = 현재페이지 [1,2,3,4,5,6,7,8,9,10],
  /// currentIndexPage = 현재페이지의페이지 [1~10], [11~20], [21~30]
  int currentPage = 1, currentIndexPage = 0;

  Widget main = SizedBox();
  View_REPU view_repu = View_REPU();
  View_Contract view_contract = View_Contract();
  View_Delete view_delete = View_Delete();
  View_CS view_cs = View_CS();
  View_Factory view_factory = View_Factory();
  View_MO view_mo = View_MO();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  void didChangeDependencies() {
    var user = FirebaseAuth.instance.currentUser;
    if(user == null) {
      context.go('/login/o');
      setState(() {});
    }

    initAsync();
  }

  dynamic initAsync() async {
    await SystemT.init();
    StyleT.init();
    await view_repu.init();
    await view_contract.init();
    await view_delete.init();
    await view_cs.init();
    await view_factory.init();

    //purchase = SystemT.purchase.toList();
    revpurs = SystemT.revpur.toList();
    //items = SystemT.items.toList();

    FunT.setState = () { mainW(); setState(() {}); };

    await mainW();

    refreshSchedule();
    setState(() {});
  }

  dynamic refreshSchedule() async {
    events.clear();
    for(var s in SystemT.schedule) {
      if(s.getDate() == null) continue;
      var ev = CalendarEvent(eventName:'[${StyleT.scheduleName[s.type] ?? '알수없음'}] ${s.memo}', eventDate: s.getDate()!,
          eventBackgroundColor: Colors.transparent,
          eventTextColor: StyleT.scheduleColor[s.type] ?? Colors.red);
      events[s.id] = ev;
    }
    mainW();
  }

  dynamic search() async {
    WidgetT.loadingBottomSheet(context, text: '검색 정보를 불러오는 중입니다.');
    if(currentSubMenu == '수납관리') {
      if(searchInput.text != '') {
        currentPage = 1; currentIndexPage = 0;
        var tmpList = await SystemT.searchTSMeta(searchInput.text,);
        //Algolia.contractSearch.query(searchInput.text);
      }
      setState(() {});
    }
    else if(currentSubMenu == '금전출납현황') {
      List<TS> tmpList = [];
      if(searchInput.text != '') {
        currentPage = 1; currentIndexPage = 0;
        tmpList = await SystemT.searchTSMeta(searchInput.text,);
      }
      searchTs = tmpList.toList();
      setState(() {});
    }

    Navigator.pop(context);
    WidgetT.showSnackBar(context, text: '검색 정보 로드 완료');

    mainW();
  }

  DateTime rpStartAt = DateTime.now();
  DateTime rpLastAt = DateTime.now();


  DateTime fdStartAt = DateTime.now(); DateTime fdLastAt = DateTime.now();


  VersionInfo version = VersionInfo.fromDatabase({});
  var reMenu = '';
  dynamic mainW({ bool refresh=false }) async {
    if(!Version.checkVersion()) {
      WidgetDT.showAlertDlVersion(context);
      return;
    }
    WidgetT.loadingBottomSheet(context, text: '데이터를 불러오는 중입니다.');
    setState(() {});

    List<Widget> childrenW = [];
    var divideHeight = 4.0;

    var startAt = (currentPage - 1) * pageCount;
    var limitAt = startAt + pageCount;

    var menu = subMenu[currentMenu] as List;
    if(currentSubMenu == '' && menu.length > 0) currentSubMenu = menu.first;

    var subMenuList = [
      '생산관리/공장일보',
      '생산관리/생산일보',
      '매입매출/매입매출관리',
      '매입매출/수납관리',
      '금전출납부/금전출납현황',
      '고객관리/고객관리',
      '고객관리/계약관리',
      '생산관리/품목입출현황',
      '설정/변경사항',
    ];

    var subMenuHeight = 42.0;
    var tabDsColor =  new Color(0xff777777), tabEnColor = new Color(0xffd7d7d7);
    var menuW =  TextButton(
      onPressed: null,
      style: StyleT.buttonStyleNone(padding: 0, elevation: 8, color: StyleT.subTabBarColor),
      child: Container( height: 36,
        child: Row(
          children: [
            SizedBox(width: 260,),
            for(var m in menu)
              TextButton(
                  onPressed: () async {
                    if(currentSubMenu == m) return;

                    searchInput.text = '';
                    currentSubMenu = m;
                    currentPage = 1; currentIndexPage = 0;

                    await mainW(refresh: true);
                  },
                  style: StyleT.buttonStyleNone(padding: 0, color: Colors.transparent),
                  child: Container( padding: EdgeInsets.fromLTRB(18, 6, 18, 6),
                    child: Row( mainAxisSize: MainAxisSize.min,
                      children: [
                        if(m == '고객관리')
                          WidgetT.iconMini(Icons.support_agent, color:tabDsColor),
                        if(m == '계약관리')
                          WidgetT.iconMini(Icons.gavel, color:tabDsColor),

                        if(m == '매입매출관리')
                          WidgetT.iconMini(Icons.account_balance, color:tabDsColor),
                        if(m == '수납관리')
                          WidgetT.iconMini(Icons.wallet, color:tabDsColor),
                        if(m == '매출등록')
                          WidgetT.iconMini(Icons.input, color:tabDsColor),
                        if(m == '매입등록')
                          WidgetT.iconMini(Icons.output, color:tabDsColor),
                        if(m == '수납등록')
                          WidgetT.iconMini(Icons.add_box, color:tabDsColor),

                        if(m == '사원관리')
                          WidgetT.iconMini(Icons.badge, color:tabDsColor),
                        if(m == '근태관리')
                          WidgetT.iconMini(Icons.manage_accounts, color:tabDsColor),

                        if(m == '공장일보')
                          WidgetT.iconMini(Icons.precision_manufacturing, color:tabDsColor),
                        if(m == '생산일보')
                          WidgetT.iconMini(Icons.precision_manufacturing, color:tabDsColor),
                        if(m == '품목관리')
                          WidgetT.iconMini(Icons.category, color:tabDsColor),
                        if(m == '입출현황')
                          WidgetT.iconMini(Icons.storage, color:tabDsColor),
                        if(m == '재고현황')
                          WidgetT.iconMini(Icons.inventory, color:tabDsColor),

                        if(m == '금전출납현황')
                          WidgetT.iconMini(Icons.currency_exchange, color:tabDsColor),
                        if(m == '미수현황')
                          WidgetT.iconMini(Icons.file_download_off, color:tabDsColor),
                        if(m == '미지급현황')
                          WidgetT.iconMini(Icons.file_upload_outlined, color:tabDsColor),
                        SizedBox(width: 4,),
                        WidgetT.titleT(m, color: (currentSubMenu == m) ? tabEnColor : tabDsColor, bold: true ),
                        SizedBox(width: 6,),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
    var searchBar = Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              const Color(0xFF009fdf).withOpacity(0.0),
              const Color(0xFF1855a5).withOpacity(0.0),
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: Row(
        children: [
          SizedBox(width: divideHeight * 2,),
          Expanded(flex: 1, child: SizedBox(), ),
          Expanded( flex: 8,
            child: TextButton(
              onPressed: null,
              style: StyleT.buttonStyleNone(round: 18, elevation: 6, padding: 0,),
              child: Container( height: 36,
                child: TextFormField(
                  maxLines: 1,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textInputAction: TextInputAction.search,
                  keyboardType: TextInputType.text,
                  onEditingComplete: () {
                    search();
                  },
                  onChanged: (text) {
                    if(text == '') search();
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: Colors.transparent, width: 0)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: Colors.transparent, width: 0),),
                    filled: true,
                    fillColor: Colors.white.withOpacity(1),
                    suffixIcon: Icon(Icons.keyboard),
                    hintText: '',
                    contentPadding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                  ),
                  controller: searchInput,
                ),
              ),
            ),),
          SizedBox(width: divideHeight * 4,),
          TextButton(
            onPressed: () async {
            },
            style: StyleT.buttonStyleNone(round: 18, elevation: 6, padding: 0, color:Colors.white, strock: 2),
            child: Container( height: 36, width: 36,
              child: WidgetT.iconNormal(Icons.search),),),
          Expanded(flex: 1, child: SizedBox(), ),
          SizedBox(width: divideHeight * 2,),
        ],
      ),
    );

    var div_infoMenu = Column(children: [
      SizedBox(height: divideHeight * 2,),
      WidgetT.dividHorizontal(size: 0.35),
      SizedBox(height: divideHeight * 2,),
    ],);
    var infoMenuW = Container(
      width: 220,
      child: ListView(
        padding: EdgeInsets.all(18),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for(var m in subMenuList)
                InkWell(
                  onTap: () async {
                    currentMenu =  m.split('/').first;
                    currentSubMenu = m.split('/').last;
                    await mainW(refresh: true);
                  },
                  child: Container( height: subMenuHeight,
                    decoration: StyleT.inkStyleNone(round: 8, color: (m.split('/').last == currentSubMenu) ? Colors.black.withOpacity(0.05) : Colors.transparent),
                    child: Row(
                      children: [
                        if(m.split('/').last == '수납관리') WidgetT.iconNormal(Icons.account_balance_wallet,  size: 36),
                        if(m.split('/').last == '매입매출관리') WidgetT.iconNormal(Icons.inventory_outlined,  size: 36),
                        if(m.split('/').last == '계약관리') WidgetT.iconNormal(Icons.account_tree,  size: 36),
                        if(m.split('/').last == '고객관리') WidgetT.iconNormal(Icons.support_agent,  size: 36),
                        if(m.split('/').last == '공장일보') WidgetT.iconNormal(Icons.precision_manufacturing,  size: 36),
                        if(m.split('/').last == '생산일보') WidgetT.iconNormal(Icons.production_quantity_limits,  size: 36),
                        if(m.split('/').last == '품목입출현황') WidgetT.iconNormal(Icons.insert_page_break,  size: 36),
                        if(m.split('/').last == '금전출납현황') WidgetT.iconNormal(Icons.attach_money,  size: 36),
                        if(m.split('/').last == '변경사항') WidgetT.iconNormal(Icons.update,  size: 36),

                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('${m.split('/').last}', size: 14),
                        //WidgetT.iconNormal(Icons.open_in_new,  size: 36),
                      ],
                    ),
                  )),

              div_infoMenu,
              InkWell(
                  onTap: () async {
                    await DialogEM.showInfoEmployee(context,);
                    FunT.setStateMain();
                  },
                  child: Container( height: subMenuHeight,
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.badge,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('사원 추가', size: 14),
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () async {
                    await DialogCS.showCustomerDialog(context, isCreate: true);
                    FunT.setStateMain();
                  },
                  child: Container( height: subMenuHeight,
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.support_agent,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('거래처 추가', size: 14),
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () async {
                    await DialogCT.showCreateCt(context);
                    FunT.setStateMain();
                  },
                  child: Container( height: subMenuHeight,
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.gavel,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('계약 추가', size: 14),
                      ],
                    ),
                  )),

              InkWell(
                  onTap: () async {
                    await DialogRE.showCreateRe(context);
                  },
                  child: Container( height: subMenuHeight,
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.output,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('매출 추가', size: 14),
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () async {
                    await WidgetPR.showCreatePu(context);
                  },
                  child: Container( height: subMenuHeight,
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.input,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('매입 추가', size: 14),
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () async {
                    await WidgetPR.showCreateTS(context);
                  },
                  child: Container( height: subMenuHeight,
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.balance,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('수납 추가', size: 14),
                      ],
                    ),
                  )),

              InkWell(
                  onTap: () async {
                    await DialogIT.showFdInfo(context);
                  },
                  child: Container( height: subMenuHeight,
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.precision_manufacturing,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('공장일보 추가', size: 14),
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () async {
                    await DialogIT.showProductInfo(context);
                  },
                  child: Container( height: subMenuHeight,
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.production_quantity_limits,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('생산일보 추가', size: 14),
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () async {
                    await DialogIT.showItemDl(context);
                  },
                  child: Container( height: subMenuHeight,
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.category,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('품목 추가', size: 14),
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () async {
                    await DialogSHC.showSCHCreate(context);
                  },
                  child: Container( height: subMenuHeight,
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.access_alarms_sharp,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('스케쥴 및 메모 추가', size: 14),
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () async {
                    await DialogAC.showAccountDl(context);
                  },
                  child: Container( height: subMenuHeight,
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.account_tree,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('지불 정보 추가', size: 14),
                      ],
                    ),
                  )),

              div_infoMenu,

              InkWell(
                  onTap: () async {
                    currentMenu = '휴지통';
                    FunT.setStateMain();
                  },
                  child: Container( height: subMenuHeight,
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.delete_forever,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('휴지통', size: 14),
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () async {
                    currentMenu = '설정';
                    FunT.setStateMain();
                  },
                  child: Container( height: subMenuHeight,
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.settings,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('설정', size: 14),
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () async {
                    await DialogT.showItemSetting(context);
                  },
                  child: Container( height: subMenuHeight,
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.settings_suggest,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('품목 기초정보 설정', size: 14),
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () async {
                    if(!isDev) WidgetT.showSnackBar(context, text: '접근이 제한되었습니다.');
                    currentMenu = isDev ? '개발자' : currentMenu;
                    FunT.setStateMain();
                  },
                  child: Container( height: subMenuHeight,
                    child: Row(
                      children: [
                        WidgetT.iconNormal(Icons.code,  size: 36),
                        SizedBox(width: divideHeight * 2,),
                        WidgetT.text('개발자 설정', size: 14),
                      ],
                    ),
                  )),
            ],
          ),
        ],
      ),
    );

    if(currentMenu == '홈') {
      FunT.scheduleRf = refreshSchedule;

      List<Widget> widgetsBookmark = [];
      UserSystem.user.bookmark.forEach((key, value) async {
        var iconUrl = null;
        print(iconUrl);
        //var icon = await FaviconFinder.getBest(value['url'] ?? '');
        widgetsBookmark.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () async {
                  await launchUrl( Uri.parse(value['url'] ?? ''),
                    webOnlyWindowName: true ? '_blank' : '_self',
                  );
                },
                child: Container(
                  decoration: StyleT.inkStyle(round: 8, color: Colors.grey.withOpacity(0.1), stroke: 0.7),
                  padding: EdgeInsets.all(divideHeight),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 22, height: 22,
                           child: (value['url'] != null) ?
                           ClipRRect(
                           borderRadius: BorderRadius.circular(8),
                               child: CachedNetworkImage(imageUrl: 'http://www.google.com/s2/favicons?domain=' + value['url'] + '&size=128', fit: BoxFit.cover,))
                               : WidgetT.iconNormal(Icons.open_in_new),
              ),
                      SizedBox(width: divideHeight,),
                      WidgetT.text((value['name'] ?? 'null') + '(${value['url'] ?? ''})'),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  if(!await DialogT.showAlertDl(context, text:'북마크를 삭제하시겠습니까?')) {
                    WidgetT.showSnackBar(context, text: '취소됨');
                    return;
                  }
                  UserSystem.user.bookmark.remove(key);
                  await UserSystem.updateUser(UserSystem.user);
                  WidgetT.showSnackBar(context, text: '삭제됨');
                },
                child: WidgetT.iconMini(Icons.cancel),
              ),
              SizedBox(width: divideHeight * 3,),

            ],
          ),
        );
      });

      main = Column(
        children: [
          menuW,
          Expanded(
            child: Row(
              children: [
                infoMenuW,
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(height: divideHeight,),
                      WidgetT.title('북마크 바로가기', size: 18),
                      SizedBox(height: divideHeight,),
                      Wrap(
                        spacing: divideHeight, runSpacing: divideHeight,
                        children: [
                          for(var w in widgetsBookmark) w,
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await DialogUS.showAddBookMark(context, UserSystem.user);
                                },
                                child: Container( width: 32, height: 32,
                                    decoration: StyleT.inkStyle(round: 8, color: Colors.grey.withOpacity(0.1), stroke: 2),
                                    child: WidgetT.iconNormal(Icons.add_box,)),
                              ),
                              SizedBox(width: divideHeight,),
                              WidgetT.text('추가'),
                              SizedBox(width: divideHeight * 3,),
                            ],
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 1024,
                              child: CellCalendar(
                                events: events.values.toList(),
                                onCellTapped: (date){
                                  print("$date is tapped !");
                                  final eventsOnTheDate = SystemT.schedule.where((event) {
                                    final eventDate = DateTime.fromMicrosecondsSinceEpoch(event.date);
                                    return eventDate.year == date.year &&
                                        eventDate.month == date.month &&
                                        eventDate.day == date.day;
                                  }).toList();
                                  print(eventsOnTheDate.length);
                                  DialogSHC.showSCHInfo(context, eventsOnTheDate, date);
                                },
                                daysOfTheWeekBuilder: (dayIndex) {
                                  /// dayIndex: 0 for Sunday, 6 for Saturday.
                                  final labels = ["일", "월", "화", "수", "목", "금", "토"];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text(
                                      labels[dayIndex],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                                monthYearLabelBuilder: (datetime) {
                                  final year = datetime!.year.toString();
                                  final month = datetime!.month.toString();
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      "$year년 $month월",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              )
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    else if(currentMenu == '고객관리') {
      main = await view_contract.mainView(context, currentSubMenu, infoWidget: infoMenuW, topWidget: menuW, refresh: refresh);
    }
    else if(currentMenu == '인사급여')  {
      childrenW.clear();
      if(currentSubMenu == '사원관리') {
        List<Widget> widgets = [];
        for(int i = 0; i < EmployeeSystem.stream.length; i++) {
          var em = EmployeeSystem.stream.values.elementAt(i);

          var w = InkWell(
              onTap: () async {
                await DialogEM.showInfoEmployee(context, org: em);
              },
              child: Container( height: 36 + divideHeight,
                decoration: StyleT.inkStyleNone(color: Colors.transparent),
                child: Row(
                    children: [
                      WidgetT.excelGrid(label: '${i + 1}', width: 32),
                      WidgetT.excelGrid(text: em.name, width: 250),
                      WidgetT.excelGrid(text: em.rank, width: 150),
                      WidgetT.excelGrid(text: em.mobileNum, width: 150),
                      WidgetT.excelGrid(text: '', width: 150),
                      Expanded(child: WidgetT.excelGrid(text: em.memo, width: 150)),
                      TextButton(
                          onPressed: () async {
                            WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
                         /*   if(await DialogT.showAlertDl(context, text: '"${cs.businessName}" 거래처를 데이터베이스에서 삭제하시겠습니까?')) {
                              await FireStoreT.deleteCustomer(cs);
                            }*/
                            FunT.setStateDT();
                          },
                          style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                          child: Container( height: 32, width: 32,
                            child: WidgetT.iconMini(Icons.delete),)
                      ),
                    ]
                ),
              ));
          widgets.add(w);
          widgets.add(WidgetT.dividHorizontal(size: 0.35));
        }
        childrenW.add(Column(children: widgets,));
      }
      else if(currentSubMenu == '근태관리') {
        var widgets = Column(children: [],);
        var widgetUser = Column(children: [],);
        var currentMonthDay = DateTime(SystemDate.selectWorkDate.year, SystemDate.selectWorkDate.month + 1, 0).day;
        var userCount = 8;

        /// 타이틀
        childrenW.add(Row(
          children: [
            Expanded(child: SizedBox(), flex: 1,),
            Expanded(flex: 10,child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 100,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      focusColor: Colors.transparent,
                      focusNode: FocusNode(),
                      autofocus: false,
                      customButton: Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(child: SizedBox()),
                            WidgetT.title(SystemDate.dateFormat_YYYY_kr(SystemDate.selectWorkDate), size: 24),
                            Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                      items: SystemDate.years?.map((item) => DropdownMenuItem<dynamic>(
                        value: item,
                        child: Text(
                          item.toString() + '년',
                          style: StyleT.titleStyle(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )).toList(),
                      onChanged: (value) async {
                        var org = SystemDate.selectWorkDate;
                        SystemDate.selectWorkDate = DateTime(value, org.month, 1);
                        await FunT.setStateMain();
                      },
                      itemHeight: 28,
                      itemPadding: const EdgeInsets.only(left: 16, right: 16),
                      dropdownWidth: 100,
                      dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
                      dropdownDecoration: BoxDecoration(
                        border: Border.all(
                          width: 1.7,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(0),
                        color: Colors.white.withOpacity(0.95),
                      ),
                      dropdownElevation: 0,
                      offset: const Offset(0, 0),
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      focusColor: Colors.transparent,
                      focusNode: FocusNode(),
                      autofocus: false,
                      customButton: Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(child: SizedBox()),
                            WidgetT.title(SystemDate.dateFormat_MM_kr(SystemDate.selectWorkDate), size: 24),
                            Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                      items: SystemDate.months?.map((item) => DropdownMenuItem<dynamic>(
                        value: item,
                        child: Text(
                          item.toString() + '월',
                          style: StyleT.titleStyle(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )).toList(),
                      onChanged: (value) async {
                        var org = SystemDate.selectWorkDate;
                        SystemDate.selectWorkDate = DateTime(org.year, value, 1);
                        await FunT.setStateMain();
                      },
                      itemHeight: 28,
                      itemPadding: const EdgeInsets.only(left: 16, right: 16),
                      dropdownWidth: 60,
                      dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
                      dropdownDecoration: BoxDecoration(
                        border: Border.all(
                          width: 1.7,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(0),
                        color: Colors.white.withOpacity(0.95),
                      ),
                      dropdownElevation: 0,
                      offset: const Offset(0, 0),
                    ),
                  ),
                ),
                SizedBox(width: divideHeight * 2,),
              ],
            ),),
          ],
        ));
        childrenW.add(SizedBox(height: divideHeight * 2,));

        var title =  Row(children: [],);
        widgets.children.add(WidgetT.dividHorizontal(size: 0.7));
        title.children.add(WidgetT.dividViertical(height: 36, size: 0.7));
        for(int c = 0; c < currentMonthDay; c++) {
          var date = DateTime(SystemDate.selectWorkDate.year, SystemDate.selectWorkDate.month, c + 1);
          title.children.add(Expanded(flex: 1,child: Container( height: 36, alignment: Alignment.center, child: Column(
            children: [
              WidgetT.text('${c + 1}일', size: 10),
              WidgetT.title(SystemDate.dateFormat_EE(date)),
            ],
          ), ),));
          title.children.add(WidgetT.dividViertical(height: 36, size: 0.35));
        }
        title.children.add(WidgetT.dividViertical(height: 36, size: 0.35));
        widgets.children.add(title);
        widgets.children.add(WidgetT.dividHorizontal(size: 0.7));
        widgetUser.children.add( Container(height: 36.7, alignment: Alignment.center, child: WidgetT.title(''),) );

        for(int i = 0; i < EmployeeSystem.stream.length; i++) {
          var user = EmployeeSystem.stream.values.elementAt(i);
          var w =  Row(children: [],);
          w.children.add(WidgetT.dividViertical(height: 36, size: 0.7));
          for(int c = 0; c < currentMonthDay; c++) {
            var date = DateTime(SystemDate.selectWorkDate.year, SystemDate.selectWorkDate.month, c + 1);
            var att = EmployeeSystem.attStream[user.id + ':' + StyleT.dateFormat(date)] ?? Attendance.fromDatabase({});
            w.children.add(Expanded(flex: 1,child: InkWell(
               onTap: () async {
                 await DialogEM.showAttCreate(context, setDate: date, setEm: user, org: att);
               },
               child: Container( height: 36,
                   alignment: Alignment.center,
                   child: WidgetT.title(att.getThumbnailText()),
               ),
             ),));
             w.children.add(WidgetT.dividViertical(height: 36, size: 0.35));
          }
          w.children.add(WidgetT.dividViertical(height: 36, size: 0.35));

          widgets.children.add(w);
          widgets.children.add(WidgetT.dividHorizontal(size: 0.35));

          widgetUser.children.add(Container(height: 36.35, alignment: Alignment.center, child: WidgetT.title(user.name),) );
        }
        widgets.children.add(WidgetT.dividHorizontal(size: 0.35));

        childrenW.add(Row(
          children: [
            Expanded(child: widgetUser, flex: 1,),
            Expanded(child: widgets, flex: 10,),
          ],
        ));
      }

      main = Column(
        children: [
          menuW,
          Expanded(
            child: Row(
              children: [
                infoMenuW,
                Expanded(
                  child: Column(
                    children: [
                      if(currentSubMenu == '사원관리')
                        Container(
                          child: WidgetUI.titleRowNone([ '순번', '사원', '직급', '전화번호', '근무년수', '메모', ], [ 32, 250, 150, 150, 150, 999, ]),
                        ),
                      WidgetT.dividHorizontal(size: 0.7),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.all(divideHeight * 3),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: childrenW,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    else if(currentMenu == '연락처')  {
      main = Column(
        children: [
          menuW,
          Container(
            padding: EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container( height: 36,
                    child: TextFormField(
                      maxLines: 1,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textInputAction: TextInputAction.search,
                      keyboardType: TextInputType.text,
                      onEditingComplete: () {
                        search();
                      },
                      onChanged: (text) {
                        if(text == '') search();
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
                        suffixIcon: Icon(Icons.keyboard),
                        hintText: '',
                        contentPadding: EdgeInsets.all(6),
                      ),
                      controller: searchInput,
                    ),
                  ),),
                SizedBox(width: 8,),
              ],
            ),
          ),
          WidgetT.dividHorizontal(),
          Expanded(
            child: AdaptiveScrollbar(
                controller: verticalScroll,
                width: 0.1,
                sliderSpacing: EdgeInsets.zero,
                sliderDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: StyleT.accentLowColor,
                ),
                sliderActiveDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color:  StyleT.accentLowColor,
                ),
                sliderDefaultColor: Colors.transparent,
                child: AdaptiveScrollbar(
                    controller: horizontalScroll,
                    width: 18,
                    position: ScrollbarPosition.bottom,
                    sliderSpacing: EdgeInsets.zero,
                    sliderDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: StyleT.accentLowColor,
                    ),
                    sliderActiveDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color:  StyleT.accentLowColor,
                    ),
                    underSpacing: EdgeInsets.only(bottom: 28),
                    child: SingleChildScrollView(
                      controller: horizontalScroll,
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: 1450,
                        child:  ListView(
                          padding: EdgeInsets.all(8),
                          children: [
                            Column(
                              children: [
                                for(var w in childrenW) w,
                                SizedBox(height: 28,),
                              ],
                            )
                          ],
                        ),
                      ),
                    ))),
          ),
        ],
      );
    }
    else if(currentMenu == '매입매출') {
      main = await view_repu.mainView(context, currentSubMenu, infoWidget: infoMenuW, topWidget: menuW, refresh: refresh);
    }
    else if(currentMenu == '생산관리') {
      main = await view_factory.mainView(context, currentSubMenu, infoWidget: infoMenuW, topWidget: menuW, refresh: refresh);
    }
    else if(currentMenu == '기초정보') {
      var chW = [];
      for(int i = 0; i < SystemT.accounts.values.length; i++) {
        var ac = SystemT.accounts.values.elementAt(i);
        Widget w = SizedBox();
        w = InkWell(
            onTap: () async {
              await DialogAC.showAccountDl(context, account_org: ac);
            },
            child: Container( height: 36,
              decoration: StyleT.inkStyleNone(color: Colors.transparent),
              child: Row(
                  children: [
                    WidgetT.excelGrid(label: '${i + 1}', width: 32),
                    WidgetT.excelGrid(text: ac.type, width: 150,),
                    WidgetT.excelGrid(text: '${ac.name}', width: 250, ),
                    WidgetT.excelGrid(text: ac.account, width: 200,),
                    Expanded(child: WidgetT.excelGrid(width: 250,  text: ac.memo,),),
                    TextButton(
                        onPressed: () async {
                          await WidgetT.showSnackBar(context, text: '개발중입니다.');
                        },
                        style: StyleT.buttonStyleNone(padding: 0, strock: 2, round: 8, color: Colors.transparent),
                        child: WidgetT.iconMini(Icons.delete,  size: 36),),
                  ]
              ),
            ));
        chW.add(w);
        chW.add(WidgetT.dividHorizontal(size: 0.35));
      }

      main = Column(
        children: [
          menuW,
          Expanded(
            child: Row(
              children: [
                infoMenuW,
                Expanded(
                  child: Column(
                    children: [
                      Container( padding: EdgeInsets.all(12),
                        child: WidgetUI.titleRowNone([ '순번', '분류', '별명', '계좌번호', '메모' ], [ 32, 150, 250, 200, 999 ]),),
                      WidgetT.dividHorizontal(size: 0.7),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.all(12),
                          children: [
                            Column(
                              children: [
                                for(var w in chW) w,
                                SizedBox(height: 28,),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    else if(currentMenu == '금전출납부') {
      main = await view_mo.mainView(context, currentSubMenu, infoWidget: infoMenuW, topWidget: menuW, refresh: refresh);
    }
    else if(currentMenu == '개발자') {
      main = Column(
        children: [
          menuW,
          Expanded(
            child: Row(
              children: [
                infoMenuW,
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.all(12),
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for(var m in devMenu)
                                    Container(
                                      padding: EdgeInsets.only(bottom: divideHeight * 2),
                                      child: TextButton(
                                          onPressed: () async {
                                            WidgetT.loadingBottomSheet(context, text:'로딩중');
                                            if(m == devMenu[0]) {
                                              List<Purchase> data = await FireStoreT.getPurchaseAll();
                                              for(var pu in data) {
                                                await FireStoreT.updatePurchase(pu);
                                              }
                                            }
                                            else if(m == devMenu[1]) {

                                            }
                                            else if(m == devMenu[2]) {
                                              for(var pu in SystemT.purchase.values) {
                                                await FireStoreT.updatePurchase(pu);
                                              }
                                            }
                                            else if(m == devMenu[4]) {
                                            }
                                            Navigator.pop(context);
                                          },
                                          style: StyleT.buttonStyleNone(padding: 0, strock: 2, round: 8,
                                              color: Colors.black.withOpacity(0.05)),
                                          child: Container( height: subMenuHeight, alignment: Alignment.center,
                                            child: WidgetT.text(m, size: 14),
                                          )),
                                    ),
                                ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    else if(currentMenu == '설정') {
      if(currentSubMenu == '변경사항') {
        List<VersionInfo> versions = await FireStoreT.getVersionInfo();

        childrenW.clear();
        for(var v in versions) {
          var w = Container(
            padding: EdgeInsets.all(divideHeight * 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetT.title('ver ' + v.name, size: 18),
                SizedBox(height: divideHeight * 2,),
                Row(
                  children: [
                    Expanded(child: WidgetT.text(v.info, size: 12),)
                  ],
                ),
                SizedBox(height: divideHeight * 2,),
                Row(
                  children: [
                    WidgetT.text('${v.updateAt} - 업데이트됨', size: 12)
                  ],
                )
              ],
            ),
          );
          childrenW.add(w);
          childrenW.add(WidgetT.dividHorizontal(size: 0.35));
        }

        if(isDev) {
          childrenW.add(WidgetTF.textTitInput(context, 'version.titleacascasdc',
          onEdite: (i, data) {
            version.name = data;
          }, text: version.name));

          childrenW.add(
              Row(
                children: [
                  Expanded(child: WidgetTF.textTitInput(context, '메모', isMultiLine: true, textSize: 12,
            onEdite: (i, data) { version.info = data; },
            text: version.info,
          ),),
                ],
              ));
          childrenW.add(InkWell(
            onTap: () async {
              version.updateAt = DateTime.now().microsecondsSinceEpoch;
              await FireStoreT.updateVersion(version);
              FunT.setStateMain();
            },
            child: Container(
              color: Colors.grey.withOpacity(0.35),
              child: WidgetT.title('버전추가'),
            ),
          ));
          childrenW.add(InkWell(
            onTap: () {
              version = VersionInfo.fromDatabase({});
              FunT.setStateMain();
            },
            child: Container(
              color: Colors.grey.withOpacity(0.35),
              child: WidgetT.title('초기화'),
            ),
          ));
        }
        
        main = Column(
          children: [
            menuW,
            Expanded(
              child: Row(
                children: [
                  infoMenuW,
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.all(12),
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WidgetT.title('버전기록', size: 18),
                                  SizedBox(height: divideHeight * 4,),
                                  
                                  for(var w in childrenW) w,
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
      else {
        main = Column(
          children: [
            menuW,
            Expanded(
              child: Row(
                children: [
                  infoMenuW,
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.all(12),
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WidgetT.title('은행 목록', size: 14),
                                  Container(
                                    padding: EdgeInsets.only(bottom: divideHeight * 2),
                                    child: TextButton(
                                        onPressed: () async {

                                        },
                                        style: StyleT.buttonStyleNone(padding: 0, strock: 2, round: 8,
                                            color: Colors.black.withOpacity(0.05)),
                                        child: Container( height: subMenuHeight, alignment: Alignment.center,
                                          child: WidgetT.text('은행 목록 추가', size: 14),
                                        )),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    }
    else if(currentMenu == '휴지통') {
      main = await view_delete.mainView(context, currentSubMenu, infoWidget: infoMenuW, topWidget: menuW );
    }

    Navigator.pop(context);
    setState(() {});
  }

  @override
  void dispose() {
    SystemT.exiteStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: StyleT.accentColor,
        elevation: 18,
        automaticallyImplyLeading: false,
        toolbarHeight: 68, // Set this height
        flexibleSpace: Container(
        ),
        title: Stack(
          children: [
            Container(height: 68,),
            Positioned(
              child: Material(
                elevation: 18, color: Colors.black,
                child: Container(
                  height: 68, padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                  child: Row(
                    children: [
                      TextButton(
                      onPressed: () { currentMenu = '홈'; FunT.setStateMain(); },
                          style: StyleT.buttonStyleNone(elevation: 0, color: Colors.transparent,),
                          child: Container(height: 48, child: Image(image: AssetImage('assets/icon_hor.png')))),
                      //WidgetT.titleBig('Evers.1', size: 30, color: StyleT.tabColor),
                      SizedBox(width: 48,),
                      Row(
                        children: [
                          for(var m in this.menu)
                            TextButton(
                              onPressed: () async {
                                searchInput.text = '';
                                currentMenu = m;
                                currentSubMenu = '';

                                await mainW(refresh: true);
                              },
                              style: (currentMenu == m) ? StyleT.buttonStyleNone(padding: 0, elevation: 0, color: Colors.transparent)
                                  : StyleT.buttonStyleNone(padding: 0, elevation: 0, color: Colors.transparent),
                              child: Container(height: 48, padding: EdgeInsets.fromLTRB(24, 12, 24, 0), alignment: Alignment.center,
                                  child: WidgetT.titleTabMenu(m, accent: ((currentMenu == m)))),
                            )
                        ],
                      ),
                      Expanded(child: SizedBox()),
                      WidgetT.loginUser(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: main,
     /* floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: floating(), // This trailing comma makes auto-formatting nicer for build methods.*/
    );
  }
}
