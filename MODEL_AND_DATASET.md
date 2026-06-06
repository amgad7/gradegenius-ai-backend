# GradeGenius Model and Dataset Explanation

## What model does the app use?

The current app sends text to Menna's Grammar Project hosted on Hugging Face
Spaces:

`https://menna169-grammer-project.hf.space`

The backend is a Gradio API. The Flutter app calls:

`POST /gradio_api/call/analyze_text`

Then it reads the final event result from:

`GET /gradio_api/call/analyze_text/{event_id}`

The model returns coherence percentage, grammar status, and spelling errors.

The app does not train a local AI model. There is no local `.h5`, `.pkl`, `.pt`,
`.onnx`, or `.tflite` model file in this project.

Inside this repository, the backend/model code is stored in:

- `ai_backend/model/essay_grader.py`
- `ai_backend/server.py`
- `ai_backend/evaluate_model.py`
- `ai_backend/requirements.txt`

So if someone asks for the "model code", send the `ai_backend` folder.

## Where is the model configured?

The model/backend integration is configured in the Flutter code here:

- `lib/core/constants/app_constants.dart`
  - `customBackendUrl`
  - Menna Hugging Face Space URL

- `lib/core/network/api_client.dart`
  - Creates `customInstance`
  - Uses `customBackendUrl` as the API base URL

- `lib/features/essay_grading/data/datasources/essay_remote_data_source.dart`
  - `EssayRemoteDataSourceCustom`
  - Sends the text to the Gradio `analyze_text` endpoint
  - Reads the Gradio event result
  - Maps the model output to the Flutter result model

If the supervisor asks for the "model file", the accurate answer is:

> The mobile app does not contain a local model weight file. It calls a backend
> hosted on Hugging Face Spaces. The editable model/backend files are in the
> `ai_backend` folder / Hugging Face Space repository, while the Flutter app
> contains the API connection code.

## What is the Hugging Face docs link?

The current Gradio API link:

`https://menna169-grammer-project.hf.space`

is the hosted model interface.

The app uses the Gradio API endpoint behind that interface. It receives essay
text from the app and returns the analysis result.

In simple words:

> Hugging Face hosts Menna's NLP grammar model service. Flutter is the user
> interface. The dataset is used to test the output.

## What does the custom model code do?

The connected model analyzes:

- grammar status
- spelling errors
- sentence coherence percentage

The previous local backend/model code is still stored in:

`ai_backend/model/essay_grader.py`

The previous FastAPI file is:

`ai_backend/server.py`

If spelling mistakes do not appear in the app, check these points:

1. Menna's Hugging Face Space must be running.
2. The app must call the Gradio `analyze_text` endpoint successfully.
3. The model must return spelling errors in the `Spelling Errors` output.

## What dataset is used?

The project dataset is:

`datasets/essay_correction_evaluation.csv`

This dataset contains labeled essay examples used for evaluation and testing.
It includes:

- essay text
- expected wrong words
- expected corrections
- expected essay category
- expected vocabulary improvements
- notes for evaluation

## Is the dataset used for training?

No. The dataset is not used inside the Flutter app to train a model.

The dataset is used to test and validate the app/backend output.

The correct explanation is:

> The dataset is an evaluation dataset. I use it to compare the app result with
> expected results for spelling correction, category detection, and vocabulary
> suggestions.

## How is the dataset tested?

Manual testing:

1. Open `datasets/dataset_viewer.html`.
2. Choose a row from the dataset.
3. Copy the `essay_text`.
4. Paste it into the app.
5. Compare the app result with the expected columns.

Automated testing:

Run:

```bash
dart run tools/evaluate_dataset.dart
```

The script reads:

`datasets/essay_correction_evaluation.csv`

Then it sends each essay to the grading API and writes:

- `datasets/evaluation_results.csv`
- `datasets/evaluation_summary.md`

## Short answer for discussion

> The Flutter app calls Menna's Grammar Project hosted on Hugging Face Spaces.
> The app sends the text to the Gradio `analyze_text` endpoint and maps the
> returned coherence, grammar status, and spelling errors to the app UI. The
> dataset is used for evaluation, not training.
