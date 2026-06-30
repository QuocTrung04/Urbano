// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:urbano/Models/tien_ich_model.dart';

// class TienIchServices {
//   static const String baseUrl = 'http://10.0.2.2:5080/api';

//   // Lấy danh sách tiện ích
//   Future<List<TienIch>> fetchTienIch() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';

//     final res = await http.get(
//       Uri.parse('$baseUrl/tienich'),
//       headers: {
//         'Content-Type': 'application/json',
//         if (token.isNotEmpty) 'Authorization': 'Bearer $token',
//       },
//     );

//     if (res.statusCode == 200) {
//       final decoded = jsonDecode(utf8.decode(res.bodyBytes));
//       final List data = decoded is List
//           ? decoded
//           : (decoded[r'$values'] ??
//                     decoded['value'] ??
//                     decoded['data'] ??
//                     [])
//                 as List;
//       return data
//           .map<TienIch>((e) => TienIch.fromJson(e as Map<String, dynamic>))
//           .toList();
//     }
//     throw Exception('Lỗi tải tiện ích (${res.statusCode})');
//   }
// }

import 'package:urbano/Models/tien_ich_model.dart';

class TienIchServices {
  Future<List<TienIch>> fetchTienIch() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      TienIch(
        id: 1,
        tenTienIch: "Hồ bơi",
        loaiTienIch: LoaiTienIch(id: 1, tenLoaiTienIch: "Thể thao"),
        toaNha: 1,
        moTa: "Hồ bơi ngoài trời dành cho cư dân.",
        viTri: "Tầng 5 - Tòa A",
        sucChua: 100,
        gioMoCua: "06:00",
        gioDongCua: "22:00",
        phiSuDung: 0,
        canDatTruoc: false,
        hinhUrl: "https://picsum.photos/400/250?1",
        trangThai: 1,
      ),
      TienIch(
        id: 2,
        tenTienIch: "Phòng Gym",
        loaiTienIch: LoaiTienIch(id: 1, tenLoaiTienIch: "Thể thao"),
        toaNha: 1,
        moTa: "Phòng tập hiện đại với đầy đủ thiết bị.",
        viTri: "Tầng 3 - Tòa A",
        sucChua: 50,
        gioMoCua: "05:30",
        gioDongCua: "22:00",
        phiSuDung: 100000,
        canDatTruoc: true,
        hinhUrl: "https://picsum.photos/400/250?2",
        trangThai: 1,
      ),
      TienIch(
        id: 3,
        tenTienIch: "Sân Tennis",
        loaiTienIch: LoaiTienIch(id: 1, tenLoaiTienIch: "Thể thao"),
        toaNha: 2,
        moTa: "Sân tennis tiêu chuẩn quốc tế.",
        viTri: "Khu thể thao",
        sucChua: 20,
        gioMoCua: "06:00",
        gioDongCua: "21:00",
        phiSuDung: 150000,
        canDatTruoc: true,
        hinhUrl: "https://picsum.photos/400/250?3",
        trangThai: 1,
      ),
      TienIch(
        id: 4,
        tenTienIch: "Khu BBQ",
        loaiTienIch: LoaiTienIch(id: 2, tenLoaiTienIch: "Giải trí"),
        toaNha: null,
        moTa: "Khu nướng ngoài trời cho gia đình.",
        viTri: "Công viên trung tâm",
        sucChua: 40,
        gioMoCua: "08:00",
        gioDongCua: "22:00",
        phiSuDung: 200000,
        canDatTruoc: true,
        hinhUrl: "https://picsum.photos/400/250?4",
        trangThai: 1,
      ),
      TienIch(
        id: 5,
        tenTienIch: "Phòng sinh hoạt cộng đồng",
        loaiTienIch: LoaiTienIch(id: 3, tenLoaiTienIch: "Cộng đồng"),
        toaNha: 3,
        moTa: "Không gian tổ chức hội họp và sự kiện.",
        viTri: "Tầng 1 - Tòa C",
        sucChua: 150,
        gioMoCua: "07:00",
        gioDongCua: "21:00",
        phiSuDung: 500000,
        canDatTruoc: true,
        hinhUrl: "https://picsum.photos/400/250?5",
        trangThai: 1,
      ),
      TienIch(
        id: 6,
        tenTienIch: "Sân bóng rổ",
        loaiTienIch: LoaiTienIch(id: 1, tenLoaiTienIch: "Thể thao"),
        toaNha: 2,
        moTa: "Sân bóng rổ ngoài trời.",
        viTri: "Khu thể thao",
        sucChua: 30,
        gioMoCua: "06:00",
        gioDongCua: "21:00",
        phiSuDung: 50000,
        canDatTruoc: false,
        hinhUrl: "https://picsum.photos/400/250?6",
        trangThai: 1,
      ),
    ];
  }
}
