#!/bin/bash

# Frugal AI Backend Setup Script
# This script automates backend setup and deployment

set -e

echo "🚀 Frugal AI Backend Setup"
echo "=========================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed${NC}"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

echo -e "${GREEN}✓ Node.js $(node --version)${NC}"

# Navigate to backend
cd backend

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠ .env file not found${NC}"
    echo "Creating .env from .env.example..."
    
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${YELLOW}⚠ Please update .env with your credentials${NC}"
        echo "Edit: backend/.env"
        exit 1
    else
        echo -e "${RED}❌ .env.example not found${NC}"
        exit 1
    fi
fi

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
npm install

# Create uploads directory
mkdir -p uploads
mkdir -p logs

# Check Firebase config
echo ""
echo "🔐 Checking Firebase configuration..."
if ! grep -q "FIREBASE_PROJECT_ID" .env; then
    echo -e "${RED}❌ Firebase credentials not configured${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Firebase configured${NC}"

# Run tests (optional)
if command -v npm &> /dev/null && npm list jest > /dev/null 2>&1; then
    echo ""
    echo "🧪 Running tests..."
    npm test || true
fi

# Start server
echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}✓ Setup complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "To start the server:"
echo -e "${YELLOW}npm run dev${NC}  (Development with auto-reload)"
echo -e "${YELLOW}npm start${NC}    (Production)"
echo ""
echo "API will be available at: http://localhost:5000"
echo ""
