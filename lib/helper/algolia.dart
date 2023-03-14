import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as en;

import '../class/Customer.dart';
import '../class/revenue.dart';
import '../class/schedule.dart';
import '../class/system.dart';
import '../class/transaction.dart';
import 'function.dart';

class Algolia {
  static final contractSearch = HitsSearcher(
    applicationID: 'NPJYQ36957',
    apiKey: '1b03dbd461c435d42f4547c1161d0762',
    indexName: 'contract',
  );
  static dynamic initSearchContract() async {
    contractSearch.responses.listen((event) async {
      final hits = event?.hits.toList() ?? [];
      List<Contract> contracts = [];
      for(var h in hits) {
        var c = await FireStoreT.getContractDoc(h['objectID']);
        contracts.add(c);
      }
      SystemT.searchCt = contracts.toList();
      FunT.setStateMain();
    });
  }
}

