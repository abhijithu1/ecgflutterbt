import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:newtest/bltctrl.dart';

class LineGraphScreen extends StatefulWidget {
  const LineGraphScreen({Key? key}) : super(key: key);

  @override
  _LineGraphScreenState createState() => _LineGraphScreenState();
}

class _LineGraphScreenState extends State<LineGraphScreen> {
  final List<FlSpot> _dataPoints = [];
  final int _maxVisiblePoints = 100; // Adjusted to accommodate more data
  final double _timeStep = 0.1;
  final ValueNotifier<List<FlSpot>> _notifier = ValueNotifier([]);
  double _minY = double.infinity;
  double _maxY = double.negativeInfinity;
  final double _xAxisDuration = 10.0; // 10-second x-axis duration

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
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation != Orientation.landscape) {
            return const Center(
              child: Text("Please rotate device to landscape mode"),
            );
          }

          return SafeArea(
            child: ValueListenableBuilder<List<FlSpot>>(
              valueListenable: _notifier,
              builder: (context, dataPoints, _) {
                if (dataPoints.isEmpty) {
                  return const Center(
                    child: Text("Waiting for data..."),
                  );
                }

                // Calculate intervals dynamically
                final double yInterval = ((_maxY - _minY) / 5).clamp(1, 100);
                final double xInterval = (_xAxisDuration / 5);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: yInterval,
                        verticalInterval: xInterval,
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: yInterval,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toStringAsFixed(1)}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: xInterval,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toStringAsFixed(1)}s',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: Colors.blue,
                          spots: dataPoints,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      minX: dataPoints.isNotEmpty
                          ? dataPoints.last.x - _xAxisDuration
                          : 0,
                      maxX: dataPoints.isNotEmpty
                          ? dataPoints.last.x
                          : _xAxisDuration,
                      minY: _minY - (_maxY - _minY) * 0.05, // Reduced padding
                      maxY: _maxY + (_maxY - _minY) * 0.05,
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
