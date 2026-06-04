import 'package:member_card_app/shared/services/api_client.dart';

/// 优惠券仓库 - 处理优惠券相关 API
class CouponRepository {
  final ApiClient _api = ApiClient.instance;

  /// 获取优惠券列表
  Future<List<dynamic>> getCoupons() async {
    final resp = await _api.get('/marketing/coupons');
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as List<dynamic>;
    }
    throw Exception(data['message'] ?? '获取优惠券列表失败');
  }

  /// 创建优惠券
  Future<Map<String, dynamic>> createCoupon(Map<String, dynamic> data) async {
    final resp = await _api.post('/marketing/coupons', data: data);
    final result = resp.data;
    if (result['code'] == 200) {
      return result['data'] as Map<String, dynamic>;
    }
    throw Exception(result['message'] ?? '创建优惠券失败');
  }
}
