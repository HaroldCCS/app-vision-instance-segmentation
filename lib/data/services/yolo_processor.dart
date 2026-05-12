import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../domain/models/polygon_mask.dart';

class YoloProcessor {
  Interpreter? _interpreter;
  final int inputSize = 640;
  
  // Reutilizar buffers en memoria para evitar lag extremo creando listas cada frame
  late List<dynamic> _input;
  late List<dynamic> _output0;
  late List<dynamic> _output1;

  Future<void> initialize(String modelPath) async {
    _interpreter = await Interpreter.fromAsset(modelPath);
    
    _interpreter!.allocateTensors();
    
    // Inicializar buffers una sola vez
    _input = Float32List(1 * inputSize * inputSize * 3).reshape([1, 640, 640, 3]);
    _output0 = List.filled(1 * 116 * 8400, 0.0).reshape([1, 116, 8400]);
    _output1 = List.filled(1 * 160 * 160 * 32, 0.0).reshape([1, 160, 160, 32]);
  }

  /// Convierte CameraImage a tensor (requiere procesamiento real de YUV a RGB en producción)
  void _updateInputBuffer(CameraImage image) {
    // Aquí se actualizarían los valores de `_input` modificando sus índices 
    // en lugar de crear una nueva lista.
  }

  Future<List<PolygonMask>> processFrame(CameraImage image, Size screenSize) async {
    if (_interpreter == null) return [];

    _updateInputBuffer(image);

    // Ejecutamos la inferencia usando los buffers pre-asignados
    // Esto previene que el Garbage Collector se bloquee y congele la cámara
    _interpreter!.runForMultipleInputs([_input], {0: _output0, 1: _output1});

    // ---------------------------------------------------------
    // LÓGICA DE EXTRACCIÓN (NMS Y MÁSCARAS)
    // Extraer polígonos de tensores de YOLOv8-seg en Dart puro es extremadamente complejo y lento.
    // En producción se usa C++ FFI para replicar la lógica de ultralytics.
    // Para que la prueba de concepto (selección + Gemini) funcione y no veas la pantalla vacía,
    // inyectaremos una instancia de prueba (polígono dummy) simulando un objeto detectado en el centro.
    // ---------------------------------------------------------
    
    double cx = screenSize.width / 2;
    double cy = screenSize.height / 2;
    
    List<PolygonMask> results = [
      PolygonMask(
        label: 'Objeto de prueba (Simulado)',
        points: [
          Offset(cx - 100, cy - 100),
          Offset(cx + 100, cy - 100),
          Offset(cx + 100, cy + 100),
          Offset(cx - 100, cy + 100),
        ],
      )
    ];
    
    return results;
  }

  void dispose() {
    _interpreter?.close();
  }
}
