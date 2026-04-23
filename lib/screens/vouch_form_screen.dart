import 'package:flutter/material.dart';
import '../models/vouch_model.dart';
import '../services/vouch_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

const List<String> _kRatingLabels = [
  'Poor',
  'Fair',
  'Good',
  'Very Good',
  'Excellent',
];

class VouchFormScreen extends StatefulWidget {
  const VouchFormScreen({super.key});

  @override
  State<VouchFormScreen> createState() => _VouchFormScreenState();
}

class _VouchFormScreenState extends State<VouchFormScreen> {
  late Map<String, String> _args;
  bool _argsInitialized = false;

  int _selectedRating = 0;
  final Set<String> _selectedTags = {};
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsInitialized) {
      _args = Map<String, String>.from(
        ModalRoute.of(context)!.settings.arguments as Map,
      );
      _argsInitialized = true;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedRating == 0 || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await VouchService().createVouch(
        workerId: _args['workerId']!,
        employerId: _args['employerId']!,
        conversationId: _args['conversationId']!,
        employerDisplayName: _args['employerDisplayName']!,
        rating: _selectedRating,
        tags: _selectedTags.toList(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vouch submitted. Thank you!')),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to submit vouch. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workerName = _argsInitialized ? _args['workerName'] ?? '' : '';
    final atLimit = _selectedTags.length >= 5;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        title: Text('Vouch for $workerName'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        children: [
          _sectionLabel('RATING'),
          _card(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final starIndex = i + 1;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedRating = starIndex),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            starIndex <= _selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            size: 40,
                            color: AppColors.orange,
                          ),
                        ),
                      );
                    }),
                  ),
                  if (_selectedRating > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      _kRatingLabels[_selectedRating - 1],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _sectionLabel('WHAT DID YOU LIKE? (CHOOSE UP TO 5)'),
          _card(
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kAllowedVouchTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            setState(() => _selectedTags.remove(tag));
                          } else if (!atLimit) {
                            setState(() => _selectedTags.add(tag));
                          }
                          // silently reject 6th tap
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.teal.withValues(alpha: 0.12)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.teal
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected
                                  ? AppColors.teal
                                  : Colors.grey.shade700,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (atLimit) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Maximum 5 tags selected',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _sectionLabel('SHARE MORE (OPTIONAL)'),
          _card(
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _noteController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Tell future employers more about this person...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
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
          ),
          const SizedBox(height: 32),
          GradientButton(
            text: 'Submit Vouch',
            isLoading: _isSubmitting,
            onPressed: (_selectedRating == 0 || _isSubmitting) ? null : _submit,
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
}
