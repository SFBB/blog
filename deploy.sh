#!/usr/bin/env bash
set -e

# Add possible user gem bin paths to PATH and set GEM_HOME
export GEM_HOME="$HOME/.local/share/gem/ruby/3.2.0"
export PATH="$GEM_HOME/bin:$HOME/.local/bin:$PATH"

# Ensure Bundler installs into project-local vendor/bundle to avoid /var/lib permission issues
bundle config set --local path 'vendor/bundle' &> /dev/null || true

echo "=========================================="
echo "🚀 Starting Local Build & Deploy"
echo "=========================================="

# Check for bundle command
if ! command -v bundle &> /dev/null; then
    echo "❌ Error: 'bundle' command not found."
    echo "👉 Please run the following command to install ruby dev dependencies:"
    echo "   sudo apt install -y ruby-dev build-essential"
    echo "   gem install --user-install bundler"
    exit 1
fi

# Check if gems are installed
if ! bundle check &> /dev/null; then
    echo "📦 Installing Ruby dependencies via bundle..."
    bundle install || {
        echo "❌ 'bundle install' failed."
        echo "👉 If it failed compiling C extensions, run: sudo apt install -y ruby-dev build-essential"
        exit 1
    }
fi

# Detect repository name from git remote
REMOTE_URL=$(git config --get remote.origin.url)
if [ -z "$REMOTE_URL" ]; then
    echo "❌ Error: git remote origin not configured."
    exit 1
fi

REPO_NAME=$(basename -s .git "$REMOTE_URL")
if [[ "$REPO_NAME" == *".github.io" ]]; then
    BASE_URL=""
else
    BASE_URL="/$REPO_NAME"
fi

echo "📋 Target Repository: $REPO_NAME"
echo "🌐 Base URL: ${BASE_URL:-/(root)}"

# Clean previous build
rm -rf _site

# Build the site
echo "🔨 Building Jekyll site..."
JEKYLL_ENV=production bundle exec jekyll build -d _site -b "$BASE_URL"

# Create .nojekyll to ensure GitHub Pages does not run Jekyll again
touch _site/.nojekyll

# Get git author info from local git config
AUTHOR_NAME=$(git config user.name || echo "SFBB")
AUTHOR_EMAIL=$(git config user.email || echo "sfbb123@proton.me")

echo "📤 Deploying to gh-pages branch..."
cd _site
git init
git config user.name "$AUTHOR_NAME"
git config user.email "$AUTHOR_EMAIL"
git branch -M gh-pages
git add -A
git commit --no-gpg-sign -m "Deploy site at $(date '+%Y-%m-%d %H:%M:%S')"
git remote add origin "$REMOTE_URL"
git push -f origin gh-pages

cd ..
rm -rf _site

echo "=========================================="
echo "✅ Deployed successfully to gh-pages branch!"
if [ -z "$BASE_URL" ]; then
    echo "🔗 Blog URL: https://sfbb.github.io"
else
    echo "🔗 Blog URL: https://sfbb.github.io/$REPO_NAME"
fi
echo "=========================================="
echo "💡 Reminder: Make sure your GitHub Pages setting is:"
echo "   Settings -> Pages -> Source: 'Deploy from a branch' -> Branch: 'gh-pages' / '/ (root)'"
