
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/employee.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/revenue.dart';
import 'package:evers/class/schedule.dart';
import 'package:evers/class/transaction.dart';
import 'package:evers/class/user.dart';
import 'package:evers/class/version.dart';
import 'package:evers/helper/algolia.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/system/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';
import 'package:korea_regexp/get_regexp.dart';
import 'package:korea_regexp/models/regexp_options.dart';

import 'Customer.dart';

class SystemT {
  static Map<String, Customer?> customers = {};
  static List<Schedule> schedule = [];

  static Map<dynamic, Contract> contractMap = {};

  static List<Contract> searchCt = [];

  static Map<String, Purchase> purchase = {};
  static Map<String, Revenue> revenue = {};
  static List<RevPur> revpur = [];

  /// 메타데이터
  static List<Item> items = [];         /// 품목
  static Map<String, Item> itemMaps = {};         /// 품목
  static Map<String, ItemFD> inventory = {}; /// 재고수량
  static Map<String, Account> accounts = {};

  static Map<dynamic, dynamic> customerSearch = {};
  static Map<dynamic, dynamic> contractSearch = {};
  static Map<dynamic, dynamic> transactionSearch = {};
  static Map<dynamic, dynamic> revSearch = {};
  static Map<dynamic, dynamic> purSearch = {};

  static Map<dynamic, FactoryD> streamFacD = {};

  static Balance balance = Balance();
  static SearchMeta searchMeta = SearchMeta.fromDatabase({});

  static var searchText = '';

  static dynamic init() async {
    await FireStoreT.initStreamVersion();
    if(!Version.checkVersion()) {
      return;
    }

    searchMeta = await FireStoreT.getSearchMeta();
    itemMaps = await FireStoreT.getItems();

    schedule = await FireStoreT.getSchedule();
    //items = itemMaps.values.toList();
    inventory = await FireStoreT.getItemSV();
    accounts = await FireStoreT.getAccount();

    await initStream();
    await Algolia.initSearchContract();
  }
  static dynamic initStream() async {
     await FireStoreT.getItemsStream();
     await FireStoreT.initStreamCtMeta();

     await FireStoreT.initStreamCSMeta();
     await FireStoreT.initStreamContract();

     await FireStoreT.initStreamTsMeta();
     await FireStoreT.initStreamPuMeta();

     await FireStoreT.initStreamReMeta();

     //await FireStoreT.initStreamTs();
     //await FireStoreT.initStreamPurchase();
     //await FireStoreT.initStreamRevenue();
     //await ProductSystem.init();

     await EmployeeSystem.init();
     await UserSystem.init();
  }

  static initREPU() {
    revpur.clear();
    for(var p in purchase.values) revpur.add(RevPur.fromDatabase(pu: p));
    for(var r in revenue.values) revpur.add(RevPur.fromDatabase(re: r));

    revpur.sort((a, b) {
      if(a.dateAt < b.dateAt) return 1;
      if(a.dateAt > b.dateAt) return -1;
      else return 0;
    });
  }

  static dynamic searchItem(String search, List<Item> sort) async {
    searchText = search.trim();
    List<Item> searchs = [];
    late RegExp regExp;
    try {
      regExp = getRegExp(searchText, RegExpOptions(initialSearch: true, startsWith: false, endsWith: false));
    } catch (e) {
      print(e);
      return sort;
    }
    var searchTmp = await sort.where((e) => regExp.hasMatch(e.name + ' ' + e.memo)).toList() ?? [];
    searchs.addAll(searchTmp);
    return searchs;
  }

  static Map<dynamic, dynamic> getAccountDropMenu() {
    var data = {};
    accounts.forEach((key, value) {
      data[key] = value.name;
    });
    return data;
  }
  static dynamic getAccount(String id) {
    return accounts[id];
  }
  static dynamic getAccountName(String id) {
    var data = accounts[id];
    if(data == null) return id;
    return data.name;
  }

  static dynamic searchCSMeta(String search) async {
    searchText = search.trim();
    List<Customer> searchs = [];
    late RegExp regExp;
    try {
      regExp = getRegExp(searchText, RegExpOptions(initialSearch: true, startsWith: false, endsWith: false));
    } catch (e) {
      print(e); return [];
    }
    var searchKey = [];
    customerSearch.forEach((k, e) {
     if(regExp.hasMatch(e)) searchKey.add(k);
    });
    print(searchKey);

    if(searchKey.length > 25) searchKey = searchKey.sublist(0, 25);
    for(var s in searchKey) {
      var a = await FireStoreT.getCustomerDoc(s);
      if(a != null) searchs.add(a);
    }

    return searchs;
  }
  static dynamic searchCTMeta(String search) async {
    searchText = search.trim();
    List<Contract> searchs = [];
    late RegExp regExp;
    try {
      regExp = getRegExp(searchText, RegExpOptions(initialSearch: true, startsWith: false, endsWith: false));
    } catch (e) {
      print(e); return [];
    }
    var searchKey = [];
    for(var a in contractSearch.values) {
      if(searchKey.length > 25) break;
      var meta = a as Map;
      meta.forEach((k, e) {
        if(regExp.hasMatch(e)) searchKey.add(k);
      });
    }
    print('contract search res');
    print(searchKey);

    if(searchKey.length > 25) searchKey = searchKey.sublist(0, 25);
    for(var s in searchKey) {
      var a = await FireStoreT.getContractDoc(s);
      if(a != null) searchs.add(a);
    }

    return searchs;
  }
  static dynamic searchTSMeta(String search, { String? startAt, String? lastAt }) async {
    searchText = search.trim();
    List<TS> searchs = [];
    if(searchText == '') return searchs;

    late RegExp regExp;
    try {
      regExp = getRegExp(searchText, RegExpOptions(initialSearch: true, startsWith: false, endsWith: false));
    } catch (e) {
      print(e); return [];
    }

    List<SortKey> searchMap = [];
    transactionSearch.forEach((k, e) {
      if(searchMap.length > 25) return;
      if(e == null) return;

      if(regExp.hasMatch(e.toString())) {
        var sort = SortKey();
        sort.id = k;
        try {
          sort.data = e.toString().split('&:')[3];
        } catch (e) {
          sort.data = '';
        }
        if(startAt != null)
          if(sort.data.compareTo(startAt) < 0) return;

        searchMap.add(sort);
      }
    });

    searchMap.sort((a, b) => b.data.compareTo(a.data));

    if(searchMap.length > 25) searchMap = searchMap.sublist(0, 25);
    for(var s in searchMap) {
      var a = await FireStoreT.getTsDoc(s.id);
      if(a != null) searchs.add(a);
    }

    return searchs;
  }


  static dynamic searchPuMeta(String search) async {
    searchText = search.trim();
    List<Purchase> searchs = [];
    late RegExp regExp;
    try {
      regExp = getRegExp(searchText, RegExpOptions(initialSearch: true, startsWith: false, endsWith: false));
    } catch (e) {
      print(e); return [];
    }
    var searchKey = [];
    for(var a in purSearch.values) {
      if(searchKey.length > 25) break;
      var meta = a as Map;
      meta.forEach((k, e) {
        if(e != null)
          if(regExp.hasMatch(e)) searchKey.add(k);
      });
    }
    print('purchase search res');
    print(searchKey);

    if(searchKey.length > 25) searchKey = searchKey.sublist(0, 25);
    for(var s in searchKey) {
      var a = await FireStoreT.getPurchaseDoc(s);
      if(a != null) searchs.add(a);
    }

    return searchs;
  }
  static dynamic searchReMeta(String search) async {
    searchText = search.trim();
    List<Revenue> searchs = [];
    late RegExp regExp;
    try {
      regExp = getRegExp(searchText, RegExpOptions(initialSearch: true, startsWith: false, endsWith: false));
    } catch (e) {
      print(e); return [];
    }
    var searchKey = [];
    for(var a in revSearch.values) {
      if(searchKey.length > 25) break;
      var meta = a as Map;
      meta.forEach((k, e) {
        if(e != null) if(regExp.hasMatch(e)) searchKey.add(k);
      });
    }
    print('res search res');
    print(searchKey);

    if(searchKey.length > 25) searchKey = searchKey.sublist(0, 25);
    for(var s in searchKey) {
      Revenue? rev = await FireStoreT.getResDoc(s);
      if(rev != null) searchs.add(rev);
    }

    return searchs;
  }
  static dynamic searchItMeta(String search,) async {
    searchText = search.trim();
    List<Item> searchs = [];
    late RegExp regExp;
    try {
      regExp = getRegExp(searchText, RegExpOptions(initialSearch: true, startsWith: false, endsWith: false));
    } catch (e) {
      print(e);
      return searchs;
    }
    var searchTmp = await itemMaps.values.where((e) => regExp.hasMatch(e.name + ' ' + e.memo)).toList() ?? [];
    searchs.addAll(searchTmp);
    return searchs;
  }


  static dynamic searchCT(String search, List<Contract> sort) async {
    searchText = search.trim();
    List<Contract> searchs = [];
    late RegExp regExp;
    try {
      regExp = getRegExp(searchText, RegExpOptions(initialSearch: true, startsWith: false, endsWith: false));
    } catch (e) {
      print(e);
      return sort;
    }
    var searchTmp = await sort.where((e) => regExp.hasMatch(e.ctName + ' ' + e.manager + ' ' + e.managerPhoneNumber + ' ' + e.purchasingDepartment ?? '')).toList() ?? [];
    searchs.addAll(searchTmp);
    return searchs;
  }
  static dynamic getInventoryItemCount(String id) {
    var data = inventory[id];
    if(data == null) return 0;
    return data.count ?? 0;
  }

  static Contract? getCt(String id) {
    var data = contractMap[id];
    return data;
  }
  static Future<Customer> getCS(String id) async {
    Customer? data = customers[id];
    customers[id] ??= data ??= await FireStoreT.getCustomerDoc(id);
    return data ?? Customer.fromDatabase({});
  }
  static String getCSName(String id) {
    var data = customers[id];
    return (data == null) ? '' : data.businessName;
  }

  static Item? getItem(String id) {
    var item = itemMaps[id];
    return item;
  }
  static int getItemUnitPrice(String id) {
    var item = itemMaps[id];
    if(item == null) return 0;
    return item.unitPrice ?? 0;
  }
  static String getItemUnit(String id) {
    var item = itemMaps[id];
    if(item == null) return '';
    return item.unit ?? '';
  }
  static String getItemName(String id) {
    var item = itemMaps[id];
    if(item == null) return id;
    return item.name ?? id;
  }

  static String generateRandomString(int len) {
    var r = Random();
    //const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    const _chars = '0123456789';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
  }
}

class MetaT {
  static Map<dynamic, dynamic> itemGroup = {
    '1': '품목그룹분류1',
    '2': '품목그룹분류2',
    '3': '품목그룹분류3',
    '4': '품목그룹분류4',
    '5': '품목그룹분류5',
    '6': '품목그룹분류6',
    '7': '품목그룹분류7',
    '8': '품목그룹분류8',
    '9': '품목그룹분류9',
    '10': '품목그룹분류10',
  };
  static var itemType = {
    'PU': '원자재',
    'RE': '생산품',
    'ETC': '기타',
  };
  static var itemTsType = {
    'PU': '매입',
    'RE': '매출',
    'PR': '생산',
    'FC': '투입',
    'ETC': '기타',
  };

  static var schTypeName = {
    '0': '기타',
    '1': '운송',
    '2': '개인',
    '3': '발주',
    '4': '통화메모',
    '5': '마감',
  };
  static var schTypeColor = {
    '0': Color(0xff293742),
    '1': Color(0xffFFDC95),
    '2': Color(0xffD98BA0),
    '3': Color(0xff197B9A),
    '4': Color(0xff05ACF2),
    '5': Color(0xffF25A38),
  };

}

class SortKey {
  var id = '';
  var data = '';
  SortKey() {}
  SortKey.fromData(Map) {
  }
}