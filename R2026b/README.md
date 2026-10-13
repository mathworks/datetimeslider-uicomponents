# Datetime Sliders for MATLAB R2026b

This folder contains exports created with MATLAB R2026b. The original
`.mlapp` files in the repository root remain available for earlier releases,
subject to the [project requirements](../README.md#requirements).

| Files | Editing workflow |
| --- | --- |
| `DatetimeSlider.m`, `DatetimeRangeSlider.m` | Complete component code exported for editing in the MATLAB Editor. |
| `DatetimeSlider_Example_App.m` and `.xml` | Native App Designer app; open the `.m` file to edit the layout and callbacks. |
| `DatetimeRangeSlider_Example_App.m` and `.xml` | Native App Designer app; open the `.m` file to edit the layout and callbacks. |
| `Advanced_Example_App.m` and `.xml` | Native App Designer app; open the `.m` file to edit the layout and callbacks. |
| `resources/appDesigner.json` | Component Library metadata for the exported components. |
| `doc/GettingStarted.m` | Runnable guide using this folder's component exports. |

The `.xml` files are part of their apps and must stay with the corresponding
`.m` files. Native App Designer text apps require MATLAB R2026b or newer.
The component `.m` files are code exports; use the original component
`.mlapp` files for visual layout editing in App Designer.

## Run

Set MATLAB's Current Folder to this folder, then run:

```matlab
addpath(pwd)
run("doc/GettingStarted.m")
```

Launch an example by name:

```matlab
Advanced_Example_App
```

For properties, callbacks, and existing behavior limitations, see the
[main README](../README.md).

## Switch Versions

Keep only the chosen version's folder on the MATLAB path. Close app instances
and figures containing the components before changing versions. A same-name
`.mlapp` in the Current Folder takes precedence over a path-based `.m`, so
use this folder as the Current Folder when working with these exports.

Check which version MATLAB resolves:

```matlab
which DatetimeSlider -all
which Advanced_Example_App -all
```

If MATLAB retains classes from the previous version, restart MATLAB after
selecting the intended folder and path. For R2026a and earlier, use the
original files and the root setup instructions.

## Refresh the Exports

1. In MATLAB R2026b, open an original example `.mlapp` file in App Designer.
2. Select **Save Copy As**, choose the MATLAB App `.m` format, and save here
   with the same base filename. Keep both the resulting `.m` and `.xml`.
3. For `DatetimeSlider.mlapp` and `DatetimeRangeSlider.mlapp`, use App
   Designer's **Export to MATLAB File** command and save here with the
   original class name, such as `DatetimeSlider.m`.
4. Refresh `resources/appDesigner.json` from the root metadata if component
   registration settings change. Keep the copied guide aligned with the
   root guide, retaining its R2026b path and requirement notes.
5. Run the guide and all three examples from this folder, and verify
   selection callbacks and limit synchronization.

Keep the original `.mlapp` files at their existing release compatibility when
refreshing exports; saving them in R2026b can change that compatibility.
Edits to exported files do not synchronize back to the original `.mlapp`
files.
