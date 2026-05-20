import '../../../../core/constants/app_constants.dart';

/// Data model for the essay grading API request
class EssayRequestModel {
  final String essayText;

  const EssayRequestModel({required this.essayText});

  /// Convert to Gemini API payload format
  Map<String, dynamic> toGeminiPayload() {
    return {
      "contents": [
        {
          "parts": [
            {
              "text": "${AppConstants.gradingPrompt}\n\n$essayText"
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.2,
        "maxOutputTokens": 1500,
        "responseMimeType": "application/json"
      }
    };
  }
}
