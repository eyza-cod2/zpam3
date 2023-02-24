#include maps\mp\gametypes\global\_global;

init()
{
	if (!level.spectatingSystem)
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
	}

	addEventListener("onConnected",  ::onConnected);
}

onConnected()
{
	if (!isDefined(self.pers["autoSpectatingESP"]))
		self.pers["autoSpectatingESP"] = true;
}



ESP_Destroy()
{
	// Destroy all
	for(i = 0; i < self.spec_ESP_names.size; i++)
	{
		// If HUD is not defined, it means player disconnect and HUD object was deleted
		if (isDefined(self.spec_ESP_names[i]))
			self.spec_ESP_names[i] destroy2();
		if (isDefined(self.spec_ESP_images[i]))
			self.spec_ESP_images[i] destroy2();
	}
	self.spec_ESP_names = undefined;
	self.spec_ESP_images = undefined;

	if (level.debug_spectator) self iprintln("autospec> ESP HUD destroyed ^1ALL");
}

/*
self is spectater
*/
ESP_Loop()
{
	self endon("disconnect");

	if (isDefined(self.spec_ESP_names))
		self ESP_Destroy();
	self.spec_ESP_names = [];
	self.spec_ESP_images = [];

	self thread FollowCloseByPlayer();

	spectator = self;
	i_ESP = 0;

	for(;;)
	{
		// Clear unused HUD elements
		for (i = self.spec_ESP_names.size - 1; i >= i_ESP; i--)
		{
			// If HUD is not defined, it means player disconnect and HUD object was deleted
			if (isDefined(self.spec_ESP_names[i]))
				self.spec_ESP_names[i] destroy2();
			if (isDefined(self.spec_ESP_images[i]))
				self.spec_ESP_images[i] destroy2();

			self.spec_ESP_names[i] = undefined;
			self.spec_ESP_images[i] = undefined;

			if (level.debug_spectator) self iprintln("autospec> ESP HUD destroyed index " + i);
		}

		wait level.frame;

		i_ESP = 0;

		// Player disconnects
		if (!isDefined(self))
			break;
		// Variables destroyed (not likely)
		if (!isDefined(self.spec_ESP_names) || !isDefined(self.spec_ESP_images))
			break;
		// All needs to be removed (changed team )
		if (self.pers["team"] != "spectator")
			break;
		// Hide hud in Readyup or bash
		if (level.in_readyup || level.in_bash)
			continue;
		// Dont show ESP if killcam or its turned off
		if (isDefined(spectator.killcam) || !spectator.pers["autoSpectatingESP"])
			continue;

		// Get spectated player
		autospectated_player = undefined;
		if (spectator.pers["autoSpectating"] && isDefined(level.autoSpectating_spectatedPlayer))
			autospectated_player = level.autoSpectating_spectatedPlayer;

		// Spectating player but not via auto-spectator
		if (!isDefined(autospectated_player) && !spectator.freeSpectating)
			continue;


		// Find players that will be showed via ESP
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player == spectator || !(player.pers["team"] == "allies" || player.pers["team"] == "axis"))
				continue;
			if (player.sessionstate != "playing" && player.sessionstate != "dead")
				continue;

			// Skip spectated player
			if (isDefined(autospectated_player) && player == autospectated_player)
				continue;

			// When auto-spectating (not flying) and followed player died, hide all (because game does not provide correct angles in this session state)
			if (isDefined(autospectated_player) && autospectated_player.sessionstate != "playing")
				continue;

			// When auto-spectating show only enemy (except for DM where show all players)
			// When free-flying show all players
			if (isDefined(autospectated_player) && autospectated_player.sessionteam == player.sessionteam && player.sessionteam != "none")
				continue;


			// Create new HUD element
			isNew = false;
			if (!isDefined(self.spec_ESP_names[i_ESP]))
			{
				self.spec_ESP_names[i_ESP] = addHUDClient(self, 10, 10, 1.2, (1,1,1), "center", "bottom", "subleft", "subtop");
				self.spec_ESP_names[i_ESP].name = "name";
				self.spec_ESP_names[i_ESP].fontscale = 0.8;
				self.spec_ESP_names[i_ESP].archived = false;

				self.spec_ESP_images[i_ESP] = addHUDClient(self, 10, 10, 1.2, (1,1,1), "center", "bottom", "subleft", "subtop");
				self.spec_ESP_images[i_ESP].name = "layout";
				self.spec_ESP_images[i_ESP].archived = false;
				self.spec_ESP_images[i_ESP].sort = -1;

				isNew = true;

				if (level.debug_spectator) self iprintln("autospec> ESP HUD added NEW index " + i_ESP);
			}

			// Update HUD
			if (isNew || self.spec_ESP_names[i_ESP].player != player)
			{
				self.spec_ESP_names[i_ESP].player = player;
				self.spec_ESP_names[i_ESP].offset = (0, 0, 25);
				self.spec_ESP_names[i_ESP].tag = "head";
				self.spec_ESP_names[i_ESP] SetPlayerNameString(player);
				self.spec_ESP_names[i_ESP] thread SetPlayerWaypoint(self, player);
				self.spec_ESP_names[i_ESP] thread hud_waypoint_animate(self, player);

				self.spec_ESP_images[i_ESP].player = player;
				self.spec_ESP_images[i_ESP].offset = (0, 0, -15);
				self.spec_ESP_images[i_ESP] thread SetPlayerWaypoint(self, player);
				self.spec_ESP_images[i_ESP] thread hud_waypoint_animate(self, player);
			}

			i_ESP++;
		}
	}

	// Destroy HUD (unles player disconnects)
	if (isDefined(self))
		self ESP_Destroy();
}


/*
When free-flying check for close-by player according to ESP names
*/
FollowCloseByPlayer()
{
	self endon("disconnect");

	self.spec_follow_text = addHUDClient(self, 0, 50, 1.2, (1,1,1), "center", "top", "center", "top");
	self.spec_follow_text.alpha = 0;

	saved_player_last = undefined;

	for(;;)
	{
		wait level.frame;

		// All needs to be removed (changed team or timeout is called)
		if (!isDefined(self) || self.pers["team"] != "spectator" || level.in_readyup)
			break;

		if (!self.freeSpectating)
			continue;

		saved_dist2D = 0;
		saved_dist3D = 0;
		saved_player = undefined;

		for(i = 0; i < self.spec_ESP_names.size; i++)
		{
			hud = self.spec_ESP_names[i];

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
				self.spec_follow_text fadeOverTime(time);
				self.spec_follow_text.alpha = 0;
				wait level.fps_multiplier * time;
				if (!isDefined(self)) break; // in case player disconnects
			}
			if (!isDefined(saved_player_last) || saved_player_last != saved_player)
			{
				self.spec_follow_text SetPlayerNameString(saved_player);
				self.spec_follow_text fadeOverTime(time);
				self.spec_follow_text.alpha = 1;
				wait level.fps_multiplier * time;
				if (!isDefined(self)) break; // in case player disconnects
			}
		}
		else if (isDefined(saved_player_last))
		{
			self.spec_follow_text fadeOverTime(time);
			self.spec_follow_text.alpha = 0;
			wait level.fps_multiplier * time;
			if (!isDefined(self)) break; // in case player disconnects
		}

		saved_player_last = saved_player;

		self.spec_follow = saved_player;
	}

	self.spec_follow_text destroy2();
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

		if (!isDefined(self) || !isDefined(spectator) || !isDefined(player))
			break;

		// Get spectated player
		spectated_player = spectator;
		if (!isDefined(spectator.killcam) && spectator.pers["autoSpectating"] && isDefined(level.autoSpectating_spectatedPlayer))
			spectated_player = level.autoSpectating_spectatedPlayer;


		alpha = 0.0;
		if (isAlive(player))
		{
			// Player is far way
			dist = distance(spectated_player.origin, player.origin);

			if (self.name == "name")
			{
				// Hide name if player is too far
				if (dist < 1500 || spectator.freeSpectating)
					alpha = 1;
			}

			if (self.name == "layout")
			{
				// Hide player icon when player is visible
				if (!spectated_player isPlayerInSight(player))
					alpha = 0.25;
			}

			// Hide if mouse is over
			if (!spectator.freeSpectating)
			{
				// If is in center, add alpha
				dist2D = distance((self.x, self.y, 0), (320, 240, 0));	// Distance of text from center - text is in 640x480 rectangle aligned left top
				if (dist2D <= 25)
					alpha = 0.0;
				else if (dist2D > 25 && dist2D <= 150)
					alpha = alpha * ((dist2D-25) / 125);
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
			if (player.pers["team"] == "allies")
			{
				if(game["allies"] == "american")
					color = (0.4, 0.9, .56);
				else if(game["allies"] == "british")
					color = (0.45, 0.73, 1);
				else if(game["allies"] == "russian")
					color = (1, 0.4, 0.4);
			}
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
			if (player.pers["team"] == "allies")
			{
				if(game["allies"] == "american")
					color = (0.7, 0.95, .8);
				else if(game["allies"] == "british")
					color = (0.73, 0.86, 1);
				else if(game["allies"] == "russian")
					color = (1, 0.7, 0.7);
			}
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
