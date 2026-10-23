import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

import '../../domain/models/polygon_mask.dart';
import '../../data/services/yolo_processor.dart';
import '../../data/services/image_extractor.dart';
import '../../data/services/gemini_client.dart';
import '../widgets/mask_overlay.dart';

class VisionPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const VisionPage({super.key, required this.cameras});

  @override
  State<VisionPage> createState() => _VisionPageState();
}

class _VisionPageState extends State<VisionPage> {
  CameraController? _controller;
  final YoloProcessor _yoloProcessor = YoloProcessor();
  late GeminiClient _geminiClient;

  bool _isProcessing = false;
  bool _isPaused = false;
  bool _isAnalyzing = false;

  List<PolygonMask> _currentMasks = [];
  CameraImage? _lastImage;

  Map<String, String>? _analysisResult;
  Uint8List? _isolatedImage;

  @override
  void initState() {
    super.initState();
    // La API Key se pasa solo en desarrollo: flutter run --dart-define=GEMINI_API_KEY=...
    _geminiClient = GeminiClient(const String.fromEnvironment('GEMINI_API_KEY'));
    _initializeModel();
    _initializeCamera();
  }

  Future<void> _initializeModel() async {
    await _yoloProcessor.initialize('assets/yolov8n-seg.tflite');
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();
    if (!mounted) return;

    _controller!.startImageStream((CameraImage image) async {
      if (_isProcessing || _isPaused) return;

      _isProcessing = true;
      _lastImage = image;

      final Size screenSize = MediaQuery.of(context).size;
      _currentMasks = await _yoloProcessor.processFrame(image, screenSize);

      if (mounted) setState(() {});
      _isProcessing = false;
    });
  }

  void _handleTap(TapDownDetails details) async {
    if (!_isPaused || _isAnalyzing || _lastImage == null) return;

    final offset = details.localPosition;

    // Réplica del comportamiento cv2.pointPolygonTest para detectar objeto tocado
    for (var mask in _currentMasks) {
      if (mask.points.isEmpty) continue;

      Path path = Path();
      path.moveTo(mask.points[0].dx, mask.points[0].dy);
      for (int i = 1; i < mask.points.length; i++) {
        path.lineTo(mask.points[i].dx, mask.points[i].dy);
      }
      path.close();

      // Validación con Flutter native
      if (path.contains(offset)) {
        await _processObjectSelection(mask);
        break;
      }
    }
  }

  Future<void> _processObjectSelection(PolygonMask mask) async {
    setState(() { _isAnalyzing = true; });

    // Instanciación dummy para demostración del PoC de compatibilidad (evitando errores)
    // En producción se requiere el formateo de YUV420 de _lastImage a RGB
    img.Image baseImage = img.Image(width: _lastImage!.width, height: _lastImage!.height);

    // 1. Recorte con fondo transparente y canal alfa
    final pngBytes = await ImageExtractor.extractObject(baseImage, mask.points);

    if (pngBytes != null) {
      // 2. Envío a Gemini de manera asíncrona sin bloquear la UI
      final response = await _geminiClient.analyzeObject(pngBytes, mask.label);

      if (mounted) {
        setState(() {
          _isolatedImage = pngBytes;
          _analysisResult = response;
        });
      }
    }

    if (mounted) setState(() { _isAnalyzing = false; });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _yoloProcessor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visión Artificial (Instancias)'),
        actions: [
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () => setState(() => _isPaused = !_isPaused),
          )
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller?.value.isInitialized ?? false)
            CameraPreview(_controller!),

          GestureDetector(
            onTapDown: _handleTap,
            child: CustomPaint(
              painter: MaskPainter(_currentMasks),
              size: Size.infinite,
            ),
          ),

          if (_isPaused && !_isAnalyzing && _analysisResult == null)
            const Positioned(
              top: 20, left: 20,
              child: Text(
                'PAUSADO - Selecciona un objeto segmentado',
                style: TextStyle(
                  color: Colors.yellow, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)]
                ),
              ),
            ),

          if (_isAnalyzing)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analizando imagen con Gemini...', style: TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 4)]))
                ],
              ),
            ),

          if (_analysisResult != null && _isolatedImage != null)
            _buildResultDialog(),
        ],
      ),
    );
  }

  Widget _buildResultDialog() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.black87,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[900], // Para evidenciar la transparencia
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Image.memory(_isolatedImage!, fit: BoxFit.contain),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _analysisResult!['nombre']!.toUpperCase(),
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _analysisResult!['descripcion']!,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => setState(() {
                  _analysisResult = null;
                  _isolatedImage = null;
                  _isPaused = false;
                }),
                child: const Text('Continuar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
