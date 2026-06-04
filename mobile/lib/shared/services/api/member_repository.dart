import 'package:member_card_app/shared/services/api_client.dart';

/// 会员仓库 - 处理会员相关 API
class MemberRepository {
  final ApiClient _api = ApiClient.instance;

  /// 获取会员列表
  Future<List<dynamic>> getMembers({String? query}) async {
    final params = <String, dynamic>{};
    if (query != null && query.isNotEmpty) params['q'] = query;
    final resp = await _api.get('/members', params: params);
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as List<dynamic>;
    }
    throw Exception(data['message'] ?? '获取会员列表失败');
  }

  /// 获取会员详情
  Future<Map<String, dynamic>> getMemberDetail(int id) async {
    final resp = await _api.get('/members/$id');
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception(data['message'] ?? '获取会员详情失败');
  }

  /// 创建会员
  Future<Map<String, dynamic>> createMember(Map<String, dynamic> data) async {
    final resp = await _api.post('/members', data: data);
    final result = resp.data;
    if (result['code'] == 200) {
      return result['data'] as Map<String, dynamic>;
    }
    throw Exception(result['message'] ?? '创建会员失败');
  }
}
