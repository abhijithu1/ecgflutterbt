import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:newtest/bltctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:newtest/home.dart';

class Scanview extends StatelessWidget {
  const Scanview({super.key});

  @override
  Widget build(BuildContext context) {
    final BLEController blc = Get.find<BLEController>();
    blc.startScan();

    return Scaffold(
      appBar: _buildAppBar(blc),
      body: Container(
        color: backgroundGray,
        child: Obx(() => Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildDeviceList(blc),
            )),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BLEController blc) {
    return AppBar(
      title: const Text("Scanning Devices"),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryBlue, Color(0xFF153075)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            await blc.startScan();
            debugPrint("Refresh pressed");
          },
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: cardWhite.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildDeviceList(BLEController blc) {
    // Filter devices to only include those with a non-null and non-empty platformName
    final namedDevices = blc.devices
        .where((device) =>
            device.platformName != null && device.platformName!.isNotEmpty)
        .toList();

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: namedDevices.length, // Use the filtered list length
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final device = namedDevices[index]; // Use the filtered list
        return _buildDeviceTile(blc, device);
      },
    );
  }

  Widget _buildDeviceTile(BLEController blc, BluetoothDevice device) {
    return Obx(() {
      final isConnecting = blc.isConnecting.value;
      final isConnected =
          blc.connectionState.value == BluetoothConnectionState.connected;
      final isThisDeviceConnected =
          isConnected && blc.selectedDevice?.remoteId == device.remoteId;

      return Material(
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          tileColor: cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(
            Icons.devices_rounded,
            color: primaryBlue,
            size: 32,
          ),
          title: Text(
            device.platformName ?? 'Unknown Device',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            device.remoteId.str,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'RobotoMono',
            ),
          ),
          trailing: _buildConnectionStatus(
              isConnecting, isThisDeviceConnected, device),
          onTap: () => blc.connectToDevice(device),
        ),
      );
    });
  }

  Widget _buildConnectionStatus(
      bool isConnecting, bool isConnected, BluetoothDevice device) {
    if (isConnecting) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: primaryBlue,
        ),
      );
    }
    return Icon(
      isConnected ? Icons.check_circle_rounded : Icons.link_rounded,
      color: isConnected ? accentTeal : Colors.grey,
      size: 28,
    );
  }
}
