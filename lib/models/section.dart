import 'dart:math';

import 'package:grwm_flutter_ai/commons/algebra_helper.dart';
import 'package:grwm_flutter_ai/models/point.dart';

class Section {
  Point start;
  Point end;
  Point? mid;
  Section(this.start, this.end, {this.mid});
  @override
  String toString() {
    return "[$start, $end], mid: $mid";
  }

  String getDistanceToMid() {
    double r = AlgebraHelper.distance2Points(end, mid!);
    double l = AlgebraHelper.distance2Points(start, mid!);
    return '[$l,$r]';
  }

  double getMiddleDistanceToLeft() {
    return AlgebraHelper.distance2Points(start, mid!);
  }

  double getMiddleDistanceToRight() {
    return AlgebraHelper.distance2Points(end, mid!);
  }

  double get length {
    return sqrt((start.x - end.x) * (start.x - end.x) +
        (start.y - end.y) * (start.y - end.y));
  }

  bool operator >(Section other) {
    return length > other.length;
  }

  bool operator <(Section other) {
    return length < other.length;
  }

  double operator /(Section other) {
    return length / other.length;
  }

  Map toMap() {
    return {"start": start.toMap(), "end": end.toMap(), "length": length};
  }
}
