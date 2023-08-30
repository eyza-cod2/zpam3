#include maps\mp\gametypes\global\_global;

init()
{
	if (!level.streamerSystem)
		return;

	if(game["firstInit"])
	{
		precacheShader("stance_stand_front");
		precacheShader("stance_stand_back");
		precacheShader("stance_stand_left");
		precacheShader("stance_stand_right");
		precacheShader("stance_crouch_front");
		precacheShader("stance_crouch_back");
		precacheShader("stance_crouch_left");
		precacheShader("stance_crouch_right");
		precacheShader("stance_prone_front");
		precacheShader("stance_prone_back");
		precacheShader("stance_prone_left");
		precacheShader("stance_prone_right");

		//game["STRING_STREAMERSYSTEM_XRAY_ON"] = 		"XRAY ^2On";
		//game["STRING_STREAMERSYSTEM_XRAY_OFF"] = 		"XRAY ^1Off";

		precacheString2("STRING_STREAMERSYSTEM_ARROW_LEFT", &"<");
		precacheString2("STRING_STREAMERSYSTEM_ARROW_RIGHT", &">");
	}

	addEventListener("onConnected",  ::onConnected);
}

onConnected()
{
	if (!isDefined(self.pers["streamerSystem_XRAY"]))
		self.pers["streamerSystem_XRAY"] = false;

	self.streamerSystem_XRAY_inFreeSpectating = false;

	// Disable XRAY by default every round
	self.pers["streamerSystem_XRAY"] = false;
}


toggle()
{
	if (self.streamerSystem_freeSpectating)
	{
		self.streamerSystem_XRAY_inFreeSpectating = !self.streamerSystem_XRAY_inFreeSpectating;
		self.pers["streamerSystem_XRAY"] = self.streamerSystem_XRAY_inFreeSpectating;
	}
	else
		self.pers["streamerSystem_XRAY"] = !self.pers["streamerSystem_XRAY"];

	/*if (self.pers["streamerSystem_XRAY"])
		self iprintln(game["STRING_STREAMERSYSTEM_XRAY_ON"]);
	else
		self iprintln(game["STRING_STREAMERSYSTEM_XRAY_OFF"]);*/

	self thread maps\mp\gametypes\_streamer_hud::settingsChangedForPlayer("xray");
}



XRAY_Destroy()
{
	// Destroy all
	for(i = 0; i < self.streamerSystem_XRAY_names.size; i++)
	{
		// If HUD is not defined, it means player disconnect and HUD object was deleted
		if (isDefined(self.streamerSystem_XRAY_names[i]))
			self.streamerSystem_XRAY_names[i] destroy2();
		if (isDefined(self.streamerSystem_XRAY_images[i]))
			self.streamerSystem_XRAY_images[i] destroy2();
	}
	self.streamerSystem_XRAY_names = undefined;
	self.streamerSystem_XRAY_images = undefined;

	if (level.debug_spectator) self iprintln("autospec> XRAY HUD destroyed ^1ALL");
}

/*
self is spectater
*/
XRAY_Loop()
{
	self endon("disconnect");

	if (isDefined(self.streamerSystem_XRAY_names))
		self XRAY_Destroy();
	self.streamerSystem_XRAY_names = [];
	self.streamerSystem_XRAY_images = [];

	self thread FollowCloseByPlayer();

	i_XRAY = 0;
	freeSpectating = self.streamerSystem_freeSpectating;

	for(;;)
	{
		// Clear unused HUD elements
		for (i = self.streamerSystem_XRAY_names.size - 1; i >= i_XRAY; i--)
		{
			// If HUD is not defined, it means player disconnect and HUD object was deleted
			if (isDefined(self.streamerSystem_XRAY_names[i]))
				self.streamerSystem_XRAY_names[i] destroy2();
			if (isDefined(self.streamerSystem_XRAY_images[i]))
				self.streamerSystem_XRAY_images[i] destroy2();

			self.streamerSystem_XRAY_names[i] = undefined;
			self.streamerSystem_XRAY_images[i] = undefined;

			if (level.debug_spectator) self iprintln("autospec> XRAY HUD destroyed index " + i);
		}

		wait level.frame;

		i_XRAY = 0;

		// Player disconnects
		if (!isDefined(self))
			break;
		// Variables destroyed (not likely)
		if (!isDefined(self.streamerSystem_XRAY_names) || !isDefined(self.streamerSystem_XRAY_images))
			break;
		// All needs to be removed (changed team)
		if (self.pers["team"] != "streamer")
			break;
		// Hide hud in Readyup or bash
		if (/*level.in_readyup || */level.in_bash)
			continue;
		// Dont show XRAY if killcam or its turned off
		if (isDefined(self.killcam))
			continue;


		// If player started free spectating, force XRAY by another toggler
		if (freeSpectating != self.streamerSystem_freeSpectating && self.streamerSystem_freeSpectating)
			self.streamerSystem_XRAY_inFreeSpectating = true;
		freeSpectating = self.streamerSystem_freeSpectating;

		// Get spectated player
		spectated_player = undefined;
		if (self.streamerSystem_turnedOn && isDefined(level.streamerSystem_player))
			spectated_player = level.streamerSystem_player;


		// In free spectating is XRAY enabled by default (to enable follow close by player)
		// There is separated toggler for that
		if (self.streamerSystem_freeSpectating)
		{
			// XRAY is turned off
			if (!self.streamerSystem_XRAY_inFreeSpectating)
				continue;
		}
		else
		{
			// XRAY is turned off
			if (!self.pers["streamerSystem_XRAY"])
				continue;

			// Show xray only if we know spectated player
			if (!isDefined(spectated_player))
				continue;
		}


		// Find players that will be showed via XRAY
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player == self || !(player.pers["team"] == "allies" || player.pers["team"] == "axis"))
				continue;
			if (player.sessionstate != "playing" && player.sessionstate != "dead")
				continue;

			// Skip spectated player
			if (isDefined(spectated_player) && player == spectated_player)
				continue;

			// When auto-spectating (not flying) and followed player died, hide all (because game does not provide correct angles in this session state)
			if (isDefined(spectated_player) && spectated_player.sessionstate != "playing")
				continue;

			// When auto-spectating show only enemy (except for DM where show all players)
			// When free-flying show all players
			if (isDefined(spectated_player) && spectated_player.sessionteam == player.sessionteam && player.sessionteam != "none")
				continue;


			// Create new HUD element
			isNew = false;
			if (!isDefined(self.streamerSystem_XRAY_names[i_XRAY]))
			{
				self.streamerSystem_XRAY_names[i_XRAY] = addHUDClient(self, 10, 10, 1.2, (1,1,1), "center", "bottom", "subleft", "subtop");
				self.streamerSystem_XRAY_names[i_XRAY].name = "name";
				self.streamerSystem_XRAY_names[i_XRAY].archived = false;

				self.streamerSystem_XRAY_images[i_XRAY] = addHUDClient(self, 10, 10, 1.2, (1,1,1), "center", "bottom", "subleft", "subtop");
				self.streamerSystem_XRAY_images[i_XRAY].name = "layout";
				self.streamerSystem_XRAY_images[i_XRAY].archived = false;
				self.streamerSystem_XRAY_images[i_XRAY].sort = -1;

				isNew = true;

				if (level.debug_spectator) self iprintln("autospec> XRAY HUD added NEW index " + i_XRAY);
			}

			// Update HUD
			if (isNew || self.streamerSystem_XRAY_names[i_XRAY].player != player)
			{
				self.streamerSystem_XRAY_names[i_XRAY].player = player;
				self.streamerSystem_XRAY_names[i_XRAY].offset = (0, 0, 25);
				self.streamerSystem_XRAY_names[i_XRAY].tag = "head";
				self.streamerSystem_XRAY_names[i_XRAY].string = "name"; // name | < | >
				self.streamerSystem_XRAY_names[i_XRAY].fontscale = 0.8;
				self.streamerSystem_XRAY_names[i_XRAY] SetPlayerNameString(player);
				self.streamerSystem_XRAY_names[i_XRAY] thread SetPlayerWaypoint(self, player);
				self.streamerSystem_XRAY_names[i_XRAY] thread hud_waypoint_animate(self, player);

				self.streamerSystem_XRAY_images[i_XRAY].player = player;
				self.streamerSystem_XRAY_images[i_XRAY].offset = (0, 0, -15);
				self.streamerSystem_XRAY_images[i_XRAY] thread SetPlayerWaypoint(self, player);
				self.streamerSystem_XRAY_images[i_XRAY] thread hud_waypoint_animate(self, player);
			}

			i_XRAY++;
		}
	}

	// Destroy HUD (unles player disconnects)
	if (isDefined(self))
		self XRAY_Destroy();
}


/*
When free-flying check for close-by player according to XRAY names
*/
FollowCloseByPlayer()
{
	self endon("disconnect");

	self.streamerSystem_HUD_followPlayerName = addHUDClient(self, 0, 50, 1.2, (1,1,1), "center", "top", "center", "top");
	self.streamerSystem_HUD_followPlayerName.alpha = 0;

	saved_player_last = undefined;

	for(;;)
	{
		wait level.frame;

		// All needs to be removed (changed team or timeout is called)
		if (!isDefined(self) || self.pers["team"] != "streamer" /*|| level.in_readyup*/)
			break;

		if (!self.streamerSystem_freeSpectating)
			continue;

		saved_dist2D = 0;
		saved_dist3D = 0;
		saved_player = undefined;

		for(i = 0; i < self.streamerSystem_XRAY_names.size; i++)
		{
			hud = self.streamerSystem_XRAY_names[i];

			// If HUD is not defined, it means player disconnect and HUD object was deleted
			if (!isDefined(hud) || !isDefined(hud.player) || !isAlive(hud.player))
				continue;

			// Find out looking at player to follow on click
			dist3D = distance(self.origin, hud.player.origin);

			// If text is somewhere in rectangle around center
			if ((hud.x > 160 && hud.x < 480 && hud.y > 120 && hud.y < 360) || (dist3D < 300 && hud.x > 160 && hud.x < 480))
			{
				if (dist3D < 1000)
				{
					dist2D = distance((hud.x, hud.y, 0), (320, 240, 0));	// Distance of text from center - text is in 640x480 rectangle aligned left top

					if (!isDefined(saved_player) || (dist2D < saved_dist2D && dist3D < saved_dist3D))
					{
						saved_dist2D = dist2D;
						saved_dist3D = dist3D;
						saved_player = hud.player;
					}
				}
			}
		}

		time = 0.1;

		if (isDefined(saved_player))
		{
			if (isDefined(saved_player_last) && saved_player_last != saved_player)
			{
				self.streamerSystem_HUD_followPlayerName fadeOverTime(time);
				self.streamerSystem_HUD_followPlayerName.alpha = 0;
				wait level.fps_multiplier * time;
				if (!isDefined(self)) break; // in case player disconnects
			}
			if (!isDefined(saved_player_last) || saved_player_last != saved_player)
			{
				self.streamerSystem_HUD_followPlayerName SetPlayerNameString(saved_player);
				self.streamerSystem_HUD_followPlayerName fadeOverTime(time);
				self.streamerSystem_HUD_followPlayerName.alpha = 1;
				wait level.fps_multiplier * time;
				if (!isDefined(self)) break; // in case player disconnects
			}
		}
		else if (isDefined(saved_player_last))
		{
			self.streamerSystem_HUD_followPlayerName fadeOverTime(time);
			self.streamerSystem_HUD_followPlayerName.alpha = 0;
			wait level.fps_multiplier * time;
			if (!isDefined(self)) break; // in case player disconnects
		}

		saved_player_last = saved_player;

		self.streamerSystem_playerToFollow = saved_player;
	}

	self.streamerSystem_HUD_followPlayerName destroy2();
}




// self is HUD, spectator is hud owner and player is waypoined player
hud_waypoint_animate(spectator, player)
{
	// Make sure only 1 thread is running on this HUD element
	self notify("hud_waypoint_animate");
	self endon("hud_waypoint_animate");

	alpha_old = 0;
	alpha_cnt = 0;
	alpha_last = 0;
	self.alpha = 0;

	for (;;)
	{
		wait level.frame;
		waittillframeend;

		if (!isDefined(self) || !isDefined(spectator) || !isDefined(player))
			break;

		// Get spectated player
		spectated_player = spectator;
		if (!isDefined(spectator.killcam) && spectator.streamerSystem_turnedOn && isDefined(level.streamerSystem_player))
			spectated_player = level.streamerSystem_player;


		alpha = 0.0;
		if (isAlive(player))
		{
			// Player is far way
			dist = distance(spectated_player.origin, player.origin);

			if (self.name == "name")
			{
				if (self.x < 40)
				{
					self.x = 40;
					self.y = 310;

					if (self.string != "<")
					{
						self.string = "<";
						self SetText(game["STRING_STREAMERSYSTEM_ARROW_LEFT"]);
						self.fontscale = 1.2;
					}
				}
				else if (self.x > 640 - 40)
				{
					self.x = 640 - 40;
					self.y = 310;

					if (self.string != ">")
					{
						self.string = ">";
						self SetText(game["STRING_STREAMERSYSTEM_ARROW_RIGHT"]);
						self.fontscale = 1.2;
					}
				}
				else
				{
					if (self.string != "name")
					{
						self.string = "name";
						self SetPlayerNameString(player);
						self.fontscale = 0.8;
						alpha_last = 0; // to avoid animation from 1 to 0
					}
				}

				// Show name only if enemy is close, in free spectating or if arrows are showed
				if (spectator.streamerSystem_freeSpectating || self.string == "<" || self.string == ">")
					alpha = 1;
				else if (dist > 0 && dist < 1500)
				{
					size = (1500 / dist); //ex:   far = 1;  close = 6;   very close = 300
					size = size / 4; // make it smaller numbers
					if (size > 1.0) size = 1.0;
					if (size < 0.5) size = 0.5;

					self.fontscale = size;
					alpha = 1;
				}
			}

			if (self.name == "layout")
			{
				// Hide player icon when player is visible
				if (!spectated_player isPlayerInSight(player) && !spectator.streamerSystem_freeSpectating)
					alpha = 0.5;
			}

			// Hide if mouse is over
			if (!spectator.streamerSystem_freeSpectating)
			{/*
				// If is in center, add alpha
				dist2D = distance((self.x, self.y, 0), (320, 240, 0));	// Distance of text from center - text is in 640x480 rectangle aligned left top
				if (dist2D <= 25)
					alpha = 0.0;
				else if (dist2D > 25 && dist2D <= 150)
					alpha = alpha * ((dist2D-25) / 125);*/
			}
		}

		// Alpha smooth animation
		if (alpha_last != alpha)
		{
			alpha_old = self.alpha;
			alpha_cnt = 10;
			alpha_last = alpha;
		}
		if (alpha_cnt > 0)
		{
			self.alpha = alpha_old + ((alpha - alpha_old) / 10) * (10-alpha_cnt);
			alpha_cnt--;
		}
		else
			self.alpha = alpha;


		// Item is not visible, no need to continue animation
		if (self.alpha == 0)
			continue;


		if (self.name == "name")
		{
			color = (0.8, 0.8, 0.8);

			self.color = color;
		}


		if (self.name == "layout")
		{
			stance = player maps\mp\gametypes\global\player::getStance(); // prone crouch stand

			angles = player getPlayerAngles();

			diff = (player.origin - spectated_player.origin);
			diff = (diff[0], diff[1], 0);
			diff = vectortoangles(diff);

			angle = (angles[1] - diff[1]);

			if (angle > 180)	angle -= 360;
			else if (angle < -180)	angle += 360;
			angle += 180; // flip direction, now in range 0 <-> 360
			if (angle > 180) angle -= 360; // back to range -180 <-> +180


			if ((angle > 135 && angle <= 180) || (angle < -135 && angle >= -180))
				self.shader = "stance_" + stance + "_back";
			else if (angle > 45 && angle < 135)
				self.shader = "stance_" + stance + "_right";
			else if (angle < -45 && angle > -135)
				self.shader = "stance_" + stance + "_left";
			else
				self.shader = "stance_" + stance + "_front";

			self.w = 25;
			self.h = 25;
			self.scale = 1400;

			color = (0.9, 0.9, 0.9);

			if (player.health <= 0)
				color = (1, 0, 0); // red
			else if (player.health < 100)
			{
				dmg = (player.health / 100);
				color = (color[0] + (1-color[0]) * (1-dmg), color[1] * dmg, color[2] * dmg);
			}
			self.color = color;
		}
	}
}
