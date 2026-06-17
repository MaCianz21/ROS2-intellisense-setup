#!/usr/bin/env bash
# =============================================================================
# ROS IntelliSense Build & Merge Script
# =============================================================================
# Usage:
#   ./build.sh                          # Build all packages
#   ./build.sh --packages-select pkg_a  # Build specific packages
#
# All extra arguments are forwarded to colcon build.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ---------------------------------------------------------------------------
# 1. Build with compile-commands export
# ---------------------------------------------------------------------------
echo "========================================"
echo " Building ROS workspace with IntelliSense support..."
echo "========================================"

colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON "$@"

BUILD_EXIT=$?
if [ $BUILD_EXIT -ne 0 ]; then
    echo "ERROR: colcon build failed (exit code $BUILD_EXIT)" >&2
    exit $BUILD_EXIT
fi

echo ""
echo "Build complete."

# ---------------------------------------------------------------------------
# 2. Merge compile_commands.json files
# ---------------------------------------------------------------------------
echo "========================================"
echo " Merging compile_commands.json files..."
echo "========================================"

if [ ! -d "build" ]; then
    echo "ERROR: 'build/' directory not found. Are you in a ROS workspace root?" >&2
    exit 1
fi

# Check if merge.py exists
MERGE_SCRIPT="$SCRIPT_DIR/merge.py"
if [ ! -f "$MERGE_SCRIPT" ]; then
    echo "ERROR: merge.py not found at $MERGE_SCRIPT" >&2
    exit 1
fi

# Ensure merge.py is executable
chmod +x "$MERGE_SCRIPT"

# Run the merge script
python3 "$MERGE_SCRIPT"

MERGE_EXIT=$?
if [ $MERGE_EXIT -ne 0 ]; then
    echo "ERROR: merge.py failed (exit code $MERGE_EXIT)" >&2
    exit $MERGE_EXIT
fi

# ---------------------------------------------------------------------------
# 3. Signal VS Code to reload IntelliSense (if possible)
# ---------------------------------------------------------------------------
# Touch the merged file so the C/C++ extension detects the change
if [ -f "build/compile_commands.json" ]; then
    touch "build/compile_commands.json"
fi

echo ""
echo "========================================"
echo " SUCCESS"
echo "========================================"
echo ""
echo "  Next steps:"
echo "    - If IntelliSense doesn't update automatically, run:"
echo "      Ctrl+Shift+P  →  C/C++: Reset IntelliSense Database"
echo ""
echo "  Shortcuts for future builds:"
echo "    ./build.sh                                    # Build all"
echo "    ./build.sh --packages-select my_pkg           # Build one package"
echo "    Ctrl+Shift+B  (in VS Code with task defined)  # Build from editor"
echo "========================================"
