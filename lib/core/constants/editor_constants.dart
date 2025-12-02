import 'package:flutter/material.dart';

enum AdjustmentType {
  brightness,
  contrast,
  saturation,
  warmth,
  exposure,
  highlights,
  shadows,
  sharpness,
  // Beauty adjustments
  skinSmooth,
  blemishRemoval,
  skinTone,
  faceLight,
}

extension AdjustmentTypeExtension on AdjustmentType {
  IconData get icon {
    switch (this) {
      case AdjustmentType.brightness:
        return Icons.brightness_6_rounded;
      case AdjustmentType.contrast:
        return Icons.contrast_rounded;
      case AdjustmentType.saturation:
        return Icons.palette_rounded;
      case AdjustmentType.warmth:
        return Icons.thermostat_rounded;
      case AdjustmentType.exposure:
        return Icons.exposure_rounded;
      case AdjustmentType.highlights:
        return Icons.wb_sunny_rounded;
      case AdjustmentType.shadows:
        return Icons.nights_stay_rounded;
      case AdjustmentType.sharpness:
        return Icons.deblur_rounded;
      case AdjustmentType.skinSmooth:
        return Icons.face_retouching_natural_rounded;
      case AdjustmentType.blemishRemoval:
        return Icons.healing_rounded;
      case AdjustmentType.skinTone:
        return Icons.color_lens_rounded;
      case AdjustmentType.faceLight:
        return Icons.light_mode_rounded;
    }
  }

  String get label {
    switch (this) {
      case AdjustmentType.brightness:
        return 'Light';
      case AdjustmentType.contrast:
        return 'Contrast';
      case AdjustmentType.saturation:
        return 'Vibrance';
      case AdjustmentType.warmth:
        return 'Warmth';
      case AdjustmentType.exposure:
        return 'Exposure';
      case AdjustmentType.highlights:
        return 'Highlights';
      case AdjustmentType.shadows:
        return 'Shadows';
      case AdjustmentType.sharpness:
        return 'Sharpen';
      case AdjustmentType.skinSmooth:
        return 'Smooth';
      case AdjustmentType.blemishRemoval:
        return 'Blemish';
      case AdjustmentType.skinTone:
        return 'Tone';
      case AdjustmentType.faceLight:
        return 'Glow';
    }
  }

  bool get isBeauty {
    return this == AdjustmentType.skinSmooth ||
        this == AdjustmentType.blemishRemoval ||
        this == AdjustmentType.skinTone ||
        this == AdjustmentType.faceLight;
  }

  double get minValue => isBeauty ? 0 : -100;
  double get maxValue => 100;
}

enum FilterType {
  none,
  aurora,
  velvet,
  midnight,
  golden,
  arctic,
  noir,
  bloom,
  ember,
}

extension FilterTypeExtension on FilterType {
  String get label {
    switch (this) {
      case FilterType.none:
        return 'Original';
      case FilterType.aurora:
        return 'Aurora';
      case FilterType.velvet:
        return 'Velvet';
      case FilterType.midnight:
        return 'Midnight';
      case FilterType.golden:
        return 'Golden';
      case FilterType.arctic:
        return 'Arctic';
      case FilterType.noir:
        return 'Noir';
      case FilterType.bloom:
        return 'Bloom';
      case FilterType.ember:
        return 'Ember';
    }
  }
}

enum EditorTab {
  adjust,
  beauty,
  filters,
  crop,
}

extension EditorTabExtension on EditorTab {
  IconData get icon {
    switch (this) {
      case EditorTab.adjust:
        return Icons.tune_rounded;
      case EditorTab.beauty:
        return Icons.auto_fix_high_rounded;
      case EditorTab.filters:
        return Icons.filter_vintage_rounded;
      case EditorTab.crop:
        return Icons.crop_rotate_rounded;
    }
  }

  String get label {
    switch (this) {
      case EditorTab.adjust:
        return 'Adjust';
      case EditorTab.beauty:
        return 'Beauty';
      case EditorTab.filters:
        return 'Filters';
      case EditorTab.crop:
        return 'Crop';
    }
  }
}

enum CropAspectRatio {
  free,
  square,
  ratio4x3,
  ratio16x9,
  ratio9x16,
}

extension CropAspectRatioExtension on CropAspectRatio {
  String get label {
    switch (this) {
      case CropAspectRatio.free:
        return 'Free';
      case CropAspectRatio.square:
        return '1:1';
      case CropAspectRatio.ratio4x3:
        return '4:3';
      case CropAspectRatio.ratio16x9:
        return '16:9';
      case CropAspectRatio.ratio9x16:
        return '9:16';
    }
  }

  double? get value {
    switch (this) {
      case CropAspectRatio.free:
        return null;
      case CropAspectRatio.square:
        return 1.0;
      case CropAspectRatio.ratio4x3:
        return 4 / 3;
      case CropAspectRatio.ratio16x9:
        return 16 / 9;
      case CropAspectRatio.ratio9x16:
        return 9 / 16;
    }
  }
}

class EditorConstants {
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
