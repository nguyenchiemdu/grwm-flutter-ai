import 'package:grwm_flutter_ai/models/section.dart';

class LogParams {
  // The confidences when detect the mask
  final double confidenceParameter;
  // The acceptable ration between leftside and rightside of midsection
  final double midsectionDeltaRatio;
  // The vertical expansion of the midsection in percentage
  final double midsectionExpandPercent;
  // THe acceptable ration between old section and new section when expanding in the
  // vertical side of the midsection
  final double midsectionExpandRatio;
  final int midsectionMinNoOfLines;
  // Shoulder section
  final Section a1;
  // Waist section
  final Section? a2;
  // Hip section
  final Section a3;
  final String imagePath;
  LogParams(
      {required this.confidenceParameter,
      required this.midsectionDeltaRatio,
      required this.midsectionExpandPercent,
      required this.midsectionExpandRatio,
      required this.midsectionMinNoOfLines,
      required this.a1,
      this.a2,
      required this.a3,
      required this.imagePath});
  Map toMap() {
    Map json = {
      "imgPath": imagePath,
      "confidence": confidenceParameter,
      "midsectionDeltaRatio": midsectionDeltaRatio,
      "midsectionExpandPercent": midsectionExpandPercent,
      "midsectionExpandRatio": midsectionExpandRatio,
      "midsectionMinNoOfLines": midsectionMinNoOfLines,
      "a1": a1.toMap(),
      "a2": a2?.toMap(),
      "a3": a3.toMap(),
    };
    return json;
    // return jsonEncode(json);
  }
}
