%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if %ERRORLEVEL% neq 0 exit 1

:: Install the menuinst shortcut spec and its icons into %PREFIX%\Menu so the
:: installer (conda / mamba / pixi global) creates a native desktop entry.
if not exist "%PREFIX%\Menu" mkdir "%PREFIX%\Menu"
copy /Y "%RECIPE_DIR%\menu\pixiline.json" "%PREFIX%\Menu\pixiline.json"
if %ERRORLEVEL% neq 0 exit 1
copy /Y "%RECIPE_DIR%\icons\pixiline.ico" "%PREFIX%\Menu\pixiline.ico"
if %ERRORLEVEL% neq 0 exit 1
copy /Y "%RECIPE_DIR%\icons\pixiline.icns" "%PREFIX%\Menu\pixiline.icns"
if %ERRORLEVEL% neq 0 exit 1
copy /Y "%RECIPE_DIR%\icons\pixiline.png" "%PREFIX%\Menu\pixiline.png"
if %ERRORLEVEL% neq 0 exit 1
