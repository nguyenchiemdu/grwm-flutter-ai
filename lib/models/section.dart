import 'dart:math';

import 'package:grwm_flutter_ai/models/point.dart';

class Section {
  Point start;
  Point end;
  Section(this.start, this.end);
  @override
  String toString() {
    return "[$start, $end]";
  }

  double get length {
    return sqrt((start.x - end.x) * (start.x - end.x) +
        (start.y - end.y) * (start.y - end.y));
  }
}
