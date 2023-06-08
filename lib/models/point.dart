class Point {
  int x, y;
  Point(this.x, this.y);
  @override
  String toString() {
    return "{$x, $y}";
  }

  Map toMap() {
    return {
      "x": x,
      "y": y,
    };
  }
}
