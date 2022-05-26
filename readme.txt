Broker_XPBar, a World of Warcraft® user interface addon.
Copyright© 2010 Bernhard Voigt, aka tritium - All rights reserved.
License is given to copy, distribute and to make derivative works.

Broker_XPBar - A widely customizable addon that attaches a XP/Rep bar to any globally named frame and adds XP and reputation info to your Broker addon.

Features -

	* Attaches bars for XP and/or reputation to (almost) any globally named frame.
	* Configure layout of bars: Colors, dimensions, texture.
	* Tooltip displays extended information about XP and reputation of currently watched faction.
	* Provides data about XP and reputation for completed and incomplete quests in the quest log.
	* Notifications when completed quests allow to level up when handed in (or to reach the next standing with the watched faction).
	* Customizable texts for bar and Broker label.
	* Select texts from predefined selection or define your own texts via script API.
	* Provided information includes: Time to Level, Kills to Level, XP/Rep/Kills per Hour, 
	* Ace3 profile support for settings.

Install -

	Copy the Broker_XPBar folder to your Interface\AddOns directory.
		
Commands - 

	/brokerxpbar arg
	/bxp arg

	With arg:
	menu - display options menu
	version - display the version information
	help - display this help
	
Usage -

    Activating Broker: XPBar in your Broker display will show up the label text in that display only. To display the actual bars you will need to attach them to a frame on your screen first. To do this go to Options->Frame and click the button "Select by Mouse". Select the frame to attach the bars to by left-clicking on it and the bars should show up. 

    The mouse cursor gets highlighted and shows the frame name as tooltip for each frame it hovers over. Left-click on desired frame to attach the bars to. Right-click will disable the selection cursor. Frame names may also be entered manually in the edit box. Use the option "Attach to" to select the side (Top or Bottom) of the frame where you want the bars. Fine adjust the position by using the Offset settings if needed. 

    If you are trying to attach to a Broker display make sure you hit an empty spot on the display. If you click on another plugin on the display the bars will attach to the frame of this Broker plugin only. 

    If you use Docking Station and want to attach to it's panels you need to make sure you have the Global option (Panels -> General) enabled for the panel you want to connect to. 

    The "Jostle" option displaces the blizzard frames by the width of the bars. This should only be used with frames on the upper and lower edge of the screen and not with free floating frames! 

    Consider that the Reputation bar is hidden if no faction is watched.
