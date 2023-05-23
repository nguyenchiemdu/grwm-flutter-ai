import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:matrix2d/matrix2d.dart';

import '../commons/algebra_helper.dart';


class SegmentationPainter extends CustomPainter {
  final SegmentationMask mask;
  final Size absoluteImageSize;
  final Color color = Colors.red;
  final InputImageRotation rotation;
  final double confidenceRange;
  SegmentationPainter(this.mask, this.absoluteImageSize, this.rotation,
      {this.confidenceRange = 0.7});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    final width = mask.width;
    final height = mask.height;
    final confidences = AlgebraHelper.to2Darray(mask, mask.confidences);
    // log(mask.confidences.shape.toString());
    // log(confidences.shape.toString());

    final paint = Paint()..style = PaintingStyle.fill;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int tx = transformX(x.toDouble(), size).round();
        final int ty = transformY(y.toDouble(), size).round();
        //final double opacity = confidences[(y * width) + x] * 0.25;
        
        // if (confidences[(y * width) + x] > confidenceRange) {
        //   paint.color = color.withOpacity(1);
        // } else {
        //   paint.color = color.withOpacity(0);
        // }
        
        if (confidences[y][x] > confidenceRange) {
          paint.color = color.withOpacity(1);
        } else {
          paint.color = color.withOpacity(0);
        }

        if (rotation == InputImageRotation.rotation90deg) {
          canvas.drawCircle(
              Offset(
                ty.toDouble(),
                tx.toDouble(),
              ),
              1,
              paint);
        } else {
          canvas.drawCircle(
              Offset(
                tx.toDouble(),
                ty.toDouble(),
              ),
              1,
              paint);
        }
      }
    }
  }

  double transformX(double x, Size size) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return x * size.width / absoluteImageSize.height;
      // case InputImageRotation.rotation270deg:
      //   return size.width - x * size.width / absoluteImageSize.height;
      default:
        return x * size.width / absoluteImageSize.width;
    }
  }

  double transformY(double y, Size size) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return 3 / 4 * size.height - y * size.height / absoluteImageSize.width;
      // case InputImageRotation.rotation270deg:
      //   return y * size.height / absoluteImageSize.width;
      default:
        return y * size.height / absoluteImageSize.height;
    }
  }

  @override
  bool shouldRepaint(SegmentationPainter oldDelegate) {
    return oldDelegate.mask != mask;
  }
}
