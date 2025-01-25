import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BLEController extends GetxController {
  // Observable variables
  final isScanning = false.obs;
  final devices = <BluetoothDevice>[].obs;
  final connectionState = BluetoothConnectionState.disconnected.obs;
  final receivedData = ''.obs;

  BluetoothDevice? selectedDevice;
  BluetoothCharacteristic? txCharacteristic;

  // UUID for ESP32 service and characteristic
  final String SERVICE_UUID =
      "4fafc201-1fb5-459e-8fcc-c5c9c331914b"; // Replace with your ESP32 service UUID
  final String CHARACTERISTIC_UUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26a8"; // Replace with your characteristic UUID

  @override
  void onInit() {
    super.onInit();
    // Initialize FlutterBluePlus
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        // Bluetooth is on
      }
    });
  }

  // Start scanning for devices
  Future<void> startScan() async {
    if (isScanning.value) return;
    debugPrint("check 1");

    // Clear previous devices
    devices.clear();
    debugPrint("check 2");

    // Start scanning
    isScanning.value = true;
    debugPrint("check 3");

    // Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      debugPrint("check 4");
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          devices.add(result.device);
          debugPrint("devices added");
        }
      }
    });

    // Start scanning for 10 seconds
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    isScanning.value = false;
  }

  // Connect to selected device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      selectedDevice = device;

      // Update connection state
      device.connectionState.listen((state) {
        connectionState.value = state;
      });

      // Discover services after connection
      await _discoverServices();
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  // Discover services and characteristics
  Future<void> _discoverServices() async {
    if (selectedDevice == null) return;

    List<BluetoothService> services = await selectedDevice!.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == SERVICE_UUID) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            txCharacteristic = characteristic;
            // Set up notification listener
            await _setupNotifications();
            break;
          }
        }
      }
    }
  }

  Future<List<int>> collectDataForSeconds(int seconds) async {
    // Variable to store the collected integer values
    List<int> collectedValues = [];

    // Subscription to listen to the received data
    StreamSubscription? subscription;

    // Completer to wait for the specified duration
    Completer<void> completer = Completer<void>();

    // Listen to the receivedData observable
    subscription = receivedData.listen((data) {
      if (data.isNotEmpty) {
        try {
          // Convert the received string to an integer
          int value = int.parse(data);
          // Append the value to the list
          collectedValues.add(value);
        } catch (e) {
          debugPrint('Error parsing data: $e');
        }
      }
    });

    // Stop listening after the specified duration
    Future.delayed(Duration(seconds: seconds)).then((_) {
      subscription?.cancel();
      completer.complete();
    });

    // Wait until the duration completes
    await completer.future;

    // Return the collected values
    return collectedValues;
  }

  // Setup notifications to receive data
  Future<void> _setupNotifications() async {
    if (txCharacteristic == null) return;

    await txCharacteristic!.setNotifyValue(true);
    txCharacteristic!.lastValueStream.listen((value) {
      if (value.isNotEmpty) {
        // Convert received bytes to string
        receivedData.value = String.fromCharCodes(value);
      }
    });
  }

  // Disconnect from device
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
