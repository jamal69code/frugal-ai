@echo off
REM Frugal AI Backend Setup Script for Windows
REM This script automates backend setup and deployment

echo.
echo 🚀 Frugal AI Backend Setup
echo ==========================
echo.

REM Check Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js is not installed
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo ✓ Node.js %NODE_VERSION%
echo.

REM Navigate to backend
cd /d "%~dp0backend"

REM Check if .env exists
if not exist .env (
    echo ⚠ .env file not found
    echo Creating .env from .env.example...
    
    if exist .env.example (
        copy .env.example .env
        echo ⚠ Please update .env with your credentials
        echo Edit: backend\.env
        pause
        exit /b 1
    ) else (
        echo ❌ .env.example not found
        pause
        exit /b 1
    )
)

REM Install dependencies
echo.
echo 📦 Installing dependencies...
call npm install

REM Create directories
if not exist uploads mkdir uploads
if not exist logs mkdir logs

echo.
echo ==================================
echo ✓ Setup complete!
echo ==================================
echo.
echo To start the server:
echo npm run dev    (Development with auto-reload)
echo npm start      (Production)
echo.
echo API will be available at: http://localhost:5000
echo.
pause
