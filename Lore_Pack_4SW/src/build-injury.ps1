$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$csc = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$managed = 'C:\Program Files (x86)\Steam\steamapps\common\BATTLETECH\BattleTech_Data\Managed'
$refs = @(
  (Join-Path $managed '0Harmony.dll'),
  (Join-Path $managed 'Assembly-CSharp.dll'),
  (Join-Path $managed 'UnityEngine.dll'),
  (Join-Path $managed 'UnityEngine.CoreModule.dll')
)
$refArgs = $refs | ForEach-Object { "/reference:`"$_`"" }
$out = Join-Path $root 'FamilyMattersInjury.dll'
$src = Join-Path $PSScriptRoot 'FamilyMattersInjury.cs'
& $csc /nologo /optimize /target:library /out:$out @refArgs $src
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Output "OK $out"
