import 'package:ecgdisplay/wavectrl.dart';
import 'package:fl_chart/fl_chart.dart';
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
                  const SizedBox(height: 20),
                  Obx(() {
                    final timeStep =
                        wavctrl.sec.value / wavctrl.acquiredData.length;
                    return SizedBox(
                      height: 300, // Adjust height as needed
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 10,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval: wavctrl.sec.value / 5,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              color: Colors.blue,
                              spots: wavctrl.acquiredData
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final x = entry.key *
                                    timeStep; // Convert index to time.
                                final y = entry.value;

                                return FlSpot(x, y);
                              }).toList(),
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ]))
          ],
        ));
  }
}
