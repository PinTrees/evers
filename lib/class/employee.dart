
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/helper/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import '../helper/firebaseCore.dart';
import '../helper/function.dart';
import 'Customer.dart';
import 'contract.dart';
import 'revenue.dart';
import 'system.dart';

class Employee {
  var id = '';
  var name = '';
  var group = '';       /// 소속부서
  var rank = '';        /// 직급
  var workType = '';    /// 근무유형 [ 정규직, 계약직, 아르바이트, 기타 ]

  List<dynamic> rrn = [ '', '' ];         /// 주민등록번호
  var phoneNum = '';     /// 전화번호
  var mobileNum = '';     /// 휴대폰번호
  var email = '';
  var address = '';
  var memo = '';
  var personnelRecord = '';     /// 인사기록정보

  var joinAt = 0;         /// 입사일
  var leaveAt = 0;        /// 퇴사일

  var payType = '';       /// [ 월급, 일급, 시급 ]
  var payM = 0, payD = 0, payH = 0;

  /// 계좌 정보
  AccountT account = AccountT.fromDatabase({});
  /// 보험 및 대상자 확인
  Insurance insurance = Insurance.fromDatabase({});
  EmPayment payment = EmPayment.fromDatabase({});
  
  var deductionHI = 0;        /// 건깅보험 공제
  var deductionNP = 0;        /// 국민연금 공제

  var filesMap = {};
  var filesDetail = {};

  Employee.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    group = json['group'] ?? '';
    rank = json['rank'] ?? '';
    workType = json['workType'] ?? '';

    rrn = (json['rrn'] == null) ? [ '', '' ] : json['rrn'] as List;
    phoneNum = json['phoneNum'] ?? '';
    mobileNum = json['mobileNum'] ?? '';
    email = json['email'] ?? '';
    address = json['address'] ?? '';
    memo = json['memo'] ?? '';
    personnelRecord = json['personnelRecord'] ?? '';

    joinAt = json['joinAt'] ?? 0;
    leaveAt = json['leaveAt'] ?? 0;

    payType = json['payType'] ?? '';
    payM = json['payM'] ?? 0; payD = json['payD'] ?? 0; payH = json['payH'] ?? 0;

    account = (json['account'] == null) ? AccountT.fromDatabase({}) : AccountT.fromDatabase(json['account'] as Map);
    insurance = (json['insurance'] == null) ? Insurance.fromDatabase({}) : Insurance.fromDatabase(json['account'] as Map);
    payment = (json['payment'] == null) ? EmPayment.fromDatabase({}) : EmPayment.fromDatabase(json['account'] as Map);

    deductionHI = json['deductionHI'] ?? 0;
    deductionNP = json['deductionNP'] ?? 0;

    filesMap = (json['filesMap'] == null) ? {} : json['filesMap'] as Map;
    filesDetail = (json['filesDetail'] == null) ? {} : json['filesDetail'] as Map;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'group': group, 'rank': rank,
      'workType': workType,

      'rrn': rrn,
      'phoneNum': phoneNum,
      'mobileNum': mobileNum,
      'email': email,
      'address': address,
      'memo': memo,
      'personnelRecord': personnelRecord,

      'joinAt': joinAt, 'leaveAt': leaveAt,
      'payType': payType,
      'payM': payM, 'payD': payD, 'payH': payH,

      'account': account.toJson(),
      'insurance': insurance.toJson(),
      'payment': payment.toJson(),

      'deductionHI': deductionHI, 'deductionNP': deductionNP,
      'filesMap': filesMap as Map,
      'filesDetail': filesDetail as Map,
    };
  }

  void setPay(int pay) {
    if(payType == 'M') payM = pay;
    else if(payType == 'D') payD = pay;
    else if(payType == 'H') payH = pay;
  }
  int getPay() {
    if(payType == 'M') return payM;
    else if(payType == 'D') return payD;
    else if(payType == 'H') return payH;
    return 0;
  }
  String getMaskingRRN() {
    var count = rrn[1].toString().length;
    return '*' * count;
  }
  String getFileName(String code) {
    var file = filesDetail[code];
    if(file == null) return code;
    return file['name'] ?? code;
  }
}

class EmployeeSystem {
  static Map<dynamic, Employee> stream = {};
  static Map<dynamic, Attendance> attStream = {};

  static var searchText = '';

  static dynamic init() async {
    await initStream();
  }
  static dynamic initStream() async {
    CollectionReference coll = await FirebaseFirestore.instance.collection('employee');
    await coll.orderBy('joinAt', descending: true).limit(50).snapshots().listen((value) {
      print('employee stream data');
      if(value.docs == null) return;
      print(value.docs.length);

      for(var a in value.docs) {
        if(a.data() == null) continue;
        var em = Employee.fromDatabase(a.data() as Map);
        stream[em.id] = em;
      }
      FunT.setStateMain();
    });

    await FirebaseFirestore.instance.collection('meta/date-m/attendance').limit(50).snapshots().listen((value) {
      print('att stream data');
      if(value.docs == null) return;
      print(value.docs.length);

      for(var a in value.docs) {
        if(a.data() == null) continue;
        if(a.data()['list'] == null) continue;
        Map<dynamic, dynamic> list = a.data()['list'] as Map;
        for(var l in list.keys) {
          var em = Attendance.fromDatabase(list[l] as Map);
          attStream[em.id] = em;
        }
      }
      FunT.setStateMain();
    });
  }




  static dynamic updateAttendance(Attendance data, DateTime date) async {
    if(data.id == '') data.id = data.uid + ':' + StyleT.dateFormat(date);
    var dateID = StyleT.dateFormatM(date);

    await FireStoreHub.docUpdate('attendance/${data.id}', 'AT.PATCH', data.toJson(),);
    await FireStoreHub.docUpdate('meta/date-m/attendance/${dateID}', 'AT-Date.PATCH', { 'list\.${data.id}': data.toJson(), 'updateAt': FieldValue.serverTimestamp(), },
      setJson: { 'list': { data.id: data.toJson(), }, 'updateAt': FieldValue.serverTimestamp(), },
    );
  }
}

class AccountT {
  var bank = '';
  var holder = '';
  var number = '';

  AccountT.fromDatabase(Map<dynamic, dynamic> json) {
    bank = json['bank'] ?? '';
    holder = json['holder'] ?? '';
    number = json['number'] ?? '';
  }
  Map<String, dynamic> toJson() {
    return {
      'bank': bank,
      'holder': holder,
      'number': number,
    };
  }
}
class Insurance {
  var isEmploymentInsurance = true;         /// 고용보험
  var isElderlyInsuranceReduction = true;   /// 노인보험감면
  var isIncomeTax = true;                   /// 소득세
  var isJobClassification = true;           /// 직종구분
  var isResidenceClassification = true;     /// 거주구분

  Insurance.fromDatabase(Map<dynamic, dynamic> json) {
    isEmploymentInsurance = json['isEmploymentInsurance'] ?? true;
    isElderlyInsuranceReduction = json['isElderlyInsuranceReduction'] ?? true;
    isIncomeTax = json['isIncomeTax'] ?? true;
    isJobClassification = json['isJobClassification'] ?? true;
    isResidenceClassification = json['isResidenceClassification'] ?? true;
  }
  Map<String, dynamic> toJson() {
    return {
      'isEmploymentInsurance': isEmploymentInsurance,
      'isElderlyInsuranceReduction': isElderlyInsuranceReduction,
      'isIncomeTax': isIncomeTax,
      'isJobClassification': isJobClassification,
      'isResidenceClassification': isResidenceClassification,
    };
  }
}
class EmPayment {
  var payRank = 0;        /// 직급수당
  var payLate = 0;        /// 만근수당
  var payVehicleSp = 0;   /// 차량지원비
  var payMeal = 0;        /// 식대

  EmPayment.fromDatabase(Map<dynamic, dynamic> json) {
    payRank = json['payRank'] ?? 0;
    payLate = json['payLate'] ?? 0;
    payVehicleSp = json['payVehicleSp'] ?? 0;
    payMeal = json['payMeal'] ?? 0;
  }
  Map<String, dynamic> toJson() {
    return {
      'payRank': payRank,
      'payLate': payLate,
      'payVehicleSp': payVehicleSp,
      'payMeal': payMeal,
    };
  }
}


class BankList {
  static var list = [
    '신한', '국민', '우리', '기업', '농협', '하나', '외환'
  ];
}

class Attendance {
  var id = '';
  var uid = '';
  var type = [];  /// [ 1, 2, 3, 4, 5, 6, 7 ] [ 출근, 지각, 조퇴, 결근, 외출, 휴가, 연장근무 ]

  var startAt = 0;      /// 근무 시작시각
  var leaveAt = 0;      /// 근무 종료시각

  var moreStartAt = 0;  /// 연장근무 시작시각
  var moreLeaveAt = 0;  /// 연장근무 종료시각

  Attendance.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    uid = json['uid'] ?? '';
    type = (json['type'] == null) ?  [] : json['type'] as List;
    startAt = json['startAt'] ?? 0;
    leaveAt = json['leaveAt'] ?? 0;
    moreStartAt = json['moreStartAt'] ?? 0;
    moreLeaveAt = json['moreLeaveAt'] ?? 0;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'type': type as List,
      'startAt': startAt,
      'leaveAt': leaveAt,
      'moreStartAt': moreStartAt,
      'moreLeaveAt': moreLeaveAt,
    };
  }

  String getThumbnailText() {
    if(type.length > 0) {
       return AttendanceType.type[type.first] ?? '';
    }
    return '';
  }
}
class AttendanceType {
  static var type = {
    '1': '출근', '2': '지각', '3': '조퇴', '4': '결근', '5': '외출', '6': '휴가', '7': '연장근무',
  };
}