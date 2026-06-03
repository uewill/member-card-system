import 'package:dio/dio.dart';
import 'package:member_card_app/shared/services/api_client.dart';

/// 会员数据仓库 - 封装会员相关 API 调用
class MemberRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// 获取会员首页概览数据
  Future<Map<String, dynamic>> getMemberOverview() async {
    final response = await _apiClient.get('/member/overview');
    return response.data['data'];
  }

  /// 获取会员卡包列表
  Future<List<Map<String, dynamic>>> getCardList() async {
    final response = await _apiClient.get('/member/cards');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  /// 获取消费记录列表（按时间倒序）
  Future<List<Map<String, dynamic>>> getConsumeRecords({
    int page = 1,
    int size = 20,
    String? startDate,
    String? endDate,
  }) async {
    final response = await _apiClient.get('/member/consume-records', params: {
      'page': page,
      'size': size,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    return List<Map<String, dynamic>>.from(response.data['data']['records']);
  }

  /// 获取消费记录详情
  Future<Map<String, dynamic>> getConsumeDetail(Long orderId) async {
    final response = await _apiClient.get('/member/consume-records/$orderId');
    return response.data['data'];
  }

  /// 获取可购买的套餐列表
  Future<List<Map<String, dynamic>>> getPackageList() async {
    final response = await _apiClient.get('/member/packages');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  /// 获取套餐详情
  Future<Map<String, dynamic>> getPackageDetail(Long templateId) async {
    final response = await _apiClient.get('/member/packages/$templateId');
    return response.data['data'];
  }

  /// 创建购买套餐订单
  Future<Map<String, dynamic>> createPurchaseOrder({
    required Long templateId,
    required Long storeId,
    required String paymentMethod,
  }) async {
    final response = await _apiClient.post('/member/purchase', data: {
      'templateId': templateId,
      'storeId': storeId,
      'paymentMethod': paymentMethod,
    });
    return response.data['data'];
  }

  /// 查询支付状态
  Future<Map<String, dynamic>> queryPaymentStatus(String orderNo) async {
    final response = await _apiClient.get('/member/payment-status/$orderNo');
    return response.data['data'];
  }

  /// 获取会员个人信息
  Future<Map<String, dynamic>> getMemberProfile() async {
    final response = await _apiClient.get('/member/profile');
    return response.data['data'];
  }

  /// 更新会员个人信息
  Future<void> updateMemberProfile(Map<String, dynamic> profile) async {
    await _apiClient.put('/member/profile', data: profile);
  }

  /// 获取消息通知列表
  Future<List<Map<String, dynamic>>> getNotifications({
    int page = 1,
    int size = 20,
  }) async {
    final response = await _apiClient.get('/member/notifications', params: {
      'page': page,
      'size': size,
    });
    return List<Map<String, dynamic>>.from(response.data['data']['records']);
  }

  /// 标记消息已读
  Future<void> markNotificationRead(Long notificationId) async {
    await _apiClient.put('/member/notifications/$notificationId/read');
  }

  /// 获取会员二维码（用于出示给员工扫码）
  Future<Map<String, dynamic>> getMemberQrCode() async {
    final response = await _apiClient.get('/member/qrcode');
    return response.data['data'];
  }

  /// 获取充值赠送规则
  Future<List<Map<String, dynamic>>> getGiftRules() async {
    final response = await _apiClient.get('/member/gift-rules');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  /// 创建充值订单
  Future<Map<String, dynamic>> createRechargeOrder({
    required Long cardId,
    required double amount,
    required String paymentMethod,
  }) async {
    final response = await _apiClient.post('/member/recharge', data: {
      'cardId': cardId,
      'amount': amount,
      'paymentMethod': paymentMethod,
    });
    return response.data['data'];
  }
}
