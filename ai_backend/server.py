"""
GradeGenius - FastAPI Server
============================
Connects the Custom NLP Model to the Flutter app.
Replaces the Gemini API with your own local AI backend.

Run with:
    uvicorn server:app --host 0.0.0.0 --port 8000 --reload
"""

import time
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# Import our custom model
from model.essay_grader import grade_essay

# ── App Setup ──────────────────────────────────────────────────
app = FastAPI(
    title="GradeGenius AI API",
    description="Custom NLP Essay Grading Model — built without any external AI APIs",
    version="1.0.0",
)

# Allow Flutter app to connect (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Request / Response Models ──────────────────────────────────

class EssayRequest(BaseModel):
    """Matches the Flutter EssayRequestModel"""
    essay_text: str

class SpellingError(BaseModel):
    wrong: str
    correction: str

class VocabSuggestion(BaseModel):
    original: str
    suggestion: str

class GradeResponse(BaseModel):
    """Matches the Flutter EssayResponseModel JSON format exactly"""
    score: float
    grammar: str
    coherence: str
    vocabulary: str
    semantics: str
    category: str
    title: str
    grammar_status: str
    coherence_status: str
    spelling_errors: list[SpellingError]
    vocab_suggestions: list[VocabSuggestion]
    analysis_time_seconds: float


# ── Endpoints ──────────────────────────────────────────────────

@app.get("/")
def root():
    """Health check endpoint"""
    return {
        "status": "running",
        "model": "GradeGenius Custom NLP v1.0",
        "message": "Essay grading API is ready"
    }

@app.get("/health")
def health():
    """Ping endpoint for the Flutter app to check connectivity"""
    return {"status": "ok", "model_loaded": True}


@app.post("/grade", response_model=GradeResponse)
def grade(request: EssayRequest):
    """
    Main endpoint: Grades an essay using the custom NLP model.
    
    - Receives essay text from Flutter
    - Runs through the NLP grading pipeline
    - Returns structured JSON result
    """
    essay_text = request.essay_text.strip()

    if not essay_text:
        raise HTTPException(status_code=400, detail="Essay text cannot be empty")

    if len(essay_text) < 20:
        raise HTTPException(
            status_code=400,
            detail=f"Essay too short ({len(essay_text)} chars). Minimum is 20."
        )

    # ── Run the model and measure time
    start = time.time()
    result = grade_essay(essay_text)
    elapsed = round(time.time() - start, 3)

    # Inject actual analysis time
    result["analysis_time_seconds"] = elapsed

    return GradeResponse(**result)
