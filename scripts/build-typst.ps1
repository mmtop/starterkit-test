$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$projectFonts = (Resolve-Path (Join-Path $projectRoot "fonts")).Path
$templateFonts = (Resolve-Path (Join-Path $projectRoot "..\\typst_template\\src\\assets\\fonts")).Path
$stagedFonts = Join-Path $projectRoot "_build\\typst-fonts"

New-Item -ItemType Directory -Path $stagedFonts -Force | Out-Null

# Typst 0.14 warns on variable fonts, so stage only static font files here.
$projectFontFiles = Get-ChildItem -Path $projectFonts -Recurse -File -Include *.ttf, *.otf, *.ttc |
  Where-Object {
    $_.FullName -match '[\\/]static[\\/]' -or $_.Name -notmatch 'VariableFont'
  }

foreach ($fontFile in $projectFontFiles) {
  Copy-Item -LiteralPath $fontFile.FullName -Destination (Join-Path $stagedFonts $fontFile.Name) -Force
}

if ($env:TYPST_FONT_PATHS) {
  $env:TYPST_FONT_PATHS = "$stagedFonts;$templateFonts;$env:TYPST_FONT_PATHS"
} else {
  $env:TYPST_FONT_PATHS = "$stagedFonts;$templateFonts"
}

Write-Host "Using Typst font path: $env:TYPST_FONT_PATHS"

Push-Location $projectRoot
try {
  micromamba run -n jbost myst build --typst --strict
} finally {
  Pop-Location
}
