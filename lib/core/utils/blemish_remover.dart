import 'dart:typed_data';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:image/image.dart' as img;

class BlemishRemover {
  /// Remove blemishes using OpenCV's inpainting algorithm
  static Future<Uint8List> removeBlemishes(Uint8List imageBytes, double intensity) async {
    if (intensity <= 0) return imageBytes;
    
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;
      
      // Convert to OpenCV Mat
      final mat = cv.Mat.fromList(image.height, image.width, cv.MatType.CV_8UC3, 
        _imageToBytes(image));
      
      // Create mask for blemishes
      final mask = _createBlemishMask(mat, intensity);
      
      // Apply inpainting
      final result = cv.inpaint(mat, mask, 3.0, cv.INPAINT_TELEA);
      
      // Convert back to image bytes
      final resultImage = _matToImage(result, image.width, image.height);
      
      // Clean up
      mat.dispose();
      mask.dispose();
      result.dispose();
      
      return Uint8List.fromList(img.encodeJpg(resultImage, quality: 95));
    } catch (e) {
      print('OpenCV blemish removal failed: $e');
      return imageBytes;
    }
  }
  
  static cv.Mat _createBlemishMask(cv.Mat src, double intensity) {
    // Convert to different color spaces for detection
    final hsv = cv.cvtColor(src, cv.COLOR_BGR2HSV);
    final lab = cv.cvtColor(src, cv.COLOR_BGR2Lab);
    
    // Create empty mask
    final mask = cv.Mat.zeros(src.rows, src.cols, cv.MatType.CV_8UC1);
    
    final normalizedIntensity = intensity / 100;
    final threshold = (30 - normalizedIntensity * 20).toInt();
    
    // Detect dark spots and red spots
    for (int y = 5; y < src.rows - 5; y++) {
      for (int x = 5; x < src.cols - 5; x++) {
        final pixel = src.at<cv.Vec3b>(y, x);
        final b = pixel.val1;
        final g = pixel.val2;
        final r = pixel.val3;
        
        // Check if it's skin-like
        if (!_isSkinPixel(r, g, b)) continue;
        
        // Get local average
        double avgL = 0;
        int count = 0;
        for (int dy = -4; dy <= 4; dy++) {
          for (int dx = -4; dx <= 4; dx++) {
            if (dx.abs() < 2 && dy.abs() < 2) continue;
            final np = lab.at<cv.Vec3b>(y + dy, x + dx);
            avgL += np.val1;
            count++;
          }
        }
        avgL /= count;
        
        final currentL = lab.at<cv.Vec3b>(y, x).val1;
        final lumDiff = avgL - currentL;
        
        // Dark spot detection
        if (lumDiff > threshold) {
          mask.set<int>(y, x, 255);
        }
        
        // Red spot detection (pimples)
        final redRatio = r / (g + 1);
        if (redRatio > 1.3 && r > 100) {
          mask.set<int>(y, x, 255);
        }
      }
    }
    
    // Dilate mask slightly
    final kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (3, 3));
    final dilatedMask = cv.dilate(mask, kernel);
    
    hsv.dispose();
    lab.dispose();
    mask.dispose();
    kernel.dispose();
    
    return dilatedMask;
  }
  
  static bool _isSkinPixel(int r, int g, int b) {
    if (r < 60 || g < 30 || b < 15) return false;
    if (r <= g || r <= b) return false;
    if ((r - g).abs() < 10) return false;
    return true;
  }
  
  static List<int> _imageToBytes(img.Image image) {
    final bytes = <int>[];
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        bytes.add(pixel.b.toInt());
        bytes.add(pixel.g.toInt());
        bytes.add(pixel.r.toInt());
      }
    }
    return bytes;
  }
  
  static img.Image _matToImage(cv.Mat mat, int width, int height) {
    final image = img.Image(width: width, height: height);
    final data = mat.data;
    int i = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final b = data[i++];
        final g = data[i++];
        final r = data[i++];
        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }
    return image;
  }
}
