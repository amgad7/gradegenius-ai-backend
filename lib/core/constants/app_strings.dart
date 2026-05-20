/// All user-facing strings used throughout the app
class AppStrings {
  AppStrings._();

  // === App Identity ===
  static const String appName = 'Essay Grader AI';
  static const String appTagline = 'THE LUCID SCHOLAR';
  static const String appPowered = 'POWERED BY ADVANCED ANALYTICS';

  // === Home Screen ===
  static const String submitTitle = 'Submit Your Essay';
  static const String submitSubtitle =
      'Experience the clarity of AI-driven academic feedback. Paste your text below to begin a comprehensive editorial analysis.';
  static const String inputHint = 'Start typing your essay or paste it here...';
  static const String wordCount = 'Words';
  static const String analyzeButton = 'Analyze Essay';
  static const String uploadDocument = 'Upload Document';
  static const String analysisSettings = 'Analysis Settings';

  // === What We Analyze ===
  static const String whatWeAnalyze = 'What we analyze';
  static const String structureTitle = 'Structure & Flow';
  static const String structureDesc =
      'We examine the logical progression of your arguments and paragraph transitions.';
  static const String grammarTitle = 'Grammar & Syntax';
  static const String grammarDesc =
      'Surgical precision in identifying punctuation, spelling, and sentence structure issues.';
  static const String argumentTitle = 'Argument Depth';
  static const String argumentDesc =
      'AI-powered insights into the strength of your thesis and supporting evidence.';

  // === Analyzing Screen ===
  static const String aiActive = 'AI ACTIVE';
  static const String analyzingTitle = 'Analyzing your essay...';
  static const String analyzingSubtitle =
      'The Lucid Scholar is scanning for clarity, structure, and editorial depth.';
  static const String contextLoaded = 'Context Loaded';
  static const String evaluatingFlow = 'Evaluating Flow';
  static const String verifyingTone = 'Verifying Tone';

  // === Results Screen ===
  static const String analysisComplete = 'Analysis';
  static const String completeWord = 'Complete.';
  static const String resultSubtitle = 'Here is a short correction summary.';
  static const String finalScore = 'FINAL SCORE';
  static const String topPercentage = 'AI Score';
  static const String grammarFeedback = 'Grammar Feedback';
  static const String spellingCorrections = 'Spelling Corrections';
  static const String noSpellingErrors = 'No spelling mistakes found.';
  static const String misspelledWord = 'WRONG';
  static const String correctedWord = 'CORRECTION';
  static const String coherenceFeedback = 'Coherence Feedback';
  static const String vocabularySuggestions = 'Better Words';
  static const String semanticsAnalysis = 'Semantics Analysis';
  static const String tryAnother = 'Try Another Essay';
  static const String evaluationTime = 'Evaluation took';
  static const String usingModel = 'using Gemini 2.0 Flash';
  static const String insteadOf = 'WORD';
  static const String tryWord = 'BETTER';

  // === History Screen ===
  static const String historyTitle = 'Your Essays';
  static const String historySubtitle =
      'Review your scholarly progress and previous AI evaluations.';
  static const String loadMore = 'Load more essays';
  static const String noHistory = 'No essays analyzed yet';
  static const String noHistorySubtitle =
      'Submit your first essay to see it appear here.';

  // === Navigation ===
  static const String navHome = 'Home';
  static const String navHistory = 'History';

  // === Errors ===
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'No internet connection. Please check your network.';
  static const String errorMinLength =
      'Essay must be at least 50 characters long.';
  static const String errorEmpty = 'Please enter your essay text.';
  static const String retryButton = 'Retry';
}
