# 👁️ app-vision-instance-segmentation

App en **Flutter** que segmenta objetos en tiempo real **dentro del celular** con **YOLOv8** (TensorFlow Lite). Al tocar un objeto, lo recorta por su silueta y le pide a **Gemini** que lo identifique y lo describa.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)
![TensorFlow Lite](https://img.shields.io/badge/TensorFlow_Lite-FF6F00?style=flat-square&logo=tensorflow&logoColor=white)
![YOLOv8](https://img.shields.io/badge/YOLOv8--seg-111F68?style=flat-square&logo=ultralytics&logoColor=white)
![Gemini](https://img.shields.io/badge/Gemini-8E75B2?style=flat-square&logo=googlegemini&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat-square&logo=githubactions&logoColor=white)

## ✨ Flujo

```
Cámara ──► YOLOv8n-seg (TFLite, en el dispositivo) ──► máscaras poligonales sobre la vista previa
                                                              │ el usuario toca un objeto
                                                              ▼
                                       Recorte del objeto por su polígono (PNG)
                                                              │
                                                              ▼
                                  Gemini: { "nombre", "descripcion" } en español
```

- **Inferencia local**: la segmentación corre en el celular, sin enviar el video a ningún servidor.
- **IA generativa solo cuando hace falta**: a Gemini se envía únicamente el recorte del objeto elegido, junto con la etiqueta que detectó YOLO.
- **Respuesta estructurada**: el prompt exige JSON con nombre y descripción para mostrarlo directamente en la interfaz.

## 📁 Estructura

```
lib/
  data/services/
    yolo_processor.dart     # carga el modelo TFLite y procesa cada frame
    image_extractor.dart    # recorta el objeto según su máscara
    gemini_client.dart      # consulta a Gemini con imagen + etiqueta
  domain/models/            # PolygonMask
  presentation/
    pages/vision_page.dart  # cámara + superposición de máscaras
    widgets/mask_overlay.dart
assets/
  yolov8n-seg.tflite        # modelo cuantizado para móvil
```

## 🚀 Ejecutar

```bash
echo "GEMINI_API_KEY=tu_api_key" > .env
flutter pub get
flutter run
```

## 📦 Releases automáticos

Al publicar un tag, GitHub Actions compila el **APK de Android** y el **ejecutable de Windows** y los adjunta a un GitHub Release.

---

Hecho por [Harold Camargo](https://haroldsoftware.com) · [LinkedIn](https://www.linkedin.com/in/haroldcamargo2002/)
