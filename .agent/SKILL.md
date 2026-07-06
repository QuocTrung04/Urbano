---
name: urbano-cudan-flutter
description: >
  Quy tắc và công thức bắt buộc khi làm việc trên app Flutter Urbano bản CƯ DÂN.
  Kích hoạt skill này cho MỌI yêu cầu liên quan tới: sửa lỗi, thêm tính năng,
  refactor, cải thiện UI/UX, hoặc bất kỳ thay đổi nào trong dự án Flutter cư dân.
  Luôn đọc skill này TRƯỚC khi sinh code Dart.
---

# Skill: App Flutter Urbano — Bản Cư dân

Nguyên tắc số 1: **giữ nguyên mọi tính năng hiện có, chỉ sửa/cải thiện**.
KHÔNG xóa màn hình, KHÔNG đổi flow nghiệp vụ, KHÔNG đổi kiến trúc (MVVM + Provider
+ route-based navigation) trừ khi được yêu cầu rõ ràng.

## 1. Stack & package (giữ nguyên, KHÔNG thêm nếu không cần)

- Flutter, Material 3, theme **tối** (dark). SDK Dart `^3.12.0`.
- State: `provider` (ChangeNotifier) — pattern MVVM.
- Gọi API: `http`. Lưu local: `shared_preferences`. Ảnh cache: `cached_network_image`.
- Font: `google_fonts`. Mở URL: `url_launcher`. Localization: `flutter_localizations` (vi_VN).
- KHÔNG thêm dio/bloc/riverpod/get nếu chưa được duyệt.

## 2. Cấu trúc thư mục THẬT (bám theo cái này)

```
lib/
├── main.dart                          # MultiProvider (UserProvider, HoaDonViewModel) + MaterialApp + routes
├── Models/                            # model có fromJson/toJson
├── Services/                          # lớp gọi HTTP tới API
├── ViewModels/                        # ChangeNotifier, xử lý logic
│   ├── auth/                          # login, change_password, user_provider
│   ├── account/                       # account_info, add_nhan_khau
│   ├── home/                          # home_viewmodel
│   └── (các file viewmodel khác)
├── Views/                             # UI screens
│   ├── auth/                          # login, forgot, reset, verify_otp, change_password
│   ├── home/                          # home_screen (trang chủ)
│   ├── notification/                  # thông báo, bảng tin
│   ├── support/                       # yêu cầu, liên hệ, điều khoản, trợ giúp
│   ├── vehicle/                       # phương tiện CRUD
│   ├── utilities/                     # tiện ích, đặt lịch
│   ├── account/                       # hồ sơ, nhân khẩu
│   └── (thanh_toan, lich_su_thanh_toan, setting, ...)
├── features/invoice/                  # hóa đơn (cấu trúc feature riêng)
│   ├── ViewModels/
│   └── Views/
└── core/
    ├── constants/apiconfig.dart       # ApiConfig.baseUrl
    ├── constants/app_colors.dart      # bảng màu dùng chung
    ├── Widgets/                       # AppButton, AppTextField
    └── routes/app_routes.dart         # tất cả named routes + onGenerateRoute
```

## 3. Điều hướng — Route-based (KHÁC app quản lý)

App cư dân dùng **named routes** (`Navigator.pushNamed`), KHÔNG dùng MainShell/IndexedStack
như app quản lý. Mỗi màn có `Scaffold` riêng — đây là thiết kế đúng cho app cư dân
(nhiều màn con, không cần drawer điều hướng).

- Routes khai báo trong `app_routes.dart`: static routes (không argument) trong `routes`,
  routes cần argument trong `onGenerateRoute`.
- Khi thêm màn mới: đăng ký route name + builder trong `AppRoutes`.
- Truyền data qua `settings.arguments`, cast đúng type.

## 4. baseUrl & gọi API

- **Luôn lấy URL từ `ApiConfig.baseUrl`** (`lib/core/constants/apiconfig.dart`).
  KHÔNG hardcode IP.
- **LẤY TÊN FIELD CHÍNH XÁC TỪ SWAGGER**: trước khi viết/sửa Model, mở Swagger UI tại
  **http://localhost:5080/swagger/index.html**, xem schema response thật. KHÔNG đoán.
- **Luôn decode UTF-8**: `jsonDecode(utf8.decode(response.bodyBytes))` cho MỌI response
  có tiếng Việt. KHÔNG dùng `response.body` trực tiếp.
- Response list có thể là **mảng trần** hoặc `{ "value": [...] }` — xử lý cả hai.
- Thành công đọc: `statusCode == 200`. Ghi: `200 || 201 || 204`. Thất bại: throw Exception.

## 5. Xác thực & Token — VẤN ĐỀ CẦN SỬA

### Hiện trạng (có vấn đề):
Token đang được **truyền tay** qua parameter ở mỗi Service method:
`fetchData(int id, String token)` → mỗi ViewModel phải tự đọc prefs lấy token rồi
truyền vào. Lặp lại ở MỌI chỗ, dễ quên, dễ sai.

### Cách sửa đúng:
Tạo helper **`lib/core/network/auth_http.dart`** (giống app quản lý):
```dart
class AuthHttp {
  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json; charset=utf-8',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}
```
Sau đó refactor dần các Service: bỏ parameter `token`, dùng `AuthHttp.getHeaders()`.
**Nhưng refactor từ từ**, không sửa hết một lúc — giữ tương thích, sửa service nào
thì sửa ViewModel gọi nó cho khớp.

## 6. Xử lý lỗi 401/403

Khi API trả 401 (token hết hạn hoặc không hợp lệ):
- Hiện SnackBar "Phiên đăng nhập đã hết hạn".
- Xóa token/cuDan khỏi SharedPreferences.
- Điều hướng về màn Login (`Navigator.pushNamedAndRemoveUntil(AppRoutes.login, ...)`).

## 7. Các tính năng HIỆN CÓ (KHÔNG được xóa/phá vỡ)

| Nhóm | Màn hình | File chính |
|---|---|---|
| **Auth** | Đăng nhập, Quên MK, Xác minh OTP, Reset MK, Đổi MK | `Views/auth/*` |
| **Home** | Trang chủ (tổng hợp: thông báo, hóa đơn, bảng tin, tiện ích) | `Views/home/home_screen.dart` |
| **Thông báo** | Danh sách + Chi tiết | `Views/notification/notification_*` |
| **Bảng tin** | Danh sách + Chi tiết | `Views/notification/bang_tin_*` |
| **Hóa đơn** | Danh sách + Chi tiết + Thanh toán + Lịch sử TT + Thông báo TT | `features/invoice/*`, `Views/thanh_toan_*`, `Views/lich_su_*` |
| **Yêu cầu** | Danh sách + Tạo mới + Chi tiết | `Views/support/yeu_cau_*`, `tao_yeu_cau_*` |
| **Phương tiện** | Danh sách + Chi tiết + Thêm + Sửa | `Views/vehicle/*` |
| **Tiện ích** | Danh sách + Đặt lịch + Lịch sử đặt | `Views/utilities/*` |
| **Tài khoản** | Thông tin + Sửa hồ sơ + Nhân khẩu + Thêm nhân khẩu | `Views/account/*` |
| **Cài đặt** | Cài đặt chung + Liên hệ + Điều khoản + Trợ giúp | `Views/setting_*`, `Views/support/*` |

## 8. Quy tắc khi sửa lỗi / cải thiện

1. **KHÔNG đổi tên file/class/route hiện có** trừ khi được yêu cầu rõ — Flutter dùng
   named routes, đổi tên route là breaking change.
2. **KHÔNG gộp nhiều sửa lỗi không liên quan vào một commit** — mỗi sửa một commit.
3. **Sửa xong phải chạy `flutter analyze`** — không được có lỗi/warning mới.
4. **Giữ đúng style hiện có**: dark theme, `AppColors`, `AppButton`, `AppTextField`,
   gradient nền (`bgDark → bgMid → bgDarkest`), `SafeArea`, icon teal.
5. **Dispose TextEditingController** trong StatefulWidget.
6. **Model sửa field phải kiểm tra Swagger** — không đoán.
7. **UserProvider** (`context.watch<UserProvider>()`) là nguồn cuDan dùng chung cho
   toàn app — dùng nó thay vì tự đọc prefs ở mỗi màn.

## 9. Công thức thêm màn mới

### Bước 1 — Model (nếu cần)
- File: `lib/Models/<tên>_model.dart`
- `fromJson` null-safe, tên field khớp Swagger (camelCase).

### Bước 2 — Service
- File: `lib/Services/<tên>_services.dart`
- Dùng `ApiConfig.baseUrl`, decode UTF-8, dùng `AuthHttp.getHeaders()` (hoặc pattern
  truyền token nếu chưa refactor helper).

### Bước 3 — ViewModel
- File: `lib/ViewModels/<tên>_viewmodel.dart`
- `extends ChangeNotifier`, pattern isLoading/error/try-catch-finally.
- KHÔNG gọi http trực tiếp, KHÔNG dùng BuildContext.

### Bước 4 — View (Screen)
- File: `lib/Views/<nhom>/<tên>_screen.dart`
- Bọc trong `ChangeNotifierProvider(create: ... child: ...)` hoặc dùng provider đã
  đăng ký global.
- Scaffold riêng (app cư dân dùng route, không dùng Shell).
- Gradient nền, SafeArea, AppBar theo style hiện có.

### Bước 5 — Đăng ký route
- Thêm route name trong `AppRoutes` + builder trong `routes` hoặc `onGenerateRoute`.

## 10. Checklist trước khi báo "đã xong"

- [ ] Tính năng cũ KHÔNG bị phá vỡ (test thủ công: login, home, xem thông báo, xem hóa đơn).
- [ ] Model dùng đúng field Swagger (camelCase), fromJson null-safe.
- [ ] Service decode UTF-8, dùng ApiConfig.baseUrl, xử lý lỗi throw Exception.
- [ ] ViewModel theo mẫu isLoading/error/try-catch-finally.
- [ ] View dùng AppColors + gradient nền + SafeArea, dispose controller.
- [ ] Route đăng ký đúng trong AppRoutes.
- [ ] `flutter analyze` sạch (không lỗi/warning mới).

## 11. LỖI ĐÃ BIẾT CẦN SỬA (ưu tiên)

| # | Vấn đề | File | Cách sửa |
|---|---|---|---|
| 1 | **3 Service thiếu UTF-8 decode** → tiếng Việt bị lỗi | `auth_services.dart`, `home_services.dart`, `notification_services.dart` | Đổi `jsonDecode(res.body)` → `jsonDecode(utf8.decode(res.bodyBytes))` |
| 2 | **`home_services.dart` không dùng ApiConfig** | `home_services.dart` | Không ảnh hưởng trực tiếp (nó gọi qua các service khác) nhưng kiểm tra lại |
| 3 | **Token truyền tay, không có auth_http helper** | Mọi Service | Tạo `AuthHttp` + refactor dần |
| 4 | **Không có xử lý 401 global** | Toàn app | Thêm vào AuthHttp hoặc wrapper |
| 5 | **Không có test** | `test/` chỉ có stub | Thêm test ViewModel cơ bản |
| 6 | **Một số View không dispose TextEditingController** | Nhiều file | Rà soát StatefulWidget có controller |
