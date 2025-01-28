class PanTompkins {
  static const int samplingRate = 360; // Assuming a sampling rate of 360 Hz
  static const double lowCutoff = 5.0;
  static const double highCutoff = 15.0;
  static const int windowWidth = 43; // 120 ms window (0.12 * 360 ≈ 43)

  List<double> _bandpassFilter(List<double> ecgData) {
    // Implement a bandpass filter (low cutoff: 5 Hz, high cutoff: 15 Hz)
    // This is a simplified version; in practice, you would use a proper filter design.
    List<double> filteredData = [];
    for (int i = 2; i < ecgData.length; i++) {
      filteredData.add(ecgData[i] - 2 * ecgData[i - 1] + ecgData[i - 2]);
    }
    return filteredData;
  }

  List<double> _differentiate(List<double> ecgData) {
    // Differentiation to highlight the QRS complex
    List<double> differentiatedData = [];
    for (int i = 1; i < ecgData.length; i++) {
      differentiatedData.add((ecgData[i] - ecgData[i - 1]) / 2);
    }
    return differentiatedData;
  }

  List<double> _square(List<double> ecgData) {
    // Squaring to make all data points positive and emphasize higher frequencies
    return ecgData.map((value) => value * value).toList();
  }

  List<double> _movingWindowIntegration(List<double> ecgData) {
    // Moving window integration to smooth the data
    List<double> integratedData = List.filled(ecgData.length, 0.0);
    for (int i = windowWidth; i < ecgData.length; i++) {
      double sum = 0.0;
      for (int j = 0; j < windowWidth; j++) {
        sum += ecgData[i - j];
      }
      integratedData[i] = sum / windowWidth;
    }
    return integratedData;
  }

  List<int> _findPeaks(List<double> ecgData) {
    // Adaptive thresholding to detect peaks
    List<int> peaks = [];
    double threshold = 0.0;
    for (int i = 1; i < ecgData.length - 1; i++) {
      if (ecgData[i] > ecgData[i - 1] && ecgData[i] > ecgData[i + 1]) {
        if (ecgData[i] > threshold) {
          peaks.add(i);
          threshold = ecgData[i] * 0.75; // Adjust threshold dynamically
        }
      }
    }
    return peaks;
  }

  int calculateBPM(List<double> ecgData) {
    List<double> filteredData = _bandpassFilter(ecgData);
    List<double> differentiatedData = _differentiate(filteredData);
    List<double> squaredData = _square(differentiatedData);
    List<double> integratedData = _movingWindowIntegration(squaredData);
    List<int> peaks = _findPeaks(integratedData);

    if (peaks.isEmpty) return 0;

    // Calculate average RR interval
    double totalRRInterval = 0.0;
    for (int i = 1; i < peaks.length; i++) {
      totalRRInterval += peaks[i] - peaks[i - 1];
    }
    double averageRRInterval = totalRRInterval / (peaks.length - 1);

    // Calculate BPM
    double bpm = (60.0 * samplingRate) / averageRRInterval;
    return bpm.round();
  }
}
