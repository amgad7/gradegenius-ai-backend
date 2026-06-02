import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/essay_result.dart';

class SpellingCorrectionsCard extends StatelessWidget {
  final List<SpellingError> errors;

  const SpellingCorrectionsCard({super.key, required this.errors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.grammarIconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.spellcheck_rounded,
                  color: AppColors.primaryPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  AppStrings.spellingCorrections,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (errors.isEmpty)
            Text(
              AppStrings.noSpellingErrors,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ...errors.asMap().entries.map((entry) {
            final index = entry.key;
            final error = entry.value;

            return Column(
              children: [
                if (index > 0)
                  Divider(
                    color: AppColors.textHint.withValues(alpha: 0.2),
                    height: 24,
                  ),
                _CorrectionPair(error: error),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _CorrectionPair extends StatelessWidget {
  final SpellingError error;

  const _CorrectionPair({required this.error});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _WordColumn(
            label: AppStrings.misspelledWord,
            word: error.wrong,
            color: AppColors.errorRed,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.textHint,
            size: 20,
          ),
        ),
        Expanded(
          child: _WordColumn(
            label: AppStrings.correctedWord,
            word: error.correction,
            color: AppColors.successGreen,
          ),
        ),
      ],
    );
  }
}

class _WordColumn extends StatelessWidget {
  final String label;
  final String word;
  final Color color;

  const _WordColumn({
    required this.label,
    required this.word,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '"$word"',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
