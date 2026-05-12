import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class ImageExtractor {
  /// Extrae el objeto seleccionado aplicando la máscara al frame original (RGBA con Alpha = 0 afuera).
  static Future<Uint8List?> extractObject(
      img.Image baseImage, List<ui.Offset> polygon) async {
    if (polygon.isEmpty) return null;

    // Obtención de los límites (BoundingBox)
    double minX = polygon[0].dx;
    double maxX = polygon[0].dx;
    double minY = polygon[0].dy;
    double maxY = polygon[0].dy;

    for (var p in polygon) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    int x = minX.toInt().clamp(0, baseImage.width - 1);
    int y = minY.toInt().clamp(0, baseImage.height - 1);
    int w = (maxX - minX).toInt().clamp(1, baseImage.width - x);
    int h = (maxY - minY).toInt().clamp(1, baseImage.height - y);

    // Creamos imagen con 4 canales (RGBA)
    img.Image cropped = img.Image(width: w, height: h, numChannels: 4);

    ui.Path path = ui.Path();
    path.moveTo(polygon[0].dx, polygon[0].dy);
    for (int i = 1; i < polygon.length; i++) {
      path.lineTo(polygon[i].dx, polygon[i].dy);
    }
    path.close();

    // Rellenamos aplicando transparencia a los píxeles fuera del polígono
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < h; j++) {
        int origX = x + i;
        int origY = y + j;

        if (path.contains(ui.Offset(origX.toDouble(), origY.toDouble()))) {
          img.Pixel pixel = baseImage.getPixelSafe(origX, origY);
          cropped.setPixelRgba(i, j, pixel.r, pixel.g, pixel.b, 255);
        } else {
          cropped.setPixelRgba(i, j, 0, 0, 0, 0); // Canal Alpha 0
        }
      }
    }

    return img.encodePng(cropped);
  }
}
