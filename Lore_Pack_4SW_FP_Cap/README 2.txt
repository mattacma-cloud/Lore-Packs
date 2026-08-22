================================================================================
Lore_Pack_4SW_FP_Cap — UNPUBLISHED (Enabled: false)
================================================================================
Optional companion for Lore Pack users on BT_Extended_CE. Raises career
MaxActiveFlashpoints from 5 to 25 (global — all flashpoints, not Lore-only).

STATUS: Unpublished. mod.json Enabled is false — ModTek ignores this mod until
you set "Enabled": true for local testing or release.

WHY A SEPARATE MOD
------------------
Do NOT ship Flashpoints-only SimGameConstants from Lore_Pack_4SW — BT_Extended_CE
SimGameConstants_FromJSON throws NullReferenceException and hangs launch.

This mod mirrors CE's merge path with CE-complete constants + Flashpoints block:
  StreamingAssets\data\simGameConstants\SimGameConstants.json

DependsOn: ModTek, BT_Extended, BT_Extended_CE (loads after CE merge).

ENABLE (when ready)
-------------------
1. Set mod.json "Enabled": true
2. Clear ModTek cache (Mods\.modtek)
3. Launch career — verify no SimGameConstants_FromJSON spam in output_log.txt

REFRESH ON CE UPDATE
--------------------
Re-copy Finances / Story / CareerMode / MechLab from current
BT_Extended_CE\StreamingAssets\data\simGameConstants\SimGameConstants.json
then re-apply Flashpoints.MaxActiveFlashpoints : 25.

SOURCE CE VERSION AT BUILD: BT_Extended_CE 2.0.0.4 (2026-06-12)

================================================================================
