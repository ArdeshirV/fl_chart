import 'package:equatable/equatable.dart';

import 'line_chart_data.dart';

/// Contains anything that helps LineChart works
class LineChartHelper {

  /// Contains List of cached results, base on [List<LineChartBarData>]
  ///
  /// We use it to prevent redundant calculations
  static final Map<List<LineChartBarData>, LineChartMinMaxAxisValues> _cachedResults = {};

  static LineChartMinMaxAxisValues calculateMaxAxisValues(List<LineChartBarData> lineBarsData) {
    if (lineBarsData.isEmpty) {
      return LineChartMinMaxAxisValues(0, 0, 0, 0);
    }

    if (_cachedResults.containsKey(lineBarsData)) {
      return _cachedResults[lineBarsData]!.copyWith(readFromCache: true);
    }

    for (var i = 0; i < lineBarsData.length; i++) {
      final lineBarChart = lineBarsData[i];
      if (lineBarChart.spots.isEmpty) {
        throw Exception('spots could not be null or empty');
      }
    }


    var minX = lineBarsData[0].spots[0].x;
    var maxX = lineBarsData[0].spots[0].x;
    var minY = lineBarsData[0].spots[0].y;
    var maxY = lineBarsData[0].spots[0].y;

    for (var i = 0; i < lineBarsData.length; i++) {
      final barData = lineBarsData[i];
      for (var j = 0; j < barData.spots.length; j++) {
        final spot = barData.spots[j];
        if (spot.isNotNull()) {
          if (spot.x > maxX) {
            maxX = spot.x;
          }

          if (spot.x < minX) {
            minX = spot.x;
          }

          if (spot.y > maxY) {
            maxY = spot.y;
          }

          if (spot.y < minY) {
            minY = spot.y;
          }
        }
      }
    }

    final result = LineChartMinMaxAxisValues(minX, maxX, minY, maxY);
    _cachedResults[lineBarsData] = result;
    return result;
  }

}

extension LineChartDataExtension on LineChartBarData {
  
  /// Returns colorStops
  /// 
  /// if [colorStops] provided, returns it directly, 
  /// Otherwise we calculate it using colors list
  List<double> getColorStops() {
    var stops = <double>[];
    if (colorStops == null || colorStops!.length != colors.length) {
      /// provided colorStops is invalid and we calculate it here
      colors.asMap().forEach((index, color) {
        final percent = 1.0 / colors.length;
        stops.add(percent * index);
      });
    } else {
      stops = colorStops!;
    }
    return stops;
  }
  
}


/// Holds minX, maxX, minY, and maxY for use in [LineChartData]
class LineChartMinMaxAxisValues with EquatableMixin {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final bool readFromCache;

  LineChartMinMaxAxisValues(
    this.minX,
    this.maxX,
    this.minY,
    this.maxY, {
    this.readFromCache = false,
  });

  @override
  List<Object?> get props => [
    minX,
    maxX,
    minY,
    maxY,
    readFromCache
  ];

  LineChartMinMaxAxisValues copyWith({
    double? minX,
    double? maxX,
    double? minY,
    double? maxY,
    bool? readFromCache
  }) {
    return LineChartMinMaxAxisValues(
      minX ?? this.minX,
      maxX ?? this.maxX,
      minY ?? this.minY,
      maxY ?? this.maxY,
      readFromCache: readFromCache ?? this.readFromCache,
    );
  }
}