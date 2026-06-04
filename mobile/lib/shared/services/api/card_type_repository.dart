import 'package:member_card_app/shared/services/api_client.dart';

/// 卡类型仓库 - 处理卡类型相关 API
class CardTypeRepository {
  final ApiClient _api = ApiClient.instance;

  /// 获取卡类型列表
  Future<List<dynamic>> getCardTypes() async {
    final resp = await _api.get('/card-types');
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as List<dynamic>;
    }
    throw Exception(data['message'] ?? '获取卡类型列表失败');
  }
}
