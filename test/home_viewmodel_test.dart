import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/ViewModels/home/home_viewmodel.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loadData thay đổi isLoading', () async {
    final viewModel = HomeViewModel();
    expect(viewModel.isLoading, false);
    final future = viewModel.loadData();
    expect(viewModel.isLoading, true);
    await future;
    expect(viewModel.isLoading, false);
  });
}
