$encPath = "C:\Program Files (x86)\Steam\steamapps\common\BATTLETECH\Background Docs\reference-sheets\encounter-layer.csv"
$contractsRoot = "C:\Program Files (x86)\Steam\steamapps\common\BATTLETECH\BattleTech_Data\StreamingAssets\data\contracts"
$mcRoot = "C:\Program Files (x86)\Steam\steamapps\common\BATTLETECH\Mods\MissionControl"
$outPath = "C:\Program Files (x86)\Steam\steamapps\common\BATTLETECH\Documents\tools\validation-output-sample.txt"

# SubTypes from MC jsonc
$subtypes = [System.Collections.Generic.HashSet[string]]::new()
Get-ChildItem -Path $mcRoot -Recurse -Include '*.json','*.jsonc' -ErrorAction SilentlyContinue | ForEach-Object {
    $t = Get-Content -LiteralPath $_.FullName -Raw -ErrorAction SilentlyContinue
    if ($t) {
        [regex]::Matches($t, '"SubType"\s*:\s*"([^"]+)"') | ForEach-Object { [void]$subtypes.Add($_.Groups[1].Value) }
    }
}

# Objective/Chunk tokens from vanilla contracts
$objTokens = [System.Collections.Generic.HashSet[string]]::new()
$chunkTokens = [System.Collections.Generic.HashSet[string]]::new()
Get-ChildItem -Path $contractsRoot -Recurse -Filter '*.json' -ErrorAction SilentlyContinue | ForEach-Object {
    $t = Get-Content -LiteralPath $_.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $t) { return }
    [regex]::Matches($t, '"title"\s*:\s*"(Objective_[^"]+)"') | ForEach-Object { [void]$objTokens.Add($_.Groups[1].Value) }
    [regex]::Matches($t, '"name"\s*:\s*"(Chunk_[^"]+)"') | ForEach-Object { [void]$chunkTokens.Add($_.Groups[1].Value) }
}

# Story map layer counts by enc prefix
$storyMaps = @{}
Import-Csv $encPath | ForEach-Object {
    $m = $_.MapID
    if ($m -notmatch '^mapStory_|^MapStory_|^mapRestoration_') { return }
    if (-not $storyMaps.ContainsKey($m)) { $storyMaps[$m] = 0 }
    $storyMaps[$m]++
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("=== MC + encounter SubTypes (MissionControl contractTypeBuilds) ===")
$subtypes | Sort-Object | ForEach-Object { $lines.Add("  $_") }
$lines.Add("TOTAL: $($subtypes.Count)")

$lines.Add("")
$lines.Add("=== Sample Objective_* titles in vanilla contracts (unique, first 80) ===")
$objTokens | Sort-Object | Select-Object -First 80 | ForEach-Object { $lines.Add("  $_") }
$lines.Add("TOTAL Objective_* titles: $($objTokens.Count)")

$lines.Add("")
$lines.Add("=== Sample Chunk_* names in vanilla contracts (unique, first 60) ===")
$chunkTokens | Sort-Object | Select-Object -First 60 | ForEach-Object { $lines.Add("  $_") }
$lines.Add("TOTAL Chunk_* names: $($chunkTokens.Count)")

$lines.Add("")
$lines.Add("=== Story/Restoration maps: encounter layer row counts ===")
$storyMaps.GetEnumerator() | Sort-Object Name | ForEach-Object { $lines.Add("  $($_.Key): $($_.Value) layers") }

$lines | Set-Content -LiteralPath $outPath -Encoding UTF8
Write-Output "Done"
