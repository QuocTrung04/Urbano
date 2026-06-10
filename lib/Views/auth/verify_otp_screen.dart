import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbano/core/Widgets/app_back_button.dart';
import 'package:urbano/core/Widgets/app_button.dart';
import 'package:urbano/core/constants/app_colors.dart';

class VerifyOtpScreen extends StatefulWidget {
  // final String contact;
  // final bool isSms;

  const VerifyOtpScreen({
    super.key,
    // required this.contact,
    // required this.isSms,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  static const int _otpLength = 6;
  static const int _expireSeconds = 300;

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

  void _onResend() {
    if (_resendCountdown > 0) return;
    //goi lai api gui otp
    setState(() {
      _secondsLeft = _expireSeconds;
      _resendCountdown = 60;
      for (final c in _controller) {
        c.clear();
      }
      _focusNode[0].requestFocus();
    });
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
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
                AppBackButton(),
                SizedBox(height: 38),
                _buildHeader(),
                SizedBox(height: 28),
                _buildOtpBox(),
                SizedBox(height: 24),
                _buildTimeText(),
                SizedBox(height: 34),
                AppButton(label: 'Xác nhận', onPressed: () {}),
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
              color: AppColors.tealDark.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSide, width: 1.5),
            ),
            child: Icon(
              Icons.sms_outlined,
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
            color: Colors.white,
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
                text: '.........',
                style: TextStyle(color: AppColors.tealPrimary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOtpBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (i) {
        final filled = _controller[i].text.isNotEmpty;
        return SizedBox(
          width: 45,
          height: 60,
          child: TextField(
            controller: _controller[i],
            focusNode: _focusNode[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: filled
                  ? AppColors.tealPrimary.withOpacity(0.15)
                  : AppColors.inputFill,
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: filled ? AppColors.tealPrimary : AppColors.inputFill,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.tealPrimary, width: 2),
              ),
            ),
            onChanged: (v) => _onChanged(i, v),
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
}
