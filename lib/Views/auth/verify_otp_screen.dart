import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbano/core/Widgets/app_button.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';
import 'package:urbano/Services/auth_services.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String contact;
  final bool _isSms;

  const VerifyOtpScreen({
    super.key,
    required this.contact,
    required this._isSms,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  static const int _otpLength = 6;
  static const int _expireSeconds = 300;
  final _auth = AuthServices();
  final List<TextEditingController> _controller = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNode = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  Timer? _time;
  int _secondsLeft = _expireSeconds;
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _time = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
        if (_resendCountdown > 0) _resendCountdown--;
      });
    });
  }

  String get _otp => _controller.map((c) => c.text).join();

  String _formatTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNode[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNode[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _onResend() async {
    if (_resendCountdown > 0) return;
    try {
      await _auth.forgotPassword(widget.contact); // gửi lại OTP
      if (!mounted) return;
      setState(() {
        _secondsLeft = _expireSeconds;
        _resendCountdown = 60;
        for (final c in _controller) {
          c.clear();
        }
        _focusNode[0].requestFocus();
      });
      _snack('Đã gửi lại mã OTP');
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  void dispose() {
    _time?.cancel();
    for (final c in _controller) {
      c.dispose();
    }
    for (final f in _focusNode) {
      f.dispose();
    }
    super.dispose();
  }

  bool _verifying = false;

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: AppColors.isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                _buildButtonBack(context),
                SizedBox(height: 38),
                _buildHeader(),
                SizedBox(height: 28),
                _buildOtpBox(),
                SizedBox(height: 24),
                _buildTimeText(),
                SizedBox(height: 34),
                AppButton(
                  label: 'Xác nhận',
                  onPressed: () async {
                    if (_secondsLeft == 0) {
                      _snack('Mã đã hết hạn, vui lòng gửi lại');
                      return;
                    }
                    if (_otp.length < _otpLength) {
                      _snack('Vui lòng nhập đủ 6 số');
                      return;
                    }
                    if (_verifying) return;
                    final nav = Navigator.of(context);
                    setState(() => _verifying = true);
                    try {
                      await _auth.verifyOtp(
                        widget.contact,
                        _otp,
                      ); // <-- KIỂM OTP
                      if (!mounted) return;
                      setState(() => _verifying = false);
                      nav.pushNamed(
                        AppRoutes.resetPassword,
                        arguments: {'email': widget.contact, 'otp': _otp},
                      );
                    } catch (e) {
                      if (!mounted) return;
                      setState(() => _verifying = false);
                      _snack(
                        e.toString().replaceFirst('Exception: ', ''),
                      ); // "OTP sai hoặc đã hết hạn"
                    }
                  },
                ),
                SizedBox(height: 24),
                _buildResend(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.tealDark.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSide, width: 1.5),
            ),
            child: Icon(
              widget._isSms ? Icons.phone_callback : Icons.email_outlined,
              size: 40,
              color: AppColors.tealPrimary,
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Nhập mã xác nhận',
          style: TextStyle(
            fontSize: 26,
            letterSpacing: 1,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Mã 6 số được gửi tới ',
                style: TextStyle(fontSize: 18, color: AppColors.textMuted),
              ),
              TextSpan(
                text: _maskContact(),
                style: TextStyle(color: AppColors.tealPrimary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _maskPhone(String phone) {
    if (phone.length < 7) return phone;
    final start = phone.substring(0, 3);
    final end = phone.substring(phone.length - 3);
    return '$start****$end';
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return email;
    final visible = name.substring(0, 3);
    return '$visible****@$domain';
  }

  String _maskContact() {
    return widget._isSms
        ? _maskPhone(widget.contact)
        : _maskEmail(widget.contact);
  }

  Widget _buildOtpBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (i) {
        final filled = _controller[i].text.isNotEmpty;
        return SizedBox(
          width: 45,
          height: 60,
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
                if (_controller[i].text.isEmpty && i > 0) {
                  _focusNode[i - 1].requestFocus();
                  _controller[i - 1].clear();
                  setState(() {});
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: _controller[i],
              focusNode: _focusNode[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: filled
                    ? AppColors.tealPrimary.withValues(alpha: 0.15)
                    : AppColors.inputFill,
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: filled ? AppColors.tealPrimary : AppColors.inputFill,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.tealPrimary, width: 2),
                ),
              ),
              onChanged: (v) => _onChanged(i, v),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimeText() {
    final expired = _secondsLeft == 0;
    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: expired ? 'Mã đã hết hạn' : 'Mã hết hạn sau: ',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
                fontSize: 15,
              ),
            ),
            if (!expired)
              TextSpan(
                text: _formatTime(_secondsLeft),
                style: TextStyle(
                  color: AppColors.tealPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResend() {
    final canResend = _resendCountdown == 0;
    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Chưa nhận được mã?  ',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
                fontSize: 15,
              ),
            ),
            TextSpan(
              text: canResend ? 'Gửi lại' : 'Gửi lại (${_resendCountdown}s)',
              style: TextStyle(
                color: canResend ? AppColors.tealPrimary : AppColors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = canResend
                    ? () {
                        _onResend();
                      }
                    : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonBack(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}
