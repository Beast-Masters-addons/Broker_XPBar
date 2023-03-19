#### Broker: XPBar - Sparkly XP Bars that can be attached anywhere.

Displays Infos about XP and watched Faction and adds bars for XP and/or reputation to your Broker bar addon. Select custom colors for bars or use predefined colors based on standing for the reputation bar.

You can attach the bars to (almost) any frame by click selecting the desired anchor frame with the mouse (similar to Xparky). You can attach the bars to any side of the frame on outside as well as on the inside. Adjust anchor position by setting X- and Y-Offset.

#### Update for Version 2

*   New text system for Broker label and bars.
    *   Provides wide selection of predefined texts for display.
    *   Custom texts can be freely configured via script API.
*   XP and reputation data for completed and incomplete quests.
    *   Shown in tooltip, in label texts and as bar sections.
    *   Notifications when completed quests allow to level up when handed in (or to reach the next standing with the watched faction).
*   Bar length is now adjustable.
*   Bar texts can now be shown side by side. That allows for bigger font sizes especially when XP and reputation bar are shown both.
*   Fixed darkened color problem with default addon texture.
*   Added option 'No Texture' to display bars just in opaque colors.

#### NOTE

*   Due to the new text system the old text options have been dumped. Reconfiguring texts for Broker label and bars is required.
*   Larger memory footprint mainly due to use of a library containing quest reputation reward data since Blizzard broke or scrapped API functions to retrieve that data from quests in log.

#### New

*   Short faction names: It is now possible to use custom set short names for factions in label and bar texts. Set up short faction names in Options in section "Factions". To apply short names in the label and bar texts adjust the custom text in the "Custom Texts" section. (Copy your preferred template if required.) The function call GetValue("Faction") now accepts an additional parameter maxLength. When the default faction name is longer than the specified maximum length the custom set short name is used instead. So GetValue("Faction", 16) will use the short name for faction names longer then 16 characters. If no short name has been set up the default faction name will be used. Set the adjusted custom text as your bar and/or label text.

#### Features

*   Attaches bars for XP and/or reputation to (almost) any globally named frame.
*   Configure layout of bars: Colors, dimensions, texture.
*   Tooltip displays extended information about XP and reputation of currently watched faction.
*   Provides data about XP and reputation for completed and incomplete quests in the quest log.
*   Notifications when completed quests allow to level up when handed in (or to reach the next standing with the watched faction).
*   Customizable texts for bar and Broker label.
*   Select texts from predefined selection or define your own texts via script API.
*   Provided information includes: Time to Level, Kills to Level, XP/Rep/Kills per Hour,
*   Ace3 profile support for settings.

#### Usage Hints

*   Activating _Broker: XPBar_ in your Broker display will show up the label text in that display only. To display the actual bars you will need to attach them to a frame on your screen first. To do this go to _Options->Frame_ and click the button _"Select by Mouse"_. Select the frame to attach the bars to by left-clicking on it and the bars should show up.

*   The mouse cursor gets highlighted and shows the frame name as tooltip for each frame it hovers over. Left-click on desired frame to attach the bars to. Right-click will disable the selection cursor. Frame names may also be entered manually in the edit box. Use the option "Attach to" to select the side (Top or Bottom) of the frame where you want the bars. Fine adjust the position by using the Offset settings if needed.

*   If you are trying to attach to a Broker display make sure you hit an empty spot on the display. If you click on another plugin on the display the bars will attach to the frame of this Broker plugin only.

*   If you use _Docking Station_ and want to attach to it's panels you need to make sure you have the Global option (_Panels -> General_) enabled for the panel you want to connect to.

*   The "Jostle" option displaces the blizzard frames by the width of the bars. This should only be used with frames on the upper and lower edge of the screen and not with free floating frames!

*   Consider that the Reputation bar is hidden if no faction is watched.