#!/bin/bash
# Update version across all project files
# Usage: ./scripts/update-version.sh 2.2.0

set -eo pipefail

VERSION=${1:-}

# Validation
if [ -z "$VERSION" ]; then
  echo "❌ Usage: update-version.sh <version>"
  echo ""
  echo "Examples:"
  echo "  update-version.sh 2.1.0"
  echo "  update-version.sh 2.2.0-beta.1"
  exit 1
fi

# Validate version format (semantic versioning)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?(\+[a-zA-Z0-9.]+)?$ ]]; then
  echo "❌ Invalid version format: $VERSION"
  echo "Expected: MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]"
  exit 1
fi

echo "🔄 Updating version to $VERSION..."
echo ""

# Project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# 1. Update VERSION file
echo "📝 Updating VERSION file..."
echo "$VERSION" > VERSION
echo "  ✓ VERSION → $VERSION"

# 2. Update CHANGELOG.md (only if it's a release version, not -dev)
if [[ ! "$VERSION" =~ -dev$ ]]; then
  if grep -q "## \[Unreleased\]" CHANGELOG.md; then
    echo "📝 Updating CHANGELOG.md..."
    RELEASE_DATE=$(date +%Y-%m-%d)
    sed -i.bak "s/## \[Unreleased\]/## [$VERSION] - $RELEASE_DATE/" CHANGELOG.md
    rm CHANGELOG.md.bak 2>/dev/null || true
    echo "  ✓ CHANGELOG.md updated with date $RELEASE_DATE"
  fi
fi

# 3. Update docs with version marker
echo "📝 Updating documentation files..."
doc_count=0
for file in docs/*.md; do
  if grep -q "^**版本**:" "$file"; then
    sed -i.bak "s/^\*\*版本\*\*:.*/\*\*版本\*\*: $VERSION/" "$file"
    rm "$file.bak" 2>/dev/null || true
    ((doc_count++))
  fi
done
echo "  ✓ Updated $doc_count documentation files"

# 4. Check for version mentions in README
if grep -q "homeup" README.md; then
  echo "📝 Checking README.md..."
  if grep -q "v[0-9]\+\.[0-9]\+\.[0-9]\+" README.md; then
    echo "  ⚠️  README.md contains version references - please review manually"
  fi
fi

# 5. Verify sync
echo ""
echo "✅ Version update complete!"
echo ""
echo "📋 Verification:"
echo "  VERSION file: $(cat VERSION)"

# Count docs with correct version
doc_correct=$(grep -r "版本: $VERSION" docs/ 2>/dev/null | wc -l)
echo "  Documentation: $doc_correct files with correct version"

echo ""
echo "📦 Next steps for release:"
echo "  1. Review changes: git diff"
echo "  2. Update CHANGELOG.md (if not already done)"
echo "  3. Commit: git add -A && git commit -m 'chore: release v$VERSION'"
echo "  4. Tag: git tag -a v$VERSION -m 'Release version $VERSION'"
echo "  5. Push: git push origin main --tags"
echo "  6. Create GitHub Release with changelog"
