# VS Code IntelliSense setup for ROS workspace

This workspace uses a merged `compile_commands.json` so Visual Studio Code IntelliSense can see all package compile flags and include paths.

## Quick start (one-time setup)

### 1. Configure VS Code

Make sure the workspace file `.vscode/c_cpp_properties.json` contains:

```json
{
  "configurations": [
    {
      "name": "Linux",
      "includePath": [
        "${workspaceFolder}/**"
      ],
      "defines": [],
      "cStandard": "c17",
      "cppStandard": "gnu++17",
      "intelliSenseMode": "linux-gcc-x64",
      "compileCommands": "${workspaceFolder}/build/compile_commands.json"
    }
  ],
  "version": 4
}
```

This points IntelliSense at the workspace-level build database.

### 2. Make scripts executable

```bash
chmod +x merge.py build.sh
```

---

## Daily workflow — one command

### Option A: VS Code task (recommended)

Press **`Ctrl+Shift+B`** (or **`Cmd+Shift+B`** on macOS) to build **all packages** and auto-merge the compile commands.

To build a **specific package**: `Ctrl+Shift+P` → **Tasks: Run Task** → **ROS: Build (specific package) & Merge IntelliSense`.

### Option B: Terminal

```bash
./build.sh                          # Build all packages
./build.sh --packages-select my_pkg # Build a single package
```

That's it. The script handles everything:

1. Runs `colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`
2. Automatically runs `merge.py` to consolidate all compile databases
3. Touches the merged file to signal the C/C++ extension

If IntelliSense doesn't pick up the changes automatically, run:
- `Ctrl+Shift+P` → **C/C++: Reset IntelliSense Database**

---

## Advanced

### Individual steps (if you prefer doing them manually)

```bash
# Step 1 — Build
colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# Step 2 — Merge
./merge.py
```

### Reset IntelliSense

If the C/C++ extension doesn't detect the change:
- `Ctrl+Shift+P` → **C/C++: Reset IntelliSense Database**
- Or run the **ROS: Reset IntelliSense Database** task from the command palette
- Or just reload the VS Code window

---

## When to rebuild

Run `./build.sh` (or `Ctrl+Shift+B`) whenever:

- you rebuild a package
- new source files are added
- compiler flags or dependencies change

---

## Notes

- The merged file must contain the translation unit you are editing.
- If you still see `#include` errors, confirm the package build produced a `compile_commands.json` and that the file is listed in `build/compile_commands.json`.
- All extra arguments passed to `build.sh` are forwarded to `colcon build`, so `./build.sh --packages-select my_pkg --cmake-clean-first` works too.
