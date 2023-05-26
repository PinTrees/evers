



import 'package:flutter/material.dart';

import '../class/user.dart';








enum MainMenuInfo {
  /// pathName, displayName and menuKey, IconData
  home("home", '홈', Icons.home, [ SubMenuInfo.schedule ]),
  customer("customer", '고객관리', Icons.gavel, [ SubMenuInfo.customer, SubMenuInfo.contract ]),
  revenuePurchase("revenuePurchase", "매입매출", Icons.input, [ SubMenuInfo.revenuePurchase, SubMenuInfo.payment ]),
  employee("employee", "인사급여", Icons.card_travel, [ SubMenuInfo.employee, SubMenuInfo.employeeM]),
  product("product", "생산관리", Icons.production_quantity_limits, [ SubMenuInfo.factoryPaper, SubMenuInfo.productPaper, SubMenuInfo.itemManager,
    SubMenuInfo.itemTrans, SubMenuInfo.itemBalance, SubMenuInfo.productManager ]),
  payment("payment", "금전출납부", Icons.monetization_on_sharp, [ SubMenuInfo.paymentSystem, SubMenuInfo.paymentRevenue, SubMenuInfo.paymentPurchase ]),
  userAccount("userAccount", "계정관리", Icons.verified_user, [ SubMenuInfo.userSetting ]),
  schedule("schedule", "일정관리", Icons.schedule, [ SubMenuInfo.schedule ]),
  data("data", "연락처", Icons.add, []),
  setting("setting", "설정", Icons.settings_suggest, [ SubMenuInfo.update, SubMenuInfo.delete ]),
  dev("dev", "개발자", Icons.developer_board, []);

  const MainMenuInfo(this.code, this.displayName, this.icon, this.subMenus);
  final String code;
  final String displayName;
  final IconData icon;
  final List<SubMenuInfo> subMenus;

  factory MainMenuInfo.getByCode(String code){
    return MainMenuInfo.values.firstWhere((value)
    => value.code == code,
        orElse: () => MainMenuInfo.schedule
    );
  }

  factory MainMenuInfo.getByValue(String code){
    return MainMenuInfo.values.firstWhere((value)
    => value.displayName == code,
        orElse: () => MainMenuInfo.schedule
    );
  }
}


















enum SubMenuInfo {
  /// pathName, displayName and menuKey, IconData

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

  const SubMenuInfo(this.code, this.displayName, this.icon);
  final String code;
  final String displayName;
  final IconData icon;

  factory SubMenuInfo.getByCode(String code){
    return SubMenuInfo.values.firstWhere((value)
    => value.code == code,
        orElse: () => SubMenuInfo.schedule
    );
  }

  factory SubMenuInfo.getByValue(String code){
    return SubMenuInfo.values.firstWhere((value)
    => value.displayName == code,
        orElse: () => SubMenuInfo.schedule
    );
  }
}








enum NavigationMenuInfo {
  /// pathName, displayName and menuKey, IconData
  factoryPaper("1", SubMenuInfo.factoryPaper, Icons.insert_page_break, []),
  productPaper("2", SubMenuInfo.productPaper, Icons.insert_page_break, []),
  productSystem('3', SubMenuInfo.productManager, Icons.new_label_rounded, []),
  revenuePurchase('4', SubMenuInfo.revenuePurchase, Icons.input, [ PermissionType.isPurchaseRead ]),
  payment('5', SubMenuInfo.payment, Icons.monetization_on_sharp, [ PermissionType.isPaymentRead ]),
  transactionSystem('6', SubMenuInfo.paymentSystem, Icons.monetization_on_sharp, [ PermissionType.isPaymentRead ]),
  customer('7', SubMenuInfo.customer, Icons.person, [ PermissionType.isCustomerRead ]),
  contract('8', SubMenuInfo.contract, Icons.confirmation_num, [ PermissionType.isContractRead ]),
  salarySystem('9', SubMenuInfo.employeeM, Icons.contact_mail, [ PermissionType.isContractRead ]),
  schedule('10', SubMenuInfo.schedule, Icons.schedule, [ ] ),
  userSetting('11', SubMenuInfo.userSetting, Icons.verified_user, [ PermissionType.isUserRead ]),
  updatelog('12', SubMenuInfo.update, Icons.update, [ PermissionType.isUserWrite ]);


  const NavigationMenuInfo(this.code, this.menu, this.icon, this.permissions);
  final String code;
  final SubMenuInfo menu;
  final IconData icon;
  final List<PermissionType> permissions;

  factory NavigationMenuInfo.getByCode(String code){
    return NavigationMenuInfo.values.firstWhere((value)
    => value.code == code,
        orElse: () => NavigationMenuInfo.schedule
    );
  }
}






