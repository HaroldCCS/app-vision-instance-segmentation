import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/pages/vision_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carga las variables de entorno desde el archivo .env
  await dotenv.load(fileName: ".env");
  
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
