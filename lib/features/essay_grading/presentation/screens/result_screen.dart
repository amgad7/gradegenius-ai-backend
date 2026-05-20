import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../cubit/essay_cubit.dart';
import '../cubit/essay_state.dart';
import '../widgets/app_header.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/score_circle.dart';
import '../widgets/feedback_card.dart';
import '../widgets/vocabulary_card.dart';

/// Result screen showing the AI grading results
/// Displays score, grammar, coherence, vocabulary, and semantics feedback
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EssayCubit, EssayState>(
      builder: (context, state) {
        if (state is! EssaySuccess) {
          // Should not happen, but handle gracefully
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final result = state.result;
        final grammarFeedback = result.spellingErrors.isEmpty
            ? AppStrings.noSpellingErrors
            : result.spellingErrors
                  .map((error) => '"${error.wrong}" -> "${error.correction}"')
                  .join('\n');

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: const AppDrawer(),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const AppHeader(),
                    const SizedBox(height: 32),

                    // "Analysis Complete." title
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${AppStrings.analysisComplete} ',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          TextSpan(
                            text: AppStrings.completeWord,
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(color: AppColors.successGreen),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      AppStrings.resultSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),

                    // Score circle
                    Center(child: ScoreCircle(score: result.score)),
                    const SizedBox(height: 32),

                    // Grammar feedback card
                    FeedbackCard(
                      icon: Icons.spellcheck_rounded,
                      iconBgColor: AppColors.grammarIconBg,
                      iconColor: AppColors.primaryPurple,
                      title: AppStrings.grammarFeedback,
                      feedback: grammarFeedback,
                      statusText: result.grammarStatus,
                      statusIcon: Icons.check_circle_outline,
                    ),
                    const SizedBox(height: 16),

                    // Coherence feedback card
                    FeedbackCard(
                      icon: Icons.account_tree_rounded,
                      iconBgColor: AppColors.coherenceIconBg,
                      iconColor: AppColors.primaryBlue,
                      title: AppStrings.coherenceFeedback,
                      feedback: result.coherence,
                      statusText: result.coherenceStatus,
                      statusIcon: Icons.check_circle_outline,
                    ),
                    const SizedBox(height: 16),

                    // Vocabulary suggestions
                    if (result.vocabSuggestions.isNotEmpty)
                      VocabularyCard(suggestions: result.vocabSuggestions),

                    if (result.vocabSuggestions.isNotEmpty)
                      const SizedBox(height: 16),

                    // Semantics feedback card
                    FeedbackCard(
                      icon: Icons.psychology_rounded,
                      iconBgColor: AppColors.semanticsIconBg,
                      iconColor: AppColors.successGreen,
                      title: AppStrings.semanticsAnalysis,
                      feedback: result.semantics,
                      statusText: 'Semantic analysis complete',
                      statusIcon: Icons.check_circle_outline,
                    ),
                    const SizedBox(height: 32),

                    // "Try Another Essay" button
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<EssayCubit>().reset();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home',
                              (route) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primaryPurple,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: Text(
                            AppStrings.tryAnother,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.primaryPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Evaluation time footer
                    Center(
                      child: Text(
                        '${AppStrings.evaluationTime} ${result.analysisTimeSeconds.toStringAsFixed(1)} seconds ${AppStrings.usingModel}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: 0,
            onTap: (index) {
              if (index == 0) {
                context.read<EssayCubit>().reset();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/home', (route) => false);
              } else if (index == 1) {
                Navigator.of(context).pushNamed('/history');
              }
            },
          ),
        );
      },
    );
  }
}
