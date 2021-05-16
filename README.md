# Introduction

Mod zPAM3.21 is new version of PAM mode for COD2.<br>

The code form previous zPAM 2.07 version is completely rewritten and ported to new code base, which helped in the implementation of new features and bug fixes.

Work on this pam was iniciated by me in 2015 a was not never fully finished. In corona days, I decided to finish it.


## Download
- Actual version:
	- 2021/05/16 - <b><a href="https://github.com/eyza-cod2/zpam3/raw/master/zpam321.zip">zPAM 3.21</a></b>


- Previous versions:
	- 2021/05/05 - <b><a href="https://github.com/eyza-cod2/zpam3/tree/c7d5fa259e6e21a7fc510847421fab5338f19d0d">zPAM 3.20</a></b>
	- 2021/01/05 - <b><a href="https://github.com/eyza-cod2/zpam3/tree/a365aa9d884f87a368e51879b016157b431ee449">zPAM 3.1 BETA 6</a></b></b>
	- 2020/11/29 - <b><a href="https://github.com/eyza-cod2/zpam3/tree/b3e8711b13b493134ec1c762aeba17399eefb95d">zPAM 3.1 BETA 5</a></b></b>
	- 2020/09/24 - <b><a href="https://github.com/eyza-cod2/zpam3/tree/2d3e3589dced881409bd42d2c5c500cc6ed3e0a1">zPAM 3.1 BETA 4</a></b></b>
	- 2020/05/13 - <b><a href="https://github.com/eyza-cod2/zpam3/tree/c327385fd7cc7fbcb1d3d04a443abf16ee93ad6b">zPAM 3.1 BETA 3</a></b></b>
	- 2020/04/28 - <b><a href="https://github.com/eyza-cod2/zpam3/tree/8c9e528ad09be3ce626bcd36463c3cdf180295ae">zPAM 3.1 BETA 2</a></b></b>
	- 2020/04/23 - <b><a href="https://github.com/eyza-cod2/zpam3/tree/f58fdedbf23f31c62e29ffd25379d6a1d7993e49">zPAM 3.1 BETA</a></b></b>


## Changelog
<details><summary>zPAM 3.21 changes (click to open)</summary>
<p>

#### Bugs fixed:
- Updated Toujane FIX to version 2 - fixed link wall vault - https://youtu.be/DuoJOrDeaaM
- PAM installations checks - on some servers it says installation error even if installed correctly -> fixed

#### Update of existing:
- [3.3.10] Match info - ingame info with team names and score visibility is turned off by default now
- Strat - players are now spawned by SD spawn positions, not DM spawn positions - this make vallente map working in strat
</p>
</details>


<details><summary>zPAM 3.20 changes (click to open)</summary>
<p>

#### Bugs fixed:
- When you picked up weapon of enemy team into secondary slot, you was respawned only with pistol -> fixed
- On start of new round, when you have mp44 for example and you picked up a weapon or you dropped a weapon, changing weapon to shotgun via menu (you get shotgun next round) gives you a smoke  -> fixed
- Auto-recording didnt start to record when some menu is opened -> fixed, opened menus are closed when recording starts
r_polygonOffsetScale and r_polygonOffsetBias warning appears even if they were correctly set to -1 -> fixed
- In strat, spawned bots are kicked when player disconnect from server
- FPS drops in strat - caused by HUD texts with keys of bind -> fixed
- Deadchat in strat
- g_allowVote fixed in menu

#### News:
- Code base was rewrited a bit, now code from old pam is completely ported to new pam codebase
- New mp_toujane_fix_v1 map with fixed bugs
- New mp_burgundy_fix_v1 map with fixed bugs
- [3.3.27] MG clip FIX - if you drop a MG, you will be spawned right behind the MG
- [3.3.28] Dead bodies are not spawned near planted bomb
- [3.3.29] Score changing via menu - in first readyup, you can change a score of teams via rcon menu (in case wrong pam_mode was set, server crash, etc..)
- [3.3.30] New spectating system - new UI, auto-spectator is now better, score stats, player progress stats, etc..
- [3.3.31] Round report - at the end of the round info about kills and hits you made are printed
- [3.3.32] New damage feedback for assists - when player damaged by you is killed, damage feedback cross is showed
- [3.3.33] Enemy list - new player names list of alive enemy players. Players can be marked with different color via ingame scoreboard menu.
- [3.3.34] In readyup, you can throw nades like in strat mode
- [3.3.35] New custom settings for map mode in rcon menu - a few of the settings can be changed (for example fast-reload fix, shotgun rebalance,..) and this change stays applied in next maps
- [3.3.36] New menu section in Main -> Options for zPAM settings
- [3.3.37] List of all changed server cvars is showed in "Server info" menu
- [3.3.38] Score in left-top corner can by enabled via settings menu
- [3.3.39] For future hit diagnostics, at the end of each round info about hits is saved to cvar pam_damage_debug
- [3.3.40] Hand hitbox fix - if you fire from rifle or scope to left arm at +-20* degrees, it will be changed to kill to body (more info on github)
- [3.3.41] In halftime-readyup and between map readyup, when 5min timer expire, red timer is showed. If all players from 1 team are ready, match automatically start even if opponent team is not ready.
- [3.4.15] PAM now has to be installed in main folder - this will fix problem with not saved cvar changes you made in game

#### Update of existing:
- [2.2.3] Timeout now can be called in round before halftime / map end
- [3.2.1] Warning that you cannot drop actual weapons are now printed into killfeed instead of center messages
- [3.3.2] Auto-recording is now recording between maps (demo is not stopped on next map)
- [3.3.16] Rebalanced shotgun was updated to handle close range hits and long range kills better. Is enabled by default now.
- [3.3.17] Scoreboard - new stats for assists; damage was changed to hits and is counted better; plants/defuses are not showed for enemy team
- [3.3.18] Quick menu - new option for enable team score in left top corner, same as [3.3.38]
- [3.3.19] Bash mode - message is printed if it is bash round; map is not restarted after bash is over
- [3.3.26] Prone-peek is now processed better and is enabled by default. (400m delay is added only if pronepeek-able wall / conver is detected instead of adding it every time)
- [3.4.14] Strat time was set to 6 seconds for cg and cg_mr12 pam modes
- Diagonal fix was removed
</p>
</details>


## Installation
- Download <b><a href="https://github.com/eyza-cod2/zpam3/raw/master/zpam321.zip">zPAM 3.21</a></b> and extract folders with files into following locations:
	- ./pb/pbsvuser.cfg
	- ./main/zpam321.iwd
	- ./main/mp_toujane_fix_v2.iwd
	- ./main/mp_burgundy_fix_v1.iwd
	- ./main/server.cfg


- Notes:
	- When your server is runned, you may get an error message saying "PAM is not installed correctly". To fix this error, follow instructions in [Troubleshooting](#troubleshooting) section
	- <i>mp_toujane_fix_v2.iwd</i> and <i>mp_burgundy_fix_v1.iwd</i> are fixed version of original maps - these files needs to be included with PAM, more info in [Questions & Answers](#questions--answers) section
		- Toujane FIX changes: https://github.com/eyza-cod2/mp_toujane_fix
		- Burgundy FIX changes: https://github.com/eyza-cod2/mp_burgundy_fix.
	- <i>server.cfg</i> - exec this file for fast server configuration and in case you are running a public server (+exec server)
	- you have to enable downloading via cvar <i>sv_wwwDownload 1</i> and specify a download url via cvar <i>sv_wwwBaseURL "url"</i>; if you dont have any, you can use <i>sv_wwwBaseURL "http://cod2x.me/zpam321"</i> (this is to make sure fixed maps are downloaded in fast way for players)


## Contact
Write message on discord <b>LetsPlay Europe</b> in <b>#cod2-zpam-3</b> channel.<br>
Or add me on discord <b>eyza#7930</b><br>
Or write me on email <b>kratas.tom@seznam.cz</b><br>
<br>
Supporters: askeslav, tomik, cokY, Sk1lzZ, YctN, kebit, foxbuster, <==Mustang==>Clan from Hungary, hubertgruber / dutch, excel
<br><br>
Please support this work on my Paypal -> https://paypal.me/kratasy
<br>

<br><br>

## Questions & Answers

### What is Toujane FIX (mp_toujane_fix_v2) and Burgundy FIX (mp_burgundy_fix_v1)
These are recompiled version of original maps that contains a bug fixes.
List of all changes are available in these repositories: [mp_toujane_fix](https://github.com/eyza-cod2/mp_toujane_fix), [mp_burgundy_fix](https://github.com/eyza-cod2/mp_burgundy_fix).
Other maps will follow in next release.<br>
If you know bugs that are not fixed yet, please contact me!<br>
Big thanks goes to Stendby and YctN.

<br>

### How does the "Fast reload fix" works / what is it
Fast reload is when you fire from KAR98 for example, press R to reload and then you scroll down 2x, you are able to shoot faster.
PAM is blocking you from fast-switching weapon for short period of time after you fire from weapon.
This take effect to following weapons: kar98k, kar98k_sniper, enfield, enfield_scope, mosin_nagant, mosin_nagant_sniper, springfield, shotgun.<br>
You can debug fast-reload fix in game via command **/rcon debug_fastreload 1**.<br>
**Fast reload fix is enabled by default.**

<br>

### How does the "Rebalanced shotgun" works / what is it
First of all, lets describe how the classic shotgun works:
- When you fire from shotgun, 8 pellets are fired.
- Spread of pellets is unpredictable and completly random.
- <img src="/images/shotgun_spread.png" height="60" />
- Damage of each individual pellet is based on distance between you and the pellet hit location.
- #### How does the default shotgun damage works
	- Damage is splited into 2 range parts according to distance between you and hit location of enemy player: (this is how it is when the game was released in 2005)
	- <img src="/images/shotgun_graph_classic.png" />
	- Each one of 8 fired pellets follow this rules:
		- if **distance is 0 - 384**: constant **50hp damage** is applied for every pellet
		- if **distance is 384 - 800**: damage is linearly based on distance in range of **50hp - 5hp**
- #### How does the rebalanced shotgun damage works
 - Rebalanced shotgun tries to address close range hits and long range kills.
   - Close range hits are caused by only 1 pellet hit the target, others goes off target
   - Long range kills are caused by pellets fired close together.
  - Random spread is responsible for these close range hits and long range kills
 - To make it better, rebalanced shotgun defines new damage values for close range and long range:
 - <img src="/images/shotgun_graph_rebalanced.png" />
 - Each one of 8 fired pellets follow this rules:
 	- if **distance is 0 - 200** (close range): **100hp damage** is applied if you hit important **body parts** (head, neck, left_arm_upper, right_arm_upper, torso_upper, torso_lower, left_leg_upper, right_leg_upper) (so 1 pellet means kill if you hit these body parts)
 	- if **distance is 0 - 384**: damage is lineary based on distance in range of **100hp - 50hp** (so if only 1 pellet hit the target, you do more damage)
 	- if **distance is 384 - 500**: **original damage** is used
 	- if **distance is 500 - 800** (long range): **original damage** is used, but total damage of all pellets is **limited to 99hp**, so you cannot kill a player at this distance
 - Examples:
	 - Example 1:
		 - You fire at close range (distance 150), **2 or more pellets** hits the target
			 - classic shotgun: **kill**
			 - rebalanced shotgun: **kill**
	 - Example 2:
	 	- You fire at close range (distance 150), **only 1 pellet** hits the target
			- classic shotgun: **50hp damage**
			- rebalanced shotgun:
				- in case of hit to hand: **~80hp damage**
				- in case of hit to body: **100hp damage**
	 - Example 3:
		- You fire at mid range (distance 280), **only 1 pellet** hits the target
			- classic shotgun: **50hp damage**
			- rebalanced shotgun: **~63hp damage**
	 - Example 4:
		- You fire at far range (distance 650), **5 pellets** hits the target
			- classic shotgun: **~105hp damage** (~21hp damage per bullet)
			- rebalanced shotgun: **99hp damage** (total damage limited)
 - Distance preview on toujane
 - <img src="/images/shotgun_graph_rebalanced_tj.png" />
 - You can debug rebalanced shotgun in game via command **/rcon debug_shotgun 1**

**Rebalanced shotgun is enabled by default**

<br>

### How does the "Hand hitbox fix" works / what is it
There are some weird situations when you shot player to the body, but the game process it as a hit only.
These types of bugs are probably caused by wrongly processed bullet trajectory / unexpected server lag.
Most of the time the game procces the hit location as hand / arm instead of body (when the arm is right behind the body)
Hitbox fix tries to address this issue by these rules:
 - if you fire from rifle or scope to left arm (left_arm_lower), and
 - enemy is in ads (zoomed), and
 - angle difference between you and enemy is +-20°, and
 - distance is more than 200
 - <img src="/images/hitbox.png" height="100"/>
 - In this case, hit location is changed to body, causing deadly damage
 - You can debug hitbox fix in game via command **/rcon debug_handhitbox 1**
 - **Hitbox fix is enabled by default**

<br>

### How does the "Clip" and "Prone peek fix" works / what is it
Lets describe a "clip" and "prone-peek" a bit

- ### Clip
	- In zPAM2.07, when you go from prone position to crouch position, a "standing-up" animation was played on player's character
	- If you go immediately back to prone position, the animation makes you invisible to enemy, because before your body and head gets to higher position, you are back in prone position
	- This animation is well described on this image:
	- <img src="/images/clip.gif" height="100"/>
	- This animation bug is fixed in zPAM3, but there is still one problem described below
- ### Prone-peek
	- Prone peek is when you go from prone position to crouch position and then immediately back to prone position.
	- If you also lean left/right while standing-up, your head is moving too fast from side to center position.
	- For enemy its difficult to shoot, because character animation is moving too fast and it seems like bugged character animation
	- The prone-peek fix just make sure you stay in crouch position 400ms longer.
	- This delay is applied only if:
	  - pronepeek-able wall / cover is detected (cover that block your view in prone position, but not in crouch position)
	  - you are in ads (zoomed in)
	- You can debug prone-peek fix in game via command **/rcon debug_pronepeek 1**
- **Prone-peek fix is enabled by default**

<br>

### How does the "MG clip" fix works / what is it
Clipping a MG is situation, when you grab a MG while you are behind cover and you immidietely drop it. This makes you almost impossible to kill you, while you can easily get opponent's positions.
MG clip fix make sure you are spawned right behind the MG every time you drop the MG.<br>
Note: your teammates that are spectating you may see you "lagging". Thats normal and is caused by the way I used to fix this bug.<br>
**MG clip fix is enabled by default**

<br>

### How does the "Enemy list" works
Enemy list is feature that show names of alive player from opponent team. This feature can be enabled / disabled via menu.
You can change color of opponent team via scoreboard menu. Button "Set" will toggle between red, blue and white color.<br>
<img src="/images/enemylist_setcolor.png" /><br>
If you change a color, its applied to team, so your teammates can also see the colors.

<br>

### How does the "Round report" works
At the end of the round, hit + kill informations are printed. It include damage value, hit location and first hit location. For shotgun it prints number of pellets that hit the target<br>
<img src="/images/round_report.png" />

<br>

### How does the "Double kill" works
- Lets describe a situation when you fire a bullet to players that are lined right behind each other. When you fire, a "bullet-trace" is computed - it will find a first player in front of you, and this trace continue until it encounter an obstacle (wall, dead body, etc..)

- #### Old pam:
	- "bullet-trace" will find first player, witch receive damage, that is processed into kill and player dead body is spawned; bullet trace now continues from position of this player, but because there is a dead body spawned, the bullet-trace stops here (because dead-body is an obstacle) and the second player did not receive damage at all; there was situation where dead-body were spawned at slightly different position/angle then player body (on rough terrain for example) and then the bullet trace was able to continue. That's why the double kills were very rare on old pam

- #### New pam
	- in new pam, the dead-body is spawned after the bullet-trace is completely processed - that means the bullet is never stopped by spawned dead-bodies of players killed by this bullet and you can get double kills more easily

<br>

### What is "Diagonal"
Diagonal bug is when you walk forward + left/right + lean left/right + in ads. Doing this to the left side (walk forward + left + lean left + ads) makes our head and body rotated more to the right + down. This make you in an advantage position, because you can see enemy sooner then enemy sees you.
Option witch disabled leaning left/right when walking forward + left/right, preventing you from doing diagonal was removed from PAM, since it was affecting the player movement quite much.
So diagonal is not affected by PAM.

<br>

### How does the "Auto-spectator" works / what is it
- When you join spectator team and match is in progress, auto-spectator feature is enabled by default
- Auto-spectator will automatically switch to player in these cases:
 - player is looking at enemy (enemy is in their crosshair)
 - player is last alive player in team
- At round start, automatically followed player is selected by these steps:
  - Round 1: sniper of team allies
  - Round 2: sniper of team axis
  - Next rounds follows this pattern:
    - Best player in team allies
    - Best player in team axis
    - Next player in row in team allies
    - Next player in row in team axis
    - Next player in row in team allies
    - Next player in row in team axis
- When there is a request for player switch, player is switched to player from the same team (if round starts spectating player from team allies, it switch to player from team allies)
- If bomb is planted, team with lower alive players is preferred
- When player is switched, next switch is possible after 8 seconds.
- <img src="/images/spectator.png" />

<br>

### How does the "Spectator killcam" works / what is it
- In spectator team, you are able to replay actions (killcam)
- Actions are kills by players. When multiple kills happends within period of 5 seconds between each kill, these kills are saved as action.
- Actions are stored for 40 seconds (its game limitation)
- <img src="/images/spectator_killcam.png" />

<br>

### Scoreboard menu - how the Score, Kills, Deaths, Assists, Hits, Plant and Defuses are counted
<img src="/images/scoreboard_columns.png" />

| Column  | Description                                                                                                                                                                                |
|---------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Score   | Sum of following items:<br>Kill +1<br>Teamkill -1<br>Assist +0.5<br>Plant +0.5<br>Defuse +0.5                                                                                              |
| Kills   | Number of killed enemy players.<br>Teamkills are not counted (neither substracted)                                                                                                         |
| Deaths  | Number of times you were killed                                                                                                                                                            |
| Assists | Number of players you damaged and were killed by your teammate within 5 second                                                                                                             |
| Hits    | Damage you inflicted to opponent that does not lead to kill.<br>For example, if you damage a player for 75hp, after the player's health is regenerated, you will recieve +0.75 hit points. |
| Plants  | Number of bomb plants                                                                                                                                                                      |
| Defuses | Number of bomd defuses                                                                                                                                                                     |

<br>

### How damage debug cvar works
At the end of each round, debug info about hits is saved into cvar **pam_damage_debug**.<br>
Following format is used: time|miliseconds|attacker.origin|self.origin|distance|damage|self.health|weapon|hitLocation|point";
This cvar can be readed from demo.

<br>

### How does the zPAM settings works
zPAM uses cvar /server16 to save custom settings. This cvar is used because value of this cvar is saved into config when game is closed.<br>
Format: "item_value|item2_value2|...". <br>
Example: "autorecording_1|matchinfo_1|score_0|playersleft_1"

<br>
<br>

## Known bugs
 - When quick messages menu is opened, auto-recording will not start (its not able to close quick messages menu via pam)
 - You cannot take screenshot of new scoreboard via F12 (in menu binds are not working)
 - When you spawn a bot in strat, this bot will occupy player slot on server even if the bot is kicked; server restart is needed then

<br>
<br>

## Troubleshooting
### Error "zPAM is not installed correctly"
#### Iwd file zpam321.iwd must be installed in main folder. (fs_game)
 - From version 3.21, all iwd files have to be installed in main folder.
This is because of bug that cvars / settings changed in game are not saved into the config when running a game with fs_game set.
Make sure cvar /fs_game is empty and iwd files are placed in main folder.

#### Error while getting loaded iwd files. Make sure iwd files does not contains spaces.
- PAM was not able to parse loaded iwd files. Some of the iwd files have probably name with spaces.

#### Iwd file mp_toujane_fix_v2.iwd must be installed in main folder<br>Iwd file mp_burgundy_fix_v1.iwd must be installed in main folder
- From version 3.20, fixed versions of some maps are available. PAM is forcing to include these files to make sure maps are available on every server.

####  WWW downloading must be enabled. Set sv_wwwDownload and sv_wwwBaseURL
- You have to enable www downloading via cvar /sv_wwwDownload 1 and specify a download url via cvar /sv_wwwBaseURL "url".
- If you dont have any url, you can use /sv_wwwBaseURL "http://cod2x.me/zpam321"
- This is to make sure fixed maps are downloaded in fast way for players

####  Old pam / maps detected in main folder. Delete iwd file you see above.
- Your main folder contains also a other versions of pam or maps. Delete all .iwd files that the game prints on screen.



### Error "recursive error after: Can´t create Dvar 'xxx': 1280 dvars already exist"
This error happens when you have defined more than 1280 cvars in game.
You have to clean your config from useless cvars. If you dont know that cvars to delete, create a new profile and compare these 2 configs. Normal config should have ~400 lines.
This PAM defines ~150 new cvars for all of the features, so if your config contains a lot of mess, it may be the trigger for this error.


<br>
<br>


## Main changes
* Clip / Prone-peek bug fixed
* Double kills fixed
* Fast-reload shot bug fixed
* Missing textures fixed
* Auto demo recording
* Auto overtime mode for MR12
* New functions for STRAT mode (bots, path recording)
* Adjustable mouse vertical sensitivity, acceleration
* GUI improvements (menu, hud)
* Ability to change map / pam mode / kick player directly from menu
* Rebalanced shotgun
* MG clip fix
* New interface for spectators
* Match info bar
* <del>Diagonal bug fix</del> (removed - the way it was fixed affect a player movement a lot)
* <del>Changable FOV</del> (canceled - too big change)

*And much more - see full list down below*

### Gametypes
Only Search and Destroy, Deathmatch, Team Deathmatch and STRAT game type modes are currently supported.
Implementation of CTF and HQ maybe in the future.

### PAM modes
##### Search and Destroy
| pcw | cg | cg_mr12 | cg_2v2 | mr3 | mr10 | mr12 | mr15 | fun | pub |
|-----|----|---------|--------|-----|------|------|------|-----|-----|

##### Deathmatch
| pcw | pub | warmup |
|-----|-----|--------|

##### Team Deathmatch
| pcw | pub |
|-----|-----|



<br>

#### Formats
| First to 21                         | Max round 3 (MR3)                                       | Max round 10 (MR10)                                        | Max round 12 (MR12)                                        | Max round 15 (MR15)                                        |
|-------------------------------------|---------------------------------------------------------|------------------------------------------------------------|------------------------------------------------------------|------------------------------------------------------------|
| pcw, cg, cg_2v2                     | mr3                                                     | mr10                                                       | mr12, cg_mr12                                              | mr15                                                       |
| 10 rounds per half<br>20 rounds max | 3 rounds per half<br>6 rounds max<br>4 is winning score | 10 rounds per half<br>20 rounds max<br>11 is winning score | 12 rounds per half<br>24 rounds max<br>13 is winning score | 15 rounds per half<br>30 rounds max<br>16 is winning score |

#### Settings
| pcw                                                                                                                                    | cg modes, mr modes                                                                                                                    | pub           |
|----------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|---------------|
| - for classic match<br>- deadchat is enabled<br>- no count-down timer in half<br>- russian side turned on<br>- auto recording disabled | - for CyberGamer match<br>- deadchat is disabled<br>- 5min timer in half<br>- british replace russians<br>- auto recording is enabled | - public mode<br>- own settings |



| fun                                                    | warmup |
|--------------------------------------------------------|--------|
| - just fun mode with<br>higher speed and lower gravity | - mode for DM gametype<br>- no readyup, killcam enabled |

<br><br><br>







## List of changes

### 1. Fixed game bugs
<sub>
[1.1] Clip fix fix<br>
<a href="/images/clip.gif"><img src="/images/clip.gif" height="130" /></a><br>
[1.2] Texture fixes (adding xmodel)<br>
<a href="/images/toujane_jump.jpg"><img src="/images/toujane_jump.jpg" height="130" /></a><br>
<a href="/images/toujane_axis_roof.jpg"><img src="/images/toujane_axis_roof.jpg" height="130" /></a><br><br>
<a href="/images/toujane_jump_2.jpg"><img src="/images/toujane_jump_2.jpg" height="130" /></a><br>
<a href="/images/toujane_allies_window.jpg"><img src="/images/toujane_allies_window.jpg" height="130" /></a><br><br>
<a href="/images/carentan_stairs_1.jpg"><img src="/images/carentan_stairs_1.jpg" height="130" /></a><br>
<a href="/images/carentan_stairs_2.jpg"><img src="/images/carentan_stairs_2.jpg" height="130" /></a><br><br>
[1.3] Collision box / killtrigger<br>
<a href="/images/burgundy_jump.jpg"><img src="/images/burgundy_jump.jpg" height="130" /></a><br>
<a href="/images/dawnville_jump.jpg"><img src="/images/dawnville_jump.jpg" height="130" /></a><br>
[1.4] Fast reload bug (when you fire, press R to reload and then you scroll down 2x, you are able to shoot faster) -&gt; fixed<br>
[1.5] Bind to stop actually playing sound -&gt; fixed<br>
[1.6] Toujane bug inder A roof<br>
<a href="/images/toujane_underAroof_bug.jpg"><img src="/images/toujane_underAroof_bug.jpg" height="800" /></a><br>
[1.7] Toujane bucket is not visible from far distance -> fixed<br>
<a href="/images/toujane_bucket_fixed.jpg"><img src="/images/toujane_bucket_fixed.jpg" height="108" /></a><br>
[1.8] Toujane B tank model top grid is not visible from far distance -> fixed<br>
<a href="/images/toujane_B_bomb.jpg"><img src="/images/toujane_B_bomb.jpg" height="172" /></a><br>
[1.9] <del>Toujane sandbags holes</del> <strong>(canceled)</strong><br>
<a href="/images/toujaneSandbags.jpg"><img src="/images/toujaneSandbags.jpg" height="172" /></a><br>
[1.10] <del>Matmata sandbags holes</del> <strong>(canceled)</strong><br>
<a href="/images/matmataSandbags.jpg"><img src="/images/matmataSandbags.jpg" height="172" /></a><br>
[1.11] Carentan plant B 333fps plant - players are now not able to plant on B bomb tank.<br>
[1.12] <del>Carentan roof jump - added collision to avoid jumping to building roof</del> <strong>(canceled)</strong><br>
[1.13] BAR sound bug - when some player plays with BAR weapon, all other players can hearing sounds of changing weapon (happends when player with BAR is switching between BAR and pistol) -> fixed
</sub>

### 2. Fixed script bugs
#### 2.1 Weapons (complete weapon system rewrited)
<sub>
[2.1.1] limited weapons (sniper, shotgun) can be picked up by another player and can be saved to next round -&gt; fixed<br>
[2.1.2] if you change weapon for example from mp_44 to kar98 in starttime, you are not able to pickup mp_44 from ground until round ends -&gt; fixed<br>
[2.1.3] if limited weapon is selected, for all other players it is not correctly indicated in menu -&gt; fixed<br>
[2.1.4] weapon is dropped if player change a team in start time (can be exploited if player change team to spectator and back during strattime) -&gt; fixed<br>
[2.1.5] when player kills somebody with grenade while he is using MG - shows MG icon instead of grenade in killfeed-&gt; fixed<br>
[2.1.6] if player is killed while he cooks grenade/smoke, cooked grenade/smoke is throwed and second grenade/smoke is dropped to ground -&gt; fixed
</sub>

#### 2.2 Timeout
<sub>
[2.2.1] when timeout is canceled, player can not use quickmessages anymore until round/map ends -&gt; fixed<br>
[2.2.2] in sd, timeout is executed at the end of the round with no ability to walk -&gt; fixed, timeout is now executed always at the start of the new round<br>
[2.2.3] Timeout now can be called in round before halftime / map end
</sub><br>

#### 2.3 Other
<sub>
[2.3.1] <del>in sd, when last player dies, all players in defeated team are in spectator mode, but they can not move -&gt; fixed</del><br>
    <b>removed - now when all players from team are dead, camera is locked to location where last player die</b><br>
[2.3.2] when max team limit is reached and other player disconnect, other players was unable to select team -&gt; fixed<br>
[2.3.3] fixed bash pam mode (only pistols are allowed, disabled planting)<br>
[2.3.4] a lot of code rewrited, removed unnessesary things (splitscreen, xbox codes, ...)<br>
</sub>


### 3. Improvements already done
#### 3.1 Ready-up
<sub>
[3.1.1] added ability to stop killing in readyup mode<br>
[3.1.2] if you change weapon in readyup mode, you will get new grenades after 5sec (to avoid grenade spam)<br>
[3.1.3] ready-up now starts when there is atleast one player (useful when you need to test something on server alone)<br>
[3.1.4] no team limit for teams in ready-up mode (you can select whatever team you want in readyup mode)<br>
[3.1.5] when you are in spectator and you are following some player, now you can see really "Your status" instead of followed player status<br>
[3.1.6] added voice sound when all players are ready in readyup / halftime / timeout<br>
[3.1.7] added info indicating that server is cracked<br>
  <a href="/images/cracked.jpg"><img src="/images/cracked.jpg" height="100" /></a>
</sub>

#### 3.2 Weapons
<sub>
[3.2.1] primary weapon can be dropped if you have 2 main weapons (except limited weapons, like scopes) <br>
[3.2.2] recoded system for saving weapons at the end of the round - now its not exploitable<br>
[3.2.3] improved weapon menu - selected weapon is highlighted, used weapons are grayed out correctly, number of grenades under weapon image shows correctly, + added text who is using limited weapon <br>
    <a href="/images/gui_weapon.jpg"><img src="/images/gui_weapon.jpg" height="450" /></a>
</sub>

#### 3.3 New stuff
<sub>
[3.3.1] double kills - you are now able to shot thru players<br>
[3.3.2] added demo auto recording functionality<br>
<del>- when match is starting, text "Hold F to start recording a demo" is shown - when player holds F, demo start recording in format "XvX_map_team1_team2__ID.dm_1"</del><br>
    - demo starts recording automatically after ready-up is over + is recorded again every map (in format XvX_map_team1_team2__ID.dm_1)<br>
    - auto recording can be turned off via player settings, check [3.3.18]<br>
[3.3.3] <del>added "Kill me" and "Start recording" to quick-messages</del> <strong>(removed, check [3.3.18])</strong><br>
[3.3.4] some new cvar forces, like dx9 shadows forced off, duplicate packet forced off, ...<br>
[3.3.5] abillity to spawn bot in strat mode<br>
 - you can record and replay path for bots.<br>
[3.3.6] <del>abillity to change FOV (filed-of-view)</del> <strong>(canceled)</strong><br>
[3.3.7] add new info to small scoreboard at the end of the round (how long you are playing + rounds to halftime)<br>
[3.3.8] <del>show weapon instead of headshot in killfeed in match pam mode</del> <strong>(removed)</strong><br>
[3.3.9] <del>Shotgun rebalance 1</del> <strong>(removed)</strong><br>
[3.3.10] Match info - menu with information about team names, score, scores in previous maps, total played time. <br>Showable also in game. <br>Visible always for spectators.<br>
    <a href="/images/matchinfo.png"> <img src="/images/matchinfo.png" alt="" height="150" /> </a><br>
[3.3.11] Match info server cvars - basic information like team names, scores, round can be showed via HLSW for example<br>
    <a href="/images/matchinfo_hlsw.jpg"> <img src="/images/matchinfo_hlsw.jpg" alt="" height="150" /> </a><br>
[3.3.12] Server settings (Rcon change map)<br>
    <a href="/images/rcon_map.png"> <img src="/images/rcon_map.png" alt="" height="450" /> </a><br>
[3.3.13] Rcon kick menu<br>
    <a href="/images/rcon_kick.png"> <img src="/images/rcon_kick.png" alt="" height="450" /> </a><br>
[3.3.14] Strat bot support with path recording<br>
    <a href="/images/strat_bot.jpg"> <img src="/images/strat_bot.jpg" alt="" height="450" /> </a><br>
    Path recording:<br>
    <a href="/images/strat_bot_recording.jpg"> <img src="/images/strat_bot_recording.jpg" alt="" height="450" /> </a><br>
[3.3.15] <del>Match info ingame for ingames</del> <strong>(merged into 3.3.10)</strong><br>
[3.3.16] Shotgun rebalance 3 (new conditions to avoid long shots and close range hits)<br>
[3.3.17] Scoreboard menu, player's stats. Visible in menu and at the end of the map.<br>
    <a href="/images/scoreboard_ingame.jpg"> <img src="/images/scoreboard_ingame.jpg" alt="" height="600" /> </a><br><br>
    <a href="/images/scoreboard.jpg"> <img src="/images/scoreboard.jpg" alt="" height="450" /> </a><br>
    <br>
[3.3.18] Quick menu<br>
Added settings - you can disable auto recording, show matchinfo, score, enemy list (these settings are saved to cvar "server16")<br>
You can adjust mouse settings<br>
Added posibility to call bash mode from menu.<br>
    <a href="/images/quickmenu.png"> <img src="/images/quickmenu.png" alt="" height="300" /> </a><br><br>
[3.3.19] Bash mode - added posibility to call bash mode directly in first readyup. No need to set "pam_mode bash".<br>
[3.3.20] Player's score is restored when he reconnect in middle of game. To purposely reset score, name must be changed.<br>
[3.3.21] Secondary weapon replacement to pistol - if you click the same weapon in the menu you already have selected, your secondary weapon will be replaced by pistol (in start time). This could be useful for example if you have good spawn to rush, but you have two heavy weapons.<br>
[3.3.22] Message "Server lag detected" will be printed to all players if server have performence lags. (it will not detect network lags, just performence lags)<br>
[3.3.23] Auto-spectating mode - if you are in spectator team, you can toggle auto mode. It will automatically switch spectated player according to action in game. For example, if some player start looking at somebody, it will be automaticlly switched to this player.<br>
[3.3.24] Fullscreen image of map with warning is showed when important cvars (like com_maxfps) are not in allowed range. (this is kind of replace of cvar checks when punkbuster is off)<br>
<a href="/images/cvar_check.jpg"><img src="/images/cvar_check.jpg" height="100" /></a><br>
[3.3.25] In readyup, sound "Time to go get movin" is played to last not-ready player (only if it is 3v3 or more).<br>
[3.3.26] Prone peek fix - when you go from prone to crouch position, you are allowed to prone again after a small delay. This should avoid these situations: you are proned, leaned left/right and you peek behind the wall by going to crouch and back to prone as fast as possible. For enemy its difficult to shoot, because character animation is bugged and moving too fast.<br>
[3.3.27] MG clip FIX - if you drop a MG, you will be spawned right behind the MG<br>
[3.3.28] Dead bodies are not spawned near planted bomb<br>
[3.3.29] Score changing via menu - in first readyup, you can change a score of teams (in case wrong pam_mode was set, server crash, etc..)<br>
[3.3.30] New spectating system - new UI, auto-spectator is now better, score stats, player progress stats, etc..<br>
[3.3.31] Round report - at the end of the round info about kills and hits you made are printed<br>
[3.3.32] New damage feedback for assists - when player damaged by you is killed, damage feedback cross is showed<br>
[3.3.33] Players left - new player names list of alive enemy players above players left counter (can be turned off via menu)<br>
[3.3.34] In readyup, you can throw nades like in strat mode<br>
[3.3.35] New custom settings for map mode in rcon menu - a few of the settings can be changed (for example shotgun rebalance, fast-reload fix) and this change stays applied in next maps<br>
[3.3.36] New menu section in Main -> Options<br>
<a href="/images/settings.png"> <img src="/images/settings.png" alt="" height="450" /> </a><br>
[3.3.37] List of all changed server cvars is showed in "Server info" menu<br>
<a href="/images/serverinfo.png"> <img src="/images/serverinfo.png" alt="" height="450" /> </a><br>
[3.3.38] Score in left-top corner can by enabled via settings menu<br>
[3.3.39] For future hit diagnostics, at the end of each round info about hits is saved to cvar pam_damage_debug<br>
[3.3.40] Hitbox rebalance - if you fire from rifle or scope to left arm at +-20* degress, it will be changed to kill to body<br>
[3.3.41] In halftime-readyup and between map readyup, when 5min timer expire, red timer is showed. If all players from 1 team are ready, match automatically start even if opponent team is not ready.<br>
<a href="/images/auto_readyup.png"> <img src="/images/auto_readyup.png" /> </a><br>

</sub>

#### 3.4 Other
<sub>
[3.4.1] <del>New LOD force - all models are rendered in high details (this fixes ussues that enemy can be spotted behind tank from far distances, or bucket on toujane is not visible from far distance)<br>
    (this may be applyed only for toujane)</del><br>
    <b>Canceled - this caused significant FPS drops on some spots</b><br>
    <b>Some models are forced to render in high detail by another method</b><br><br>
[3.4.2] New bomb explosion radius + fixed explosion effect <br>
  <img src="/images/bomb_damage.jpg" alt="" height="300" /><br>
[3.4.3] when bomb explodes and kills someone, kill is assigned to planter<br>
[3.4.4] fixed bug when grenade icon is not visible in scope zoom - it depends on "cg_hudGrenadeIconInScope" - so now pam force value of this cvar to "1"<br>
[3.4.5] in overtime mode (for mr3, mr10, mr12, mr15 modes) - if match ends with draw, teams are automaticly switched over and over untill one team wins <br>
[3.4.6] when team is changed, team is changed immediately (before - team was changed after weapon choose)<br>
[3.4.7] all hud text are animated (small fadein and fadeout translations) and adapted to widescreen ratio<br>
[3.4.8] when you connect to match in progress, there is image of map in background - so player can not see anything and also is spawned outside map, so he can not hear anything (inspiration from COD4)<br>
    <a href="/images/blackout.jpg"><img src="/images/blackout.jpg" height="300" /></a><br>
[3.4.9] Added check if player has downloaded mod (mod needs to be downloaded or bug fixes described above will not work) <br>
    <a href="/images/mod_download.jpg"><img src="/images/mod_download.jpg" height="300" /></a><br>
[3.4.10] <del>Added check to "fs_game" if pam is installed correctly (if all servers with new pam will be installed in same folder, players will not have to downloading mod again on other servers)</del>replaced with [3.4.15]<br>
[3.4.11] Added new cvar system - all cvars (sv_, g_, scr_) are monitored against change (not all cvars was monitored in old pam) + added warning in readyup if cvars are not equal to league rules<br>
[3.4.12] Removed anoying music at the and of the map<br>
[3.4.13] Removed anoying music from main menu<br>
[3.4.14] Current pam modes (changes are marked bold):<br>
cg<br>
 - 10 rounds per half<br>
 - 20 rounds max<br>
 - used as "first to 21" format<br>
<br>
cg_1v1 - <b>removed</b><br>
<br>
cg_2v2<br>
 - same as cg<br>
 - sniper + shotgun disabled<br>
<br>
cg_mr10 - <b>removed</b><br>
 - removed, this mod was same as cg (mr10 word is misscorectly used for "first to 21" format)<br>
<br>
cg_mr12 - <b>changed</b><br>
 - 12 rounds per half<br>
 - 24 rounds max<br>
 - 13 end score  <b>(there is the change)</b><br>
<br>
mr3, mr10, mr12, mr15<br>
bash<br>
pub<br>
<br>
<b>pcw (new)<br>
- new mode for not cg matches<br>
- russian side turned on<br>
- auto recording is disabled<br>
- deadchat is enabled<br>
- there is no timer in half<br>
<br>
fun (new)<br>
- just fun mode with higher speed and lower gravity<br>
</b><br>
[3.4.15] PAM now has to be installed in main folder - this will fix problem with not saved cvar changes you made in game
</sub>

<br><br><br>

### 4. IDEAS
<sub>
[4.1] <del>player / server options (player settings, all rcon commands, new commands like set/reset score, move player to team, ...) </del><strong>(done as 3.3.13)</strong> <br>
[4.2] <del>add more info in shoutcaster mode (weapon, grenades..., like in CS:GO) (+ keybindings for players, map overview)  </del> <strong>implemented in [3.3.30]</strong><br>
[4.3] new binds for taking weapon class -&gt; like when the bind is pressed, player gets Thompson, MP44, or PPSh based on actual team&nbsp;<br>  
[4.4] increase sv_fps? <br>
[4.5] remove quickmessages (like "Follow me", "Move in!") in match pam mode  <br>
[4.6] remove "Explosives planted" voice sound for planter (just for planter, retain for rest of team) to avoid ninja defuse <a href="https://www.youtube.com/watch?v=SfRdlWHzUWQ"> https://www.youtube.com/watch?v=SfRdlWHzUWQ </a>&nbsp; <br>
[4.7] suggestion to drop smoke instead of nade if sg gets killed before smoke was used  <br>
[4.8] get Russians back with modified ppsh <br>
[4.9] <del>Spectator - keep following player from previsous round in new round (in current pam when new round started, spectator is moved to default position even if he was following some player...)</del> <strong>implemented in [3.3.30]</strong><br>
</sub>


### 5. KNOWN BUGS
<sub>
[5.0] Diagonal bug<br>
    <a href="/images/diagonal.jpg"> <img src="/images/diagonal.jpg" alt="" height="721" /> </a> <br>
[5.1] Slide bug (when player hits the ground he can not stop moving. It looks like he is "sliding" on the ground) <br>
[5.2] Defusing with F12 (player can defuse outside plant area when screenshot bind and F is pressed at one time) <br>
[5.3] Smoke is not visible if player press F12 or game window is minimized <br>
[5.4] <del>When some player plays with BAR weapon, all other players can hearing sounds of changing weapon on their side (happends when player with BAR is switching between BAR and pistol)</del> <strong>fixed, check [1.13]</strong> <br>
[5.5] When player is defusing and he use binoculars - its seems like he is not defunsing and zooming with weapon (but weapon is not visible) <br>
[5.6] bind MOUSE1 "+attack;+smoke" -&gt; this bind silences gun<br>
[5.7] <del>toujane bug - you get stuck in "link" if you crouch next to the wall</del> <strong>fixed in mp_toujane_fix</strong> <br>
    <a href="/images/toujane_cigan.jpg"> <img src="/images/toujane_cigan.jpg" alt="" height="150" /> </a><br>
[5.8] Carentan MG house at doors. Prone push  <br>
    <a href="/images/carentan_mg_house_bug1.jpg"> <img src="/images/carentan_mg_house_bug1.jpg" alt="" height="150" /> </a> <br>
    <a href="/images/carentan_mg_house_bug2.jpg"> <img src="/images/carentan_mg_house_bug2.jpg" alt="" height="150" /> </a><br>
[5.9] Dawnville: Bug in last apartment <br>
    <a href="/images/dawnville_apartment_bug.jpg"> <img src="/images/dawnville_apartment_bug.jpg" alt="" height="150" /> </a><br>
[5.10] too hight mg sensitivity <br>
[5.11] switching from scope to other player while dead, you keep hearing the "scopeshot" <br>
[5.12] r_picmip can be abused, find a way to make sure picmip 3 cant be used <br>
[5.13] <del>Carentan: make sure people cant jump on the B bombsite from sandbags with 333fps or from boxhouse.</del> <strong>fixed, check [1.11]</strong><br>
[5.14] Carentan: complaining about a bug behind the B bomb, the fences are bugged while scoping<br>
[5.15] MG clip bug - if you prone behind MG and press F to take it, enemy see you with a delay<br>
[5.16] You cannot hear sounds of players that are far away from you. In some spots you cannot hear sounds of players just around a corner. This is caused by map portals - every map is split up to portals. Only portals that you can see from your location are rendered by game engine. Unforcenetly players are also not rendered. Thats why you cannot hear your teammate shooting on A bombsite while you are on allies spawn for example.<br>
[5.17] Bash bug - you cannot bust while reload animation (untill weapon chamber is not fully refilled -> bash is blocked)<br>
[5.18] Burgundy low sky box - grenades are removed from game if you throw them above you with jump<br>
[5.19] Matmata jungle texture bug <br>
    <a href="/images/matmata_bug_1.jpg"><img src="/images/matmata_bug_1.jpg" alt="" height="150" /> </a>
    <a href="/images/matmata_bug_2.jpg"><img src="/images/matmata_bug_2.jpg" alt="" height="150" /> </a><br>
[5.20] Tanks - some tanks dont have solid tank wheels - shots go throught them<br>
[5.21] <del>Toujane bug under A roof</del><br>
<b>Fixed, viz [1.6]</b><br>
[5.22] Toujane bug in track on B bomb site - you can see enemy behind track boxes with jumping, but enemy cannot see you<br>
[5.23] Burgundy black tank - you can see enemy under tank wheels when you are far away from tank
 </sub>
