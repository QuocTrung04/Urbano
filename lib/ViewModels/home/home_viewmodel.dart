import 'package:flutter/material.dart';
import 'package:urbano/Services/home/home_services.dart';
import 'package:urbano/Models/home/home_model.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeServices _services = HomeServices();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  HomeData? _data;
  HomeData? get data => _data;

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _services.fetchHomeData();
    } catch (e) {
      _error = 'Không tải được dữ liệu, vui lòng thử lại';
    }
    _isLoading = false;
    notifyListeners();
  }
}
