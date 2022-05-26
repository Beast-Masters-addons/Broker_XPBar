--[[ *******************************************************************
Project                 : Broker_XPBar
Description             : English translation file (enUS)
Author                  : tritium
Translator              : 
Revision                : $Rev: 1 $
********************************************************************* ]]

local ADDON = ...

local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale(ADDON, "enUS", true, true)
if not L then return end

L["%s/%s (%3.0f%%) %d to go (%3.0f%% rested)"] = true
L["%s: %s/%s (%3.2f%%) Currently %s with %d to go"] = true
L["/brokerxpbar arg"] = true
L["/bxp arg"] = true
L["_S_thousand_separator"] = ","
L["_S_decimal_separator"] = "."
L["Abbrev_billion"] = "bn"
L["Abbrev_Faction"] = "F"
L["Abbrev_kilo"] = "k"
L["Abbrev_Kills to Level"] = "KTL"
L["Abbrev_Kills to Standing"] = "KTS"
L["Abbrev_million"] = "m"
L["Abbrev_Quest Complete"] = "QC"
L["Abbrev_Quest Incomplete"] = "QI"
L["Abbrev_Rested"] = "R"
L["Abbrev_Standing"] = "S"
L["Abbrev_Time to Level"] = "TTL"
L["Abbrev_Time to Standing"] = "TTS"
L["Abbreviations"] = true
L["Args:"] = true
L["Attach bars to the inside of the frame."] = true
L["Attach to Side"] = true
L["Auto-switch watched faction on reputation gain."] = true
L["Auto-switch watched faction on reputation gains/losses."] = true
L["Auto-switch watched faction on reputation loss."] = true
L["Bar Properties"] = true
L["Bar Text"] = true
L["Bar Texture"] = true
L["Blizzard Bars"] = true
L["Blizzard Reputation Colors"] = true
L["Bottom"] = true
L["Broker Label"] = true
L["Click"] = true
L["Click to activate the frame selector. (Left-Click to select frame, Right-Click do deactivate selector)"] = true
L["Code"] = true
L["Colors"] = true
L["Completed quest Rep"] = true
L["Completed Quest Reputation"] = true
L["Completed quest XP"] = true
L["Completed Quest XP"] = true
L["Copy"] = true
L["Copy fixed template to selected custom text."] = true
L["Current reputation"] = true
L["Current XP"] = true
L["Currently no faction tracked."] = true
L["Custom code instructions"] = [[|cffffd100Custom code instructions:|r
The code has to end with a return string statement.

|cffffd100Functions:|r
|cffe54100GetValue|r(|cff04adcbid|r [, |cff04adcbmaxLength|r]) - Get the value of the specified |cff04adcbid|r. Only when |cff04adcbid|r is |cff00ff00"Faction"|r |cff04adcbmaxLength|r specifies at which length to use the short faction name set in options.
|cffe54100Check|r(|cff04adcbid|r) - Returns |cffeda55fvalid|r, |cffeda55ftext|r. Boolean |cffeda55fvalid|r is false if check fails. The |cffeda55ftext|r represents an appropriate message if |cffeda55fvalid|r is false. Only accepts |cff00ff00"XP"|r (false at max. level) and |cff00ff00"Reputation"|r (false at max. reputation or when no faction is watched) as |cff04adcbid|r.
|cffe54100FormatNumber|r(|cff04adcbvalue|r, |cff04adcbuseAbbrev|r) - Returns formatted string of |cff04adcbvalue|r using numbers settings. Set |cff04adcbuseAbbrev|r for abbreviation.
|cffe54100Percentage|r(|cff04adcbvalue|r, |cff04adcbminValue|r, |cff04adcbmaxValue|r) - Convert |cff04adcbvalue|r to integer percentage in range |cff04adcbminValue|r..|cff04adcbmaxValue|r.
|cffe54100GetColor|r(|cff04adcbvalue|r, |cff04adcbfrom|r, |cff04adcbto|r) - Returns color for |cff04adcbvalue|r in range |cff04adcbfrom|r (red)..|cff04adcbto|r (green).
|cffe54100GetColorById|r(|cff04adcbid|r) - Returns color that represents the progress of value represented by |cff04adcbid|r.
|cffe54100Colorize|r(|cff04adcbcolor|r, |cff04adcbtext|r) - Colorizes |cff04adcbtext|r with |cff04adcbcolor|r. Provide color as hex ('ffffff') or RGB ({r=1, g=1, b=1}).
|cffe54100GetDescription|r(|cff04adcbid|r, |cff04adcbshort|r) - Get a localized description of the specified |cff04adcbid|r. If |cff04adcbshort|r is set a shortened version will be returned.
|cffe54100HasWatchedFaction|r() - Returns true if any faction is watched.
|cffe54100AtMax|r(|cff04adcbid|r) - Returns true if max. value is reached for |cff04adcbid|r. Only useful for |cff04adcbid|r: |cff00ff00"XP"|r, |cff00ff00"Rested"|r, |cff00ff00"Level"|r, |cff00ff00"Reputation"|r, |cff00ff00"Standing"|r

|cffffd100IDs and their return values for|r |cffe54100GetValue|r(|cff04adcbid|r)|cffffd100:|r
|cff00ff00"XP"|r - (number) - Current experience.
|cff00ff00"MaxXP"|r - (number) - Maximum experience on current level.
|cff00ff00"QuestCompleteXP"|r - (number) - Experience in completed quests.
|cff00ff00"QuestIncompleteXP"|r - (number) - Experience in incomplete quests.
|cff00ff00"TimeToLevel"|r - (string) - Time to level.
|cff00ff00"KillsToLevel"|r - (number) - Number of kills to next level.
|cff00ff00"XPPerHour"|r - (number) - Experience per hour.
|cff00ff00"KillsPerHour"|r - (number) - Kills per hour.
|cff00ff00"Rested"|r - (number) - Rested experience.
|cff00ff00"Level"|r - (number) - Current player level.
|cff00ff00"Reputation"|r - (number) - Reputation with current faction.
|cff00ff00"MaxReputation"|r - (number) - Max reputation on current reputation level.
|cff00ff00"QuestCompleteRep"|r - (number) - Reputation in completed quests for watched faction.
|cff00ff00"QuestIncompleteRep"|r - (number) - Reputation in incomplete quests for watched faction.
|cff00ff00"Standing"|r - (string) - Localized standing label (e.g. 'Friendly').
|cff00ff00"Faction"|r - (string) - Localized name of currently tracked faction or '' if none.
|cff00ff00"TimeToStanding"|r - (number) - Time to reach next standing level with faction.
|cff00ff00"KillsToStanding"|r - (number) - Number of kills to reach next standing level with faction.
|cff00ff00"ReputationPerHour"|r - (number) - Reputation per hour.
]]
L["Custom code to modify."] = true
L["Custom Text"] = true
L["Custom text for configuration."] = true
L["Custom Texts"] = true
L["Decimal Places"] = true
L["Don't show the reputation bar at maximum reputation."] = true
L["Don't show the reputation label text at maximum reputation."] = true
L["Don't show the XP bar at maximum level."] = true
L["Don't show the XP label text at maximum level."] = true
L["Don't use any texture but use opaque colors for bars."] = true
L["Experience"] = true
L["Experience per Hour"] = true
L["Faction"] = true
L["Faction to set a short name for."] = true
L["Faction Tracking"] = true
L["Factions"] = true
L["Font"] = true
L["Font Size"] = true
L["Frame"] = true
L["Frame to attach to"] = true
L["General settings for number formatting."] = true
L["Hand in completed quests to level up!"] = true
L["Hand in completed quests to level up faction!"] = true
L["help - display this help"] = true
L["Hide Hint"] = true
L["Hide the usage hint in the tooltip."] = true
L["If you want more fonts, you should install the addon 'SharedMedia'."] = true
L["If you want more textures, you should install the addon 'SharedMedia'."] = true
L["Incomplete quest Rep"] = true
L["Incomplete Quest Reputation"] = true
L["Incomplete quest XP"] = true
L["Incomplete Quest XP"] = true
L["Inside"] = true
L["Inverse Order"] = true
L["Jostle"] = true
L["Kills per hour"] = true
L["Kills per Hour"] = true
L["Kills to level"] = true
L["Kills to Level"] = true
L["Kills to next Standing"] = true
L["Kills/h"] = true
L["Left"] = true 
L["Length"] = true
L["Level"] = true
L["Level up!"] = true
L["Leveling"] = true
L["Lvl"] = true
L["Max. Level"] = true
L["Max. Rep"] = true
L["Max. XP"] = true
L["Max. XP/Rep"] = true
L["Maximum Experience"] = true
L["Maximum level reached."] = true
L["Maximum Reputation"] = true
L["menu - display options menu"] = true
L["Minimap Button"] = true
L["Mock Values"] = true
L["Mouse-Over"] = true
L["Move Blizzard-frames to avoid overlapping with the bars."] = true
L["No custom text selected."] = true
L["No Reputation"] = true
L["No Reputation Bar"] = true
L["No Reputation Label"] = true
L["No template selected."] = true
L["No Texture"] = true
L["No watched faction"] = true
L["No XP"] = true
L["No XP Bar"] = true
L["No XP Label"] = true
L["None"] = true
L["Notification"] = true
L["Notifications"] = true
L["Numbers"] = true
L["Open option menu."] = true
L["Other Texture"] = true
L["per Tick"] = true
L["Place the reputation bar before the XP bar."] = true
L["Preview"] = true
L["Preview custom text using dummy data."] = true
L["Quest Complete"] = true
L["Quest Incomplete"] = true
L["Refresh"] = true
L["Refresh bar position."] = true
L["Rep"] = true
L["Rep over XP"] = true
L["Rep per hour"] = true
L["Rep/h"] = true
L["Rep: Custom Bar"] = true
L["Rep: Custom Label"] = true
L["Rep: Full"] = true
L["Rep: Full (No Color)"] = true
L["Rep: Kills Per Hour"] = true
L["Rep: Kills To Level"] = true
L["Rep: Long"] = true
L["Rep: Long (No Color)"] = true
L["Rep: Rep Per Hour"] = true
L["Rep: Time To Level"] = true
L["Rep: To Go (Percent)"] = true
L["Rep: Value (Percent)"] = true
L["Rep: Value/Max"] = true
L["Rep: Value/Max (Percent)"] = true
L["Reputation"] = true
L["Reputation Bar Colors"] = true
L["Reputation per Hour"] = true
L["Rested"] = true
L["Rested XP"] = true
L["Right"] = true 
L["Right-Click"] = true
L["Select by Mouse"] = true
L["Select Label Text"] = true
L["Select Reputation Text"] = true
L["Select the faction to track."] = true
L["Select the font of the bar text."] = true
L["Select the font size of the text."] = true
L["Select the label text for the Broker display."] = [[Select label text for Broker display:
|cffffff00None|r - No text.
|cffffff00Reputation|r - Display selected reputation text.
|cffffff00XP|r - Displays selected XP text.
|cffffff00Rep over XP|r - Displays reputation text by default, but if no watched faction displays XP text.
|cffffff00XP over Rep|r - Displays XP text by default when below max level or else the reputation text.]]
L["Select the reputation text for Broker display."] = true
L["Select the side to attach the bars to."] = true
L["Select the strata of the bars."] = true
L["Select the text for reputation bar."] = true
L["Select the text for XP bar."] = true
L["Select the XP text for Broker display."] = true
L["Select XP Text"] = true
L["Send current reputation to an open editbox."] = true
L["Send current XP to an open editbox."] = true
L["Separator used between XP and reputation texts."] = true
L["Separators"] = true
L["Session kills"] = true
L["Session rep"] = true
L["Session XP"] = true
L["Set the bar colors."] = true
L["Set the bar properties."] = true
L["Set the bar text properties."] = true
L["Set the brightness level of the spark."] = true
L["Set the Broker label properties."] = true
L["Set the color of the completed quest reputation bar."] = true
L["Set the color of the completed quest XP bar."] = true
L["Set the color of the incomplete quest reputation bar."] = true
L["Set the color of the incomplete quest XP bar."] = true
L["Set the color of the reputation bar."] = true
L["Set the color of the rested bar."] = true
L["Set the color of the XP bar."] = true
L["Set the display behaviour at maximum level/reputation."] = true
L["Set the empty color of the reputation bar."] = true
L["Set the empty color of the XP bar."] = true
L["Set the frame attachment properties."] = true
L["Set the length of the bars. If zero bar will adjust to the dimension of the frame it attaches to."] = true
L["Set the level up notifications when completed quests allow you to gain a level."] = true
L["Set the leveling properties."] = true
L["Set the number of decimal places when using abbreviations."] = true
L["Set the number of ticks shown on the bar."] = true
L["Set the thickness of the bars."] = true
L["Set the time frame for dynamic TTL calculation."] = true
L["Set the tooltip properties."] = true 
L["Set the weight of the time frame vs. the session average for dynamic TTL calculation."] = true
L["Set the x-Offset of the bars."] = true
L["Set the y-Offset of the bars."] = true
L["Setup custom texts for bars and label."] = true
L["Shadow"] = true
L["Shift-Click"] = true
L["Short Name"] = true
L["Short name for selected faction."] = true
L["Show a notification with configurable output target."] = true
L["Show a test notification."] = true
L["Show a test Toast notification."] = true
L["Show a Toast notification."] = true
L["Show Bar Text"] = true
L["Show Completed Quest Reputation"] = true
L["Show Completed Quest XP"] = true
L["Show Incomplete Quest Reputation"] = true
L["Show Incomplete Quest XP"] = true
L["Show Reputation Bar"] = true
L["Show reputation of completed quests on the bar."] = true
L["Show reputation of incomplete quests the bar."] = true
L["Show selected text on bar."] = true
L["Show text only on mouse over bar."] = true
L["Show the default Blizzard bars."] = true
L["Show the minimap button."] = true
L["Show the reputation bar."] = true
L["Show the XP bar."]  = true
L["Show XP Bar"] = true
L["Show XP of completed quests on the bar."] = true
L["Show XP of incomplete quests on the bar."] = true
L["Side by Side Text"] = true
L["Side by Side Separator"] = true
L["Spark Intensity"] = true
L["Standing"] = true
L["Strata"] = true
L["Switch on Reputation Gain"] = true
L["Switch on Reputation Loss"] = true
L["Template Text"] = true
L["Test Notification"] = true
L["Test Toast"] = true
L["Text for both bars is shown in single line centered over both bars."] = true
L["Texts to be used as templates for custom texts."] = true
L["Texture of the bars."] = true
L["The exact name of the frame to attach to."] = true
L["Thickness"] = true
L["This frame has no global name and cannot be used!"] = true
L["Ticks"] = true
L["Time Frame"] = true
L["Time to level"] = true
L["Time to Level"] = true
L["Time to Level Rep"] = true
L["Time to next Standing"] = true
L["To next level"] = true
L["To next standing"] = true
L["Toast Notification"] = true
L["Toggle shadow display for bars."] = true
L["Toggle the use of Blizzard reputation colors."] = true
L["Tooltip"] = true
L["Top"] = true 
L["Usage:"] = true
L["Use abbreviations to shorten numbers."] = true
L["Use external texture for bar instead of the one provided with the addon."] = true
L["Use mock values for preview."] = true
L["Use separators for numbers to improve readability."] = true
L["Version"] = true
L["version - display version information"] = true
L["Weight"] = true
L["X-Offset"] = true
L["XP"] = true
L["XP Bar Colors"] = true
L["XP over Rep"] = true
L["XP per hour"] = true
L["XP: Custom Bar"] = true
L["XP: Custom Label"] = true
L["XP: Full"] = true
L["XP: Full (No Color)"] = true
L["XP: Kills Per Hour"] = true
L["XP: Kills To Level"] = true
L["XP: Long"] = true
L["XP: Long (No Color)"] = true
L["XP: Time To Level"] = true
L["XP: To Go (Percent)"] = true
L["XP: Value (Percent)"] = true
L["XP: Value/Max"] = true
L["XP: Value/Max (Percent)"] = true
L["XP: XP Per Hour"] = true
L["XP/h"] = true
L["Y-Offset"] = true
