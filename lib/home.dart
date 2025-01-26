import 'package:newtest/bltctrl.dart';
import 'package:newtest/realtime.dart';
import 'package:newtest/wavedisp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newtest/scanview.dart';

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
              title: const Text(
                "ECG Monitor",
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Get.to(() => const Scanview()),
                    child: const Text("Start scan"),
                  ),
                  const SizedBox(height: 10),
                  // Data display with proper Obx wrapping
                  Obx(() => Text(
                        blc.receivedData.value,
                      )),
                  const SizedBox(height: 10),
                  // Connection state and acquisition button
                  Obx(() {
                    final isConnected = blc.connectionState.value.toString() ==
                        "BluetoothConnectionState.connected";

                    return Column(
                      children: [
                        Text(
                          "Status: ${isConnected ? 'Connected' : 'Not Connected'}",
                          style: TextStyle(
                            color: isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                        if (isConnected) ...[
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Get.to(() => const WaveDisp()),
                            child: const Text("Start Acquisition"),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            child: Text("View realtime data"),
                            onPressed: () => Get.to(
                              () => const LineGraphScreen(),
                            ),
                          )
                        ],
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
