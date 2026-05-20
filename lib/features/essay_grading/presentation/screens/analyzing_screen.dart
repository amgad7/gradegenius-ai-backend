import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../cubit/essay_cubit.dart';
import '../cubit/essay_state.dart';
import '../widgets/animated_progress_bar.dart';

/// Analyzing screen with pulsing animation and progress indicators
/// Matches the "AI ACTIVE" mockup design
class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back navigation during analysis
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<EssayCubit, EssayState>(
            builder: (context, state) {
              final progress = state is EssayLoading ? state.progress : 0.0;
              final statusMessage = state is EssayLoading
                  ? state.statusMessage
                  : 'Starting...';

              return Column(
                children: [
                  const Spacer(flex: 2),

                  // "AI ACTIVE" badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryPurple.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      AppStrings.aiActive,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Pulsing circles + icon
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryPurple.withOpacity(
                                  0.08,
                                ),
                                width: 1,
                              ),
                            ),
                          ),
                          // Middle ring
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryPurple.withOpacity(
                                  0.12,
                                ),
                                width: 1,
                              ),
                            ),
                          ),
                          // Inner ring
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryPurple.withOpacity(0.08),
                            ),
                          ),
                          // Center icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryPurple.withOpacity(
                                    0.15,
                                  ),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit_note_rounded,
                              color: AppColors.primaryPurple,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    AppStrings.analyzingTitle,
                    style: Theme.of(
                      context,
                    ).textTheme.displayMedium?.copyWith(fontSize: 26),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      AppStrings.analyzingSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: AnimatedProgressBar(progress: progress),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    statusMessage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Status chips
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _StatusChip(
                        icon: Icons.check_circle_outline,
                        label: AppStrings.contextLoaded,
                        isActive: progress >= 0.3,
                      ),
                      _StatusChip(
                        icon: Icons.auto_awesome,
                        label: AppStrings.evaluatingFlow,
                        isActive: progress >= 0.5,
                      ),
                      _StatusChip(
                        icon: Icons.record_voice_over_outlined,
                        label: AppStrings.verifyingTone,
                        isActive: progress >= 0.7,
                      ),
                    ],
                  ),

                  const Spacer(flex: 3),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isActive ? 1.0 : 0.4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? AppColors.primaryPurple : AppColors.textHint,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isActive ? AppColors.textSecondary : AppColors.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
