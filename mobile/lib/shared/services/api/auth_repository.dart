import 'package:member_card_app/shared/services/api_client.dart';

/// 认证仓库 - 处理登录/登出逻辑
class AuthRepository {
  final ApiClient _api = ApiClient.instance;

  /// 登录
  Future<Map<String, dynamic>> login(String username, String password) async {
    final resp = await _api.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    final data = resp.data;
    if (data['code'] == 200) {
      final result = data['data'] as Map<String, dynamic>;
      // 保存 Token 到本地
      _api.setToken(result['token'] as String);
      // 设置租户 ID
      if (result['storeId'] != null) {
        _api.setTenantId(result['storeId'].toString());
      }
      return result;
    } else {
      throw Exception(data['message'] ?? '登录失败');
    }
  }

  /// 登出
  void logout() {
    _api.clearAuth();
  }

  /// 是否已认证
  bool get isAuthenticated => _api.isAuthenticated;
}
