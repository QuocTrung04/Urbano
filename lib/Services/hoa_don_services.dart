import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';
import 'package:urbano/core/network/auth_http.dart';

class HoaDonServices {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Danh sách hóa đơn theo căn hộ.
  Future<List<HoaDonModel>> fetchHoaDons(int canHoId) async {
    final decoded = await AuthHttp.get('$baseUrl/hoadon/canho/$canHoId');
    List listJson = [];
    if (decoded is List) {
      listJson = decoded;
    } else if (decoded is Map && decoded['value'] != null) {
      listJson = decoded['value'];
    }
    return listJson.map((item) => HoaDonModel.fromJson(item)).toList();
  }

  Future<HoaDonModel> fetchHoaDonDetail(int id) async {
    final decoded = await AuthHttp.get('$baseUrl/hoadon/$id');
    final map = decoded is Map<String, dynamic>
        ? (decoded['value'] ?? decoded['data'] ?? decoded)
        : decoded;
    return HoaDonModel.fromJson(map as Map<String, dynamic>);
  }

  Future<void> thanhToan(
    int hoaDonId, {
    required String phuongThuc,
    required double soTien,
  }) async {
    await AuthHttp.post(
      '$baseUrl/hoadon/$hoaDonId/thanh-toan',
      body: {'phuongThucThanhToan': phuongThuc, 'soTien': soTien},
    );
  }
}
