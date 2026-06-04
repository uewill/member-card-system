import 'package:flutter/material.dart';
import '../services/api/member_repository.dart';

/// 会员状态管理 Provider
class MemberProvider extends ChangeNotifier {
  final MemberRepository _repo = MemberRepository();
  List<dynamic> _members = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载会员列表
  Future<void> loadMembers({String? query}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _members = await _repo.getMembers(query: query);
    } catch (e) {
      _error = e.toString();
      debugPrint('加载会员失败: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  /// 搜索会员（防抖可在外层实现）
  Future<void> searchMembers(String query) async {
    await loadMembers(query: query);
  }
}
