import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

const _kReasons = [
  'Harassment or abuse',
  'Threats or intimidation',
  'Fraud or lying',
  'Inappropriate requests',
  'Spam or fake profile',
  'Other',
];

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final List<String> _selectedReasons = [];
  final TextEditingController _descController = TextEditingController();
  PlatformFile? _attachedFile;
  bool _isSubmitting = false;

  late Map<String, String> _args;
  bool _argsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsInitialized) {
      _args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      _argsInitialized = true;
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _attachedFile = result.files.first);
    }
  }

  Future<void> _submit() async {
    if (_selectedReasons.isEmpty || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await ChatService().submitReport(
        reporterUid: FirebaseAuth.instance.currentUser!.uid,
        reportedUid: _args['reportedUid']!,
        reportedName: _args['reportedName']!,
        conversationId: _args['conversationId']!,
        reasons: _selectedReasons,
        description: _descController.text.trim(),
        attachedFile: _attachedFile,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Report submitted. We will review it shortly.')),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        title: Text('Report ${_argsInitialized ? _args['reportedName'] : ''}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        children: [
          _sectionLabel('WHAT HAPPENED?'),
          _reasonsCard(),
          const SizedBox(height: 20),
          _sectionLabel('TELL US MORE (OPTIONAL)'),
          _descriptionCard(),
          const SizedBox(height: 20),
          _sectionLabel('ATTACH EVIDENCE (OPTIONAL)'),
          _attachmentCard(),
          const SizedBox(height: 32),
          GradientButton(
            text: 'Submit Report',
            isLoading: _isSubmitting,
            onPressed: (_selectedReasons.isEmpty || _isSubmitting) ? null : _submit,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textGrey,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
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
      child: child,
    );
  }

  Widget _reasonsCard() {
    return _card(
      Column(
        children: _kReasons.map((reason) {
          final isSelected = _selectedReasons.contains(reason);
          return CheckboxListTile(
            title: Text(reason,
                style: const TextStyle(fontSize: 14, color: AppColors.navyBlue)),
            value: isSelected,
            activeColor: AppColors.teal,
            onChanged: (_) {
              setState(() {
                isSelected
                    ? _selectedReasons.remove(reason)
                    : _selectedReasons.add(reason);
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _descriptionCard() {
    return _card(
      Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          controller: _descController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Describe what happened...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.teal),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ),
    );
  }

  Widget _attachmentCard() {
    return _card(
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.mic_none, color: AppColors.textGrey, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Add a call recording',
                    style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                  ),
                ),
                OutlinedButton(
                  onPressed: _pickFile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.teal),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Choose File', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
            if (_attachedFile != null) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.audio_file,
                        size: 16, color: AppColors.teal),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _attachedFile!.name,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.teal),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => setState(() => _attachedFile = null),
                      child: const Icon(Icons.close,
                          size: 16, color: AppColors.teal),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
