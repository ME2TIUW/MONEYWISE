import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:money_wise/views/ocr/bill_verification_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:money_wise/viewmodels/ocr/scan_bill.viewModel.dart';

class ScanBillPage extends StatefulWidget {
  const ScanBillPage({super.key});

  @override
  State<ScanBillPage> createState() => _ScanBillPageState();
}

class _ScanBillPageState extends State<ScanBillPage> {
  CameraController? _controller;
  late Future<void> _initCamera;
  bool _isFlashOn = false;
  int _selectedTab = 0;
  bool _isNavigatingToVerification = false;

  @override
  void initState() {
    super.initState();
    _initCamera = _setupCamera();
  }

  Future<void> _setupCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );

    await _controller!.initialize();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureAndCrop(BuildContext context) async {
    final vm = context.read<ScanBillViewModel>();

    if (!_controller!.value.isInitialized) return;

    if (_isFlashOn) {
      await _controller!.setFlashMode(FlashMode.off);
      _isFlashOn = false;
    }

    final XFile raw = await _controller!.takePicture();
    final bytes = await raw.readAsBytes();

    final original = img.decodeImage(bytes)!;

    final cropWidth = (original.width * 0.75).toInt();
    final cropHeight = (original.height * 0.45).toInt();

    final cropX = ((original.width - cropWidth) / 2).toInt();
    final cropY = ((original.height - cropHeight) / 2).toInt();

    final cropped = img.copyCrop(
      original,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/scan_bill.jpg');
    await file.writeAsBytes(img.encodeJpg(cropped));

    await vm.scanFromFile(file);
  }

  Future<void> _handleReceiptNavigation(ScanBillViewModel vm) async {
    if (_isNavigatingToVerification) return;

    final receipt = vm.receipt;
    if (receipt == null) return;

    _isNavigatingToVerification = true;
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        await _controller!.pausePreview();
      }

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BillVerificationPage(receipt: receipt),
        ),
      );

      vm.clearReceipt();
    } finally {
      if (_controller != null && _controller!.value.isInitialized) {
        await _controller!.resumePreview();
      }
      _isNavigatingToVerification = false;
    }
  }

  Widget _buildTopToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [_buildTabItem("QR", 0), _buildTabItem("Manual", 1)],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() {
            _selectedTab = index;
          });

          if (index == 1) {
            Navigator.pushNamed(context, '/transaction');

            setState(() {
              _selectedTab = 0;
            });
          } else {
            setState(() {
              _selectedTab = 0;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScanBillViewModel>(
      builder: (context, vm, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _handleReceiptNavigation(vm);
        });

        return Scaffold(
          backgroundColor: Colors.black,
          body: FutureBuilder(
            future: _initCamera,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                );
              }

              return Stack(
                children: [
                  CameraPreview(_controller!),

                  Container(color: Colors.black.withOpacity(0.3)),

                  Positioned.fill(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const BackButton(color: Colors.white),
                              const Spacer(),
                              const Text(
                                'Bill Scanner',
                                style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Tooltip(
                                message:
                                    'OCR works best when scanning shopping receipts (bills). Ensure the receipt is clear, centered, and well-lit.',
                                preferBelow: false,
                                child: const Icon(
                                  Icons.info_outline,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleFlash,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        _buildTopToggle(),

                        const SizedBox(height: 20),

                        Container(
                          width: MediaQuery.of(context).size.width * 0.80,
                          height: MediaQuery.of(context).size.height * 0.60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _BottomIcon(
                              icon: Icons.photo,
                              label: 'Gallery',
                              onTap: vm.scanFromGallery,
                            ),
                            GestureDetector(
                              onTap: () => _captureAndCrop(context),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            _BottomIcon(
                              icon: Icons.history,
                              label: 'History',
                              onTap: () {
                                Navigator.pushNamed(context, '/history');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Take Picture',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  if (vm.isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),

                  if (vm.error != null)
                    Positioned(
                      top: 60,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.red.withOpacity(0.8),
                        child: Text(
                          vm.error!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _BottomIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
