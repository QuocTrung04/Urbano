import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:urbano/core/constants/apiconfig.dart';

class SignalRService extends ChangeNotifier {
  HubConnection? _connection;
  bool isConnected = false;
  bool _isConnecting = false; // Guard chống kết nối trùng lặp

  Map<String, int> unreadCounts = {
    'yeuCau': 0,
    'datLich': 0,
    'hoaDon': 0,
    'thongBao': 0,
  };

  int get totalUnread => unreadCounts.values.fold(0, (a, b) => a + b);
  List<Map<String, dynamic>> recentEvents = [];

  /// Mask token để log an toàn (chỉ hiện 10 ký tự đầu)
  String _maskToken(String token) {
    if (token.length <= 10) return '***';
    return '${token.substring(0, 10)}...****';
  }

  Future<void> connect() async {
    // === GUARD: tránh kết nối trùng lặp ===
    if (_isConnecting) {
      debugPrint('[SignalR] ⚠️ Đang trong quá trình kết nối, bỏ qua lệnh connect() trùng lặp');
      return;
    }
    if (isConnected && _connection != null) {
      debugPrint('[SignalR] ⚠️ Đã kết nối rồi, bỏ qua lệnh connect()');
      return;
    }

    _isConnecting = true;
    debugPrint('[SignalR] ════════════════════════════════════════');
    debugPrint('[SignalR] 🚀 Bắt đầu quá trình kết nối SignalR...');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) {
      debugPrint('[SignalR] ❌ Không tìm thấy token trong SharedPreferences! Hủy kết nối.');
      _isConnecting = false;
      return;
    }
    debugPrint('[SignalR] 🔑 Token: ${_maskToken(token)}');

    // Tạo URL Hub (bỏ /api, thêm /hubs/notification)
    final hubUrl = ApiConfig.baseUrl.replaceAll('/api', '/hubs/notification');
    debugPrint('[SignalR] 🔌 Hub URL: $hubUrl');
    debugPrint('[SignalR] 📡 Transport: WebSockets (skipNegotiation: true)');

    // Đóng kết nối cũ nếu có
    if (_connection != null) {
      debugPrint('[SignalR] 🔄 Đóng kết nối cũ trước khi tạo kết nối mới...');
      try {
        await _connection!.stop();
      } catch (e) {
        debugPrint('[SignalR] ⚠️ Lỗi khi đóng kết nối cũ: $e');
      }
      _connection = null;
    }

    _connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
            transport: HttpTransportType.WebSockets,
            skipNegotiation: true,
          ),
        )
        .withAutomaticReconnect()
        .build();

    // === ĐĂNG KÝ LẮNG NGHE TẤT CẢ EVENT ===
    // Events dành cho resident (resident_{cuDanId} group):
    _connection!.on('RequestStatusChanged', _onEvent('request_status'));
    _connection!.on('BookingStatusChanged', _onEvent('booking_status'));
    _connection!.on('NewInvoice', _onEvent('new_invoice'));
    _connection!.on('PaymentConfirmed', _onEvent('payment_confirmed'));

    // Events khác (giữ lại để phòng trường hợp backend mở rộng):
    _connection!.on('ReceiveNotification', _onEvent('notification'));
    _connection!.on('NewRequest', _onEvent('new_request'));
    _connection!.on('NewBooking', _onEvent('new_booking'));
    _connection!.on('SystemAlert', _onEvent('system_alert'));

    debugPrint('[SignalR] 📋 Đã đăng ký lắng nghe 8 events:');
    debugPrint('[SignalR]    ├─ RequestStatusChanged (→ resident)');
    debugPrint('[SignalR]    ├─ BookingStatusChanged (→ resident)');
    debugPrint('[SignalR]    ├─ NewInvoice           (→ resident)');
    debugPrint('[SignalR]    ├─ PaymentConfirmed     (→ resident)');
    debugPrint('[SignalR]    ├─ ReceiveNotification  (→ staff)');
    debugPrint('[SignalR]    ├─ NewRequest           (→ managers)');
    debugPrint('[SignalR]    ├─ NewBooking           (→ managers)');
    debugPrint('[SignalR]    └─ SystemAlert          (→ all)');

    // === TRẠNG THÁI KẾT NỐI ===
    _connection!.onclose(({error}) {
      debugPrint('[SignalR] ════════════════════════════════════════');
      debugPrint('[SignalR] ❌ Connection CLOSED');
      if (error != null) {
        debugPrint('[SignalR] ❌ Close error: $error');
      }
      debugPrint('[SignalR] ════════════════════════════════════════');
      isConnected = false;
      _isConnecting = false;
      notifyListeners();
    });

    _connection!.onreconnecting(({error}) {
      debugPrint('[SignalR] ════════════════════════════════════════');
      debugPrint('[SignalR] 🔄 RECONNECTING...');
      if (error != null) {
        debugPrint('[SignalR] 🔄 Reconnect reason: $error');
      }
      debugPrint('[SignalR] ════════════════════════════════════════');
      isConnected = false;
      notifyListeners();
    });

    _connection!.onreconnected(({connectionId}) {
      debugPrint('[SignalR] ════════════════════════════════════════');
      debugPrint('[SignalR] ✅ RECONNECTED successfully!');
      debugPrint('[SignalR] 🆔 New Connection ID: $connectionId');
      debugPrint('[SignalR] ════════════════════════════════════════');
      isConnected = true;
      notifyListeners();
    });

    // === BẮT ĐẦU KẾT NỐI ===
    try {
      debugPrint('[SignalR] ⏳ Đang kết nối...');
      await _connection!.start();
      isConnected = true;
      _isConnecting = false;
      notifyListeners();
      debugPrint('[SignalR] ════════════════════════════════════════');
      debugPrint('[SignalR] ✅ KẾT NỐI THÀNH CÔNG!');
      debugPrint('[SignalR] 🆔 Connection ID: ${_connection!.connectionId}');
      debugPrint('[SignalR] 📡 State: ${_connection!.state}');
      debugPrint('[SignalR] ════════════════════════════════════════');
    } catch (e, stackTrace) {
      _isConnecting = false;
      isConnected = false;
      notifyListeners();
      debugPrint('[SignalR] ════════════════════════════════════════');
      debugPrint('[SignalR] ❌ KẾT NỐI THẤT BẠI!');
      debugPrint('[SignalR] ❌ Error: $e');
      debugPrint('[SignalR] ❌ StackTrace: $stackTrace');
      debugPrint('[SignalR] 💡 Kiểm tra:');
      debugPrint('[SignalR]    1. Server có đang chạy không?');
      debugPrint('[SignalR]    2. URL hub có đúng không? → $hubUrl');
      debugPrint('[SignalR]    3. Token có hợp lệ không?');
      debugPrint('[SignalR]    4. Thiết bị có kết nối mạng không?');
      debugPrint('[SignalR] ════════════════════════════════════════');
    }
  }

  /// Factory tạo handler cho mỗi loại event
  void Function(List<Object?>?) _onEvent(String type) {
    return (args) {
      debugPrint('[SignalR] ════════════════════════════════════════');
      debugPrint('[SignalR] 📩 EVENT RECEIVED!');
      debugPrint('[SignalR] 📩 Type: $type');
      debugPrint('[SignalR] 📩 Raw args count: ${args?.length ?? 0}');

      final data = args?.isNotEmpty == true
          ? Map<String, dynamic>.from(args![0] as Map)
          : <String, dynamic>{};
      data['_type'] = type;
      data['_receivedAt'] = DateTime.now().toIso8601String();

      // Log payload chi tiết
      try {
        final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
        debugPrint('[SignalR] 📦 Payload:\n$jsonStr');
      } catch (_) {
        debugPrint('[SignalR] 📦 Payload: $data');
      }

      recentEvents.insert(0, data);
      if (recentEvents.length > 50) recentEvents.removeLast(); // giữ 50 event gần nhất

      // Cập nhật unread counts theo đúng event type
      if (type == 'request_status' || type == 'new_request') {
        unreadCounts['yeuCau'] = (unreadCounts['yeuCau'] ?? 0) + 1;
        debugPrint('[SignalR] 🔔 Unread yeuCau: ${unreadCounts['yeuCau']}');
      } else if (type == 'booking_status' || type == 'new_booking') {
        unreadCounts['datLich'] = (unreadCounts['datLich'] ?? 0) + 1;
        debugPrint('[SignalR] 🔔 Unread datLich: ${unreadCounts['datLich']}');
      } else if (type == 'new_invoice' || type == 'payment_confirmed') {
        unreadCounts['hoaDon'] = (unreadCounts['hoaDon'] ?? 0) + 1;
        debugPrint('[SignalR] 🔔 Unread hoaDon: ${unreadCounts['hoaDon']}');
      } else {
        // notification, system_alert, etc.
        unreadCounts['thongBao'] = (unreadCounts['thongBao'] ?? 0) + 1;
        debugPrint('[SignalR] 🔔 Unread thongBao: ${unreadCounts['thongBao']}');
      }

      debugPrint('[SignalR] 📊 Total unread: $totalUnread');
      debugPrint('[SignalR] ════════════════════════════════════════');

      notifyListeners();
    };
  }

  void clearUnread(String key) {
    if (unreadCounts.containsKey(key)) {
      unreadCounts[key] = 0;
      debugPrint('[SignalR] 🧹 Cleared unread for: $key');
      notifyListeners();
    }
  }

  void clearAllUnread() {
    unreadCounts.updateAll((key, value) => 0);
    debugPrint('[SignalR] 🧹 Cleared ALL unread counts');
    notifyListeners();
  }

  Future<void> disconnect() async {
    debugPrint('[SignalR] ════════════════════════════════════════');
    debugPrint('[SignalR] 🔌 Disconnecting...');
    await _connection?.stop();
    _connection = null;
    isConnected = false;
    _isConnecting = false;
    recentEvents.clear();
    unreadCounts.updateAll((key, value) => 0);
    notifyListeners();
    debugPrint('[SignalR] ✅ Disconnected and cleaned up');
    debugPrint('[SignalR] ════════════════════════════════════════');
  }
}
