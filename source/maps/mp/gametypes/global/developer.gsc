#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("debug_shotgun", "BOOL", false);
	registerCvar("debug_pronepeek", "BOOL", false);
	registerCvar("debug_spectator", "BOOL", false);
	registerCvar("debug_fastreload", "BOOL", false);
	registerCvar("debug_handhitbox", "BOOL", false);


	// This is called only if developer_script is set to 1
	/#
  	//addEventListener("onConnected",     ::onConnected);
/*

	underAroof1 = spawn("script_model",(1506, 2213, 115));
	underAroof1.angles = (51, 328, 90);
	underAroof1 setmodel("xmodel/toujane_underA_bug");
*/


	//thread shot();

	//thread bots();

	//thread spect_menu();

	#/
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "debug_shotgun": 		level.debug_shotgun = value; return true;
		case "debug_pronepeek": 	level.debug_pronepeek = value; return true;
		case "debug_spectator": 	level.debug_spectator = value; return true;
		case "debug_fastreload": 	level.debug_fastreload = value; return true;
		case "debug_handhitbox": 	level.debug_handhitbox = value; return true;

	}
	return false;
}


bots()
{
	wait level.fps_multiplier * 8;

	for(;;)
	{
		if (!level.in_readyup)
		{
			bot = maps\mp\gametypes\_bots::addBots(1);

			wait level.fps_multiplier * 0.5;

			maps\mp\gametypes\_bots::removeBots(1);


		}
		wait level.fps_multiplier * 0.5;
	}
}



key()
{
	setCvar("id", -1);

	for(;;)
	{
		wait level.frame;

		id = getCvarInt("id");

		if (id != -1)
		{
			players = getentarray("player", "classname");
			for(p = 0; p < players.size; p++)
			{
				player = players[p];
				if (player.pers["team"] == "spectator")
				{
					player.spectatorclient = id;

					player allowSpectateTeam("allies", true);
					player allowSpectateTeam("axis", true);
					player allowSpectateTeam("freelook", true);
					player allowSpectateTeam("none", true);

					player iprintln("spectate id " + id);
				}
			}

			setcvar("id", -1);
		}
	}
}



skipReadyup()
{
	//wait level.fps_multiplier * .1;

	if (level.in_readyup)
	{
		game["Do_Ready_up"] = 0;
		game["readyup_first_run"] = false;

		map_restart(true);
	}
}


showWaypoint(player)
{
	origin = self getOrigin();

	waypoint = undefined;
	if (isDefined(player))
		waypoint = newClientHudElem2(player);
	else
		waypoint = newHudElem2();

	self.waypoint = waypoint;
	self.waypoint.name = "A";
	self.waypoint.x = origin[0];
	self.waypoint.y = origin[1];
	self.waypoint.z = origin[2];
	self.waypoint.alpha = 1;
	self.waypoint.archived = true;
	self.waypoint setShader("objpoint_default", 2, 2);
	self.waypoint setwaypoint(true);

	for (;;)
	{
		wait level.frame;

		if (!isDefined(self))
			break;

		origin = self getOrigin();

		self.waypoint.x = origin[0];
		self.waypoint.y = origin[1];
		self.waypoint.z = origin[2];
	}

	waypoint destroy2();
}


moving_obj(id)
{
	origin = self getOrigin();

	newobjpoint = newHudElem2();
	newobjpoint.name = id;
	newobjpoint.x = origin[0];
	newobjpoint.y = origin[1];
	newobjpoint.z = origin[2];
	newobjpoint.alpha = 1;
	newobjpoint.archived = true;
	newobjpoint setShader("objpoint_default", 2, 2);
	newobjpoint setwaypoint(true);

	for(;;)
	{
		wait level.frame;

		origin = self getOrigin();

		newobjpoint.x = origin[0];
		newobjpoint.y = origin[1];
		newobjpoint.z = origin[2];

		if (getCvar("id") == id)
		{
			if (getCvar("x") != "")
				self.origin += (getCvarInt("x"), 0, 0);
			if (getCvar("y") != "")
				self.origin += (0, getCvarInt("y"), 0);
			if (getCvar("z") != "")
				self.origin += (0, 0, getCvarInt("z"));

			if (getCvar("yaw") != "")
				self.angles += (getCvarInt("yaw"), 0, 0);
			if (getCvar("pitch") != "")
				self.angles += (0, getCvarInt("pitch"), 0);
			if (getCvar("roll") != "")
				self.angles += (0, 0, getCvarInt("roll"));

			if (getCvar("x") != "" || getCvar("y") != "" || getCvar("z") != "" || getCvar("yaw") != "" || getCvar("pitch") != "" || getCvar("roll") != "")
			{
				println(self.origin);
				println(self.angles);
			}

			setCvar("x", "");
			setCvar("y", "");
			setCvar("z", "");

			setCvar("yaw", "");
			setCvar("pitch", "");
			setCvar("roll", "");
		}

	}
}

spect_menu()
{

	for(;;)
	{
		wait level.frame;

		if (getCvar("do") != "")
		{
			players = getentarray("player", "classname");
			for(p = 0; p < players.size; p++)
			{
				player = players[p];

				player.sessionstate = "playing"; // enable quickmessage


				player setClientCvar2("ui_quickmessage_spectatormode", "1");



				// Exec command on client side
				// If some menu is already opened:
				//	- by player (by ESC command) -> it will work well over already opened menu
				//  - by script (via openMenu()) -> that menu will be closed and exec_cmd will not be closed correctly
				//			(mouse will be visible with clear backgorund.... so closeMenu() is called to close that menu)
				player setClientCvar2("exec_cmd", "mp_quickmessage");
				player openMenu(game["menu_exec_cmd"]);		// open menu via script
				player closeMenu();							// will only close menu opened by script

				wait level.frame;


				player.sessionstate = "spectator";
			}

			setcvar("do", "");
		}
	}
}



shot()
{
	level.ii = 0;
	for(;;)
	{
		wait level.frame;

		if (getCvar("shot") != "")
		{
			players = getentarray("player", "classname");
			for(p = 0; p < players.size; p++)
			{
				// Exec command on client side
				// If some menu is already opened:
				//	- by player (by ESC command) -> it will work well over already opened menu
				//  - by script (via openMenu()) -> that menu will be closed and exec_cmd will not be closed correctly
				//			(mouse will be visible with clear backgorund.... so closeMenu() is called to close that menu)
				players[p] setClientCvar2("exec_cmd", "+attack; -attack");
				players[p] openMenu(game["menu_exec_cmd"]);		// open menu via script
				players[p] closeMenu();							// will only close menu opened by script


				players[p] setClientCvar2("ui_match_round", level.ii);
				level.ii++;
			}

			setcvar("shot", "");
		}
	}
}

trig()
{
	for(;;)
	{
		wait level.frame;

		if (getCvar("trig") != "")
		{
			maps\mp\gametypes\_mapvote::Initialize();

			setcvar("trig", "");
		}
	}
}





waittilltests()
{
	self thread waittilltests1();
	self thread waittilltests2();
	self thread waittilltests3();
	self thread waittilltests4();
	self thread waittilltests5();
	self thread waittilltests6();
	self thread waittilltests7();
	self thread waittilltests8();
	self thread waittilltests9();
	self thread waittilltests10();
	self thread waittilltests11();
	self thread waittilltests12();
	self thread waittilltests13();
	self thread waittilltests14();
	self thread waittilltests15();
	self thread waittilltests16();
}


waittilltests1()
{
	for(;;)
	{
		self waittill("trigger");
		iprintln(": " + "trigger");
	}
}
waittilltests2()
{
	for(;;)
	{
		self waittill("trigger_damage");
		iprintln(": " + "trigger_damage");
	}
}
waittilltests3()
{
	for(;;)
	{
		self waittill("trigger_lookat");
		iprintln(": " + "trigger_lookat");
	}
}
waittilltests4()
{
	for(;;)
	{
		self waittill("worldspawn");
		iprintln(": " + "worldspawn");
	}
}
waittilltests5()
{
	for(;;)
	{
		self waittill("begin");
		iprintln(": " + "begin");
	}
}
waittilltests6()
{
	for(;;)
	{
		self waittill("touch");
		iprintln(": " + "touch");
	}
}
waittilltests7()
{
	for(;;)
	{
		self waittill("target_script_trigger");
		iprintln(": " + "target_script_trigger");
	}
}
waittilltests8()
{
	for(;;)
	{
		self waittill("damage", amount, attacker, direction_vec, point, type);
		iprintln(": " + "damage");

		if (isDefined(amount)) iprintln("    amount: " + amount);
		if (isDefined(attacker) && isPlayer(attacker)) iprintln("    attacker: " + attacker.name);
		if (isDefined(direction_vec)) iprintln("    direction_vec: ");
		if (isDefined(type)) iprintln("    type: " + type);

	}
}
waittilltests9()
{
	for(;;)
	{
		self waittill("death");
		iprintln(": " + "death");
	}
}
waittilltests10()
{
	for(;;)
	{
		self waittill("grenade");
		iprintln(": " + "grenade");
	}
}

waittilltests11()
{
	for(;;)
	{
		self waittill("prone");
		iprintln(": " + "prone");
	}
}
waittilltests12()
{
	for(;;)
	{
		self waittill("tag_camera");
		iprintln(": " + "tag_camera");
	}
}
waittilltests13()
{
	for(;;)
	{
		self waittill("fire");
		iprintln(": " + "fire");
	}
}
waittilltests14()
{
	for(;;)
	{
		self waittill("target_script_trigger");
		iprintln(": " + "target_script_trigger");
	}
}

waittilltests15()
{
	for(;;)
	{
		self waittill("movedone");
		iprintln(": " + "movedone");
	}
}

waittilltests16()
{
	for(;;)
	{
		self waittill("key1");
		iprintln(": " + "key1");
	}
}















onConnected()
{
	self endon("disconnect");

	//if (1)	return;

	wait level.fps_multiplier * 1.0;



	//self iprintln("ClientID: " + self getEntityNumber());

	if (isDefined(self.pers["_temp_"]))
		return;
	self.pers["_temp_"] = true;

	//self openMenu(game["menu_scoreboard"]);
	//self closeMenu();
	//self closeInGameMenu();


	self.pers["killer"] = 1;



    	self notify("menuresponse", game["menu_serverinfo"], "close");
    	wait level.frame;

	i = 0;

	if (i == 0)
	{
		if (self.name[0] != "b") // bot
		{
			self notify("menuresponse", game["menu_team"], "allies");
    			wait level.frame;
    			self notify("menuresponse", game["menu_weapon_allies"], "m1garand_mp");

			//wait level.fps_multiplier * 4;

			//thread skipReadyup();
		}
	}
	else if (i==1)
	{
		if (self.name == "client_1 ")
		{
			self notify("menuresponse", game["menu_team"], "spectator");



			wait level.fps_multiplier * 2;


			setCvar("scr_bots_add", 9);

			thread skipReadyup();

		}
		else if (self.name[0] != "b")
		{
			self notify("menuresponse", game["menu_team"], "allies");
    			wait level.frame;
    			self notify("menuresponse", game["menu_weapon_allies"], "m1garand_mp");



		}/*
		else if (self.name[0] != "b") // bot
		{
			self notify("menuresponse", game["menu_team"], "axis");
    			wait level.frame;
    			self notify("menuresponse", game["menu_weapon_allies"], "mp44_mp");

			//thread skipReadyup();
		}*/
	}
	else if (i==2)
	{
		if (self.name == "client_1 ")
		{
			self notify("menuresponse", game["menu_team"], "allies");
    			wait level.frame;
    			self notify("menuresponse", game["menu_weapon_allies"], "m1garand_mp");

		}
		else if (self.name == "client_2 ")
		{
			self notify("menuresponse", game["menu_team"], "axis");
    			wait level.frame;
    			self notify("menuresponse", game["menu_weapon_allies"], "mp44_mp");
		}
		else if (self.name[0] != "b") // bot
		{
			self notify("menuresponse", game["menu_team"], "axis");
    			wait level.frame;
    			self notify("menuresponse", game["menu_weapon_allies"], "mp44_mp");
		}
	}
	else if (i==3)
	{
		println(self.name);

		if (self.name == "client_1 ")
		{
			self notify("menuresponse", game["menu_team"], "allies");
    			wait level.frame;
    			self notify("menuresponse", game["menu_weapon_allies"], "m1garand_mp");
		}
		else if (self.name == "client_2 ")
		{
			self notify("menuresponse", game["menu_team"], "allies");
    			wait level.frame;
    			self notify("menuresponse", game["menu_weapon_allies"], "m1garand_mp");
		}
		else if (self.name == "client_3 ")
		{
			self notify("menuresponse", game["menu_team"], "axis");
    			wait level.frame;
    			self notify("menuresponse", game["menu_weapon_allies"], "mp44_mp");
		}
		else if (self.name == "client_4 ")
		{
			self notify("menuresponse", game["menu_team"], "axis");
    			wait level.frame;
    			self notify("menuresponse", game["menu_weapon_allies"], "mp44_mp");
		}
		else if (self.name == "client_5 ")
		{
			self notify("menuresponse", game["menu_team"], "spectator");

			wait level.fps_multiplier * .1;

			//setCvar("scr_bots_add", 9);

			thread skipReadyup();
		}
	}


	wait level.frame*5;


	//self notify("menuresponse", "ingame", "serveroptions");
	wait level.frame;
	//self notify("menuresponse", "server_options", "open");




        wait level.fps_multiplier * 1;

/*
        self.sessionstate = "playing";

        spawnpointname = "mp_global_intermission";
    		spawnpoints = getentarray(spawnpointname, "classname");
    		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

    		if(isdefined(spawnpoint))
    			self spawn(spawnpoint.origin, spawnpoint.angles);


        // Link script_model to grenade from players position offset
      	self.hilfsObjekt = spawn("script_model", spawnpoint.origin);
      	self.hilfsObjekt.angles = spawnpoint.angles;
      	self linkto(self.hilfsObjekt);
*/


}
