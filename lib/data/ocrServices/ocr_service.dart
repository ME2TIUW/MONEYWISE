import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:firebase_performance/firebase_performance.dart';

class OcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> recognize(File image) async {
    final Trace ocrTrace = FirebasePerformance.instance.newTrace(
      'ocr_local_processing',
    );

    try {
      await ocrTrace.start();

      final inputImage = InputImage.fromFile(image);
      final result = await _recognizer.processImage(inputImage);

      await ocrTrace.stop();

      return result.text;
    } catch (_) {
      try {
        await ocrTrace.stop();
      } catch (_) {}
      return '';
    }
  }

  void dispose() {
    _recognizer.close();
  }
}
