/// NPS Dialog
///
/// Net Promoter Score dialog with 0-10 rating and optional feedback.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'nps_repository.dart';

/// Show the NPS dialog
Future<void> showNpsDialog(BuildContext context, WidgetRef ref, {String trigger = 'manual'}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _NpsDialog(trigger: trigger),
  );
}

class _NpsDialog extends ConsumerStatefulWidget {
  final String trigger;

  const _NpsDialog({required this.trigger});

  @override
  ConsumerState<_NpsDialog> createState() => _NpsDialogState();
}

class _NpsDialogState extends ConsumerState<_NpsDialog> {
  int? _selectedScore;
  final _feedbackController = TextEditingController();
  bool _showFeedback = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitScore() async {
    if (_selectedScore == null) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(npsRepositoryProvider);
      await repo.submitNps(
        _selectedScore!,
        _feedbackController.text.trim().isEmpty ? null : _feedbackController.text.trim(),
        widget.trigger,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Thank you for your feedback!', style: GoogleFonts.inter()),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _dismiss() async {
    final repo = ref.read(npsRepositoryProvider);
    await repo.dismissNps();
    if (mounted) Navigator.pop(context);
  }

  void _onScoreSelected(int score) {
    setState(() {
      _selectedScore = score;
      _showFeedback = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: _dismiss,
                icon: Icon(Icons.close, size: 20, color: Colors.grey[500]),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.blue.shade400],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, color: Colors.white, size: 32),
            ),

            const SizedBox(height: 20),

            // Question
            Text(
              'How likely are you to recommend\nJob Tracker to a friend?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 24),

            // Score selector
            _buildScoreSelector(isDark),

            const SizedBox(height: 8),

            // Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Not likely',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  'Very likely',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),

            // Feedback section (appears after score selection)
            if (_showFeedback) ...[
              const SizedBox(height: 24),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFeedbackPrompt(),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Your feedback helps us improve...',
                        hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                if (!_showFeedback)
                  Expanded(
                    child: TextButton(
                      onPressed: _dismiss,
                      child: Text(
                        'Maybe Later',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.grey),
                      ),
                    ),
                  ),
                if (_showFeedback) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : _submitScore,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Skip', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitScore,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('Submit', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSelector(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(11, (index) {
        final isSelected = _selectedScore == index;
        final color = _getScoreColor(index);

        return GestureDetector(
          onTap: () => _onScoreSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: isSelected ? 32 : 28,
            height: isSelected ? 32 : 28,
            decoration: BoxDecoration(
              color: isSelected ? color : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey[100]),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.grey[300]!),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                '$index',
                style: GoogleFonts.inter(
                  fontSize: isSelected ? 13 : 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 9) return Colors.green;
    if (score >= 7) return Colors.amber[600]!;
    return Colors.red[400]!;
  }

  String _getFeedbackPrompt() {
    if (_selectedScore == null) return 'What could we improve?';
    if (_selectedScore! >= 9) return 'Awesome! What do you love most?';
    if (_selectedScore! >= 7) return 'Thanks! What could make it a 10?';
    return 'We\'d love to do better. What went wrong?';
  }
}
