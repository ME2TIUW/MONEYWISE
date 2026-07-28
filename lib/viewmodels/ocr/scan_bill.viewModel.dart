import 'dart:io';
import 'package:money_wise/data/imageServices/image_service.dart';
import 'package:money_wise/data/ocrServices/ocr_service.dart';
import 'package:money_wise/data/models/receipt_model.dart';
import 'package:money_wise/data/billparserServices/billParser_services.dart';
import 'package:money_wise/data/aiService/openRouterService.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

class ScanBillViewModel extends ChangeNotifier {
  final ImagePickerService _imagePickerService;
  final OcrService _ocrService;
  Receipt? receipt;
  final ReceiptParser _parser;
  final OpenRouterService? _openRouter;

  ScanBillViewModel(this._imagePickerService, this._ocrService, this._parser, [this._openRouter]);

  bool isLoading = false;
  String resultText = '';
  String? error;


  Future<void> scanFromCamera() async {
    final image = await _imagePickerService.pickCamera();
    if (image == null) return;

    await _process(image);
  }

  Future<void> scanFromGallery() async {
    final image = await _imagePickerService.pickGallery();
    if (image == null) return;

    await _process(image);
  }

  Future<void> _process(File image) async {
    // selectedImage = image;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final text = await _ocrService.recognize(image);

      if (_openRouter != null) {
        final parsed = await _openRouter.parseReceiptFromText(text);
        receipt = parsed ?? _parser.parse(text);
      } else {
        receipt = _parser.parse(text);
      }
    } catch (e) {
      error = e.toString();
      receipt = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> scanFromFile(File image) async {
    await _process(image);
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  void clearReceipt() {
  receipt = null;
  notifyListeners();
  }
}
