class AppValidators {
  AppValidators._();

  /// Regex kiểm tra Email
  static final RegExp _emailRegExp = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  /// Regex kiểm tra SĐT Việt Nam (Bắt đầu bằng 03, 05, 07, 08, 09 hoặc +84)
  static final RegExp _phoneRegExp = RegExp(
    r'^(?:(?:\+84|0)[35789])[0-9]{8}$',
  );

  /// Regex kiểm tra CCCD (Đúng 12 số)
  static final RegExp _cccdRegExp = RegExp(
    r'^[0-9]{12}$',
  );

  /// Regex kiểm tra Biển số xe Việt Nam (VD: 30A-123.45, 51F-12345, 29A1-12345)
  static final RegExp _licensePlateRegExp = RegExp(
    r'^[0-9]{2}[A-Z0-9]{1,2}-?[0-9]{3,5}(\.[0-9]{2})?$',
    caseSensitive: false,
  );

  /// Kiểm tra Email
  static String? validateEmail(String? value, {bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return 'Vui lòng nhập email';
      return null;
    }
    final trimmed = value.trim();
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Email không đúng định dạng (VD: vidu@gmail.com)';
    }
    return null;
  }

  /// Kiểm tra Số điện thoại
  static String? validatePhone(String? value, {bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return 'Vui lòng nhập số điện thoại';
      return null;
    }
    final trimmed = value.trim();
    if (!_phoneRegExp.hasMatch(trimmed)) {
      return 'SĐT phải gồm 10 số hợp lệ (VD: 0912345678)';
    }
    return null;
  }

  /// Kiểm tra tài khoản Đăng nhập (SĐT hoặc Email)
  static String? validatePhoneOrEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập SĐT hoặc Email';
    }
    final trimmed = value.trim();
    final isEmail = _emailRegExp.hasMatch(trimmed);
    final isPhone = _phoneRegExp.hasMatch(trimmed);

    if (!isEmail && !isPhone) {
      return 'SĐT hoặc Email không hợp lệ';
    }
    return null;
  }

  /// Kiểm tra Căn cước công dân (CCCD)
  static String? validateCccd(String? value, {bool isRequired = false}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return 'Vui lòng nhập số CCCD';
      return null;
    }
    final trimmed = value.trim();
    if (!_cccdRegExp.hasMatch(trimmed)) {
      return 'Số CCCD phải gồm đúng 12 chữ số';
    }
    return null;
  }

  /// Kiểm tra Biển số xe
  static String? validateLicensePlate(String? value, {bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return 'Vui lòng nhập biển số xe';
      return null;
    }
    final trimmed = value.trim();
    if (!_licensePlateRegExp.hasMatch(trimmed)) {
      return 'Biển số không hợp lệ (VD: 30A-123.45)';
    }
    return null;
  }

  /// Kiểm tra Mật khẩu
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < minLength) {
      return 'Mật khẩu phải từ $minLength ký tự trở lên';
    }
    return null;
  }

  /// Kiểm tra bắt buộc nhập (Required text)
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }
}
