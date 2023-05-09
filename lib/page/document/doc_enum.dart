


import 'package:flutter/material.dart';

/// 문서 타입
enum DocumentMenuType {
  customer('customer', '거래처'),
  dialogCustomer('dialog_customer', '거래처'),

  undefined('undefined', '');

  const DocumentMenuType(this.code, this.displayName);
  final String code;
  final String displayName;

  factory DocumentMenuType.getByCode(String code){
    return DocumentMenuType.values.firstWhere((value) => value.code == code,
        orElse: () => DocumentMenuType.undefined);
  }
}

class DocumentMenuIcon {
  static IconData Icon(DocumentMenuType code) {
    if(code == DocumentMenuType.customer)
      return Icons.person;

    return Icons.nearby_error;
  }
}
