import 'dart:convert';
import 'dart:math';

/// Mock 数据服务 - 提供完整的测试数据
class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  static MockDataService get instance => _instance;
  
  MockDataService._internal();
  
  // 当前登录用户
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;
  
  // 模拟登录
  Map<String, dynamic> login(String username, String password) {
    if (username == 'admin' && password == '123456') {
      _currentUser = {
        'id': 1,
        'username': 'admin',
        'realName': '管理员',
        'role': 'ADMIN',
        'storeId': 1,
        'storeName': '总店',
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      };
      return {
        'code': 200,
        'data': _currentUser,
        'message': '登录成功',
      };
    } else if (username == 'staff' && password == '123456') {
      _currentUser = {
        'id': 2,
        'username': 'staff',
        'realName': '张美容',
        'role': 'STAFF',
        'storeId': 1,
        'storeName': '总店',
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      };
      return {
        'code': 200,
        'data': _currentUser,
        'message': '登录成功',
      };
    } else if (username == 'member' && password == '123456') {
      _currentUser = {
        'id': 3,
        'username': 'member',
        'realName': '李会员',
        'role': 'MEMBER',
        'memberId': 1,
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      };
      return {
        'code': 200,
        'data': _currentUser,
        'message': '登录成功',
      };
    }
    return {
      'code': 401,
      'message': '用户名或密码错误',
    };
  }
  
  // 获取会员卡列表（会员视角）
  Map<String, dynamic> getMemberCards() {
    return {
      'code': 200,
      'data': [
        {
          'id': 1,
          'cardNo': 'MC20240001',
          'memberName': '李会员',
          'cardType': 'TIMES',
          'cardTypeName': '次卡',
          'totalTimes': 20,
          'remainTimes': 15,
          'balance': 0,
          'validStartDate': '2024-01-01',
          'validEndDate': '2024-12-31',
          'status': 'ACTIVE',
          'packageName': '面部护理套餐',
        },
        {
          'id': 2,
          'cardNo': 'MC20240002',
          'memberName': '李会员',
          'cardType': 'BALANCE',
          'cardTypeName': '储值卡',
          'totalTimes': 0,
          'remainTimes': 0,
          'balance': 2580.00,
          'validStartDate': '2024-01-01',
          'validEndDate': '2025-01-01',
          'status': 'ACTIVE',
          'packageName': 'VIP储值卡',
        },
        {
          'id': 3,
          'cardNo': 'MC20240003',
          'memberName': '李会员',
          'cardType': 'HYBRID',
          'cardTypeName': '混合卡',
          'totalTimes': 10,
          'remainTimes': 8,
          'balance': 500.00,
          'validStartDate': '2024-03-01',
          'validEndDate': '2024-09-01',
          'status': 'ACTIVE',
          'packageName': '综合护理卡',
        },
      ],
    };
  }
  
  // 获取消费记录
  Map<String, dynamic> getConsumeRecords() {
    return {
      'code': 200,
      'data': [
        {
          'id': 1,
          'orderNo': 'CO20240601001',
          'consumeTime': '2024-06-01 14:30:00',
          'serviceName': '面部深层清洁',
          'employeeName': '张美容',
          'consumeType': 'TIMES',
          'consumeTimes': 1,
          'consumeAmount': 0,
          'cardNo': 'MC20240001',
          'status': 'COMPLETED',
        },
        {
          'id': 2,
          'orderNo': 'CO20240528002',
          'consumeTime': '2024-05-28 10:15:00',
          'serviceName': '精油按摩',
          'employeeName': '王技师',
          'consumeType': 'BALANCE',
          'consumeTimes': 0,
          'consumeAmount': 298.00,
          'cardNo': 'MC20240002',
          'status': 'COMPLETED',
        },
        {
          'id': 3,
          'orderNo': 'CO20240520003',
          'consumeTime': '2024-05-20 16:00:00',
          'serviceName': '美甲服务',
          'employeeName': '李美甲',
          'consumeType': 'HYBRID',
          'consumeTimes': 1,
          'consumeAmount': 50.00,
          'cardNo': 'MC20240003',
          'status': 'COMPLETED',
        },
      ],
    };
  }
  
  // 获取员工首页数据
  Map<String, dynamic> getStaffHomeData() {
    return {
      'code': 200,
      'data': {
        'todayStats': {
          'serviceCount': 8,
          'serviceAmount': 1680.00,
          'newMembers': 2,
          'rechargeAmount': 5000.00,
        },
        'pendingTasks': [
          {'type': 'verify', 'title': '待核销', 'count': 3},
          {'type': 'appointment', 'title': '今日预约', 'count': 5},
        ],
        'recentMembers': [
          {'id': 1, 'name': '李会员', 'phone': '138****8888', 'lastVisit': '10分钟前'},
          {'id': 2, 'name': '王会员', 'phone': '139****6666', 'lastVisit': '30分钟前'},
          {'id': 3, 'name': '张会员', 'phone': '137****9999', 'lastVisit': '1小时前'},
        ],
      },
    };
  }
  
  // 获取员工业绩
  Map<String, dynamic> getStaffPerformance(String period) {
    final data = {
      'day': {
        'serviceCount': 8,
        'serviceAmount': 1680.00,
        'commission': 168.00,
        'rank': 2,
      },
      'week': {
        'serviceCount': 45,
        'serviceAmount': 9800.00,
        'commission': 980.00,
        'rank': 3,
      },
      'month': {
        'serviceCount': 168,
        'serviceAmount': 36800.00,
        'commission': 3680.00,
        'rank': 2,
      },
    };
    return {
      'code': 200,
      'data': data[period] ?? data['day'],
    };
  }
  
  // 获取服务历史
  Map<String, dynamic> getServiceHistory() {
    return {
      'code': 200,
      'data': [
        {
          'id': 1,
          'time': '2024-06-01 14:30',
          'memberName': '李会员',
          'serviceName': '面部深层清洁',
          'amount': 198.00,
          'commission': 19.80,
        },
        {
          'id': 2,
          'time': '2024-06-01 11:00',
          'memberName': '王会员',
          'serviceName': '精油按摩',
          'amount': 298.00,
          'commission': 29.80,
        },
        {
          'id': 3,
          'time': '2024-05-31 16:30',
          'memberName': '张会员',
          'serviceName': '美甲服务',
          'amount': 128.00,
          'commission': 12.80,
        },
        {
          'id': 4,
          'time': '2024-05-31 10:00',
          'memberName': '李会员',
          'serviceName': '面部护理',
          'amount': 198.00,
          'commission': 19.80,
        },
      ],
    };
  }
  
  // 核销码验证
  Map<String, dynamic> verifyCode(String code) {
    if (code == '123456' || code.length == 6) {
      return {
        'code': 200,
        'data': {
          'valid': true,
          'memberName': '李会员',
          'cardNo': 'MC20240001',
          'serviceName': '面部深层清洁',
          'remainTimes': 15,
        },
      };
    }
    return {
      'code': 400,
      'message': '无效的核销码',
    };
  }
  
  // 执行核销
  Map<String, dynamic> consumeVerify(Map<String, dynamic> data) {
    return {
      'code': 200,
      'data': {
        'orderNo': 'CO${DateTime.now().millisecondsSinceEpoch}',
        'consumeTime': DateTime.now().toIso8601String(),
        'status': 'COMPLETED',
      },
      'message': '核销成功',
    };
  }
  
  // 获取套餐列表（购卡用）
  Map<String, dynamic> getPackages() {
    return {
      'code': 200,
      'data': [
        {
          'id': 1,
          'name': '面部护理套餐',
          'type': 'TIMES',
          'typeName': '次卡',
          'times': 20,
          'price': 1980.00,
          'originalPrice': 3960.00,
          'validityMonths': 12,
          'services': ['面部深层清洁', '面部按摩', '面膜护理'],
          'image': 'package_1.jpg',
        },
        {
          'id': 2,
          'name': 'VIP储值卡',
          'type': 'BALANCE',
          'typeName': '储值卡',
          'balance': 3000.00,
          'price': 2500.00,
          'originalPrice': 3000.00,
          'validityMonths': 12,
          'discount': 0.85,
          'image': 'package_2.jpg',
        },
        {
          'id': 3,
          'name': '综合护理卡',
          'type': 'HYBRID',
          'typeName': '混合卡',
          'times': 10,
          'balance': 1000.00,
          'price': 2880.00,
          'originalPrice': 4500.00,
          'validityMonths': 6,
          'services': ['面部护理', '身体按摩', '美甲'],
          'image': 'package_3.jpg',
        },
        {
          'id': 4,
          'name': '体验套餐',
          'type': 'TIMES',
          'typeName': '次卡',
          'times': 3,
          'price': 199.00,
          'originalPrice': 594.00,
          'validityMonths': 3,
          'services': ['面部清洁体验', '按摩体验'],
          'image': 'package_4.jpg',
        },
      ],
    };
  }
  
  // 创建订单
  Map<String, dynamic> createOrder(Map<String, dynamic> data) {
    return {
      'code': 200,
      'data': {
        'orderNo': 'RC${DateTime.now().millisecondsSinceEpoch}',
        'amount': data['amount'],
        'status': 'PENDING_PAYMENT',
        'createTime': DateTime.now().toIso8601String(),
      },
    };
  }
  
  // 模拟支付
  Map<String, dynamic> mockPayment(String orderNo) {
    return {
      'code': 200,
      'data': {
        'orderNo': orderNo,
        'status': 'PAID',
        'payTime': DateTime.now().toIso8601String(),
        'payMethod': 'WECHAT',
      },
      'message': '支付成功',
    };
  }
  
  // 获取会员信息
  Map<String, dynamic> getMemberInfo() {
    return {
      'code': 200,
      'data': {
        'id': 1,
        'name': '李会员',
        'phone': '138****8888',
        'avatar': 'avatar_1.jpg',
        'level': 'VIP',
        'points': 2580,
        'totalConsume': 15800.00,
        'joinDate': '2024-01-15',
        'lastVisit': '2024-06-01',
      },
    };
  }
  
  // 获取积分记录
  Map<String, dynamic> getPointsRecords() {
    return {
      'code': 200,
      'data': [
        {
          'id': 1,
          'type': 'EARN',
          'typeName': '消费获得',
          'points': 198,
          'description': '面部深层清洁消费',
          'createTime': '2024-06-01 14:30:00',
        },
        {
          'id': 2,
          'type': 'EARN',
          'typeName': '消费获得',
          'points': 298,
          'description': '精油按摩消费',
          'createTime': '2024-05-28 10:15:00',
        },
        {
          'id': 3,
          'type': 'USE',
          'typeName': '积分抵扣',
          'points': -100,
          'description': '抵扣现金10元',
          'createTime': '2024-05-20 16:00:00',
        },
        {
          'id': 4,
          'type': 'EARN',
          'typeName': '签到奖励',
          'points': 10,
          'description': '每日签到',
          'createTime': '2024-05-20 09:00:00',
        },
      ],
    };
  }
  
  // 搜索会员
  Map<String, dynamic> searchMember(String keyword) {
    final allMembers = [
      {'id': 1, 'name': '李会员', 'phone': '13800138888', 'cardNo': 'MC20240001'},
      {'id': 2, 'name': '王会员', 'phone': '13900136666', 'cardNo': 'MC20240005'},
      {'id': 3, 'name': '张会员', 'phone': '13700139999', 'cardNo': 'MC20240012'},
      {'id': 4, 'name': '刘会员', 'phone': '13600131111', 'cardNo': 'MC20240023'},
      {'id': 5, 'name': '陈会员', 'phone': '13500132222', 'cardNo': 'MC20240034'},
    ];
    
    final filtered = allMembers.where((m) => 
      (m['name'] as String).contains(keyword) || 
      (m['phone'] as String).contains(keyword) ||
      (m['cardNo'] as String).contains(keyword)
    ).toList();
    
    return {
      'code': 200,
      'data': filtered,
    };
  }
  
  // 通用路由处理
  Map<String, dynamic> handleRequest(String method, String path, {Map<String, dynamic>? data}) {
    switch ('$method $path') {
      case 'POST /auth/login':
        return login(data?['username'] ?? '', data?['password'] ?? '');
      case 'GET /member/cards':
        return getMemberCards();
      case 'GET /member/consume-records':
        return getConsumeRecords();
      case 'GET /member/info':
        return getMemberInfo();
      case 'GET /member/points-records':
        return getPointsRecords();
      case 'GET /staff/home':
        return getStaffHomeData();
      case 'GET /staff/performance':
        return getStaffPerformance(data?['period'] ?? 'day');
      case 'GET /staff/service-history':
        return getServiceHistory();
      case 'POST /consume/verify-code':
        return verifyCode(data?['code'] ?? '');
      case 'POST /consume/verify':
        return consumeVerify(data ?? {});
      case 'GET /packages':
        return getPackages();
      case 'POST /orders':
        return createOrder(data ?? {});
      case 'POST /payment/mock':
        return mockPayment(data?['orderNo'] ?? '');
      case 'GET /members/search':
        return searchMember(data?['keyword'] ?? '');
      default:
        return {'code': 404, 'message': '接口不存在: $method $path'};
    }
  }
}
