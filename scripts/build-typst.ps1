$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$templateFonts = (Resolve-Path (Join-Path $projectRoot "..\\myst_typst_V1\\src\\assets\\fonts")).Path

if ($env:TYPST_FONT_PATHS) {
  $env:TYPST_FONT_PATHS = "$templateFonts;$env:TYPST_FONT_PATHS"
} else {
  $env:TYPST_FONT_PATHS = $templateFonts
}

Write-Host "Using Typst font path: $env:TYPST_FONT_PATHS"

Push-Location $projectRoot
try {
  micromamba run -n jbost myst build --typst --strict
} finally {
  Pop-Location
}
