// screens/scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'analysis_result_screen.dart';
import 'package:skin_food_scanner/theme.dart';
import 'package:skin_food_scanner/services/product_analysis_service.dart';
import 'package:skin_food_scanner/models/product_model.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with TickerProviderStateMixin {
  bool _isScanning = false;
  bool _isInitializing = true;
  String? _initializationError;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCamera();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        setState(() {
          _isInitializing = false;
          _initializationError = 'Camera permission denied';
        });
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _isInitializing = false;
          _initializationError = 'No cameras available';
        });
        return;
      }

      // Initialize camera controller
      _cameraController = CameraController(
        _cameras![0], // Use back camera
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitializing = false;
          _initializationError = null;
        });
      }
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _initializationError = 'Camera initialization failed: $e';
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Product'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline_rounded),
            onPressed: () => _showScanTips(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Camera View Area
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      // Camera Preview or Placeholder
                      _buildCameraView(),

                      // Scanning Overlay
                      if (_isScanning) _buildScanningOverlay(),

                      // Frame Guide
                      if (!_isInitializing && _initializationError == null)
                        _buildFrameGuide(),
                    ],
                  ),
                ),
              ),
            ),

            // Instructions
            if (!_isScanning) _buildInstructions(),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    if (_isInitializing) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Initializing camera...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_initializationError != null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Colors.white.withOpacity(0.7),
              ),
              SizedBox(height: 16),
              Text(
                'Camera Unavailable',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _initializationError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _initializeCamera(),
                child: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black87,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    // Fix for camera preview layout issues
    return LayoutBuilder(
      builder: (context, constraints) {
        final aspectRatio = _cameraController!.value.aspectRatio;
        return AspectRatio(
          aspectRatio: aspectRatio,
          child: CameraPreview(_cameraController!),
        );
      },
    );
  }

  Widget _buildFrameGuide() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.25,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Corner indicators
            Positioned(
              top: -2,
              left: -2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                    left: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                    right: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -2,
              left: -2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                    left: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                    right: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                  ),
                ),
              ),
            ),
            // Center text
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Position ingredients list here',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  strokeWidth: 3,
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Analyzing ingredients...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Using AI to identify and analyze ingredients',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Scanning Tips',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          _buildTip(Icons.center_focus_strong, 'Keep ingredients list in focus'),
          _buildTip(Icons.light_mode, 'Ensure good lighting'),
          _buildTip(Icons.straighten, 'Hold device steady'),
        ],
      ),
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Scan Button
          GestureDetector(
            onTap: _canScan() ? _captureAndAnalyze : null,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isScanning ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _canScan()
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: _canScan() ? [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ] : [],
                    ),
                    child: Icon(
                      _isScanning ? Icons.hourglass_empty_rounded : Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 16),

          Text(
            _getStatusText(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 24),

          // Upload from Gallery
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isScanning ? null : _uploadFromGallery,
              icon: Icon(Icons.photo_library_rounded),
              label: Text('Upload from Gallery'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canScan() {
    return !_isScanning &&
        !_isInitializing &&
        _initializationError == null &&
        _cameraController != null &&
        _cameraController!.value.isInitialized;
  }

  String _getStatusText() {
    if (_isInitializing) return 'Initializing camera...';
    if (_initializationError != null) return 'Camera unavailable';
    if (_isScanning) return 'Analyzing ingredients...';
    if (!_canScan()) return 'Camera not ready';
    return 'Tap to scan';
  }

  Future<void> _captureAndAnalyze() async {
    if (!_canScan()) {
      _showError('Camera not ready');
      return;
    }

    setState(() => _isScanning = true);
    _pulseController.repeat(reverse: true);

    try {
      // Capture image
      final XFile image = await _cameraController!.takePicture();

      // Analyze the captured image directly with Gemini Vision
      await _analyzeImage(image.path);

    } catch (e) {
      _showError('Failed to capture image: $e');
    } finally {
      if (mounted) {
        _pulseController.stop();
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _uploadFromGallery() async {
    try {
      // Pick image from gallery
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (image == null) return;

      // Show processing dialog
      _showProcessingDialog();

      // Analyze the selected image
      await _analyzeImage(image.path);

    } catch (e) {
      Navigator.of(context).pop(); // Close any dialogs
      _showError('Failed to process image: $e');
    }
  }

  Future<void> _analyzeImage(String imagePath) async {
    try {
      // Use the new Gemini Vision API directly
      final ProductAnalysis analysis = await ProductAnalysisService.analyzeProductFromImage(imagePath);

      // Navigate to results
      if (mounted) {
        // Close any open dialogs first
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Navigate to results screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(analysis: analysis),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        // Close processing dialog if open
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        _showError('Analysis failed: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
                strokeWidth: 3,
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analyzing ingredients...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Using AI to identify ingredients',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showScanTips() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Scanning Tips',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildDetailedTip(
              Icons.center_focus_strong,
              'Focus on Ingredients',
              'Position the ingredients list clearly within the frame. Make sure all text is readable.',
            ),
            _buildDetailedTip(
              Icons.light_mode,
              'Good Lighting',
              'Scan in well-lit areas. Natural light works best for clear text recognition.',
            ),
            _buildDetailedTip(
              Icons.straighten,
              'Keep Steady',
              'Hold your device steady and wait for the camera to focus before capturing.',
            ),
            _buildDetailedTip(
              Icons.photo_camera,
              'Image Quality',
              'Ensure the product label is flat and not curved or wrinkled for best results.',
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedTip(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}