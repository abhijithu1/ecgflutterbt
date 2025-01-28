import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newtest/wavectrl.dart';

// Theme colors from HomeScreen
const Color primaryBlue = Color(0xFF2A4BA0);
const Color accentTeal = Color(0xFF00C9AC);
const Color backgroundGray = Color(0xFFF8F9FA);
const Color cardWhite = Color(0xFFFFFFFF);

class WaveDisp extends StatelessWidget {
  const WaveDisp({super.key});

  @override
  Widget build(BuildContext context) {
    final wavctrl = Get.find<WaveController>();

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: const Text(
          "ECG Waveform",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, Color(0xFF153075)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildAcquisitionCard(wavctrl),
              const SizedBox(height: 20),
              _buildProgressIndicator(wavctrl),
              const SizedBox(height: 20),
              _buildECGGraph(wavctrl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcquisitionCard(WaveController wavctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            "Acquisition Duration",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: wavctrl.time1.value,
            decoration: InputDecoration(
              hintText: "Enter duration in seconds",
              filled: true,
              fillColor: backgroundGray,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.timer, color: primaryBlue),
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => wavctrl.settime(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                "Start Acquisition",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(WaveController wavctrl) {
    return Obx(() {
      if (wavctrl.sec.value == 0) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: const EdgeInsets.all(20),
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
          children: [
            CircularProgressIndicator(
              value: wavctrl.progress.value,
              strokeWidth: 8,
              valueColor: const AlwaysStoppedAnimation(accentTeal),
              backgroundColor: backgroundGray,
            ),
            const SizedBox(height: 12),
            Text(
              "${(wavctrl.progress.value * 100).toInt()}% Complete",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: primaryBlue,
              ),
            ),
            wavctrl.startacq.value
                ? Text("BPM: not found")
                : Text("BPM: ${wavctrl.bpm}")
          ],
        ),
      );
    });
  }

  Widget _buildECGGraph(WaveController wavctrl) {
    return Obx(() {
      if (wavctrl.acquiredData.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        height: 300,
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
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 10,
              verticalInterval: 10,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 10,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 10,
                  reservedSize: 22,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: accentTeal,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: accentTeal.withOpacity(0.1),
                ),
                spots: wavctrl.acquiredData.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value);
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });
  }
}
