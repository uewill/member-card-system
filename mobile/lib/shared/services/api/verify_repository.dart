import 'package:member_card_app/shared/services/api_client.dart';

/// 核销记录仓库 - 处理核销记录相关 API
class VerifyRepository {
  final ApiClient _api = ApiClient.instance;

  /// 获取核销记录列表
  Future<List<dynamic>> getVerifyRecords({int? memberId}) async {
    final params = <String, dynamic>{};
    if (memberId != null) params['member_id'] = memberId;
    final resp = await _api.get('/verify-records', params: params);
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as List<dynamic>;
    }
    throw Exception(data['message'] ?? '获取核销记录失败');
  }
}
