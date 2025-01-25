import 'dart:async';
import 'package:ecgdisplay/bltctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaveController extends GetxController {
  final time1 = TextEditingController().obs; // User input for duration
  final sec = 0.obs; // Acquisition time in seconds
  final acquiredData = <double>[].obs; // Stores acquired data points
  final progress = 0.0.obs; // Progress indicator
  Timer? progressTimer; // Timer for progress tracking
  Timer? acquisitionTimer; // Timer for acquisition process

  void settime() {
    // Parse the user input
    final parsedSec = int.tryParse(time1.value.text);
    if (parsedSec == null || parsedSec <= 0) {
      sec.value = 0; // Show error message
      debugPrint("Invalid input: Enter a nonzero number");
    } else {
      sec.value = parsedSec;
      acquiredData.clear(); // Clear previous data
      startAcquisition(sec.value);
    }
  }

  void startAcquisition(int durationInSeconds) {
    debugPrint("Data acquisition started for $durationInSeconds seconds");
    final BLEController blc = Get.find<BLEController>();
    int elapsed = 0;

    // Reset progress
    progress.value = 0.0;

    // Start progress timer
    progressTimer?.cancel();
    progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      elapsed += 100;
      progress.value = elapsed / (durationInSeconds * 1000);

      if (progress.value >= 1.0) {
        timer.cancel();
      }
    });

    // Start acquisition timer
    acquisitionTimer?.cancel();
    acquisitionTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      elapsed += 100;

      // Collect data from BLEController
      final receivedValue = double.tryParse(blc.receivedData.value ?? "0");
      if (receivedValue != null) {
        acquiredData.add(receivedValue);
      }

      // Stop acquisition after duration
      if (elapsed >= durationInSeconds * 1000) {
        timer.cancel();
        debugPrint("Data acquisition completed.");
        debugPrint("Acquired data: $acquiredData");
      }
    });
  }

  void stopAcquisition() {
    acquisitionTimer?.cancel();
    progressTimer?.cancel();
    debugPrint("Data acquisition stopped.");
  }

  @override
  void onClose() {
    acquisitionTimer?.cancel();
    progressTimer?.cancel();
    super.onClose();
  }
}
