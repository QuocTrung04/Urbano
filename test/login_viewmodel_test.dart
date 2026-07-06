import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/ViewModels/auth/login_viewmodel.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('login với input rỗng trả về false và có error', () async {
    final viewModel = LoginViewmodel();
    final result = await viewModel.login('', '');
    expect(result, isFalse);
    expect(viewModel.error, 'Vui lòng nhập đầy đủ thông tin');
  });

  test('login với tài khoản sai trả về false', () async {
    final viewModel = LoginViewmodel();
    final result = await viewModel.login('wrong_user', 'wrong_pass');
    expect(result, isFalse);
    expect(viewModel.error, 'Sai tài khoản hoặc mật khẩu');
  });
}
