import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:newtest/bltctrl.dart';

// Reusing the color scheme from HomeScreen
const Color primaryBlue = Color(0xFF2A4BA0);
const Color accentTeal = Color(0xFF00C9AC);
const Color backgroundGray = Color(0xFFF8F9FA);
const Color cardWhite = Color(0xFFFFFFFF);

class LineGraphScreen extends StatefulWidget {
  const LineGraphScreen({Key? key}) : super(key: key);

  @override
  _LineGraphScreenState createState() => _LineGraphScreenState();
}

class _LineGraphScreenState extends State<LineGraphScreen> {
  final List<FlSpot> _dataPoints = [];
  final int _maxVisiblePoints = 100;
  final double _timeStep = 0.1;
  final ValueNotifier<List<FlSpot>> _notifier = ValueNotifier([]);
  double _minY = double.infinity;
  double _maxY = double.negativeInfinity;
  final double _xAxisDuration = 10.0;

  @override
  void initState() {
    super.initState();
    final bleController = Get.find<BLEController>();
    bleController.receivedData.listen((data) {
      _updateChartData(data);
    });
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  void _updateChartData(String data) {
    try {
      final values =
          data.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).toList();

      for (var value in values) {
        _minY = _minY == double.infinity ? value : min(_minY, value);
        _maxY = _maxY == double.negativeInfinity ? value : max(_maxY, value);

        final newPoint = FlSpot(
          _dataPoints.isEmpty ? 0 : _dataPoints.last.x + _timeStep,
          value,
        );
        _dataPoints.add(newPoint);

        if (_dataPoints.length > _maxVisiblePoints) {
          _dataPoints.removeAt(0);
        }
      }

      _notifier.value = List<FlSpot>.from(_dataPoints);
      setState(() {});
    } catch (e) {
      debugPrint('Error parsing data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: const Text(
          'Real-time ECG',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
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
        elevation: 0,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation != Orientation.landscape) {
            return Center(
              child: Container(
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
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.screen_rotation, size: 48, color: primaryBlue),
                    SizedBox(height: 16),
                    Text(
                      "Please rotate your device",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: ValueListenableBuilder<List<FlSpot>>(
              valueListenable: _notifier,
              builder: (context, dataPoints, _) {
                if (dataPoints.isEmpty) {
                  return Center(
                    child: Container(
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: primaryBlue,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            "Awaiting ECG data...",
                            style: TextStyle(
                              fontSize: 16,
                              color: primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final double yInterval = ((_maxY - _minY) / 5).clamp(1, 100);
                final double xInterval = (_xAxisDuration / 5);

                return Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: yInterval,
                          verticalInterval: xInterval,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          ),
                          getDrawingVerticalLine: (value) => FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: yInterval,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: xInterval,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toStringAsFixed(1)}s',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            curveSmoothness: 0.35,
                            color: accentTeal,
                            gradient: const LinearGradient(
                              colors: [primaryBlue, accentTeal],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            barWidth: 3,
                            spots: dataPoints,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  accentTeal.withOpacity(0.2),
                                  primaryBlue.withOpacity(0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        minX: dataPoints.isNotEmpty
                            ? dataPoints.last.x - _xAxisDuration
                            : 0,
                        maxX: dataPoints.isNotEmpty
                            ? dataPoints.last.x
                            : _xAxisDuration,
                        minY: _minY - (_maxY - _minY) * 0.05,
                        maxY: _maxY + (_maxY - _minY) * 0.05,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  double min(double a, double b) => a < b ? a : b;
  double max(double a, double b) => a > b ? a : b;
}
