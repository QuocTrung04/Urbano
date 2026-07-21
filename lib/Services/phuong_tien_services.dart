import 'package:urbano/Models/phuong_tien_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';
import 'package:urbano/core/network/auth_http.dart';

class PhuongTienServices {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<List<PhuongTien>> fetchPhuongTien(int canHoId) async {
    final decoded = await AuthHttp.get('$baseUrl/phuongtien/canho/$canHoId');
    final data = _asList(decoded);
    return data
        .map((e) => PhuongTien.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> dangKyPhuongTien({
    required int canHoId,
    required int cuDanId,
    required String tenPhuongTien,
    required String bienSo,
    required int loaiPhuongTienId,
  }) async {
    await AuthHttp.post(
      '$baseUrl/phuongtien/dang-ky',
      body: {
        'canHoId': canHoId,
        'cuDanId': cuDanId,
        'tenPhuongTien': tenPhuongTien,
        'bienSo': bienSo,
        'loaiPhuongTienId': loaiPhuongTienId,
      },
    );
  }

//   String? _msg(String body) {
//     try {
//       final m = jsonDecode(body);
//       if (m is Map && m['message'] != null) return m['message'].toString();
//     } catch (_) {}
//     return null;
//   }

  /// Danh sách loại phương tiện (id + tên) từ API.
  Future<List<LoaiPhuongTien>> fetchLoaiPhuongTien() async {
    final decoded = await AuthHttp.get('$baseUrl/phuongtien/loai');
    final data = _asList(decoded);
    return data
        .map<LoaiPhuongTien>(
          (e) => LoaiPhuongTien(
            id: e['id'] ?? 0,
            tenLoaiPhuongTien: e['tenLoaiPhuongTien'] ?? '',
          ),
        )
        .toList();
  }

  List _asList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      final inner =
          decoded[r'$values'] ??
          decoded['value'] ??
          decoded['data'] ??
          decoded['items'];
      if (inner is List) return inner;
    }
    return const [];
  }

  /// Hủy đăng ký trực tiếp (cho xe Chờ duyệt) -> trạng thái 0.
  Future<void> huyPhuongTien(int id) async {
    await AuthHttp.put('$baseUrl/phuongtien/$id/huy');
  }

  /// Cập nhật thông tin xe (cho xe Chờ duyệt).
  Future<void> capNhatPhuongTien({
    required int id,
    required String tenPhuongTien,
    required String bienSo,
    required int loaiPhuongTienId,
    required int canHoId,
    int? nguoiCapNhatId,
    required int trangThai,
  }) async {
    await AuthHttp.put(
      '$baseUrl/phuongtien/$id',
      body: {
        'tenPhuongTien': tenPhuongTien,
        'bienSo': bienSo,
        'loaiPhuongTienId': loaiPhuongTienId,
        'canHoId': canHoId,
        'trangThai': trangThai,
        'nguoiCapNhatId': nguoiCapNhatId,
      },
    );
  }
}
