import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_selector/file_selector.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:docx_to_text/docx_to_text.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_constants.dart';
import '../cubit/essay_cubit.dart';
import '../cubit/essay_state.dart';
import '../widgets/app_header.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/essay_input_field.dart';
import '../widgets/analyze_button.dart';
import '../widgets/feature_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isAnalyzingRouteOpen = false;

  bool get _canSubmit =>
      _textController.text.trim().length >= AppConstants.minEssayLength;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EssayCubit, EssayState>(
      listener: (context, state) {
        if (state is EssayLoading && !_isAnalyzingRouteOpen) {
          _isAnalyzingRouteOpen = true;
          Navigator.of(context).pushNamed('/analyzing');
        } else if (state is EssaySuccess && _isAnalyzingRouteOpen) {
          _isAnalyzingRouteOpen = false;
          Navigator.of(context).pushReplacementNamed('/result');
        } else if (state is EssayError) {
          if (_isAnalyzingRouteOpen && Navigator.of(context).canPop()) {
            _isAnalyzingRouteOpen = false;
            Navigator.of(context).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorRed,
              action: SnackBarAction(
                label: AppStrings.retryButton,
                textColor: Colors.white,
                onPressed: () => _submitEssay(),
              ),
            ),
          );
        }
      },
      child: Scaffold(
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

                  Text(
                    AppStrings.submitTitle,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    AppStrings.submitSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  EssayInputField(
                    controller: _textController,
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _ActionChip(
                        icon: Icons.upload_file_rounded,
                        label: AppStrings.uploadDocument,
                        onTap: _pickDocument,
                      ),
                      const SizedBox(width: 12),
                      _ActionChip(
                        icon: Icons.tune_rounded,
                        label: AppStrings.analysisSettings,
                        onTap: () => SettingsSheet.show(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  AnalyzeButton(isEnabled: _canSubmit, onPressed: _submitEssay),
                  const SizedBox(height: 40),

                  Text(
                    AppStrings.whatWeAnalyze,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),

                  const FeatureCard(
                    icon: Icons.dashboard_rounded,
                    iconBgColor: AppColors.coherenceIconBg,
                    iconColor: AppColors.primaryBlue,
                    title: AppStrings.structureTitle,
                    description: AppStrings.structureDesc,
                  ),
                  const SizedBox(height: 12),
                  const FeatureCard(
                    icon: Icons.spellcheck_rounded,
                    iconBgColor: AppColors.grammarIconBg,
                    iconColor: AppColors.primaryPurple,
                    title: AppStrings.grammarTitle,
                    description: AppStrings.grammarDesc,
                  ),
                  const SizedBox(height: 12),
                  const FeatureCard(
                    icon: Icons.psychology_rounded,
                    iconBgColor: AppColors.vocabularyIconBg,
                    iconColor: Color(0xFFE17055),
                    title: AppStrings.argumentTitle,
                    description: AppStrings.argumentDesc,
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
            if (index == 1) {
              Navigator.of(context).pushNamed('/history');
            }
          },
        ),
      ),
    );
  }

  void _submitEssay() {
    if (_isAnalyzingRouteOpen) return;

    final text = _textController.text.trim();
    if (text.length >= AppConstants.minEssayLength) {
      context.read<EssayCubit>().submitEssay(text);
    }
  }

  Future<void> _pickDocument() async {
    try {
      const typeGroup = XTypeGroup(
        label: 'Documents',
        extensions: ['pdf', 'docx', 'txt'],
      );
      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file == null) return;

      final extension = file.name.split('.').last.toLowerCase();
      String contents = '';

      if (extension == 'pdf') {
        final bytes = await File(file.path).readAsBytes();
        final PdfDocument document = PdfDocument(inputBytes: bytes);
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        contents = extractor.extractText();
        document.dispose();
      } else if (extension == 'docx') {
        final bytes = await File(file.path).readAsBytes();
        contents = docxToText(bytes);
      } else if (extension == 'txt') {
        contents = await file.readAsString();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Unsupported file type ".${extension}". Please use PDF, DOCX, or TXT.',
              ),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
        return;
      }

      if (contents.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not extract text from this file. Make sure it contains readable text.',
              ),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
        return;
      }

      setState(() {
        _textController.text = contents;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reading file: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
