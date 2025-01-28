import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BLEController extends GetxController {
  final isScanning = false.obs;
  final devices = <BluetoothDevice>[].obs;
  final connectionState = BluetoothConnectionState.disconnected.obs;
  final receivedData = ''.obs;
  final RxBool isConnecting = false.obs;

  BluetoothDevice? selectedDevice;
  BluetoothCharacteristic? txCharacteristic;

  static const String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String CHARACTERISTIC_UUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  @override
  void onInit() {
    super.onInit();
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        debugPrint("Bluetooth is on");
      }
    });
  }

  Future<void> startScan() async {
    if (isScanning.value) return;

    devices.clear();
    isScanning.value = true;

    try {
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (!devices.contains(result.device)) {
            devices.add(result.device);
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Scan error: $e');
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      selectedDevice = device;
      device.connectionState.listen((state) {
        connectionState.value = state;
      });

      await _discoverServices();
    } on FlutterBluePlusException catch (e) {
      debugPrint('Connection error: ${e.code} - ${e.description}');
      await device.disconnect();
    }
  }

  Future<void> _discoverServices() async {
    if (selectedDevice == null) return;

    try {
      List<BluetoothService> services =
          await selectedDevice!.discoverServices();
      for (var service in services) {
        if (service.uuid.toString() == SERVICE_UUID) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
              txCharacteristic = characteristic;
              await _setupNotifications();
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Service discovery error: $e');
    }
  }

  Future<List<int>> collectDataForSeconds(int seconds) async {
    final completer = Completer<List<int>>();
    List<int> collectedValues = [];

    if (txCharacteristic == null) {
      completer.completeError('No characteristic found');
      return collectedValues;
    }

    StreamSubscription? subscription = txCharacteristic!.lastValueStream.listen(
      (data) {
        if (data.isNotEmpty) {
          try {
            int parsedValue = int.parse(String.fromCharCodes(data));
            collectedValues.add(parsedValue);
          } catch (e) {
            debugPrint('Data parsing error: $e');
          }
        }
      },
      onError: (error) => debugPrint('Stream error: $error'),
    );

    Timer(Duration(seconds: seconds), () {
      subscription.cancel();
      completer.complete(collectedValues);
    });

    return completer.future;
  }

  Future<void> _setupNotifications() async {
    if (txCharacteristic == null) return;

    try {
      await txCharacteristic!.setNotifyValue(true);
      txCharacteristic!.lastValueStream.listen(
        (value) {
          if (value.isNotEmpty) {
            receivedData.value = String.fromCharCodes(value);
          }
        },
        onError: (error) => debugPrint('Notification error: $error'),
      );
    } catch (e) {
      debugPrint('Notification setup error: $e');
    }
  }

  Future<void> disconnect() async {
    if (selectedDevice != null) {
      await selectedDevice!.disconnect();
      selectedDevice = null;
      txCharacteristic = null;
    }
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
