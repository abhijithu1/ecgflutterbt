import 'dart:async';
import 'package:newtest/bltctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newtest/pant.dart';

class WaveController extends GetxController {
  final time1 = TextEditingController().obs;
  final sec = 0.obs;
  final acquiredData = <double>[].obs;
  final progress = 0.0.obs;
  final receivedDataCounter = 0.obs;
  final startacq = false.obs; // Added observable acquisition state
  final bpm = 0.obs;

  StreamSubscription? _dataSubscription;
  Timer? progressTimer;

  void settime() {
    final parsedSec = int.tryParse(time1.value.text);
    if (parsedSec == null || parsedSec <= 0) {
      sec.value = 0;
      debugPrint("Invalid input: Enter a nonzero number");
      return;
    }

    sec.value = parsedSec;
    acquiredData.clear();
    receivedDataCounter.value = 0;
    startAcquisition(sec.value);
  }

  void startAcquisition(int durationInSeconds) {
    final BLEController blc = Get.find<BLEController>();
    int elapsed = 0;

    startacq.value = true; // Set acquisition state to true when starting

    progress.value = 0.0;
    progressTimer?.cancel();
    progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      elapsed += 100;
      progress.value = elapsed / (durationInSeconds * 1000);

      if (progress.value >= 1.0) {
        timer.cancel();
      }
    });

    _dataSubscription = blc.txCharacteristic!.lastValueStream.listen((data) {
      if (data.isNotEmpty) {
        try {
          final receivedValue = double.tryParse(String.fromCharCodes(data));
          if (receivedValue != null) {
            acquiredData.add(receivedValue);
            receivedDataCounter.value++;
          }
        } catch (e) {
          debugPrint('Data parsing error: $e');
        }
      }
    });

    Future.delayed(Duration(seconds: durationInSeconds), () {
      stopAcquisition();
      debugPrint("Total data points received: ${receivedDataCounter.value}");
    });
  }

  void stopAcquisition() {
    startacq.value = false; // Set acquisition state to false when stopping
    _dataSubscription?.cancel();
    progressTimer?.cancel();

    // Calculate BPM after data acquisition
    bpm.value = PanTompkins().calculateBPM(acquiredData);
    debugPrint("Calculated BPM: $bpm");

    debugPrint("Data acquisition stopped.");
    debugPrint("Data acquisition stopped.");
  }

  @override
  void onClose() {
    _dataSubscription?.cancel();
    progressTimer?.cancel();
    super.onClose();
  }
}
