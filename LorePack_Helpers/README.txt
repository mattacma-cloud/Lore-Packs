LorePack_Helpers
================

Shared ModTek helper for all Lore Pack flashpoint mods.

Acknowledgements
------------------
  Helper is based on work conducted by Kierk on Hounfor's The Big Deal Flashpoint.

Features
--------
1) Expanded drop UI + partial fills (maxNumberOfPlayerUnits > 4)
   FinishedLoading: scan Mods/*/contracts/*.json for lore IDs → authored maxUnits
     + limitFlashpointDrop / respectFourDropLimit (ModTek skips FromJSON often).
   Prefix LanceConfiguratorPanel.SetData (Priority First):
     - If flashpoint-limited OR authored ≤ 4: NOT expanded — clamp panel + Override
       maxUnits back to authored (kills bogus 12-slot force on Mission1_2-style drops)
     - Else expanded: allowUnevenLances = true; maxUnits = authored
     - If CustomUnits present and career capacity &lt; authored (e.g. DropSlot2 = 7,
       contract wants 8): temporarily PushDropLayout with N omni slots in **one**
       CU lance (not 2×4) so partial 1..N works like 4-cap missions
   OnLanceConfiguratorClosed: restore career slot layout
   MarkLanceValid also force-enables the Deploy (_confirmButton) so a valid
   partial fill is clickable (P1 hardening).

2) Slot tonnage mirror (BiggerDrops / maxNumberOfPlayerUnits > 4)
   Postfix LanceConfiguratorPanel.SetData (Priority Last):
     - Re-assert allowUnevenLances after CustomUnits
     - Read authored per-slot mins/maxes from slots 1–4 (ContractOverride length ≤ 4)
     - Mirror the last valid (>= 0) value onto slots 5+
     - Update LanceLoadoutSlot private min/max + drop tonnage UI label
   Pattern: TBD LanceTonnageFix, scoped to Lore Packs only (do not ship TBD.dll).

3) Bypass CustomUnits Mission Control 4-cap / fill-all / empty-slot min tonnage
   Applied in FinishedLoading (NOT Init — Init-time CU Prefix patches CTD ModTek).
   Skips CustomUnits ValidateLance + ValidateLanceTonnage + OnConfirmClicked Prefixes
   for matched lore contracts (expanded 8-drop AND standard 4-drop flashpoint-limited).
   Replaces ValidateLanceTonnage for lore: filled cradles only (CU otherwise fails empty
   slots that have mechMinTonnages, which blocks 1..N-1 partial deploys).
   Safety-net Postfix still forces lanceValid when filled pairs + tonnage pass.

4) Suppress Mission Control Additional Lance RewardsPerLance for matched contracts
   (replaces LorePack_McAlRewards for packs that DependOn this mod).

Contract matching
-----------------
Default Settings.ContractIdContains:
  "c_fp_lp"           → all Lore Pack stems (c_fp_lp4sw_*, future c_fp_lp01_*, …)
  "touring_tikonov"  → Touring Tikonov legacy ids

Authoring recipe (DA2a MDW INPUT C)
-----------------------------------
  maxNumberOfPlayerUnits: 8
  limitFlashpointDrop: false
  respectFourDropLimit: false
  mechMinTonnages / mechMaxTonnages: length 4 only (F-CT14)
  lanceMaxTonnage: sized for full drop (e.g. 800)
  MC AdditionalPlayerMechs: TRUE on the contract sidecar — required for the
    extra Mechs to actually spawn (UI expansion alone lands only 4; proven
    Charge Guard M1/M5, 2026-07). MC settings.json must also have
    EnableAdditionalPlayerMechsForFlashpoints true (already set on this stack).

Example — 8 Assault drop with heavy mins on all eight slots:
  mechMinTonnages: [100, 90, 80, 70]
  → slots 5–8 receive min 70 (last valid)
  Player may deploy 1–8 Mechs (uneven lance); empty slots are OK.
  Helpers force 8 UI cradles even if career Argo Drop Size is only +3.

Settings
--------
  MirrorSlotTonnage           (default true)
  AllowUnevenExpandedDrops    (default true)
  ForceContractDropSlots      (default true)
  OmniSlotDefId               (default "simgame_omni_slot")
  SuppressMcAlRewards         (default true)

Build
-----
  tools\LorePack_Helpers\build.ps1

Live mod
--------
  ...\Mods\LorePack_Helpers\

Lore Pack mod.json
------------------
  Add "LorePack_Helpers" to DependsOn.
  Remove LorePack_McAlRewards.dll / DLLEntryPoint from the pack if present
  (this mod supersedes it).
