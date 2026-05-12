import 'package:flutter/foundation.dart';
import '../models/analysis_result.dart';
import '../services/image_analysis_service.dart';

enum AppState { idle, loading, success, error }

class VisionProvider extends ChangeNotifier {
  final _service = ImageAnalysisService();

  AppState _state = AppState.idle;
  AnalysisResult? _result;
  String? _errorMessage;
  Uint8List? _imageBytes;

  AppState get state => _state;
  AnalysisResult? get result => _result;
  String? get errorMessage => _errorMessage;
  Uint8List? get imageBytes => _imageBytes;

  void setImage(Uint8List bytes) {
    _imageBytes = bytes;
    _result = null;
    _errorMessage = null;
    _state = AppState.idle;
    notifyListeners();
  }

  Future<void> analyze() async {
    if (_imageBytes == null) return;

    _state = AppState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _result = await _service.analyzeImage(_imageBytes!);
      _state = AppState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AppState.error;
    }
    notifyListeners();
  }

  void reset() {
    _state = AppState.idle;
    _result = null;
    _errorMessage = null;
    _imageBytes = null;
    notifyListeners();
  }
}
