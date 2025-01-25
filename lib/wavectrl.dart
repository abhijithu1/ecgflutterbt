import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaveController extends GetxController {
  final time1 = TextEditingController().obs;
  final sec = 0.obs;

  void settime() {
    final sec = int.tryParse(time1.value.text);

    startTimer(sec!);
  }

  final progress = 0.0.obs;
  Timer? timer;

  void startTimer(int durationInSeconds) {
    progress.value = 0.0; // Reset progress
    int elapsed = 0;

    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      elapsed += 100;
      progress.value = elapsed / (durationInSeconds * 1000);

      if (progress.value >= 1.0) {
        timer.cancel();
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    progress.value = 0.0;
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}
