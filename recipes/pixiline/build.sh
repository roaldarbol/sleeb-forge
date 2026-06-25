#!/bin/bash
set -euxo pipefail

$PYTHON -m pip install . -vv --no-deps --no-build-isolation

# Install the menuinst shortcut spec and its icons into $PREFIX/Menu so the
# installer (conda / mamba / pixi global) creates a native desktop entry.
mkdir -p "$PREFIX/Menu"
cp "$RECIPE_DIR/menu/pixiline.json" "$PREFIX/Menu/pixiline.json"
cp "$RECIPE_DIR/icons/pixiline.ico" "$PREFIX/Menu/pixiline.ico"
cp "$RECIPE_DIR/icons/pixiline.icns" "$PREFIX/Menu/pixiline.icns"
cp "$RECIPE_DIR/icons/pixiline.png" "$PREFIX/Menu/pixiline.png"
