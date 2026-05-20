# Regenerate encounter-layer compatibility notes (07 Part M.5).
# Run from repo root: .\Background Docs\tools\validate-encounter-matrix.ps1
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$encPath = Join-Path $repoRoot "Background Docs\reference-sheets\encounter-layer.csv"
$mapPath = Join-Path $repoRoot "Background Docs\reference-sheets\map-names.csv"
$saRoot = $env:BATTLETECH_STREAMING_ASSETS
if (-not $saRoot) {
    $saRoot = "C:\Program Files (x86)\Steam\steamapps\common\BATTLETECH\BattleTech_Data\StreamingAssets"
}
$outPath = Join-Path $PSScriptRoot "validation-output.txt"
$buildMaps = @{}
Import-Csv $mapPath | ForEach-Object {
    if ($_.IncludeInBuild -eq '1' -and $_.MapID) { $buildMaps[$_.MapID] = $true }
}

function Get-Family($mid) {
    if ($mid -match '^mapTest_|^test_|TestMap') { return $null }
    if ($mid -match '_uTech$') { return 'urban_uTech' }
    if ($mid -match '^mapStory_|^MapStory_') { return 'story' }
    if ($mid -match '^mapRestoration_') { return 'restoration' }
    if ($mid -match '^mapArena_') { return 'arena' }
    if ($mid -match '_vJung') { return 'jungle' }
    if ($mid -match '_aDes') { return 'desert' }
    if ($mid -match '_aBad') { return 'badlands' }
    if ($mid -match '_aWst') { return 'western' }
    if ($mid -match '_bMoon|_bMars') { return 'moon_mars' }
    if ($mid -match '_iGlc|_iTnd') { return 'glacier_tundra' }
    if ($mid -match '_vHigh|_vLow') { return 'highland_lowland' }
    if ($mid -match '^mapGeneral_') { return 'general_misc' }
    return 'other'
}

function Get-CType($name) {
    $n = $name.ToLower()
    if ($n -match 'firemission|fire') { return 'firemission' }
    if ($n -match 'threeway') { return 'threewaybattle' }
    if ($n -match 'defend') { return 'defendbase' }
    if ($n -match 'destroybase|destroy.*base') { return 'destroybase' }
    if ($n -match 'captureescort') { return 'captureescort' }
    if ($n -match 'capture') { return 'capturebase' }
    if ($n -match 'escort|convoy') { return 'escort_convoy' }
    if ($n -match 'rescue') { return 'rescue' }
    if ($n -match 'ambush') { return 'ambushconvoy' }
    if ($n -match 'assassin') { return 'assassinate' }
    if ($n -match 'attack') { return 'attackdefend' }
    if ($n -match 'battle') { return 'simplebattle' }
    return 'other_enc'
}

$families = @('highland_lowland','jungle','desert','badlands','western','moon_mars','glacier_tundra','urban_uTech','story','restoration','arena','general_misc')
$types = @('simplebattle','destroybase','capturebase','defendbase','rescue','captureescort','escort_convoy','firemission','threewaybattle','ambushconvoy','assassinate','attackdefend')

$pivot = @{}
$encNames = [System.Collections.Generic.HashSet[string]]::new()

Import-Csv $encPath | ForEach-Object {
    $mapId = $_.MapID
    if (-not $buildMaps.ContainsKey($mapId)) { return }
    $fam = Get-Family $mapId
    if (-not $fam) { return }
    $ct = Get-CType $_.Name
    $key = "$fam|$ct"
    if (-not $pivot.ContainsKey($key)) { $pivot[$key] = [System.Collections.Generic.HashSet[string]]::new() }
    [void]$pivot[$key].Add($mapId)
    [void]$encNames.Add($_.Name)
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("M.5 PIVOT (IncludeInBuild=1 maps, EncounterLayer.csv May 2026)")
$lines.Add("Cell = count of distinct MapIDs with at least one encounter layer of that type")
$lines.Add("")
$hdr = "{0,-18}" -f "Map family"
foreach ($t in $types) { $hdr += ("{0,-8}" -f $t.Substring(0,[Math]::Min(7,$t.Length))) }
$lines.Add($hdr)
foreach ($fam in $families) {
    $row = "{0,-18}" -f $fam
    foreach ($ct in $types) {
        $key = "$fam|$ct"
        $n = if ($pivot.ContainsKey($key)) { $pivot[$key].Count } else { 0 }
        $row += ("{0,-8}" -f $(if ($n -gt 0) { $n } else { '.' }))
    }
    $lines.Add($row)
}

$lines.Add("")
$lines.Add("Encounter layer Name values (unique, build maps):")
$encNames | Sort-Object | ForEach-Object { $lines.Add("  $_") }

# SubTypes
$subtypes = [System.Collections.Generic.HashSet[string]]::new()
$fileCount = 0
Get-ChildItem -Path $saRoot -Recurse -Filter '*.json' -ErrorAction SilentlyContinue | ForEach-Object {
    $fileCount++
    $text = Get-Content -LiteralPath $_.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $text) { return }
    [regex]::Matches($text, '"SubType"\s*:\s*"([^"]+)"') | ForEach-Object {
        [void]$subtypes.Add($_.Groups[1].Value)
    }
}

$lines.Add("")
$lines.Add("G.4 SubTypes ($fileCount JSON files under StreamingAssets)")
$subtypes | Sort-Object | ForEach-Object { $lines.Add("  $_") }
$lines.Add("TOTAL SubTypes: $($subtypes.Count)")

$lines | Set-Content -LiteralPath $outPath -Encoding UTF8
Write-Output "Wrote $outPath"
