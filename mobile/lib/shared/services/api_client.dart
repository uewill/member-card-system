import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:member_card_app/core/config/app_config.dart';
import 'mock_data_service.dart';
import 'auth_service.dart';

/// API 客户端 - 支持真实 API 调用，失败时 fallback 到 Mock 数据
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  late final Dio _dio;
  final MockDataService _mockService = MockDataService.instance;

  /// 是否优先使用真实 API（设为 false 则始终使用 Mock）
  bool useRealApi = true;

  /// 是否启用 Mock fallback（真实 API 失败时回退到 Mock）
  bool enableMockFallback = false;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 请求拦截器：自动添加 Token 和 tenant_id
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = AuthService.instance.token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          AuthService.instance.logout();
        }
        debugPrint('API Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  /// 初始化（在 main() 中调用）
  void init() {
    // 预初始化 Dio 实例
    debugPrint('ApiClient initialized, baseUrl: ${AppConfig.apiBaseUrl}');
    debugPrint('ApiClient useRealApi: $useRealApi, enableMockFallback: $enableMockFallback');
  }

  /// 获取底层 Dio 实例（供 Repository 层直接使用）
  Dio get dio => _dio;

  /// 设置 Token
  void setToken(String token) {
    AuthService.instance.login(token);
  }

  /// 设置租户 ID
  void setTenantId(String tenantId) {
    // 存储在 Dio 默认参数中
    _dio.options.queryParameters['tenant_id'] = tenantId;
  }

  /// 清除认证信息
  void clearAuth() {
    AuthService.instance.logout();
    _dio.options.queryParameters.remove('tenant_id');
  }

  /// 是否已认证
  bool get isAuthenticated => AuthService.instance.isLoggedIn();

  // ============ 带自动 fallback 的请求方法 ============

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    if (!useRealApi) {
      return _mockGet(path, params: params);
    }
    try {
      return await _dio.get(path, queryParameters: params);
    } catch (e) {
      if (enableMockFallback) {
        debugPrint('API GET $path failed, falling back to mock: $e');
        return _mockGet(path, params: params);
      }
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    if (!useRealApi) {
      return _mockPost(path, data: data);
    }
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      if (enableMockFallback) {
        debugPrint('API POST $path failed, falling back to mock: $e');
        return _mockPost(path, data: data);
      }
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    if (!useRealApi) {
      return _mockPut(path, data: data);
    }
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      if (enableMockFallback) {
        debugPrint('API PUT $path failed, falling back to mock: $e');
        return _mockPut(path, data: data);
      }
      rethrow;
    }
  }

  Future<Response> delete(String path) async {
    if (!useRealApi) {
      return _mockDelete(path);
    }
    try {
      return await _dio.delete(path);
    } catch (e) {
      if (enableMockFallback) {
        debugPrint('API DELETE $path failed, falling back to mock: $e');
        return _mockDelete(path);
      }
      rethrow;
    }
  }

  // ============ Mock 请求方法 ============

  Future<Response> _mockGet(String path, {Map<String, dynamic>? params}) async {
    final result = _mockService.handleRequest('GET', path, data: params);
    await Future.delayed(const Duration(milliseconds: 300));
    return Response(
      requestOptions: RequestOptions(path: path),
      data: result,
      statusCode: result['code'] == 200 ? 200 : result['code'],
    );
  }

  Future<Response> _mockPost(String path, {dynamic data}) async {
    final result = _mockService.handleRequest('POST', path, data: data);
    await Future.delayed(const Duration(milliseconds: 300));
    return Response(
      requestOptions: RequestOptions(path: path),
      data: result,
      statusCode: result['code'] == 200 ? 200 : result['code'],
    );
  }

  Future<Response> _mockPut(String path, {dynamic data}) async {
    final result = _mockService.handleRequest('PUT', path, data: data);
    await Future.delayed(const Duration(milliseconds: 300));
    return Response(
      requestOptions: RequestOptions(path: path),
      data: result,
      statusCode: result['code'] == 200 ? 200 : result['code'],
    );
  }

  Future<Response> _mockDelete(String path) async {
    final result = _mockService.handleRequest('DELETE', path);
    await Future.delayed(const Duration(milliseconds: 300));
    return Response(
      requestOptions: RequestOptions(path: path),
      data: result,
      statusCode: result['code'] == 200 ? 200 : result['code'],
    );
  }
}
