import 'package:newtest/bltctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Scanview extends StatelessWidget {
  const Scanview({super.key});

  @override
  Widget build(BuildContext context) {
    final BLEController blc = Get.find<BLEController>();
    blc.startScan();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanning devices"),
        actions: [
          IconButton(
            onPressed: () async {
              await blc.startScan();
              debugPrint("button pressed again");
            },
            icon: Icon(
              Icons.refresh,
            ),
          )
        ],
      ),
      body: Obx(() => ListView.builder(
            itemCount: blc.devices.length, // Add this
            itemBuilder: (context, index) {
              return ListTile(
                title:
                    Text(blc.devices[index].platformName ?? 'Unknown Device'),
                onTap: () => blc.connectToDevice(blc.devices[index]),
              );
            },
          )),
    );
  }
}
