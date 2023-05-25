import 'dart:math' hide Point;
import 'dart:math';

import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:grwm_flutter_ai/services/sections_detection.dart';
import 'package:matrix2d/matrix2d.dart';

class AlgebraHelper {
  static Point findDiagonalIntersection(
      Point p1, Point p2, Point p3, Point p4) {
    // # Find intersection of two diagonals
    var x1 = p1.x, y1 = p1.y;
    var x2 = p2.x, y2 = p2.y;
    var x3 = p3.x, y3 = p3.y;
    var x4 = p4.x, y4 = p4.y;

    var a = y1 - y2;
    var b = x2 - x1;
    var c = y3 - y4;
    var d = x4 - x3;
    var y = (c * x3 + d * y3 - c * (x1 + b / a * y1)) / (d - c * b / a);
    var x = x1 + b / a * y1 - b / a * y;
    return Point(x.toInt(), y.toInt());
  }

  static double findSlope(Point pointA, Point pointB) {
    var x1 = pointA.x, y1 = pointA.y;
    var x2 = pointB.x, y2 = pointB.y;
    return (y1 - y2) / (x1 - x2);
  }

  static List<double> linearEquation(double slope, Point point) {
    //  # slope-intercept form of a line: y = mx + b
    //   # convert to standard form: Ax + By + C = 0
    //   # A = -m, B = 1, C = -(y - mx)

    var x1 = point.x, y1 = point.y; //# unpack the coordinates of the point
    var m = slope; //# slope of the line
    var A = -m;
    var B = 1.0;
    var C = -(y1 - m * x1);

    return [A, B, C];
  }

  static Point pointToLeft(num A, num B, num C, num d, Point point) {
    var x = point.x;
    var slope = -A / B;

    var cosAlpha = sqrt(1 / (1 + slope * slope));
    var dx = d * cosAlpha;
    var newX = x - dx;
    var newY = -(C + A * newX) / B;
    // Prevent point from stand still
    if (newX.toInt() == x) {
      newX++;
    }
    if (newY.toInt() == point.y) {
      newY++;
    }
    return Point(newX.toInt(), newY.toInt());
  }

  static Point pointToRight(num A, num B, num C, num d, Point point) {
    var x = point.x;
    var slope = -A / B;
    var cosAlpha = sqrt(1 / (1 + slope * slope));
    var dx = d * cosAlpha;
    var newX = x + dx;
    var newY = -(C + A * newX) / B;
    // Prevent point from stand still
    if (newX.toInt() == x) {
      newX++;
    }
    if (newY.toInt() == point.y) {
      newY++;
    }
    return Point(newX.toInt(), newY.toInt());
  }

  static Point pointDown(num A, num B, num C, num d, Point point) {
    var x = point.x, y = point.y;
    var slope = -A / B;
    var cosAlpha = sqrt(1 / (1 + slope * slope));
    var dy = d * cosAlpha;
    var newY = y + dy;
    double newX;
    if (slope > 0) {
      newX = x - sqrt(d * d - dy * dy);
    } else {
      newX = x + sqrt(d * d - dy * dy);
    }
    return Point(newX.toInt(), newY.toInt());
  }

  static Point pointUp(num A, num B, num C, num d, Point point) {
    var x = point.x, y = point.y;
    var slope = -A / B;
    var cosAlpha = sqrt(1 / (1 + slope * slope));
    var dy = d * cosAlpha;
    var newY = y - dy;
    double newX;
    if (slope > 0) {
      newX = x + sqrt(d * d - dy * dy);
    } else {
      newX = x - sqrt(d * d - dy * dy);
    }
    return Point(newX.toInt(), newY.toInt());
  }

  static Section breadthPoint(double slope, Point p, List<dynamic> image,
      {double confidence = 0.7}) {
    var listParams = linearEquation(slope, p);
    var A = listParams[0], B = listParams[1], C = listParams[2];
    var point = p;
    while (image[point.y][point.x] > confidence) {
      point = pointToRight(A, B, C, 5, point);
    }
    var right = point;
    point = p;
    while (image[point.y][point.x] > confidence) {
      point = pointToLeft(A, B, C, 5, point);
    }

    var left = point;
    return Section(left, right);
  }

  static distance2Points(Point a, Point b) {
    var x1 = a.x, y1 = a.y;
    var x2 = b.x, y2 = b.y;
    return sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * y2 - y1);
  }

  static List<dynamic> to2Darray(SegmentationMask mask) {
    var width = mask.width;
    var height = mask.height;
    final newConfidences = mask.confidences.reshape(height, width);
    return newConfidences;
  }
}
