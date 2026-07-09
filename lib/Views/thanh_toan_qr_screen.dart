import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/Models/cau_hinh_thanh_toan_model.dart';
import 'package:urbano/Services/cau_hinh_thanh_toan_services.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/network/signalr_service.dart';

class ThanhToanQRScreen extends StatefulWidget {
  final HoaDonModel hoaDon;
  const ThanhToanQRScreen({super.key, required this.hoaDon});

  @override
  State<ThanhToanQRScreen> createState() => _ThanhToanQRScreenState();
}

class _ThanhToanQRScreenState extends State<ThanhToanQRScreen> {
  late SignalRService _signalRService;
  final CauHinhThanhToanServices _services = CauHinhThanhToanServices();
  
  bool _loadingConfig = true;
  CauHinhThanhToanModel? _config;
  String? _error;
  bool _daTT = false;
  String? _lastEventId;

  @override
  void initState() {
    super.initState();
    _signalRService = Provider.of<SignalRService>(context, listen: false);
    _signalRService.addListener(_onSignalREvent);
    _loadConfig();
  }

  @override
  void dispose() {
    _signalRService.removeListener(_onSignalREvent);
    super.dispose();
  }

  void _onSignalREvent() {
    if (_signalRService.recentEvents.isNotEmpty) {
      final latest = _signalRService.recentEvents.first;
      final currentEventId = latest['_receivedAt'] as String?;
      
      if (currentEventId != null && currentEventId != _lastEventId) {
        _lastEventId = currentEventId;
        final type = latest['_type'] as String?;
        if (type == 'payment_confirmed') {
          final int? eventHoaDonId = latest['hoaDonId'] as int?;
          if (eventHoaDonId == widget.hoaDon.id) {
            setState(() {
              _daTT = true;
            });
          }
        }
      }
    }
  }

  Future<void> _loadConfig() async {
    try {
      final activeConfig = await _services.fetchActive();
      if (mounted) {
        setState(() {
          _config = activeConfig;
          _loadingConfig = false;
          if (_config == null) {
            _error = 'Không tìm thấy cấu hình thanh toán hoạt động.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Lỗi tải cấu hình thanh toán: $e';
          _loadingConfig = false;
        });
      }
    }
  }

  double get _conLai {
    final tong = widget.hoaDon.tongTien ?? 0;
    final daTra = widget.hoaDon.soTienDaThanhToan ?? 0;
    final con = tong - daTra;
    return con < 0 ? 0 : con;
  }

  String _formatPrice(double price) {
    final s = price.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    return '${buffer.toString().split('').reversed.join()}đ';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label'),
        backgroundColor: AppColors.tealPrimary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'THANH TOÁN QR',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loadingConfig) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Quay lại', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }

    final config = _config!;
    final conThieuVal = _conLai;
    final addInfoText = widget.hoaDon.maThanhToan ?? '';
    
    // Construct VietQR URL safely using Uri to handle parameter encoding
    final qrUrl = Uri.parse('https://img.vietqr.io/image/${config.maNhanDien}-${config.dinhDanhThuHuong}-compact.png')
        .replace(
          queryParameters: {
            'amount': conThieuVal.toInt().toString(),
            'addInfo': addInfoText,
            'accountName': config.tenChuTaiKhoan,
          },
        ).toString();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // QR Code Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                qrUrl,
                width: 240,
                height: 240,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    width: 240,
                    height: 240,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.tealPrimary,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 240,
                    height: 240,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_rounded, color: Colors.grey, size: 48),
                          SizedBox(height: 8),
                          Text(
                            'Không thể tải mã QR',
                            style: TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Transfer Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.nenContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Ngân hàng', '${config.tenNhaCungCap} (${config.maNhanDien})'),
                const Divider(color: AppColors.borderButton, height: 24),
                _buildInfoRowWithCopy(
                  'Số tài khoản',
                  config.dinhDanhThuHuong,
                  () => _copyToClipboard(config.dinhDanhThuHuong, 'Số tài khoản'),
                ),
                const Divider(color: AppColors.borderButton, height: 24),
                _buildInfoRow('Chủ tài khoản', config.tenChuTaiKhoan.toUpperCase()),
                const Divider(color: AppColors.borderButton, height: 24),
                _buildInfoRowWithCopy(
                  'Số tiền chuyển',
                  _formatPrice(conThieuVal),
                  () => _copyToClipboard(conThieuVal.toInt().toString(), 'Số tiền'),
                ),
                const Divider(color: AppColors.borderButton, height: 24),
                _buildInfoRowWithCopy(
                  'Nội dung chuyển khoản',
                  addInfoText,
                  () => _copyToClipboard(addInfoText, 'Nội dung chuyển khoản'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Status & Buttons
          _buildStatusSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithCopy(String label, String value, VoidCallback onCopy) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onCopy,
          icon: const Icon(Icons.copy_rounded, color: AppColors.tealPrimary, size: 20),
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    if (!_daTT) {
      return Column(
        children: [
          const SizedBox(height: 12),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppColors.tealPrimary,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Đang chờ xác nhận thanh toán...',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.tealPrimary, size: 28),
            SizedBox(width: 8),
            Text(
              'Thanh toán thành công!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Quay lại',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
