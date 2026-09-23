import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/constants/colors.dart';

class TimerWidget extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onPressed;

  const TimerWidget({super.key, required this.initialSeconds, required this.onPressed});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _secondsRemaining;
  late String buttonString;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.initialSeconds;
    buttonString = "Resend in ${_secondsRemaining}s";
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_secondsRemaining == 0) {
          setState(() {
            buttonString = "Resend OTP";
            timer.cancel();
          });
        } else {
          setState(() {
            _secondsRemaining--;
            buttonString = "Resend in ${_secondsRemaining}s";
          });
        }
      },
    );
  }

  void restartTimer(int seconds) {
    setState(() {
      _secondsRemaining = seconds;
      buttonString = "Resend in ${_secondsRemaining}s";
    });
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_secondsRemaining == 0) {
          widget.onPressed();
          restartTimer(60);
        }
      },
      child: Text(
        buttonString,
        style: TextStyle(
          color: _secondsRemaining == 0 ? AppColors.colorPrimary : AppColors.colorTextMuted,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          fontFamily: AppTheme.fontFamily,
        ),
      ),
    );
  }
}
