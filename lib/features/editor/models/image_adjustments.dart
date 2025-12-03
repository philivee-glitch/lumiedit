import 'package:equatable/equatable.dart';
import '../../../core/constants/editor_constants.dart';

class ImageAdjustments extends Equatable {
  // Basic adjustments
  final double brightness;
  final double contrast;
  final double saturation;
  final double warmth;
  final double exposure;
  final double highlights;
  final double shadows;
  final double sharpness;
  
  // Beauty adjustments (0-100 range)
  final double skinSmooth;
  final double blemishRemoval;
  final double skinTone;
  final double faceLight;
  
  // Filter
  final FilterType filter;

  const ImageAdjustments({
    this.brightness = 0.0,
    this.contrast = 0.0,
    this.saturation = 0.0,
    this.warmth = 0.0,
    this.exposure = 0.0,
    this.highlights = 0.0,
    this.shadows = 0.0,
    this.sharpness = 0.0,
    this.skinSmooth = 0.0,
    this.blemishRemoval = 0.0,
    this.skinTone = 0.0,
    this.faceLight = 0.0,
    this.filter = FilterType.none,
  });

  double getValue(AdjustmentType type) {
    switch (type) {
      case AdjustmentType.brightness:
        return brightness;
      case AdjustmentType.contrast:
        return contrast;
      case AdjustmentType.saturation:
        return saturation;
      case AdjustmentType.warmth:
        return warmth;
      case AdjustmentType.exposure:
        return exposure;
      case AdjustmentType.highlights:
        return highlights;
      case AdjustmentType.shadows:
        return shadows;
      case AdjustmentType.sharpness:
        return sharpness;
      case AdjustmentType.skinSmooth:
        return skinSmooth;
      case AdjustmentType.blemishRemoval:
        return blemishRemoval;
      case AdjustmentType.skinTone:
        return skinTone;
      case AdjustmentType.faceLight:
        return faceLight;
    }
  }

  ImageAdjustments copyWithAdjustment(AdjustmentType type, double value) {
    switch (type) {
      case AdjustmentType.brightness:
        return copyWith(brightness: value);
      case AdjustmentType.contrast:
        return copyWith(contrast: value);
      case AdjustmentType.saturation:
        return copyWith(saturation: value);
      case AdjustmentType.warmth:
        return copyWith(warmth: value);
      case AdjustmentType.exposure:
        return copyWith(exposure: value);
      case AdjustmentType.highlights:
        return copyWith(highlights: value);
      case AdjustmentType.shadows:
        return copyWith(shadows: value);
      case AdjustmentType.sharpness:
        return copyWith(sharpness: value);
      case AdjustmentType.skinSmooth:
        return copyWith(skinSmooth: value);
      case AdjustmentType.blemishRemoval:
        return copyWith(blemishRemoval: value);
      case AdjustmentType.skinTone:
        return copyWith(skinTone: value);
      case AdjustmentType.faceLight:
        return copyWith(faceLight: value);
    }
  }

  ImageAdjustments copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
    double? warmth,
    double? exposure,
    double? highlights,
    double? shadows,
    double? sharpness,
    double? skinSmooth,
    double? blemishRemoval,
    double? skinTone,
    double? faceLight,
    FilterType? filter,
  }) {
    return ImageAdjustments(
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      warmth: warmth ?? this.warmth,
      exposure: exposure ?? this.exposure,
      highlights: highlights ?? this.highlights,
      shadows: shadows ?? this.shadows,
      sharpness: sharpness ?? this.sharpness,
      skinSmooth: skinSmooth ?? this.skinSmooth,
      blemishRemoval: blemishRemoval ?? this.blemishRemoval,
      skinTone: skinTone ?? this.skinTone,
      faceLight: faceLight ?? this.faceLight,
      filter: filter ?? this.filter,
    );
  }

  bool get hasChanges =>
      brightness != 0.0 ||
      contrast != 0.0 ||
      saturation != 0.0 ||
      warmth != 0.0 ||
      exposure != 0.0 ||
      highlights != 0.0 ||
      shadows != 0.0 ||
      sharpness != 0.0 ||
      skinSmooth != 0.0 ||
      blemishRemoval != 0.0 ||
      skinTone != 0.0 ||
      faceLight != 0.0 ||
      filter != FilterType.none;

  bool get hasBeautyChanges =>
      skinSmooth != 0.0 ||
      blemishRemoval != 0.0 ||
      skinTone != 0.0 ||
      faceLight != 0.0;

  static const ImageAdjustments initial = ImageAdjustments();

  // AI Magic preset - optimized auto-enhancement values
  static const ImageAdjustments aiMagic = ImageAdjustments(
    brightness: 8,
    contrast: 12,
    saturation: 15,
    warmth: 5,
    exposure: 5,
    highlights: -10,
    shadows: -20,
    sharpness: 15,
  );

  // AI Beauty preset - natural skin enhancement
  static const ImageAdjustments aiBeauty = ImageAdjustments(
    skinSmooth: 45,
    blemishRemoval: 60,
    skinTone: 20,
    faceLight: 30,
    brightness: 5,
    contrast: 5,
  );

  // Combined AI Magic + Beauty
  static const ImageAdjustments aiComplete = ImageAdjustments(
    brightness: 8,
    contrast: 10,
    saturation: 12,
    warmth: 5,
    exposure: 5,
    highlights: -10,
    shadows: -20,
    sharpness: 10,
    skinSmooth: 40,
    blemishRemoval: 50,
    skinTone: 15,
    faceLight: 25,
  );

  @override
  List<Object?> get props => [
        brightness,
        contrast,
        saturation,
        warmth,
        exposure,
        highlights,
        shadows,
        sharpness,
        skinSmooth,
        blemishRemoval,
        skinTone,
        faceLight,
        filter,
      ];
}
