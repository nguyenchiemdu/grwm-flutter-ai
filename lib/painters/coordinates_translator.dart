import 'dart:io';
import 'dart:ui';

import 'package:google_mlkit_commons/google_mlkit_commons.dart';

double translateX(
    double x, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x *
          size.width /
          (Platform.isIOS && 1 > 1
              ? absoluteImageSize.width
              : absoluteImageSize.height);
    case InputImageRotation.rotation270deg:
      return size.width -
          x *
              size.width /
              (Platform.isIOS
                  ? absoluteImageSize.width
                  : absoluteImageSize.height);
    default:
      return x * size.width / absoluteImageSize.width;
  }
}

double translateY(
    double y, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.rotation270deg:
    case InputImageRotation.rotation90deg:
      return 3 / 4 * size.height -
          y *
              size.height /
              (Platform.isIOS && 1 > 1
                  ? absoluteImageSize.height
                  : absoluteImageSize.width);
    default:
      return y * size.height / absoluteImageSize.height;
  }
}
