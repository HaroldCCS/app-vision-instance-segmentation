import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'presentation/pages/vision_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Obtiene la lista de cámaras disponibles del dispositivo
  final cameras = await availableCameras();
  
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Vision Instance Segmentation',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      home: VisionPage(cameras: cameras),
      debugShowCheckedModeBanner: false,
    );
  }
}
