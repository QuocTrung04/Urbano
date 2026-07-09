import 'package:urbano/Models/notification_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';
import 'package:urbano/core/network/auth_http.dart';

class ThongbaoServices {
  static const String url = ApiConfig.baseUrl;

  Future<List<ThongBao>> fetchThongBao(int cuDanId) async {
    final data = await AuthHttp.get('$url/thongbao?cuDanId=$cuDanId');
    return (data as List).map((e) => ThongBao.fromJson(e)).toList();
  }

  // Đánh dấu 1 thông báo đã đọc
  Future<void> danhDauDaDoc(int thongBaoId, int cuDanId) async {
    final uri = Uri.parse('$url/thongbao/danh-dau-da-doc').replace(
      queryParameters: {
        'thongBaoId': thongBaoId.toString(),
        'cuDanId': cuDanId.toString(),
      },
    );

    await AuthHttp.post(uri.toString());
  }

  // Đánh dấu TẤT CẢ thông báo đã đọc
  Future<void> danhDauTatCa(int cuDanId) async {
    final uri = Uri.parse(
      '$url/thongbao/danh-dau-tat-ca',
    ).replace(queryParameters: {'cuDanId': cuDanId.toString()});

    await AuthHttp.post(uri.toString());
  }
}
