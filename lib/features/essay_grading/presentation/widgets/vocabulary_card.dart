import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/essay_result.dart';

/// Card showing simple vocabulary improvement suggestions.
class VocabularyCard extends StatelessWidget {
  final List<VocabSuggestion> suggestions;

  const VocabularyCard({super.key, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    final visibleSuggestions = suggestions.take(2).toList();

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
                  color: AppColors.vocabularyIconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFE17055),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  AppStrings.vocabularySuggestions,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...visibleSuggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final suggestion = entry.value;
            return Column(
              children: [
                if (index > 0)
                  Divider(
                    color: AppColors.textHint.withValues(alpha: 0.2),
                    height: 24,
                  ),
                _SuggestionPair(suggestion: suggestion),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SuggestionPair extends StatelessWidget {
  final VocabSuggestion suggestion;

  const _SuggestionPair({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.insteadOf,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textHint,
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '"${suggestion.original}"',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.tryWord,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.primaryPurple,
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '"${suggestion.suggestion}"',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
