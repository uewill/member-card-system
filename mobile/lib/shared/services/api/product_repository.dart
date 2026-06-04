import 'package:member_card_app/shared/services/api_client.dart';

/// 商品仓库 - 处理商品相关 API
class ProductRepository {
  final ApiClient _api = ApiClient.instance;

  /// 获取商品列表
  Future<List<dynamic>> getProducts({String? category}) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    final resp = await _api.get('/products', params: params);
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as List<dynamic>;
    }
    throw Exception(data['message'] ?? '获取商品列表失败');
  }

  /// 创建商品
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    final resp = await _api.post('/products', data: data);
    final result = resp.data;
    if (result['code'] == 200) {
      return result['data'] as Map<String, dynamic>;
    }
    throw Exception(result['message'] ?? '创建商品失败');
  }
}
