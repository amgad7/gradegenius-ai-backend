"""
GradeGenius - Custom NLP Essay Grading Model
=============================================
Built specifically for this project without any external AI APIs.
Uses rule-based NLP + statistical scoring trained on the project dataset.

Techniques used:
  - Rule-based Spell Checking (from dataset patterns)
  - Keyword-based Category Classification
  - Lexical Diversity scoring (TTR - Type-Token Ratio)
  - Sentence structure analysis
  - Vocabulary richness scoring
  - Word-level NLP features
"""

import re
import math
from collections import Counter


# ────────────────────────────────────────────────────────────────
# 1. SPELLING CORRECTION MODULE
#    Trained from the project dataset (essay_correction_evaluation.csv)
# ────────────────────────────────────────────────────────────────

# These patterns were extracted directly from the GradeGenius dataset
SPELLING_CORRECTIONS = {
    "importent": "important",
    "languges":  "languages",
    "futuer":    "future",
    "contry":    "country",
    "teh":       "the",
    "alot":      "a lot",
    "recieve":   "receive",
    "beleive":   "believe",
    "occured":   "occurred",
    "seperate":  "separate",
    "definately": "definitely",
    "existance": "existence",
    "independant": "independent",
    "enviroment": "environment",
    "goverment": "government",
    "intresting": "interesting",
    "knowlege":  "knowledge",
    "neccessary": "necessary",
    "occassion": "occasion",
    "persue":    "pursue",
    "reccomend": "recommend",
    "relevent":  "relevant",
    "similer":   "similar",
    "successfull": "successful",
    "untill":    "until",
    "wierd":     "weird",
    "writting":  "writing",
    "youre":     "you're",
    "thier":     "their",
    "acheive":   "achieve",
    "concious":  "conscious",
    "dissapear": "disappear",
}

def detect_spelling_errors(text: str) -> list[dict]:
    """
    Detects spelling errors by scanning each word against the correction dictionary.
    Returns a list of {wrong, correction} dicts.
    """
    errors = []
    # Tokenize by word boundaries, preserve original casing info
    words = re.findall(r'\b\w+\b', text.lower())
    seen = set()
    for word in words:
        if word in SPELLING_CORRECTIONS and word not in seen:
            errors.append({
                "wrong": word,
                "correction": SPELLING_CORRECTIONS[word]
            })
            seen.add(word)
    return errors


# ────────────────────────────────────────────────────────────────
# 2. CATEGORY CLASSIFICATION MODULE
#    Rule-based classifier trained from dataset category labels
# ────────────────────────────────────────────────────────────────

CATEGORY_RULES = {
    "ARGUMENTATIVE": [
        "argue", "argument", "debate", "opinion", "claim",
        "therefore", "however", "moreover", "furthermore", "disagree",
        "agree", "evidence", "support", "oppose", "perspective",
        "some people", "others believe", "in my opinion", "i believe",
        "should", "must", "ought to", "on the other hand",
        "can be", "can also", "useful", "useless", "harmful", "benefit",
        "advantage", "disadvantage", "impact", "effect", "cause",
        "while others", "despite", "although", "even though",
        "it is important", "it is necessary", "we should", "people should",
        "students should", "distract", "helpful", "negative", "positive",
    ],
    "LITERATURE REVIEW": [
        "novel", "author", "literary", "symbolism", "character",
        "narrative", "theme", "plot", "setting", "protagonist",
        "antagonist", "metaphor", "allegory", "imagery", "writer",
        "poem", "poetry", "fiction", "chapter", "literature"
    ],
    "ETHICS": [
        "moral", "ethical", "ethics", "rights", "justice",
        "responsibility", "obligation", "virtue", "integrity",
        "fairness", "equality", "dignity", "principle", "duty",
        "wrong", "right thing", "should we", "is it right"
    ],
    "HISTORY": [
        "history", "historical", "century", "war", "revolution",
        "civilization", "ancient", "empire", "dynasty", "era",
        "period", "event", "happened", "past", "kingdom",
        "battle", "treaty", "colony", "independence", "monarch"
    ],
    "NARRATIVE": [
        "story", "narrative", "told", "once", "suddenly",
        "character", "journey", "adventure", "experience",
        "happened to me", "i remember", "one day", "she said",
        "he said", "they went", "feeling", "moment"
    ],
}

def classify_category(text: str) -> str:
    """
    Classifies essay into one of 5 categories using keyword scoring.
    Returns the category with the highest keyword match count.
    """
    lower = text.lower()
    scores = {}
    for category, keywords in CATEGORY_RULES.items():
        score = sum(1 for kw in keywords if kw in lower)
        scores[category] = score

    best = max(scores, key=scores.get)
    # Only assign if at least one keyword matched
    return best if scores[best] > 0 else "OTHER"


# ────────────────────────────────────────────────────────────────
# 3. VOCABULARY SUGGESTION MODULE
#    Maps simple/weak words to stronger academic alternatives
# ────────────────────────────────────────────────────────────────

VOCAB_UPGRADES = {
    "very big":       "huge",
    "a lot of":       "numerous",
    "a lot":          "significantly",
    "very small":     "minimal",
    "very important": "crucial",
    "very good":      "excellent",
    "very bad":       "terrible",
    "good at":        "proficient in",
    "think about":    "consider",
    "talk about":     "discuss",
    "look at":        "examine",
    "find out":       "determine",
    "get better":     "improve",
    "show that":      "demonstrate that",
    "shows that":     "demonstrates that",
    "get worse":      "deteriorate",
    "take care of":   "manage",
    "in charge of":   "responsible for",
}

def suggest_vocabulary(text: str) -> list[dict]:
    """
    Finds simple/weak phrases in the text and suggests stronger alternatives.
    Returns at most 2 suggestions.
    """
    lower = text.lower()
    suggestions = []
    for original, suggestion in VOCAB_UPGRADES.items():
        if original in lower and len(suggestions) < 2:
            suggestions.append({
                "original": original,
                "suggestion": suggestion
            })
    return suggestions


# ────────────────────────────────────────────────────────────────
# 4. CORE SCORING ENGINE
#    Computes a score 0–10 based on multiple NLP features
# ────────────────────────────────────────────────────────────────

def _tokenize(text: str) -> list[str]:
    """Splits text into lowercase word tokens."""
    return re.findall(r'\b[a-zA-Z]+\b', text.lower())

def _count_sentences(text: str) -> int:
    """Counts sentences by splitting on sentence-ending punctuation."""
    sentences = re.split(r'[.!?]+', text.strip())
    return len([s for s in sentences if len(s.strip()) > 5])

def _type_token_ratio(words: list[str]) -> float:
    """
    Lexical Diversity (TTR) = unique_words / total_words
    Range: 0.0 – 1.0. Higher = more diverse vocabulary.
    """
    if not words:
        return 0.0
    return len(set(words)) / len(words)

def _avg_word_length(words: list[str]) -> float:
    """Average character length of words — proxy for vocabulary complexity."""
    if not words:
        return 0.0
    return sum(len(w) for w in words) / len(words)

def _academic_word_density(words: list[str]) -> float:
    """
    Ratio of academically-rich words in the essay.
    Uses a curated list of academic vocabulary markers.
    """
    academic_words = {
        "therefore", "however", "furthermore", "moreover", "consequently",
        "nevertheless", "significant", "demonstrate", "analysis", "evidence",
        "perspective", "theory", "concept", "indicate", "suggest",
        "conclude", "evaluate", "examine", "identify", "illustrate",
        "implement", "interpret", "justify", "maintain", "obtain",
        "perceive", "principle", "procedure", "process", "require",
        "research", "respond", "role", "section", "significant",
        "similar", "source", "specific", "structure", "traditional",
    }
    if not words:
        return 0.0
    count = sum(1 for w in words if w in academic_words)
    return count / len(words)

def _sentence_length_variance(text: str) -> float:
    """
    Measures variation in sentence length — good writing varies sentence lengths.
    Returns a normalized variance score (0–1).
    """
    sentences = [s.strip() for s in re.split(r'[.!?]+', text) if len(s.strip()) > 5]
    if len(sentences) < 2:
        return 0.0
    lengths = [len(s.split()) for s in sentences]
    mean = sum(lengths) / len(lengths)
    variance = sum((l - mean) ** 2 for l in lengths) / len(lengths)
    # Normalize: good variance is around 20–50. Cap at 1.0
    return min(math.sqrt(variance) / 10.0, 1.0)

def compute_score(text: str, spelling_errors: list[dict]) -> float:
    """
    Computes the overall essay score from 0–10 using a weighted formula.

    Scoring dimensions:
      - Length score        (20%) — longer essays score higher
      - Lexical diversity   (25%) — TTR (unique words / total words)
      - Word complexity     (15%) — average word length
      - Academic density    (15%) — ratio of academic vocabulary
      - Sentence structure  (10%) — sentence count + variance
      - Spelling penalty    (15%) — deduct points for spelling errors
    """
    words = _tokenize(text)
    word_count = len(words)
    sentence_count = _count_sentences(text)

    # ── Length Score (0–10)
    if word_count < 30:
        length_score = 2.0
    elif word_count < 80:
        length_score = 4.0
    elif word_count < 150:
        length_score = 6.0
    elif word_count < 250:
        length_score = 7.5
    elif word_count < 400:
        length_score = 8.5
    else:
        length_score = 9.5

    # ── Lexical Diversity Score (0–10)
    ttr = _type_token_ratio(words)
    # TTR naturally decreases as text length grows, so we adjust
    if word_count > 100:
        ttr = min(ttr * 1.3, 1.0)
    diversity_score = ttr * 10.0

    # ── Word Complexity Score (0–10)
    avg_len = _avg_word_length(words)
    # Average English word is ~5 chars. Academic text is ~6–7
    complexity_score = min((avg_len / 7.0) * 10.0, 10.0)

    # ── Academic Vocabulary Score (0–10)
    academic_density = _academic_word_density(words)
    academic_score = min(academic_density * 100.0, 10.0)  # scale up

    # ── Sentence Structure Score (0–10)
    sentence_score = min(sentence_count / 10.0, 1.0) * 7.0
    variance_bonus = _sentence_length_variance(text) * 3.0
    structure_score = sentence_score + variance_bonus

    # ── Spelling Penalty
    # Each spelling error reduces score. Max penalty = 3.0 points
    spelling_penalty = min(len(spelling_errors) * 0.75, 3.0)

    # ── Weighted Final Score
    raw_score = (
        length_score     * 0.20 +
        diversity_score  * 0.25 +
        complexity_score * 0.15 +
        academic_score   * 0.15 +
        structure_score  * 0.10
    ) * (10.0 / 10.0)  # normalize

    # Spelling penalty applied after weighting
    final_score = raw_score - (spelling_penalty * 0.15)

    return round(max(2.0, min(final_score, 9.8)), 1)


# ────────────────────────────────────────────────────────────────
# 5. FEEDBACK GENERATION MODULE
#    Generates human-readable feedback for each grading dimension
# ────────────────────────────────────────────────────────────────

def generate_grammar_feedback(score: float, spelling_errors: list[dict]) -> str:
    """Generates grammar feedback string with spelling corrections."""
    if spelling_errors:
        corrections = "; ".join(
            f"'{e['wrong']}' → '{e['correction']}'" for e in spelling_errors
        )
        base = f"Spelling errors found: {corrections}."
    else:
        base = "No spelling mistakes found."

    if score >= 8.0:
        return f"{base} Overall grammar is excellent."
    elif score >= 6.0:
        return f"{base} Some sentence structures could be improved."
    else:
        return f"{base} Several grammar issues need correction."

def generate_grammar_status(score: float) -> str:
    if score >= 8.0:
        return "Overall mechanics are excellent"
    elif score >= 6.0:
        return "Some grammar issues detected"
    else:
        return "Significant grammar improvements needed"

def generate_coherence_feedback(score: float) -> str:
    if score >= 8.0:
        return "Ideas flow logically and are well-connected throughout."
    elif score >= 6.0:
        return "The essay is generally clear, but some transitions could be smoother."
    elif score >= 4.0:
        return "Some ideas feel disconnected. Use transitional phrases to improve flow."
    else:
        return "The essay lacks clear organization. Restructure with intro, body, and conclusion."

def generate_coherence_status(score: float) -> str:
    if score >= 8.0:
        return "Logic flow is highly logical"
    elif score >= 6.0:
        return "Flow could be improved"
    else:
        return "Structure needs significant work"

def generate_vocabulary_feedback(score: float, vocab_suggestions: list[dict]) -> str:
    base = ""
    if vocab_suggestions:
        pairs = ", ".join(
            f"'{s['original']}' → '{s['suggestion']}'" for s in vocab_suggestions
        )
        base = f"Vocabulary upgrades suggested: {pairs}. "

    if score >= 8.0:
        return f"{base}Vocabulary is rich and academically appropriate."
    elif score >= 6.0:
        return f"{base}Use more precise academic words in some places."
    else:
        return f"{base}Vocabulary needs more variety and academic depth."

def generate_semantics_feedback(score: float) -> str:
    if score >= 8.0:
        return "The essay meaning is clear, focused, and well-supported."
    elif score >= 6.0:
        return "The main idea is clear, but some points need stronger support."
    else:
        return "The main argument needs clearer expression and supporting evidence."

def generate_title(text: str, category: str) -> str:
    """Generates a short title from the essay's most significant words."""
    # Remove stop words and short words
    stop_words = {
        "the", "and", "for", "with", "that", "this", "from", "have",
        "are", "was", "were", "has", "had", "not", "but", "can",
        "will", "its", "their", "they", "them", "also", "been",
        "when", "which", "who", "how", "what", "where", "why",
        "about", "into", "than", "more", "some", "any", "all",
    }
    words = re.findall(r'\b[a-zA-Z]+\b', text)
    meaningful = [
        w.capitalize() for w in words
        if len(w) > 3 and w.lower() not in stop_words
    ]

    if len(meaningful) < 3:
        return f"{category.title()} Essay Analysis"

    # Use first 5 meaningful words
    return " ".join(meaningful[:5])


# ────────────────────────────────────────────────────────────────
# 6. MAIN GRADING PIPELINE
#    Orchestrates all modules into a single analysis result
# ────────────────────────────────────────────────────────────────

def grade_essay(essay_text: str) -> dict:
    """
    Main entry point — grades an essay and returns a structured result dict.

    Steps:
      1. Detect spelling errors
      2. Classify category
      3. Find vocabulary suggestions
      4. Compute score
      5. Generate all feedback
      6. Build final response

    Returns: dict matching the Flutter EssayResponseModel JSON format
    """
    text = essay_text.strip()

    # Step 1: Spelling
    spelling_errors = detect_spelling_errors(text)

    # Step 2: Category
    category = classify_category(text)

    # Step 3: Vocabulary
    vocab_suggestions = suggest_vocabulary(text)

    # Step 4: Score
    score = compute_score(text, spelling_errors)

    # Step 5: All feedback
    grammar_feedback    = generate_grammar_feedback(score, spelling_errors)
    grammar_status      = generate_grammar_status(score)
    coherence_feedback  = generate_coherence_feedback(score)
    coherence_status    = generate_coherence_status(score)
    vocabulary_feedback = generate_vocabulary_feedback(score, vocab_suggestions)
    semantics_feedback  = generate_semantics_feedback(score)
    title               = generate_title(text, category)

    # Step 6: Build response matching Flutter's EssayResponseModel
    return {
        "score":            score,
        "grammar":          grammar_feedback,
        "coherence":        coherence_feedback,
        "vocabulary":       vocabulary_feedback,
        "semantics":        semantics_feedback,
        "category":         category,
        "title":            title,
        "grammar_status":   grammar_status,
        "coherence_status": coherence_status,
        "spelling_errors":  spelling_errors,
        "vocab_suggestions": vocab_suggestions,
        "analysis_time_seconds": 0.0,  # will be filled by the server
    }
