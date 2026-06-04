import 'package:member_card_app/shared/services/api_client.dart';

/// 充值仓库 - 处理充值记录相关 API
class RechargeRepository {
  final ApiClient _api = ApiClient.instance;

  /// 获取充值记录列表
  Future<List<dynamic>> getRechargeRecords({int? memberId}) async {
    final params = <String, dynamic>{};
    if (memberId != null) params['member_id'] = memberId;
    final resp = await _api.get('/recharge-records', params: params);
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as List<dynamic>;
    }
    throw Exception(data['message'] ?? '获取充值记录失败');
  }
}
