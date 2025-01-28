import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:newtest/bltctrl.dart';
import 'package:newtest/realtime.dart';
import 'package:newtest/wavedisp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newtest/scanview.dart';

const Color primaryBlue = Color(0xFF2A4BA0);
const Color accentTeal = Color(0xFF00C9AC);
const Color backgroundGray = Color(0xFFF8F9FA);
const Color cardWhite = Color(0xFFFFFFFF);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BLEController blc = Get.find<BLEController>();

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  "ECG Monitor",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryBlue, Color(0xFF153075)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildScanButton(context),
                    const SizedBox(height: 24),
                    _buildConnectionStatus(blc),
                    const SizedBox(height: 24),
                    _buildDataDisplay(blc),
                    const SizedBox(height: 32),
                    _buildConnectedButtons(blc),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.bluetooth, size: 24),
      label: const Text("Scan Devices", style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      onPressed: () => Get.to(() => const Scanview()),
    );
  }

  Widget _buildConnectionStatus(BLEController blc) {
    return Obx(() {
      final isConnected =
          blc.connectionState.value == BluetoothConnectionState.connected;

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isConnected ? Icons.link : Icons.link_off,
              color: isConnected ? accentTeal : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              isConnected ? 'Device Connected' : 'Not Connected',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isConnected ? accentTeal : Colors.red,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDataDisplay(BLEController blc) {
    return Obx(() => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ECG Data Stream:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                blc.receivedData.value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildConnectedButtons(BLEController blc) {
    return Obx(() {
      final isConnected =
          blc.connectionState.value == BluetoothConnectionState.connected;
      if (!isConnected) return const SizedBox.shrink();

      return Column(
        children: [
          _buildActionButton(
            icon: Icons.play_arrow_rounded,
            label: "Start Acquisition",
            onPressed: () => Get.to(() => const WaveDisp()),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: Icons.show_chart_rounded,
            label: "Realtime Data",
            onPressed: () => Get.to(() => const LineGraphScreen()),
          ),
        ],
      );
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: cardWhite,
        foregroundColor: primaryBlue,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: primaryBlue, width: 2),
        ),
        elevation: 2,
      ),
      onPressed: onPressed,
    );
  }
}
