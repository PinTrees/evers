
import 'package:evers/class/system/records.dart';
import 'package:flutter/material.dart';

import '../class/user.dart';



enum MainPageI {
  /// pathName, displayName and menuKey, IconData
  productSystem('product', '생산관리/생산관리', Icons.new_label_rounded ),
  home('home', '홈/', Icons.new_label_rounded ),
  revenuePurchase('revpur', '매입매출/매입매출관리', Icons.input),
  transactionSystem('finance', '금전출납부/금전출납현황', Icons.monetization_on_sharp),
  customer('customer', '고객관리/고객관리', Icons.person),
  employee('employee', '인사급여/급여관리대장', Icons.contact_mail),
  schedule('schedule', '홈/일정관리', Icons.schedule),
  userAuth("userAuth", "계정관리/계정현황", Icons.verified_user),
  setting('setting', '설정/변경사항', Icons.update);


  const MainPageI(this.code, this.displayName, this.icon);
  final String code;
  final String displayName;
  final IconData icon;

  factory MainPageI.getByCode(String code){
    return MainPageI.values.firstWhere((value)
    => value.code == code,
        orElse: () => MainPageI.home
    );
  }
}


enum NevigationMenuInfo {
  /// pathName, displayName and menuKey, IconData
  productFactory("product/factory", '생산관리/공장일보', Icons.insert_page_break, []),
  productProduct("product/product", '생산관리/생산일보', Icons.insert_page_break, []),
  productSystem('product/system', '생산관리/생산관리', Icons.new_label_rounded, []),
  revpur('revpur/info', '매입매출/매입매출관리', Icons.input, [ PermissionType.isPurchaseRead ]),
  transaction1('revpur/transaction', '매입매출/수납관리', Icons.monetization_on_sharp, [ PermissionType.isPaymentRead ]),
  transactionSystem('finance/transaction', '금전출납부/금전출납현황', Icons.monetization_on_sharp, [ PermissionType.isPaymentRead ]),
  customer('customer/customer', '고객관리/고객관리', Icons.person, [ PermissionType.isCustomerRead ]),
  contract('customer/contract', '고객관리/계약관리', Icons.confirmation_num, [ PermissionType.isContractRead ]),
  salarySystem('employee/salary', '인사급여/급여관리대장', Icons.contact_mail, [ PermissionType.isContractRead ]),
  schedule('home/schedule', '홈/일정관리', Icons.schedule, [ ] ),
  userSetting('userAuth/setting', '계정관리/계정현황', Icons.verified_user, [ PermissionType.isUserRead ]),
  updatelog('setting/log', '설정/변경사항', Icons.update, [ PermissionType.isUserWrite ]),
  none('none', '', Icons.update, []);

  const NevigationMenuInfo(this.code, this.displayName, this.icon, this.permissions);
  final String code;
  final String displayName;
  final IconData icon;
  final List<PermissionType> permissions;

  factory NevigationMenuInfo.getByCode(String code){
    return NevigationMenuInfo.values.firstWhere((value)
    => value.code == code,
        orElse: () => NevigationMenuInfo.none
    );
  }
}