#!/bin/bash

# Fast Commit Generator - Generates 10,000 commits
# March Portfolio Edition

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 March Portfolio Commit Generator${NC}"
echo "====================================="
echo ""

# Check if git is initialized
if [ ! -d .git ]; then
    echo -e "${YELLOW}Initializing git...${NC}"
    git init
    git add .
    git commit -m "chore: initial commit" --quiet
fi

# Create commit history file
HISTORY_FILE=".commit-history.txt"
touch $HISTORY_FILE

echo -e "${YELLOW}⚠️  Generating 10,000 commits. This will take 5-10 minutes.${NC}"
echo ""

START_TIME=$(date +%s)
COMMIT_COUNT=0

# Function to generate and commit in batches
batch_commit() {
    local phase=$1
    local count=$2
    local prefix=$3
    
    echo -e "${BLUE}$phase${NC}"
    
    for ((i=1; i<=count; i++)); do
        # Generate commit message
        local num=$((RANDOM % 100))
        local msg=""
        
        case $((num % 10)) in
            0) msg="feat($prefix): implement new feature" ;;
            1) msg="fix($prefix): resolve bug" ;;
            2) msg="test($prefix): add tests" ;;
            3) msg="docs($prefix): update documentation" ;;
            4) msg="refactor($prefix): improve code structure" ;;
            5) msg="perf($prefix): optimize performance" ;;
            6) msg="style($prefix): format code" ;;
            7) msg="chore($prefix): update dependencies" ;;
            8) msg="feat($prefix): add validation" ;;
            9) msg="fix($prefix): handle edge case" ;;
        esac
        
        # Add to history file
        echo "Commit $COMMIT_COUNT: $msg" >> $HISTORY_FILE
        
        # Commit every change
        git add $HISTORY_FILE
        git commit -m "$msg" --quiet
        
        ((COMMIT_COUNT++))
        
        # Progress update every 100 commits
        if [ $((i % 100)) -eq 0 ]; then
            echo -e "   ${GREEN}✅ $COMMIT_COUNT commits${NC}"
        fi
    done
}

# Phase 1: AI & ML (1000 commits)
batch_commit "🤖 Phase 1: AI & ML" 1000 "ai-ml"

# Phase 2: Healthcare (1000 commits)
batch_commit "🏥 Phase 2: Healthcare" 1000 "healthcare"

# Phase 3: Legal (1000 commits)
batch_commit "⚖️  Phase 3: Legal" 1000 "legal"

# Phase 4: Charity (1000 commits)
batch_commit "❤️  Phase 4: Charity" 1000 "charity"

# Phase 5: Voting (1000 commits)
batch_commit "🗳️  Phase 5: Voting" 1000 "voting"

# Phase 6: Loyalty (1000 commits)
batch_commit "🎁 Phase 6: Loyalty" 1000 "loyalty"

# Phase 7: Streaming (1000 commits)
batch_commit "📺 Phase 7: Streaming" 1000 "streaming"

# Phase 8: Metaverse (1000 commits)
batch_commit "🌐 Phase 8: Metaverse" 1000 "metaverse"

# Phase 9: Carbon (1000 commits)
batch_commit "🌱 Phase 9: Carbon" 1000 "carbon"

# Phase 10: Privacy (1000 commits)
batch_commit "🔒 Phase 10: Privacy" 1000 "privacy"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo ""
echo "=================================================="
echo -e "${GREEN}✨ Complete!${NC}"
echo "=================================================="
echo -e "   Total commits: ${GREEN}$COMMIT_COUNT${NC}"
echo -e "   Time: ${GREEN}${MINUTES}m ${SECONDS}s${NC}"
echo -e "   Speed: ${GREEN}$((COMMIT_COUNT / (DURATION + 1))) commits/sec${NC}"
echo ""
echo -e "${BLUE}Next: git push origin main${NC}"
