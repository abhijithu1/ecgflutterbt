import 'package:ecgdisplay/bltctrl.dart';
import 'package:ecgdisplay/home.dart';
import 'package:ecgdisplay/wavectrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bleController = Get.put(BLEController());
    final wav = Get.put(WaveController());
    return GetMaterialApp(
      title: "ECG monitor",
      getPages: [
        GetPage(
          name: '/',
          page: () => HomeScreen(),
        ),
      ],
      initialRoute: '/',
    );
  }
}
