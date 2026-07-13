# 🏢 Urbano — Ứng dụng Quản lý Cư dân

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/.NET-Web%20API-512BD4?logo=dotnet&logoColor=white"/>
  <img src="https://img.shields.io/badge/SQL%20Server-CC2927?logo=microsoftsqlserver&logoColor=white"/>
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white"/>
</p>

Ứng dụng di động quản lý cư dân chung cư, xây dựng bằng **Flutter (MVVM)** kết nối **ASP.NET Core Web API** và **SQL Server**.

---

## ✨ Tính năng

- 🔐 Đăng nhập, Quên mật khẩu (OTP), Đổi mật khẩu
- 👤 Xem & cập nhật thông tin cá nhân, Quản lý nhân khẩu
- 🏠 Xem thông tin căn hộ
- 💰 Xem hóa đơn, Thanh toán, Lịch sử giao dịch
- 🚗 Đăng ký & quản lý phương tiện
- 🏊 Đặt lịch & quản lý tiện ích
- 📋 Gửi & theo dõi yêu cầu / khiếu nại
- 🔔 Thông báo & Bảng tin tòa nhà

---

## 🛠️ Công nghệ

| | |
|---|---|
| **Framework** | Flutter 3.x / Dart 3.12 |
| **State Management** | Provider + MVVM |
| **HTTP** | http, JWT Bearer Token |
| **Local Storage** | shared_preferences |
| **UI** | google_fonts, cached_network_image |
| **Backend** | ASP.NET Core Web API |
| **Database** | SQL Server |

---

## 📁 Cấu trúc

```
lib/
├── core/          # Hằng số, routes, widget dùng chung
├── Models/        # Data models, JSON parse
├── Services/      # Giao tiếp HTTP với API
├── ViewModels/    # Xử lý logic, trạng thái
├── Views/         # Giao diện (34 màn hình)
└── main.dart
```

---

## 🚀 Cài đặt & Chạy

```bash
git clone https://github.com/<your-username>/urbano.git
cd urbano/urbano
flutter pub get

# Cấu hình API endpoint trong lib/core/constants/apiconfig.dart

flutter run
```

```bash
# Build APK
flutter build apk --release
```

---

## 👥 Nhóm thực hiện

| Họ tên | MSSV |
|---|---|
| Mai Quốc Trung | 0306221087 |
| Trần Hoàng Tiến | 0306221080 |

**GVHD:** Đỗ Trung Thuận  
**Trường:** Cao đẳng Kỹ thuật Cao Thắng — Khoa CNTT — Khóa 2022–2025
