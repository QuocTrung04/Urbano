import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/ViewModels/yeu_cau_viewmodel.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('fetchYeuCaus thay đổi isLoading', () async {
    final viewModel = YeuCauViewModel();
    expect(viewModel.isLoading, false);
    final future = viewModel.loadData();
    expect(viewModel.isLoading, true);
    await future;
    expect(viewModel.isLoading, false);
  });
}
