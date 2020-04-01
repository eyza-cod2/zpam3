# New zPAM3.0 (2020 refresh)
Mod zPAM3.0 is new version of PAM mode for COD2.

It is based on latest zPAM2.07 version and implements new features and bug fixes

# Bug fixes
Prone-crouch-prone clip fix - when player goes from prone to crouch and back, enemy cannot see him - fixed:<br />
<img src="/images/clip.gif" height="142" />

New textures for toujane jump and bulletproof axis roof:<br />
<img src="/images/toujane_jump.jpg" width="461" height="130" /><br />
<img src="/images/toujane_jump_2.jpg" width="461" height="130" /><br />
<img src="/images/toujane_axis_roof.jpg" width="461" height="130" />

New textures for bulletproof carentan stairs:<br />
<img src="/images/carentan_stairs_1.jpg" width="461" height="130" /><br />
<img src="/images/carentan_stairs_2.jpg" width="461" height="130" />

New bomb damage radius<br />
<img src="/images/bomb_damage.jpg" width="461" height="267" />

New LOD force - all models are rendered in hight detail<br />
(this fixes ussues that enemy can be spotted behind tank from far distances)<br />
<img src="/images/lod.gif" width="461" height="267" />

GUI changes - adaptation to wide aspect ratio:<br />
<img src="/images/gui.jpg" width="461" height="130" />

Weapon menu - fixed indication who is using limited weapons<br />
<img src="/images/gui_weapon.jpg" width="461" height="130" />

New &quot;Player options&quot; and &quot;Server options&quot; menu (not fully finished)<br />
<img src="/images/gui_player_server_options.jpg" width="461" height="130" />

New &quot;Blackout&quot; mode - when player join match in progress (for example because of 999), only map background is visible until he select a team.<br />
<img src="/images/blackout.jpg" width="230" height="130" />

Players cannot stand in the air on burgundy anymore<br />
<img src="/images/burgundy_jump.jpg" width="230" height="130" />

Players cannot jump thrught windows on dawnville; also kill-trigger was removed from second window<br />
<img src="/images/dawnville_jump.jpg" width="230" height="130" />

New texture fix for window on toujane<br />
<img src="/images/toujane_allies_window.jpg" alt="" width="461" height="130" />


# Warning:
New zPAM 3.0 needs to be downloaded otherwise these fixes wont work!<br />
That is reason why downloading on client side needs to be turned on (cl_allowDownload 1)<br />
So, if you connect the server and you got this message:<br />
<img src="/images/mod_download.jpg" width="230" height="130" /><br />
please just reconnect to the server, mod will be automaticly downloaded.


# Known bugs
Fixable, not implemented yet:<br />
<img src="/images/carentan_mg_house_bug1.jpg" alt="" width="200" height="130" />
<img src="/images/dawnville_apartment_bug.jpg" alt="" width="300" height="130" />
<img src="/images/gamma.jpg" alt="" width="261" height="130" />

Other:<br />
<img src="/images/toujane_bucket.jpg" alt="" width="361" height="130" />
<img src="/images/toujane_cigan.jpg" alt="" width="200" height="130" />

* Slide bug (when player hits the ground he can not stop moving. It looks like he is "sliding" on the ground)
* Diagonal bug (player is looking straight forward but in third person he is looking to the ground)
* Defusing with F12 (player can defuse outside plant area when screenshot bind and F is pressed at one time)
* Smoke is not visible if player press F12 or game window is minimized
* When some player plays with BAR weapon, all other players can hearing sounds of changing weapon on their side (happends when player with BAR is switching between BAR and pistol)
* When player is defusing and he use binoculars - its seems like he is not defunsing and zooming with weapon (but weapon is not visible)
* Fast reload bug - if player hit fire, when hit R to realod, when scrolls down to change weapon 2x and then fire faster
* MG clip bug - if you prone behind MG and press F to take it, enemy see you with a delay
