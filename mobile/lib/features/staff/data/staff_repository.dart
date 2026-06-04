import 'package:dio/dio.dart';
import 'package:member_card_app/shared/services/api_client.dart';

/// 员工数据仓库 - 封装员工相关 API 调用
class StaffRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// 获取员工今日业绩概览
  Future<Map<String, dynamic>> getTodayOverview() async {
    final response = await _apiClient.get('/staff/today-overview');
    return response.data['data'];
  }

  /// 获取业绩详情（支持日/周/月切换）
  Future<Map<String, dynamic>> getPerformance({
    required String period, // day, week, month
    String? date,
  }) async {
    final response = await _apiClient.get('/staff/performance', params: {
      'period': period,
      if (date != null) 'date': date,
    });
    return response.data['data'];
  }

  /// 获取服务历史列表
  Future<List<Map<String, dynamic>>> getServiceHistory({
    int page = 1,
    int size = 20,
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    final response = await _apiClient.get('/staff/service-history', params: {
      'page': page,
      'size': size,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (status != null) 'status': status,
    });
    return List<Map<String, dynamic>>.from(response.data['data']['records']);
  }

  /// 获取服务历史详情
  Future<Map<String, dynamic>> getServiceHistoryDetail(int orderId) async {
    final response = await _apiClient.get('/staff/service-history/$orderId');
    return response.data['data'];
  }

  /// 获取员工个人信息
  Future<Map<String, dynamic>> getStaffProfile() async {
    final response = await _apiClient.get('/staff/profile');
    return response.data['data'];
  }

  /// 获取业绩排行
  Future<List<Map<String, dynamic>>> getPerformanceRank({
    required String period,
    int limit = 10,
  }) async {
    final response = await _apiClient.get('/staff/performance-rank', params: {
      'period': period,
      'limit': limit,
    });
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  /// 获取客户列表（员工关联的客户）
  Future<List<Map<String, dynamic>>> getCustomerList({
    int page = 1,
    int size = 20,
    String? keyword,
  }) async {
    final response = await _apiClient.get('/staff/customers', params: {
      'page': page,
      'size': size,
      if (keyword != null) 'keyword': keyword,
    });
    return List<Map<String, dynamic>>.from(response.data['data']['records']);
  }

  /// 执行消费核销
  Future<Map<String, dynamic>> verifyConsume(Map<String, dynamic> consumeData) async {
    final response = await _apiClient.post('/staff/verify-consume', data: consumeData);
    return response.data['data'];
  }
}
