@echo off
echo ============================================
echo  GradeGenius - Custom NLP Model Server
echo ============================================
echo.
echo Starting Python FastAPI server on port 8000...
echo.
echo  Flutter App (Emulator) connects via: http://10.0.2.2:8000
echo  Flutter App (Real Phone) connects via: http://YOUR_PC_IP:8000
echo  Browser test: http://localhost:8000/docs
echo.
echo Press Ctrl+C to stop the server.
echo.
cd /d %~dp0
uvicorn server:app --host 0.0.0.0 --port 8000 --reload
pause
