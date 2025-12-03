import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../constants/editor_constants.dart';
import '../../features/editor/models/image_adjustments.dart';

class ProcessingParams {
  final Uint8List imageBytes;
  final ImageAdjustments adjustments;

  ProcessingParams(this.imageBytes, this.adjustments);

  static Future<Uint8List> rotateImage(Uint8List imageBytes, int degrees) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;
    
    img.Image rotated;
    switch (degrees % 360) {
      case 90:
      case -270:
        rotated = img.copyRotate(image, angle: 90);
        break;
      case 180:
      case -180:
        rotated = img.copyRotate(image, angle: 180);
        break;
      case 270:
      case -90:
        rotated = img.copyRotate(image, angle: 270);
        break;
      default:
        rotated = image;
    }
    
    return Uint8List.fromList(img.encodeJpg(rotated, quality: 95));
  }
}

class ImageProcessor {
  static Future<Uint8List> processImage(
    Uint8List imageBytes,
    ImageAdjustments adjustments,
  ) async {
    return compute(_processImageIsolate, ProcessingParams(imageBytes, adjustments));
  }

  static Uint8List _processImageIsolate(ProcessingParams params) {
    final imageBytes = params.imageBytes;
    final adjustments = params.adjustments;

    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    // Resize for faster processing
    if (image.width > 1600 || image.height > 1600) {
      image = img.copyResize(
        image,
        width: image.width > image.height ? 1600 : null,
        height: image.height >= image.width ? 1600 : null,
        interpolation: img.Interpolation.linear,
      );
    }

    // Apply adjustments
    if (adjustments.exposure != 0) {
      image = _applyExposure(image, adjustments.exposure);
    }
    if (adjustments.brightness != 0) {
      image = _applyBrightness(image, adjustments.brightness);
    }
    if (adjustments.contrast != 0) {
      image = _applyContrast(image, adjustments.contrast);
    }
    if (adjustments.highlights != 0) {
      image = _applyHighlights(image, adjustments.highlights);
    }
    if (adjustments.shadows != 0) {
      image = _applyShadows(image, adjustments.shadows);
    }
    if (adjustments.saturation != 0) {
      image = _applySaturation(image, adjustments.saturation);
    }
    if (adjustments.warmth != 0) {
      image = _applyWarmth(image, adjustments.warmth);
    }
    if (adjustments.sharpness != 0) {
      image = _applySharpness(image, adjustments.sharpness);
    }
    
    // Beauty adjustments
    if (adjustments.skinSmooth > 0) {
      image = _applySkinSmoothing(image, adjustments.skinSmooth);
    }
    if (adjustments.blemishRemoval > 0) {
      image = _applyBlemishRemoval(image, adjustments.blemishRemoval);
    }
    if (adjustments.skinTone > 0) {
      image = _applySkinTone(image, adjustments.skinTone);
    }
    if (adjustments.faceLight > 0) {
      image = _applyFaceLight(image, adjustments.faceLight);
    }
    
    // Apply filter last
    if (adjustments.filter != FilterType.none) {
      image = _applyFilter(image, adjustments.filter);
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 92));
  }

  // ==================== BASIC ADJUSTMENTS ====================

  static img.Image _applyBrightness(img.Image src, double value) {
    // Simple additive brightness: -100 to 100 maps to -100 to +100 pixel value change
    final adj = (value * 1.0).round();
    
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        src.setPixelRgba(
          x, y,
          (pixel.r + adj).clamp(0, 255).toInt(),
          (pixel.g + adj).clamp(0, 255).toInt(),
          (pixel.b + adj).clamp(0, 255).toInt(),
          pixel.a.toInt(),
        );
      }
    }
    return src;
  }

  static img.Image _applyExposure(img.Image src, double value) {
    // Multiplicative exposure: -100 to 100 maps to 0.5x to 2x
    final factor = math.pow(2, value / 100).toDouble();
    
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        src.setPixelRgba(
          x, y,
          (pixel.r * factor).clamp(0, 255).toInt(),
          (pixel.g * factor).clamp(0, 255).toInt(),
          (pixel.b * factor).clamp(0, 255).toInt(),
          pixel.a.toInt(),
        );
      }
    }
    return src;
  }

  static img.Image _applyContrast(img.Image src, double value) {
    // Contrast adjustment around middle gray
    final factor = (100 + value) / 100;
    
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        src.setPixelRgba(
          x, y,
          ((pixel.r - 128) * factor + 128).clamp(0, 255).toInt(),
          ((pixel.g - 128) * factor + 128).clamp(0, 255).toInt(),
          ((pixel.b - 128) * factor + 128).clamp(0, 255).toInt(),
          pixel.a.toInt(),
        );
      }
    }
    return src;
  }

  static img.Image _applySaturation(img.Image src, double value) {
    final factor = (100 + value) / 100;
    
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        final gray = 0.2989 * pixel.r + 0.5870 * pixel.g + 0.1140 * pixel.b;
        src.setPixelRgba(
          x, y,
          (gray + (pixel.r - gray) * factor).clamp(0, 255).toInt(),
          (gray + (pixel.g - gray) * factor).clamp(0, 255).toInt(),
          (gray + (pixel.b - gray) * factor).clamp(0, 255).toInt(),
          pixel.a.toInt(),
        );
      }
    }
    return src;
  }

  static img.Image _applyWarmth(img.Image src, double value) {
    final adj = (value * 0.25).round();
    
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        src.setPixelRgba(
          x, y,
          (pixel.r + adj).clamp(0, 255).toInt(),
          pixel.g.toInt(),
          (pixel.b - adj).clamp(0, 255).toInt(),
          pixel.a.toInt(),
        );
      }
    }
    return src;
  }

  static img.Image _applyHighlights(img.Image src, double value) {
    final adj = value / 100 * 60;
    
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        final lum = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255;
        
        if (lum > 0.5) {
          final strength = (lum - 0.5) * 2 * adj;
          src.setPixelRgba(
            x, y,
            (pixel.r + strength).clamp(0, 255).toInt(),
            (pixel.g + strength).clamp(0, 255).toInt(),
            (pixel.b + strength).clamp(0, 255).toInt(),
            pixel.a.toInt(),
          );
        }
      }
    }
    return src;
  }

  static img.Image _applyShadows(img.Image src, double value) {
    final adj = value / 100 * 60;
    
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        final lum = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255;
        
        if (lum < 0.5) {
          final strength = (0.5 - lum) * 2 * adj;
          src.setPixelRgba(
            x, y,
            (pixel.r + strength).clamp(0, 255).toInt(),
            (pixel.g + strength).clamp(0, 255).toInt(),
            (pixel.b + strength).clamp(0, 255).toInt(),
            pixel.a.toInt(),
          );
        }
      }
    }
    return src;
  }

  static img.Image _applySharpness(img.Image src, double value) {
    if (value > 0) {
      final amount = value / 100;
      final blurred = img.gaussianBlur(img.Image.from(src), radius: 1);
      
      for (int y = 0; y < src.height; y++) {
        for (int x = 0; x < src.width; x++) {
          final orig = src.getPixel(x, y);
          final blur = blurred.getPixel(x, y);
          src.setPixelRgba(
            x, y,
            (orig.r + (orig.r - blur.r) * amount).clamp(0, 255).toInt(),
            (orig.g + (orig.g - blur.g) * amount).clamp(0, 255).toInt(),
            (orig.b + (orig.b - blur.b) * amount).clamp(0, 255).toInt(),
            orig.a.toInt(),
          );
        }
      }
      return src;
    } else {
      final radius = (-value / 100 * 3).clamp(1, 3).toInt();
      return img.gaussianBlur(src, radius: radius);
    }
  }

  // ==================== ENHANCED BEAUTY ADJUSTMENTS ====================

  static img.Image _applySkinSmoothing(img.Image src, double intensity) {
    // Multi-pass frequency separation for better results
    final blurRadius = (intensity / 100 * 10).clamp(3, 12).toInt();
    final blendStrength = (intensity / 100).clamp(0.0, 1.0);
    
    // Create heavily blurred version for color layer
    final lowFreq = img.gaussianBlur(img.Image.from(src), radius: blurRadius);
    
    // Second pass with medium blur
    final mediumBlur = img.gaussianBlur(img.Image.from(src), radius: (blurRadius / 2).round().clamp(1, 6));
    
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final orig = src.getPixel(x, y);
        final low = lowFreq.getPixel(x, y);
        final med = mediumBlur.getPixel(x, y);
        
        // Check if pixel is skin
        final skinFactor = _getSkinLikelihood(orig);
        if (skinFactor < 0.15) continue;
        
        // Calculate local blend based on skin likelihood
        final localBlend = blendStrength * skinFactor * 0.85;
        
        // High frequency detail (texture)
        final highR = (orig.r - med.r).toDouble();
        final highG = (orig.g - med.g).toDouble();
        final highB = (orig.b - med.b).toDouble();
        
        // Smooth the base colors
        final baseR = orig.r * (1 - localBlend) + low.r * localBlend;
        final baseG = orig.g * (1 - localBlend) + low.g * localBlend;
        final baseB = orig.b * (1 - localBlend) + low.b * localBlend;
        
        // Add back reduced high frequency (preserve some texture)
        final detailPreserve = 1.0 - (localBlend * 0.6);
        final finalR = (baseR + highR * detailPreserve).clamp(0, 255).toInt();
        final finalG = (baseG + highG * detailPreserve).clamp(0, 255).toInt();
        final finalB = (baseB + highB * detailPreserve).clamp(0, 255).toInt();
        
        src.setPixelRgba(x, y, finalR, finalG, finalB, orig.a.toInt());
      }
    }
    
    return src;
  }

  static double _getSkinLikelihood(img.Pixel pixel) {
    final r = pixel.r.toDouble();
    final g = pixel.g.toDouble();
    final b = pixel.b.toDouble();
    
    // Expanded skin detection for various skin tones
    
    // Rule out obvious non-skin
    if (r < 60 || g < 30 || b < 15) return 0.0;
    
    // For lighter skin tones
    bool isLightSkin = r > 95 && g > 40 && b > 20 &&
        r > g && r > b && (r - g).abs() > 10 && (r - b) > 10;
    
    // For medium skin tones
    bool isMediumSkin = r > 80 && g > 50 && b > 30 &&
        r >= g && g >= b && (r - b) > 15;
    
    // For darker skin tones
    bool isDarkSkin = r > 60 && g > 40 && b > 30 &&
        r >= g && (r - b) > 5 && (r + g + b) > 150;
    
    if (!isLightSkin && !isMediumSkin && !isDarkSkin) return 0.0;
    
    // Calculate confidence
    double confidence = 0.7;
    
    final rgRatio = g / (r + 0.001);
    final rbRatio = b / (r + 0.001);
    
    // Typical skin ratios
    if (rgRatio > 0.55 && rgRatio < 0.95) confidence += 0.15;
    if (rbRatio > 0.25 && rbRatio < 0.85) confidence += 0.15;
    
    return confidence.clamp(0.0, 1.0);
  }

  static img.Image _applyBlemishRemoval(img.Image src, double intensity) {
    // More aggressive spot healing
    final threshold = 18 - (intensity / 100 * 12);
    final maxBlend = (intensity / 100 * 0.9).clamp(0.3, 0.9);
    
    // Create reference blurred image
    final blurred = img.gaussianBlur(img.Image.from(src), radius: 3);
    
    for (int y = 3; y < src.height - 3; y++) {
      for (int x = 3; x < src.width - 3; x++) {
        final pixel = src.getPixel(x, y);
        
        final skinFactor = _getSkinLikelihood(pixel);
        if (skinFactor < 0.2) continue;
        
        // Get surrounding average
        double avgR = 0, avgG = 0, avgB = 0;
        int count = 0;
        
        for (int dy = -3; dy <= 3; dy++) {
          for (int dx = -3; dx <= 3; dx++) {
            if (dx.abs() <= 1 && dy.abs() <= 1) continue; // Skip center area
            final n = src.getPixel(x + dx, y + dy);
            avgR += n.r;
            avgG += n.g;
            avgB += n.b;
            count++;
          }
        }
        
        avgR /= count;
        avgG /= count;
        avgB /= count;
        
        final pixelLum = 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;
        final avgLum = 0.299 * avgR + 0.587 * avgG + 0.114 * avgB;
        
        // Detect blemishes (darker spots) and redness (redder spots)
        final lumDiff = avgLum - pixelLum;
        final redDiff = pixel.r - avgR;
        
        bool isBlemish = lumDiff > threshold;
        bool isRedness = redDiff > 15 && skinFactor > 0.4;
        
        if (isBlemish || isRedness) {
          final blendAmount = isBlemish 
              ? (lumDiff / 50).clamp(0.2, maxBlend)
              : (redDiff / 40).clamp(0.2, maxBlend * 0.7);
          
          final blur = blurred.getPixel(x, y);
          final finalBlend = blendAmount * skinFactor;
          
          src.setPixelRgba(
            x, y,
            (pixel.r * (1 - finalBlend) + blur.r * finalBlend).round(),
            (pixel.g * (1 - finalBlend) + blur.g * finalBlend).round(),
            (pixel.b * (1 - finalBlend) + blur.b * finalBlend).round(),
            pixel.a.toInt(),
          );
        }
      }
    }
    
    return src;
  }

  static img.Image _applySkinTone(img.Image src, double intensity) {
    final strength = intensity / 100 * 0.25;
    
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        final skinFactor = _getSkinLikelihood(pixel);
        
        if (skinFactor > 0.2) {
          final localStrength = strength * skinFactor;
          // Add subtle warmth and even out tones
          src.setPixelRgba(
            x, y,
            (pixel.r + 12 * localStrength).clamp(0, 255).toInt(),
            (pixel.g + 6 * localStrength).clamp(0, 255).toInt(),
            (pixel.b - 4 * localStrength).clamp(0, 255).toInt(),
            pixel.a.toInt(),
          );
        }
      }
    }
    
    return src;
  }

  static img.Image _applyFaceLight(img.Image src, double intensity) {
    final strength = intensity / 100 * 45;
    
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        final skinFactor = _getSkinLikelihood(pixel);
        
        if (skinFactor > 0.25) {
          final localStrength = strength * skinFactor;
          src.setPixelRgba(
            x, y,
            (pixel.r + localStrength).clamp(0, 255).toInt(),
            (pixel.g + localStrength * 0.92).clamp(0, 255).toInt(),
            (pixel.b + localStrength * 0.85).clamp(0, 255).toInt(),
            pixel.a.toInt(),
          );
        }
      }
    }
    
    return src;
  }

  // ==================== FILTERS ====================

  static img.Image _applyFilter(img.Image src, FilterType filter) {
    switch (filter) {
      case FilterType.none:
        return src;
      case FilterType.aurora:
        // Subtle teal tint
        for (int y = 0; y < src.height; y++) {
          for (int x = 0; x < src.width; x++) {
            final p = src.getPixel(x, y);
            src.setPixelRgba(x, y, p.r.toInt(), (p.g + 4).clamp(0, 255).toInt(), (p.b + 8).clamp(0, 255).toInt(), p.a.toInt());
          }
        }
        return _applySaturation(src, 10);
      case FilterType.velvet:
        // Warm vintage
        for (int y = 0; y < src.height; y++) {
          for (int x = 0; x < src.width; x++) {
            final p = src.getPixel(x, y);
            src.setPixelRgba(x, y, (p.r + 8).clamp(0, 255).toInt(), (p.g + 3).clamp(0, 255).toInt(), (p.b * 0.95).clamp(0, 255).toInt(), p.a.toInt());
          }
        }
        return src;
      case FilterType.midnight:
        // Cool blue
        for (int y = 0; y < src.height; y++) {
          for (int x = 0; x < src.width; x++) {
            final p = src.getPixel(x, y);
            src.setPixelRgba(x, y, (p.r * 0.96).clamp(0, 255).toInt(), p.g.toInt(), (p.b + 10).clamp(0, 255).toInt(), p.a.toInt());
          }
        }
        return _applySaturation(src, -10);
      case FilterType.golden:
        // Warm golden
        for (int y = 0; y < src.height; y++) {
          for (int x = 0; x < src.width; x++) {
            final p = src.getPixel(x, y);
            src.setPixelRgba(x, y, (p.r + 10).clamp(0, 255).toInt(), (p.g + 4).clamp(0, 255).toInt(), (p.b * 0.9).clamp(0, 255).toInt(), p.a.toInt());
          }
        }
        return src;
      case FilterType.arctic:
        // Cool crisp
        for (int y = 0; y < src.height; y++) {
          for (int x = 0; x < src.width; x++) {
            final p = src.getPixel(x, y);
            src.setPixelRgba(x, y, (p.r * 0.95).clamp(0, 255).toInt(), (p.g + 2).clamp(0, 255).toInt(), (p.b + 12).clamp(0, 255).toInt(), p.a.toInt());
          }
        }
        return _applyBrightness(src, 4);
      case FilterType.noir:
        // Black and white
        for (int y = 0; y < src.height; y++) {
          for (int x = 0; x < src.width; x++) {
            final p = src.getPixel(x, y);
            final gray = (0.299 * p.r + 0.587 * p.g + 0.114 * p.b).round();
            src.setPixelRgba(x, y, gray, gray, gray, p.a.toInt());
          }
        }
        return _applyContrast(src, 15);
      case FilterType.bloom:
        // Soft dreamy
        return _applyContrast(_applyBrightness(src, 6), -5);
      case FilterType.ember:
        // Warm orange
        for (int y = 0; y < src.height; y++) {
          for (int x = 0; x < src.width; x++) {
            final p = src.getPixel(x, y);
            src.setPixelRgba(x, y, (p.r + 12).clamp(0, 255).toInt(), (p.g * 0.97).clamp(0, 255).toInt(), (p.b * 0.88).clamp(0, 255).toInt(), p.a.toInt());
          }
        }
        return src;
    }
  }

  static Future<Uint8List> rotateImage(Uint8List imageBytes, int degrees) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;
    
    img.Image rotated;
    switch (degrees % 360) {
      case 90:
      case -270:
        rotated = img.copyRotate(image, angle: 90);
        break;
      case 180:
      case -180:
        rotated = img.copyRotate(image, angle: 180);
        break;
      case 270:
      case -90:
        rotated = img.copyRotate(image, angle: 270);
        break;
      default:
        rotated = image;
    }
    
    return Uint8List.fromList(img.encodeJpg(rotated, quality: 95));
  }
}
