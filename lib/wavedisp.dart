import 'package:ecgdisplay/wavectrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaveDisp extends StatelessWidget {
  const WaveDisp({super.key});

  @override
  Widget build(BuildContext context) {
    final wavctrl = Get.find<WaveController>();
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Display Wave",
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
                delegate: SliverChildListDelegate([
              Column(
                children: [
                  Text("Enter time for acquisition: "),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: wavctrl.time1.value,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      filled: true,
                      fillColor: const Color.fromARGB(255, 238, 255, 253),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextButton(
                    child: Text("Submit"),
                    onPressed: () {
                      wavctrl.settime();
                    },
                  ),
                  SizedBox(height: 20),
                  Obx(() {
                    if (wavctrl.sec.value == 0) {
                      return Text("Enter a nonzero number");
                    } else {
                      return CircularProgressIndicator(
                        value: wavctrl.progress.value,
                        strokeWidth: 8,
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                        backgroundColor: Colors.grey[300],
                      );
                    }
                  }),
                ],
              ),
            ]))
          ],
        ));
  }
}
