import 'package:flutter/material.dart';

import '../class/user.dart';







/// ERP 메인 메뉴 목록입니다.
enum ERPMenuInfo {
  /// pathName, displayName and menuKey, IconData
  homepage("homepage", "홈페이지", Icons.web, [ ERPSubMenuInfo.pageEditor, ERPSubMenuInfo.communityEditor, ERPSubMenuInfo.shopEditor ]),

  home("home", '홈', Icons.home, [ ERPSubMenuInfo.schedule ]),
  customer("customer", '고객관리', Icons.gavel, [ ERPSubMenuInfo.customer, ERPSubMenuInfo.contract ]),
  revenuePurchase("revenuePurchase", "매입매출", Icons.input, [ ERPSubMenuInfo.revenuePurchase, ERPSubMenuInfo.payment ]),
  employee("employee", "인사급여", Icons.card_travel, [ ERPSubMenuInfo.employee, ERPSubMenuInfo.employeeM]),

  product("product", "생산관리", Icons.production_quantity_limits,
      [ ERPSubMenuInfo.itemManager, ERPSubMenuInfo.itemTrans, ERPSubMenuInfo.itemBalance, ERPSubMenuInfo.productManager ]),
  paper("paper", "공장일보", Icons.production_quantity_limits, [ ERPSubMenuInfo.factoryPaper, ERPSubMenuInfo.productPaper ]),

  payment("payment", "금전출납부", Icons.monetization_on_sharp, [
    ERPSubMenuInfo.paymentSystem,
    ERPSubMenuInfo.paymentRevenue,
    ERPSubMenuInfo.paymentPurchase,
    ERPSubMenuInfo.daily,
  ]),

  userAccount("userAccount", "계정관리", Icons.verified_user, [ ERPSubMenuInfo.userSetting ]),
  schedule("schedule", "일정관리", Icons.schedule, [ ERPSubMenuInfo.schedule ]),
  data("data", "연락처", Icons.add, []),
  setting("setting", "설정", Icons.settings_suggest, [ ERPSubMenuInfo.update, ERPSubMenuInfo.delete ]),
  dev("dev", "개발자", Icons.developer_board, []);

  const ERPMenuInfo(this.code, this.displayName, this.icon, this.subMenus);
  final String code;
  final String displayName;
  final IconData icon;
  final List<ERPSubMenuInfo> subMenus;

  factory ERPMenuInfo.getByCode(String code){
    return ERPMenuInfo.values.firstWhere((value)
    => value.code == code,
        orElse: () => ERPMenuInfo.schedule
    );
  }

  factory ERPMenuInfo.getByValue(String code){
    return ERPMenuInfo.values.firstWhere((value)
    => value.displayName == code,
        orElse: () => ERPMenuInfo.schedule
    );
  }
}


/// ERP 메인메뉴 1차 하위메뉴 목록입니다.
enum ERPSubMenuInfo {
  /// pathName, displayName and menuKey, IconData

  /// 홈페이지관리 하위메뉴
  pageEditor("pageEditor", "홈페이지관리", Icons.restore_page_sharp),
  communityEditor("community", "커뮤니티관리", Icons.comment),
  shopEditor("shopping", "제품관리", Icons.shopping_bag_outlined),

  /// 고객관리 하위메누
  customer("customer", '고객관리', Icons.support_agent),
  contract("contract", '계약관리', Icons.gavel),

  /// 메입매출 하위메뉴
  revenuePurchase('revenuePurchase', '매입매출관리', Icons.account_balance),
  payment('payment', '수납관리', Icons.wallet),

  /// 금전출납부 하위메뉴
  paymentSystem('paymentSystem', '금전출납현황', Icons.monetization_on_sharp),
  paymentRevenue('paymentRevenue', '미수현황', Icons.file_download_off),
  paymentPurchase('paymentPurchase', '미지급현황', Icons.file_upload_outlined),
  daily('daily', '일계표', Icons.grid_on),

  /// 생산관리 하위메뉴
  factoryPaper('factory', '공장일보', Icons.precision_manufacturing),
  productPaper('product', '생산일보', Icons.precision_manufacturing),
  productManager('productManager', '생산관리', Icons.precision_manufacturing),
  itemManager('itemManager', '품목관리', Icons.precision_manufacturing),
  itemTrans('itemTrans', '품목입출현황', Icons.precision_manufacturing),
  itemBalance('itemBalance', '재고현황', Icons.precision_manufacturing),

  /// 인사관리 하위메뉴
  employee('employee', '사원관리', Icons.schedule),
  employeeM('employeeM', '근태관리', Icons.schedule),
  salarySystem('salary', '급여관리대장', Icons.contact_mail),

  /// 설정 하위메뉴
  update("update", "변경사항", Icons.update),
  delete('delete', "휴지통", Icons.delete),

  /// 일정관리 하위메뉴
  schedule('schedule', '일정관리', Icons.schedule),

  /// 계정관리 하위메뉴
  userSetting('userAccount', '계정현황', Icons.verified_user);

  const ERPSubMenuInfo(this.code, this.displayName, this.icon);
  final String code;
  final String displayName;
  final IconData icon;

  factory ERPSubMenuInfo.getByCode(String code){
    return ERPSubMenuInfo.values.firstWhere((value)
    => value.code == code,
        orElse: () => ERPSubMenuInfo.schedule
    );
  }

  factory ERPSubMenuInfo.getByValue(String code){
    return ERPSubMenuInfo.values.firstWhere((value)
    => value.displayName == code,
        orElse: () => ERPSubMenuInfo.schedule
    );
  }
}


/// ERP 좌측 네비게이션 메뉴 목록입니다.
enum NavigationMenuInfo {
  /// pathName, displayName and menuKey, IconData
  factoryPaper("1", ERPSubMenuInfo.factoryPaper, Icons.insert_page_break, []),
  productPaper("2", ERPSubMenuInfo.productPaper, Icons.insert_page_break, []),
  productSystem('3', ERPSubMenuInfo.productManager, Icons.new_label_rounded, []),
  revenuePurchase('4', ERPSubMenuInfo.revenuePurchase, Icons.input, [ PermissionType.isPurchaseRead ]),
  payment('5', ERPSubMenuInfo.payment, Icons.monetization_on_sharp, [ PermissionType.isPaymentRead ]),
  transactionSystem('6', ERPSubMenuInfo.paymentSystem, Icons.monetization_on_sharp, [ PermissionType.isPaymentRead ]),
  customer('7', ERPSubMenuInfo.customer, Icons.person, [ PermissionType.isCustomerRead ]),
  contract('8', ERPSubMenuInfo.contract, Icons.confirmation_num, [ PermissionType.isContractRead ]),
  salarySystem('9', ERPSubMenuInfo.employeeM, Icons.contact_mail, [ PermissionType.isContractRead ]),
  schedule('10', ERPSubMenuInfo.schedule, Icons.schedule, [ ] ),
  userSetting('11', ERPSubMenuInfo.userSetting, Icons.verified_user, [ PermissionType.isUserRead ]),
  updatelog('12', ERPSubMenuInfo.update, Icons.update, [ PermissionType.isUserWrite ]),
  homepage('13', ERPSubMenuInfo.pageEditor, Icons.update, []);


  const NavigationMenuInfo(this.code, this.menu, this.icon, this.permissions);
  final String code;
  final ERPSubMenuInfo menu;
  final IconData icon;
  final List<PermissionType> permissions;

  factory NavigationMenuInfo.getByCode(String code){
    return NavigationMenuInfo.values.firstWhere((value)
    => value.code == code,
        orElse: () => NavigationMenuInfo.schedule
    );
  }
}






/// 홈페이지 메인 메뉴 목록입니다.
enum HomeMainMenu {
  home("home", "홈", Icons.new_label_rounded, []),
  info("info", '소개', Icons.insert_drive_file_outlined, [ HomeSubMenu.greetings, HomeSubMenu.history ]),
  community("community", "소식", Icons.add_box, [ HomeSubMenu.news, HomeSubMenu.eversStory ]),
  technology("technology", '동결건조', Icons.pages_sharp, [ HomeSubMenu.freezeDrying, ]),
  product("product", "제품", Icons.production_quantity_limits, [ HomeSubMenu.meogkkun ]),
  store("store", "판매 사이트", Icons.storefront_outlined, [ HomeSubMenu.store, HomeSubMenu.naverStore]);

  const HomeMainMenu(this.code, this.displayName, this.icon, this.subMenus);
  final String code;
  final String displayName;
  final IconData icon;
  final List<HomeSubMenu> subMenus;

  factory HomeMainMenu.getByCode(String code){
    return HomeMainMenu.values.firstWhere((value)
    => value.code == code,
        orElse: () => HomeMainMenu.info
    );
  }
}


/// 홈페이지 메인메뉴의 1차 하위메뉴 목록입니다.
enum HomeSubMenu {
  /// 소개
  greetings("greetings", '인사말', Icons.waving_hand, [ ]),
  history("history", '걸어온 길', Icons.history_edu, [ ]),

  /// 소식
  news('news', "새소식", Icons.newspaper, []),
  eversStory('story', "먹꾼 이야기", Icons.work_history_sharp, []),

  /// 동결건조기술
  freezeDrying("freezeDrying", '동결건조기술', Icons.biotech, [ ]),

  /// 제품
  meogkkun("meogkkun", "나는먹꾼", Icons.tapas, []),

  /// 판매사이트
  store("store", '판매사이트', Icons.store, [ ]),
  naverStore("naverStore", "스마트스토어", Icons.shopping_bag_outlined, [ ]);

  const HomeSubMenu(this.code, this.displayName, this.icon, this.subMenus);
  final String code;
  final String displayName;
  final IconData icon;
  final List<ERPSubMenuInfo> subMenus;

  factory HomeSubMenu.getByCode(String code){
    return HomeSubMenu.values.firstWhere((value)
    => value.code == code,
        orElse: () => HomeSubMenu.greetings
    );
  }
}





