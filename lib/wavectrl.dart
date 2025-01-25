import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaveController extends GetxController {
  final time1 = TextEditingController().obs;
  final sec = 0.obs;
  final progressData = <double>[].obs;

  void settime() {
    // Parse the value from the TextField.
    final parsedSec = int.tryParse(time1.value.text);
    if (parsedSec == null || parsedSec <= 0) {
      // Handle invalid or zero input.
      sec.value = 0; // Update to trigger the "Enter a nonzero number" message.
      debugPrint("Invalid input: Enter a nonzero number");
    } else {
      sec.value = parsedSec; // Update with the valid number.
      startTimer(sec.value); // Start the timer with the entered time.
      debugPrint("Got the time: ${sec.value}");
    }
  }

  final progress = 0.0.obs;
  Timer? timer;

  void startTimer(int durationInSeconds) {
    debugPrint("Start timer started");
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
