<#
Adds the LICA code from your local working folder to this repository and commits it. Run it once.

  powershell -ExecutionPolicy Bypass -File tools\import_local_code.ps1 -Source "C:\path\to\stroke_eeg_bdcc"

-Source is the folder that contains config.py and the mdpi_lica folder. The script copies
  <Source>\mdpi_lica\*                 -> lica\        (code, run scripts, tests; caches skipped)
  <Source>\config.py, data.py, ...     -> pipeline\    (the shared modules LICA imports)
  <Source>\tests\make_fake_dataset.py  -> tests\       (simulated dataset for the smoke test)
renames the old folder name mdpi_lica to lica inside the copied files, checks them for personal
paths, and makes one git commit. Nothing is pushed.
#>
param([Parameter(Mandatory = $true)][string]$Source)
$ErrorActionPreference = "Stop"
$Repo = Split-Path -Parent $PSScriptRoot
$Utf8 = New-Object System.Text.UTF8Encoding $false

$Source = (Resolve-Path $Source).Path
if ((Split-Path -Leaf $Source) -eq "mdpi_lica") { $Source = Split-Path -Parent $Source }
$LicaSrc = Join-Path $Source "mdpi_lica"
foreach ($f in @("$LicaSrc\lica.py", "$LicaSrc\lica_common.py", "$Source\config.py", "$Source\data.py", "$Source\features.py")) {
    if (-not (Test-Path $f)) { throw "Not found: $f. -Source must be the folder that contains config.py and mdpi_lica." }
}
foreach ($f in @("R1_reanalysis.py", "S4_revision.py", "S4_analyze.py", "run_revision.bat")) {
    if (-not (Test-Path "$LicaSrc\$f")) { Write-Warning "$f is missing in $LicaSrc. The repository would not reproduce the revised article." }
}

# 1. LICA code (keep this repository's lica\README.md)
$keep = Get-Content "$Repo\lica\README.md" -Raw
robocopy $LicaSrc "$Repo\lica" /E /XD __pycache__ .pytest_cache .ruff_cache results_lica work_lica logs smoke_out /XF *.npy *.pkl *.pyc *.pyo README.md /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy failed with code $LASTEXITCODE" }
[System.IO.File]::WriteAllText("$Repo\lica\README.md", $keep, $Utf8)

# 2. Shared pipeline modules
$copied = @()
foreach ($f in @("config.py", "data.py", "features.py", "stats_tools.py", "selection.py", "00_check_timing.py")) {
    if (Test-Path "$Source\$f") { Copy-Item "$Source\$f" "$Repo\pipeline\$f" -Force; $copied += $f }
}
Write-Host "pipeline: $($copied -join ', ')"

# 3. Simulated-dataset generator for the smoke test
if (Test-Path "$Source\tests\make_fake_dataset.py") {
    Copy-Item "$Source\tests\make_fake_dataset.py" "$Repo\tests\make_fake_dataset.py" -Force
} else { Write-Warning "tests\make_fake_dataset.py not found in $Source; the smoke test will be skipped by CI." }

# 4. Folder name and wording in the copied files
$files = Get-ChildItem "$Repo\lica" -Recurse -File -Include *.py, *.bat, *.sh, *.md | Where-Object { $_.FullName -ne "$Repo\lica\README.md" }
foreach ($file in $files) {
    $t = [System.IO.File]::ReadAllText($file.FullName)
    $n = $t -replace 'mdpi_lica', 'lica' `
            -replace 'MDPI article', 'article' `
            -replace '(?i)\s*\(send me[^)]*\)', '' `
            -replace '(?i)Send me (\S+) \([^)]*\), then run:', 'Then run:' `
            -replace '(?i)and send me its last lines', 'and read its last lines' `
            -replace '(?i)send me the last lines', 'read the last lines'
    if ($n -ne $t) { [System.IO.File]::WriteAllText($file.FullName, $n, $Utf8) }
}

# 5. Personal paths must not be published
$hits = Get-ChildItem "$Repo\lica", "$Repo\pipeline", "$Repo\tests" -Recurse -File |
        Select-String -Pattern 'C:\Users\', 'OneDrive', '876427' -SimpleMatch -List
if ($hits) {
    Write-Warning "These files contain personal paths. Edit them, then commit by hand:"
    $hits | ForEach-Object { Write-Host "  $($_.Path):$($_.LineNumber)  $($_.Line.Trim())" }
    exit 1
}

# 6. Commit
Push-Location $Repo
git add -A
git commit -q -m "Add LICA code, revision scripts and shared pipeline modules"
git log --oneline -n 3
Pop-Location
Write-Host ""
Write-Host "Done. To publish (after creating an empty repository named lica-hybrid-eeg on github.com):"
Write-Host "  git remote add origin https://github.com/<your-account>/lica-hybrid-eeg.git"
Write-Host "  git push -u origin main"
