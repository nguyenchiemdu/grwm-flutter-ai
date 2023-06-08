class ModelConst {
  // reshape input image to faster the rendering
  static const maxWidth = 500.0;
  static const maxHeight = 1200.0;
  // The confidences when detect the mask
  static const confidenceParameter = 0.7;
  // The acceptable ration between leftside and rightside of midsection
  static const midsectionDeltaRatio = 0.85;
  // The vertical expansion of the midsection in percentage
  static const midsectionExpandPercent = 0.2; // 20%
  // THe acceptable ration between old section and new section when expanding in the
  // vertical side of the midsection
  static const midsectionExpandRatio = 1.1;
  // The minimum acceptable number of sections detected when expanding in the vertical side
  static const midsectionMinNoOfLines = 3;

  // parameters for determining the body shape
  static const rectangleBottomRatio = 0.95;
  static const rectangleTopRatio = 1;
  static const hourglassA1A3Bot = 0.95;
  static const hourglassA1A3Top = 1;
  static const hourglassA2A3Top = 0.85;
  static const triangleRatio = 1;
  static const invertedTriangleRatio = 1;
}
