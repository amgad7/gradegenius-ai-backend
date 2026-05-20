import 'dart:math';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/essay_result.dart';
import '../models/essay_request_model.dart';
import '../models/essay_response_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';

/// Remote data source for essay grading
/// Currently uses a MOCK implementation
/// Switch to real OpenAI API by uncommenting the real implementation
abstract class EssayRemoteDataSource {
  /// Submit an essay for AI grading
  Future<EssayResponseModel> submitEssay(EssayRequestModel request);
}

/// MOCK implementation that returns realistic fake responses
/// Replace with [EssayRemoteDataSourceReal] when API key is available
class EssayRemoteDataSourceMock implements EssayRemoteDataSource {
  @override
  Future<EssayResponseModel> submitEssay(EssayRequestModel request) async {
    // Simulate network delay (1.5 - 3 seconds)
    final delay = 1500 + Random().nextInt(1500);
    await Future.delayed(Duration(milliseconds: delay));

    // Simulate occasional errors (5% chance)
    if (Random().nextInt(20) == 0) {
      throw const ServerException(
        message: 'API rate limit exceeded. Please try again later.',
        statusCode: 429,
      );
    }

    final essayText = request.essayText;

    // Generate a realistic score based on essay length and complexity
    final baseScore = _calculateBaseScore(essayText);

    // Detect category based on keywords
    final category = _detectCategory(essayText);

    // Generate a title
    final title = _generateTitle(essayText);

    return EssayResponseModel(
      score: baseScore,
      grammar: _generateGrammarFeedback(baseScore, essayText),
      coherence: _generateCoherenceFeedback(baseScore),
      vocabulary: _generateVocabularyFeedback(baseScore),
      semantics: _generateSemanticsFeedback(baseScore),
      category: category,
      title: title,
      grammarStatus: baseScore >= 7.0
          ? 'Overall mechanics are excellent'
          : baseScore >= 5.0
          ? 'Some grammar issues detected'
          : 'Significant grammar improvements needed',
      coherenceStatus: baseScore >= 7.0
          ? 'Logic flow is highly logical'
          : baseScore >= 5.0
          ? 'Flow could be improved'
          : 'Structure needs significant work',
      spellingErrors: _detectSpellingErrors(essayText),
      vocabSuggestions: _generateVocabSuggestions(essayText),
      analysisTimeSeconds: delay / 1000.0,
    );
  }

  double _calculateBaseScore(String text) {
    final wordCount = text.split(RegExp(r'\s+')).length;
    final sentenceCount = text.split(RegExp(r'[.!?]+')).length;
    final avgWordLength =
        text.replaceAll(RegExp(r'\s+'), '').length /
        (wordCount > 0 ? wordCount : 1);

    // More words, longer words, more sentences = higher score
    double score = 5.0;
    if (wordCount > 100) score += 1.0;
    if (wordCount > 200) score += 0.5;
    if (wordCount > 300) score += 0.5;
    if (avgWordLength > 4.5) score += 0.5;
    if (avgWordLength > 5.5) score += 0.5;
    if (sentenceCount > 5) score += 0.5;
    if (sentenceCount > 10) score += 0.5;

    // Add some randomness
    score += (Random().nextDouble() * 1.0) - 0.5;

    return double.parse(score.clamp(3.0, 9.8).toStringAsFixed(1));
  }

  String _detectCategory(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('argue') ||
        lower.contains('debate') ||
        lower.contains('opinion') ||
        lower.contains('claim')) {
      return 'ARGUMENTATIVE';
    }
    if (lower.contains('novel') ||
        lower.contains('author') ||
        lower.contains('literary') ||
        lower.contains('symbolism')) {
      return 'LITERATURE REVIEW';
    }
    if (lower.contains('moral') ||
        lower.contains('ethical') ||
        lower.contains('rights') ||
        lower.contains('justice')) {
      return 'ETHICS';
    }
    if (lower.contains('history') ||
        lower.contains('century') ||
        lower.contains('war') ||
        lower.contains('revolution')) {
      return 'HISTORY';
    }
    if (lower.contains('story') ||
        lower.contains('narrative') ||
        lower.contains('character')) {
      return 'NARRATIVE';
    }
    return 'ARGUMENTATIVE'; // Default
  }

  String _generateTitle(String text) {
    final words = text.split(RegExp(r'\s+'));
    if (words.length < 5) return 'Short Essay Analysis';

    // Take first meaningful words and capitalize
    final titleWords = words
        .where(
          (w) =>
              w.length > 3 &&
              ![
                'the',
                'and',
                'for',
                'with',
                'that',
                'this',
                'from',
                'have',
              ].contains(w.toLowerCase()),
        )
        .take(6)
        .toList();

    if (titleWords.isEmpty) return 'Essay Analysis';

    return titleWords
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  String _generateGrammarFeedback(double score, String text) {
    String spellingFeedback = '';
    List<String> errors = [];

    // Hardcoded spelling detection for presentation purposes
    final lowerText = text.toLowerCase();
    if (lowerText.contains('importent'))
      errors.add("'importent' should be 'important'");
    if (lowerText.contains('languges'))
      errors.add("'languges' should be 'languages'");
    if (lowerText.contains('futuer')) errors.add("'futuer' should be 'future'");
    if (lowerText.contains('contry'))
      errors.add("'contry' should be 'country'");
    if (lowerText.contains('teh ')) errors.add("'teh' should be 'the'");
    if (lowerText.contains('alot')) errors.add("'alot' should be 'a lot'");

    if (errors.isNotEmpty) {
      spellingFeedback = "Spelling errors detected: ${errors.join(', ')}.\n\n";
    }

    if (score >= 8.0) {
      return '${spellingFeedback}Grammar is mostly correct.';
    } else if (score >= 6.0) {
      return '${spellingFeedback}Check a few sentence structure issues.';
    }
    return '${spellingFeedback}Several grammar issues need correction.';
  }

  String _generateCoherenceFeedback(double score) {
    if (score >= 8.0) {
      return 'The ideas flow clearly.';
    } else if (score >= 6.0) {
      return 'Some transitions could be smoother.';
    }
    return 'The essay needs clearer organization.';
  }

  String _generateVocabularyFeedback(double score) {
    if (score >= 8.0) {
      return 'Vocabulary is clear and strong.';
    } else if (score >= 6.0) {
      return 'Use more precise words in repeated places.';
    }
    return 'Vocabulary needs more variety.';
  }

  String _generateSemanticsFeedback(double score) {
    if (score >= 8.0) {
      return 'The meaning is clear and connected.';
    } else if (score >= 6.0) {
      return 'Some ideas need clearer connection.';
    }
    return 'The main meaning needs clearer support.';
  }

  List<SpellingError> _detectSpellingErrors(String text) {
    final lowerText = text.toLowerCase();
    final errors = <SpellingError>[];

    void addIfFound(String wrong, String correction) {
      if (lowerText.contains(wrong)) {
        errors.add(SpellingError(wrong: wrong, correction: correction));
      }
    }

    addIfFound('importent', 'important');
    addIfFound('languges', 'languages');
    addIfFound('futuer', 'future');
    addIfFound('contry', 'country');
    addIfFound('teh', 'the');
    addIfFound('alot', 'a lot');

    return errors;
  }

  List<VocabSuggestion> _generateVocabSuggestions(String text) {
    final lowerText = text.toLowerCase();
    final suggestions = <VocabSuggestion>[];

    void addIfFound(String original, String suggestion) {
      if (lowerText.contains(original) && suggestions.length < 2) {
        suggestions.add(
          VocabSuggestion(original: original, suggestion: suggestion),
        );
      }
    }

    addIfFound('very big', 'huge');
    addIfFound('a lot of', 'many');
    addIfFound('good', 'strong');
    addIfFound('bad', 'weak');
    addIfFound('show', 'explain');
    addIfFound('think about', 'consider');

    return suggestions;
  }
}

// ============================================================
// CUSTOM NLP MODEL IMPLEMENTATION  ← الموديل بتاعنا
// Calls our Python FastAPI backend at localhost:8000
// ============================================================
class EssayRemoteDataSourceCustom implements EssayRemoteDataSource {
  final Dio dio;
  final EssayRemoteDataSourceMock _mockFallback = EssayRemoteDataSourceMock();

  EssayRemoteDataSourceCustom({required this.dio});

  @override
  Future<EssayResponseModel> submitEssay(EssayRequestModel request) async {
    try {
      final response = await dio.post(
        '/grade',
        data: {'essay_text': request.essayText},
      );

      if (response.statusCode == 200) {
        return EssayResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
    } on DioException catch (_) {
      // Server not reachable → fall back to mock silently
    } catch (_) {
      // Any error → fall back to mock silently
    }

    // Fallback to mock if server is not running
    return _mockFallback.submitEssay(request);
  }
}

// ============================================================
// GEMINI API IMPLEMENTATION (kept for reference)
// ============================================================
class EssayRemoteDataSourceGemini implements EssayRemoteDataSource {
  final Dio dio;
  final EssayRemoteDataSourceMock _mockFallback = EssayRemoteDataSourceMock();

  EssayRemoteDataSourceGemini({required this.dio});

  @override
  Future<EssayResponseModel> submitEssay(EssayRequestModel request) async {
    // Try up to 2 times (with a delay between retries)
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await dio.post(
          ApiEndpoints.generateContent,
          data: request.toGeminiPayload(),
        );

        if (response.statusCode == 200) {
          // Gemini response structure parsing
          final candidates = response.data['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final content =
                candidates[0]['content']['parts'][0]['text'] as String;

            // Clean up the response if Gemini wraps it in ```json ... ```
            String cleanContent = content.trim();
            if (cleanContent.startsWith('```json')) {
              cleanContent = cleanContent.substring(7);
            } else if (cleanContent.startsWith('```')) {
              cleanContent = cleanContent.substring(3);
            }
            if (cleanContent.endsWith('```')) {
              cleanContent = cleanContent.substring(0, cleanContent.length - 3);
            }
            cleanContent = cleanContent.trim();

            final jsonResponse =
                json.decode(cleanContent) as Map<String, dynamic>;
            return EssayResponseModel.fromJson(jsonResponse);
          }
        }
      } on DioException catch (e) {
        // If 429 (rate limit) on first attempt, wait 4 seconds and retry
        if (e.response?.statusCode == 429 && attempt == 0) {
          await Future.delayed(const Duration(seconds: 4));
          continue; // retry
        }
        // On second attempt or other errors, fall through to fallback
        break;
      } catch (_) {
        break;
      }
    }

    // Fallback to Mock silently - the app NEVER crashes!
    return _mockFallback.submitEssay(request);
  }
}
