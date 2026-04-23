import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../services/aadhaar_qr_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

enum _Stage { consent, scan, confirm }

class AadhaarVerificationScreen extends StatefulWidget {
  const AadhaarVerificationScreen({super.key});

  @override
  State<AadhaarVerificationScreen> createState() =>
      _AadhaarVerificationScreenState();
}

class _AadhaarVerificationScreenState
    extends State<AadhaarVerificationScreen> {
  _Stage _stage = _Stage.consent;
  AadhaarVerificationResult? _result;
  bool _isProcessing = false;
  bool _isSaving = false;
  String? _lastScannedValue;

  // ── Scan logic ─────────────────────────────────────────────────────────────

  /// Tries text path first; falls back to rawBytes if text isn't recognised
  /// as an Aadhaar QR (covers rare BYTE-mode encoded cards).
  Future<AadhaarVerificationResult> _verifyCode(Code code) async {
    final raw = code.text?.trim() ?? '';
    if (raw.isNotEmpty) {
      try {
        return await AadhaarQrService.verify(raw);
      } on QrFormatException {
        // Not recognised as Aadhaar via text — try rawBytes fallback
      }
    }
    final bytes = code.rawBytes;
    if (bytes != null && bytes.isNotEmpty) {
      return await AadhaarQrService.verifyFromBytes(bytes);
    }
    throw const QrFormatException(
        'This does not appear to be an Aadhaar QR code.');
  }

  Future<void> _onScan(Code code) async {
    if (_isProcessing || _stage != _Stage.scan) return;
    final raw = code.text?.trim();
    final cacheKey = (raw != null && raw.isNotEmpty)
        ? raw
        : code.rawBytes?.length.toString();
    if (cacheKey == null) return;
    if (cacheKey == _lastScannedValue) return;
    _lastScannedValue = cacheKey;

    if (mounted) setState(() => _isProcessing = true);

    try {
      final result = await _verifyCode(code);
      if (mounted) {
        setState(() {
          _result = result;
          _stage = _Stage.confirm;
          _isProcessing = false;
        });
      }
    } on SignatureInvalidException {
      _showScanError(
        'Could not verify QR authenticity. Please use the QR on your original Aadhaar card.',
      );
    } on QrFormatException catch (e) {
      _showScanError(e.toString());
    } on ParseException catch (e) {
      _showScanError(e.toString());
    } catch (_) {
      _showScanError('Something went wrong. Please try again.');
    }
  }

  void _showScanError(String message) {
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _lastScannedValue = null;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Photo fallback ─────────────────────────────────────────────────────────

  Future<void> _pickAndAnalyze() async {
    if (_isProcessing) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (picked == null || !mounted) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop QR Code',
          toolbarColor: AppColors.navyBlue,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.teal,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop QR Code',
          aspectRatioLockEnabled: false,
        ),
      ],
    );
    if (cropped == null || !mounted) return;

    setState(() => _isProcessing = true);
    final croppedXFile = XFile(cropped.path);

    try {
      final code = await zx.readBarcodeImagePath(
        croppedXFile,
        DecodeParams(
          format: Format.qrCode,
          tryHarder: true,
          tryInverted: true,
          maxSize: 4096,
        ),
      );
      final hasContent = (code.text?.trim().isNotEmpty ?? false) ||
          (code.rawBytes?.isNotEmpty ?? false);
      if (!hasContent) {
        _showScanError(
          'No QR code found. Make sure the entire QR is visible and well-lit, then try again.',
        );
        return;
      }
      final result = await _verifyCode(code);
      if (mounted) {
        setState(() {
          _result = result;
          _stage = _Stage.confirm;
          _isProcessing = false;
        });
      }
    } on SignatureInvalidException {
      _showScanError(
        'Could not verify QR authenticity. Please use the QR on your original Aadhaar card.',
      );
    } on QrFormatException catch (e) {
      _showScanError(e.toString());
    } on ParseException catch (e) {
      _showScanError(e.toString());
    } catch (_) {
      _showScanError('Something went wrong. Please try again.');
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_isSaving || _result == null) return;
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final age = _result!.age;

      if (age != null && age < 18) {
        await FirestoreService().flagHelperAsUnderage(uid, age: age);
        if (mounted) {
          setState(() => _isSaving = false);
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text(
                'Account Restricted',
                style: TextStyle(
                  color: Color(0xFF1A3A5C),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'This account has been flagged as underage. We have restricted the usage of this account.\n\n'
                'If there has been a mistake on our side, please contact us at:\nsupport@kaamsathi.in',
                style: TextStyle(height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          if (mounted) Navigator.pop(context, false);
        }
        return;
      }

      await FirestoreService().saveHelperVerification(
        uid,
        age: age,
        maskedUid: _result!.maskedUid,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Please try again.')),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return switch (_stage) {
      _Stage.consent => _ConsentPage(
          onContinue: () => setState(() => _stage = _Stage.scan),
          onCancel: () => Navigator.pop(context),
        ),
      _Stage.scan => _ScanPage(
          isProcessing: _isProcessing,
          onScan: (Code code) => _onScan(code),
          onTakePhoto: _pickAndAnalyze,
          onBack: () => setState(() => _stage = _Stage.consent),
        ),
      _Stage.confirm => _ConfirmPage(
          result: _result!,
          isSaving: _isSaving,
          onConfirm: _save,
          onBack: () {
            setState(() {
              _result = null;
              _stage = _Stage.scan;
              _isProcessing = false;
              _lastScannedValue = null;
            });
          },
        ),
    };
  }
}

// ── Stage 1: Consent ──────────────────────────────────────────────────────────

class _ConsentPage extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  const _ConsentPage({required this.onContinue, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        title: const Text('Verify with Aadhaar'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onCancel,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                color: AppColors.teal,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Identity Verification',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scan the QR code on your Aadhaar card to get an Aadhaar Verified badge next to your name.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _InfoSection(
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFF22C55E),
            title: 'What will be shared',
            items: const [
              'Your age',
              'Last 4 digits of your Aadhaar number',
            ],
          ),
          const SizedBox(height: 20),
          _InfoSection(
            icon: Icons.block_outlined,
            iconColor: Colors.redAccent,
            title: 'What we will NOT store',
            items: const [
              'Your full Aadhaar number',
              'Your address',
              'Your photo',
              'The raw QR code data',
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
            ),
            child: const Text(
              'By tapping Continue, you agree to share the above information for identity verification. This is completely optional.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          GradientButton(
            text: 'Continue to Scan',
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> items;

  const _InfoSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.navyBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 26, bottom: 4),
            child: Text(
              '• $item',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stage 2: Scan ─────────────────────────────────────────────────────────────

class _ScanPage extends StatelessWidget {
  final bool isProcessing;
  final void Function(Code) onScan;
  final VoidCallback onTakePhoto;
  final VoidCallback onBack;

  const _ScanPage({
    required this.isProcessing,
    required this.onScan,
    required this.onTakePhoto,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ReaderWidget(
            onScan: onScan,
            codeFormat: Format.qrCode,
            tryHarder: true,
            tryInverted: true,
            showScannerOverlay: false,
            showFlashlight: false,
            showToggleCamera: false,
            showGallery: false,
            allowPinchZoom: true,
            resolution: ResolutionPreset.high,
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                        onPressed: onBack,
                      ),
                      const Text(
                        'Scan Aadhaar QR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Viewfinder
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.teal, width: 2.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Point camera at the QR code\non your Aadhaar card',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This may take 15–20 seconds',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: isProcessing ? null : onTakePhoto,
                  icon: const Icon(Icons.camera_alt_outlined,
                      color: Colors.white70, size: 18),
                  label: const Text(
                    'Having trouble? Take a photo instead',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          // Processing overlay
          if (isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.teal),
                    SizedBox(height: 16),
                    Text(
                      'Verifying QR...',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Stage 3: Confirm ──────────────────────────────────────────────────────────

class _ConfirmPage extends StatelessWidget {
  final AadhaarVerificationResult result;
  final bool isSaving;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  const _ConfirmPage({
    required this.result,
    required this.isSaving,
    required this.onConfirm,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        title: const Text('Confirm Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Color(0xFF22C55E),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'QR Scanned Successfully',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Review the details below before saving.\nOnly this information will be stored.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Details card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _DetailRow(label: 'Aadhaar', value: result.maskedUid),
                  if (result.age != null) ...[
                    const Divider(height: 1),
                    _DetailRow(label: 'Age', value: '${result.age} years'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '🔒  Your full Aadhaar number and address are never stored.',
              style: TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
            const Spacer(),
            GradientButton(
              text: 'Confirm & Verify',
              isLoading: isSaving,
              onPressed: isSaving ? null : onConfirm,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onBack,
              child: const Text(
                'Scan Again',
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.navyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
