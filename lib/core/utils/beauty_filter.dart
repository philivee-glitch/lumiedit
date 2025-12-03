import 'dart:typed_data';
import 'package:image/image.dart' as img;

class BeautyFilter {
  static img.Image applySkinBeauty(img.Image src, double smoothIntensity, double blemishIntensity) {
    if (smoothIntensity <= 0 && blemishIntensity <= 0) return src;
    
    final blurRadius = 10;
    final blurred = img.gaussianBlur(img.Image.from(src), radius: blurRadius);
    final blend = (smoothIntensity / 100 * 0.5).clamp(0.0, 0.8);
    
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        final blur = blurred.getPixel(x, y);
        
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();
        
        // Simple blend with blur
        final finalR = r * (1 - blend) + blur.r * blend;
        final finalG = g * (1 - blend) + blur.g * blend;
        final finalB = b * (1 - blend) + blur.b * blend;
        
        src.setPixelRgba(
          x, y,
          finalR.round().clamp(0, 255),
          finalG.round().clamp(0, 255),
          finalB.round().clamp(0, 255),
          pixel.a.toInt(),
        );
      }
    }
    
    return src;
  }
}
