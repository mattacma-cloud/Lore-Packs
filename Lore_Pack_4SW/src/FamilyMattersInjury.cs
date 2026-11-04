using System;
using System.Collections.Generic;
using BattleTech;
using Harmony;
using UnityEngine;

namespace LorePack.FamilyMatters
{
    public static class Main
    {
        const string ContractId = "c_fp_lp4sw_FamilyMatters4_Mission4_2";
        const int Interval = 7;
        const int MaxWounds = 3;

        static readonly Dictionary<string, int> WoundsApplied = new Dictionary<string, int>();
        static int lastRoundApplied = -1;

        public static void Init(string directory, string settingsJSON)
        {
            var harmony = HarmonyInstance.Create("com.blacknova.lp4sw.familymatters.injury");
            var method = AccessTools.Method(typeof(TurnDirector), "EndCurrentRound");
            if (method == null)
            {
                Debug.Log("[FamilyMatters] EndCurrentRound was not found. Pathogen wounds will not apply.");
                return;
            }
            harmony.Patch(method, null, new HarmonyMethod(typeof(Main), "AfterRound"));
            Debug.Log("[FamilyMatters] Pathogen wound hook ready for Tall Stories.");
        }

        public static void AfterRound(TurnDirector __instance)
        {
            try
            {
                var combat = __instance != null ? __instance.Combat : null;
                var contract = combat != null ? combat.ActiveContract : null;
                var id = contract != null && contract.Override != null ? contract.Override.ID : null;
                if (id != ContractId)
                {
                    WoundsApplied.Clear();
                    lastRoundApplied = -1;
                    return;
                }

                int round = __instance.CurrentRound;
                if (round == 1)
                {
                    WoundsApplied.Clear();
                    lastRoundApplied = -1;
                    return;
                }
                if (round <= 0 || round % Interval != 0 || round == lastRoundApplied)
                {
                    return;
                }
                lastRoundApplied = round;

                var team = combat.LocalPlayerTeam;
                if (team == null || team.units == null)
                {
                    return;
                }

                foreach (var actor in team.units)
                {
                    if (actor == null || actor.IsDead)
                    {
                        continue;
                    }
                    var pilot = actor.GetPilot();
                    if (pilot == null || pilot.IsIncapacitated)
                    {
                        continue;
                    }
                    var key = pilot.Description != null ? pilot.Description.Id : pilot.Name;
                    if (string.IsNullOrEmpty(key))
                    {
                        key = pilot.Name;
                    }
                    int count;
                    WoundsApplied.TryGetValue(key, out count);
                    if (count >= MaxWounds)
                    {
                        continue;
                    }
                    pilot.InjurePilot("lp4sw_fm_bio_injury", -1, 1, DamageType.Unknown, null, actor);
                    WoundsApplied[key] = count + 1;
                    Debug.Log("[FamilyMatters] Pathogen wound " + (count + 1) + " on " + pilot.Callsign + " at the end of round " + round + ".");
                }
            }
            catch (Exception ex)
            {
                Debug.Log("[FamilyMatters] Pathogen wound hook: " + ex);
            }
        }
    }
}
