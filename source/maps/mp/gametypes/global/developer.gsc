#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("debug_shotgun", "BOOL", false);
	registerCvar("debug_pronepeek", "BOOL", false);
	registerCvar("debug_spectator", "BOOL", false);
	registerCvar("debug_fastreload", "BOOL", false);
	registerCvar("debug_handhitbox", "BOOL", false);
	registerCvar("debug_torsohitbox", "BOOL", false);

	//thread scvar();

	// This is called only if developer_script is set to 1
	/#
  	//addEventListener("onConnected",     ::onConnected);
	//addEventListener("onConnected",     ::onConnected2);
	//addEventListener("onConnected",     ::onConnected3);
	//addEventListener("onConnected",     ::onConnected4);
	//addEventListener("onConnected",     ::bash_trace_debug);

	//level thread measuring_test();
	//level thread measuring_test2();

/*
	if (!isDefined(game["developer_add_bots"]))
	{
		wait level.fps_multiplier * 3.5;
		setCvar("scr_bots_add", 9);
		setCvar("scr_sd_roundlength", 10);
		setCvar("scr_sd_PlantTime", 1);
		//setCvar("scr_sd_strat_time", 1);
		wait level.fps_multiplier * 3.5;
		thread skipReadyup();

		game["developer_add_bots"] = true;
	}
*/

/*

	underAroof1 = spawn("script_model",(1506, 2213, 115));
	underAroof1.angles = (51, 328, 90);
	underAroof1 setmodel("xmodel/toujane_underA_bug");
*/


	//thread shot();

	//thread executeSync();

	//thread bots();

	//thread spect_menu();


/*
	level.aa = spawn("script_model",(81, 1355, 52));
	level.aa.angles = (0, 0, 0);
	level.aa setmodel("xmodel/toujane_jump");

	level.aa setcontents(1);*/

	//level.aa solid();

	#/
}


scvar()
{
	for (;;)
	{
		// Version
		value = "1";

		// Time
		value = value + "|" + gettime();

		// Players
		players = getentarray("player", "classname");

		for(p = 0; p < players.size; p++)
		{
			player = players[p];

			value = value + "|";
			value = value + p;
			//value = value + "," + ;
			value = value + "," + player.name;
		}

		setCvar("_stream", value);

		for(p = 0; p < players.size; p++)
		{
			player = players[p];

			if (player.pers["team"] != "streamer")
			{
				player setClientCvar("_stream", "");
			}
		}

		wait level.frame;
	}
}



bash_trace_debug()
{
	self endon("disconnect");

	traceOffsets = [];
	traceOffsets[0][0] = 0;
	traceOffsets[0][1] = 0;
	traceOffsets[1][0] = 1;
	traceOffsets[1][1] = 1;
	traceOffsets[2][0] = 1;
	traceOffsets[2][1] = -1;
	traceOffsets[3][0] = -1;
	traceOffsets[3][1] = 1;
	traceOffsets[4][0] = -1;
	traceOffsets[4][1] = -1;

	while(1)
	{
		wp = spawnstruct();

		//wp.weapDef = BG_GetWeaponDef(ent->s.weapon);

		//G_GetPlayerViewOrigin(ent, wp.muzzleTrace);
		wp.muzzleTrace = self maps\mp\gametypes\global\player::getEyeOrigin();

		//G_GetPlayerViewDirection(ent, wp.forward, wp.right, wp.up);
		angles = self getPlayerAngles();
		wp.forward = anglestoforward(angles);
		wp.right = anglestoright(angles);
		wp.up = anglestoup(angles);

		/* Weapon_Melee(
		    ent,
		    &wp,
		    player_meleeRange->current.decimal,
		    player_meleeWidth->current.decimal,
		    player_meleeHeight->current.decimal);*/

		range = getcvarint("player_meleeRange");
		width = getcvarint("player_meleeWidth");
		height = getcvarint("player_meleeHeight");

		if ( width > 0.0 || height > 0.0 )
			numTraces = 5;
		else
			numTraces = 1;



		for (i = 0; i < numTraces; i++)
		{
			end = undefined;

			//VectorMA(wp->muzzleTrace, range, wp->forward, end);
			end[0] = (wp.muzzleTrace)[0] + (wp.forward)[0] * (range);
			end[1] = (wp.muzzleTrace)[1] + (wp.forward)[1] * (range);
			end[2] = (wp.muzzleTrace)[2] + (wp.forward)[2] * (range);

			widthScale = width * traceOffsets[i][0];

			//VectorMA(end, widthScale, wp->right, end);
			end[0] = (end)[0] + (wp.right)[0] * (widthScale);
			end[1] = (end)[1] + (wp.right)[1] * (widthScale);
			end[2] = (end)[2] + (wp.right)[2] * (widthScale);

			heightScale = height * traceOffsets[i][1];

			//VectorMA(end, heightScale, wp->up, end);
			end[0] = (end)[0] + (wp.up)[0] * (heightScale);
			end[1] = (end)[1] + (wp.up)[1] * (heightScale);
			end[2] = (end)[2] + (wp.up)[2] * (heightScale);

			end = (end[0], end[1], end[2]);

			//G_LocationalTrace(traceResult, wp->muzzleTrace, end, ent->s.number, 41953329, bulletPriorityMap);
			traceResult = Bullettrace(wp.muzzleTrace, end, true, self); // BulletTrace( <start>, <end>, <hit characters>, <ignore entity> )

			//Vec3Lerp(wp->muzzleTrace, end, traceResult->fraction, hitOrigin);
			hitOrigin = undefined;
			hitOrigin[0] = (end[0] - wp.muzzleTrace[0]) * traceResult["fraction"] + wp.muzzleTrace[0];
			hitOrigin[1] = (end[1] - wp.muzzleTrace[1]) * traceResult["fraction"] + wp.muzzleTrace[1];
			hitOrigin[2] = (end[2] - wp.muzzleTrace[2]) * traceResult["fraction"] + wp.muzzleTrace[2];

			hitOrigin = (hitOrigin[0], hitOrigin[1], hitOrigin[2]);

			if (!isDefined(self.bashPoints)) self.bashPoints = [];
			if (!isDefined(self.bashPoints[i]))
			{
				self.bashPoints[i] = spawn("script_origin",(0,0,0));
				self.bashPoints[i] thread maps\mp\gametypes\global\developer::showWaypoint();
			}
			self.bashPoints[i].origin = hitOrigin;

			if (traceResult["fraction"] != 1.0)
				self.bashPoints[i].scale = 4; // hit
			else
				self.bashPoints[i].scale = 1;

			//iprintln(i + ": " + traceOffsets[i][0] + "  " + traceOffsets[i][1]);
		}

		//iprintln("---------");

		//wait level.fps_multiplier * 1;
		wait level.frame;
	}

	return 0;
}



onConnected4()
{
	self endon("disconnect");

	setcvar("client", -1);

	wait level.fps_multiplier * 1;

/*
	for(;;)
	{
		self setClientCvarIfChanged("ui_serverinfo_hud",
		"self.spectatorclient = " + self.spectatorclient + "\n" +
		"self.sessionstate = " + self.sessionstate + "\n" +
		"level.streamerSystem_playerID = " + level.streamerSystem_playerID + "\n" +
		"self.streamerSystem_turnedOn = " + self.streamerSystem_turnedOn + "\n" +
		"self.streamerSystem_freeSpectating = " + self.streamerSystem_freeSpectating + "\n" +
		"self.streamerSystem_inCinematic = " + self.streamerSystem_inCinematic + "\n" +
		"level.streamerSystem_playerID = " + level.streamerSystem_playerID + "\n" +
		"level.streamerSystem_auto_runThreads = " + level.streamerSystem_auto_runThreads + "\n" +

		"");

		wait level.frame;
	}
*/
}

onConnected3()
{
	self endon("disconnect");

	for(;;)
	{
		if (self.isMoving)
		{
			self iprintln("sending...");

			self ShowScoreBoard();
			//self UpdateScores();
		}
		wait level.frame;
	}
}


onConnected2()
{
	self endon("disconnect");

	wait level.fps_multiplier * 1;

	//self thread what();

	if (1)
	return;

	id = self getEntityNumber();


	arr[0] = "pelvis";
	arr[1] = "j_hip_le";
	arr[2] = "j_hip_ri";
	arr[3] = "j_spine1";
	arr[4] = "j_knee_le";
	arr[5] = "j_knee_ri";
	arr[6] = "back_up";
	arr[7] = "j_head";
	arr[8] = "j_shoulder_le";
	arr[9] = "j_shoulder_ri";
	arr[10] = "j_elbow_le";
	arr[11] = "j_elbow_ri";
	arr[12] = "j_wrist_le";
	arr[13] = "j_wrist_ri";
	arr[14] = "tag_eye";
/*
	if (id == 1)
	{
		for (j = 0; j < arr.size; j++)
		{
			self.tTag[j] = spawn("script_origin",(0,0,0));
			self.tTag[j] thread maps\mp\gametypes\global\developer::showWaypoint();
		}
	}*/

	for(;;)
	{
		waittillframeend;
		waittillframeend;
/*
		if (id == 1)
		{
			for (j = 0; j < arr.size; j++)
			{
				self.tTag[j] unlink();
				self.tTag[j] linkto (self, arr[j],(0,0,0),(0,0,0));

			}
		}
*/

		if (id == 0)
		{
			p = GetEntityByClientId(1);

			if (isDefined(p))
			{

				eye = self maps\mp\gametypes\global\player::getEyeOrigin();
				trace = Bullettrace(eye, p.headTag getOrigin(), true, self);

				self sayall("Head visible: " + (isDefined(trace["entity"]) && trace["entity"] == p) + "  isLookingAt:" + self islookingat( p ) );
			}

		}
		else if (id == 1)
		{
			p = GetEntityByClientId(0);

			//if (isDefined(p))
				//self sayall( self islookingat( p ) );
		}

		//self showscoreboard();

		//self setentertime(555);



		wait 0.000001;
	}




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
		case "debug_torsohitbox": 	level.debug_torsohitbox = value; return true;

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




measuring_test()
{
	level.i1 = 0;
	time = gettime();
	for (i = 0; ; i++)
	{
		//if (isDefined(level.fps_multiplier))	println(gettime() + " test> frame " + i + "  sv_fps:" + getcvar("sv_fps") + "  fps_mult:" + level.fps_multiplier + "  frame:" + level.frame);
		//else					println(gettime() + " test> frame " + i + "  sv_fps:" + getcvar("sv_fps"));

		wait level.frame;

		//println(gettime() + "  " + i);

		if (gettime() - time != level.frame * 1000)
		{
			println("Time " + (gettime() - time));
		}

		level.i1 = i;

		time = gettime();
	}
}


measuring_test2()
{
	level.i2 = 0;
	time = gettime();
	for (i = 0; ; i++)
	{
		//if (isDefined(level.fps_multiplier))	println(gettime() + " test2> frame " + i + "  sv_fps:" + getcvar("sv_fps") + "  fps_mult:" + level.fps_multiplier + "  frame:" + level.frame);
		//else					println(gettime() + " test2> frame " + i + "  sv_fps:" + getcvar("sv_fps"));

		if (isDefined(level.frame))
			wait level.frame;
		else
			wait 0.000001;

		level.i2 = i;
/*
		if (level.i1 - level.i2 > 1)
		{
			println("Mismatch i1 != i2  " + level.i1 + " != " + level.i2);
		}
*/
		if (gettime() - time != level.frame * 1000)
		{
			println("Time " + (gettime() - time));
		}

		time = gettime();
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


showWaypoint(player, size)
{
	origin = self.origin;
	if (isPlayer(self))
		origin = self getOrigin();

	if (!isDefined(size))
		size = 2;

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
	self.waypoint.archived = false;
	if (isDefined(self.waypoint_color)) self.waypoint.color = self.waypoint_color;
	self.waypoint setShader("objpoint_default", size, size);
	self.waypoint setwaypoint(true);
	self.waypoint.scale = size;

	for (;;)
	{
		wait 0.0000001; // wait a frame
		waittillframeend;
		waittillframeend;
		waittillframeend;
		waittillframeend;

		if (!isDefined(self))
			break;

		origin = self.origin;
		if (isPlayer(self))
			origin = self getOrigin();

		if (!isDefined(self.waypoint))
			return;

		self.waypoint.x = origin[0];
		self.waypoint.y = origin[1];
		self.waypoint.z = origin[2];

		if (size != self.waypoint.scale)
		{
			size = self.waypoint.scale;
			self.waypoint setShader("objpoint_default", size, size);
		}
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


				player setClientCvar2("ui_quickmessage_streamer", "1");



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

executeSync()
{
	level.ii = 0;
	for(;;)
	{
		wait level.frame;

		if (getCvar("run") != "")
		{
			players = getentarray("player", "classname");
			for(p = 0; p < players.size; p++)
			{
				// Exec command on client side
				// If some menu is already opened:
				//	- by player (by ESC command) -> it will work well over already opened menu
				//  - by script (via openMenu()) -> that menu will be closed and exec_cmd will not be closed correctly
				//			(mouse will be visible with clear backgorund.... so closeMenu() is called to close that menu)
				players[p] setClientCvar2("exec_cmd", "vstr exec");
				players[p] openMenu(game["menu_exec_cmd"]);		// open menu via script
				players[p] closeMenu();

			}

			setcvar("run", "");
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








showKill(deadPlayer, psOffsetTime)
{
	self endon("disconnect");
	self endon("spawned");

	time = gettime();

	wait level.fps_multiplier * 2;

	selfNum = self getEntityNumber();


	// Allow spectating all in killcam
	self.skip_setspectatepermissions = true;	// ignore spectate permissions
	self allowSpectateTeam("allies", true);
	self allowSpectateTeam("axis", true);
	self allowSpectateTeam("freelook", true);
	self allowSpectateTeam("none", true);

self.killcam = true;


if(!isdefined(self.kc_topbar))
{
	self.kc_topbar = newClientHudElem(self);
	self.kc_topbar.archived = false;
	self.kc_topbar.x = 0;
	self.kc_topbar.y = 0;
	self.kc_topbar.horzAlign = "fullscreen";
	self.kc_topbar.vertAlign = "fullscreen";
	self.kc_topbar.alpha = 0.5;
	self.kc_topbar.sort = 99;
	self.kc_topbar setShader("black", 640, 100);
}

if (!isDefined(self.hit_Tag))
{
	self.hit_Tag = spawn("script_origin",(0,0,0));
	self.hit_Tag thread maps\mp\gametypes\global\developer::showWaypoint();
}

self.hit_Tag.origin = self.lastHitPoint;



	pastTime = (gettime() - time) / 1000 + 1.0;

	self.sessionstate = "spectator";
	self.spectatorclient = selfNum;
	self.archivetime = pastTime;
	self.psoffsettime = psOffsetTime;	// for antilag


	wait level.fps_multiplier * 1;

	frame = 0;
	adjOffset = 0;

	attack = false;
	use = false;

	for(;;)
	{
		pastTime = (gettime() - time);

		miss = (1000 * frame / level.sv_fps - int(1000 / level.sv_fps) * frame);

		iprintln(int(1000 / level.sv_fps) + "   " + miss);

		//self.sessionstate = "spectator";
		//self.spectatorclient = selfNum;
		self.archivetime = (pastTime + miss - (adjOffset * 1000/level.sv_fps)) / 1000;
		//self.psoffsettime = psOffsetTime;	// for antilag

		//if ((gettime() - time) > 10000)
		//	break;


		if(self attackButtonPressed())
		{
			if (attack == false)
				adjOffset++;
			attack = true;
		}
		else
			attack = false;


		if(self useButtonPressed())
		{
			if (use == false)
				adjOffset--;
			use = true;
		}
		else
			use = false;

		if(self meleeButtonPressed())
			break;

		frame++;

		wait .000001; // wait frame
	}

	if(isDefined(self.kc_topbar))
		self.kc_topbar destroy();

self.killcam = undefined;
	self.sessionstate = "playing";
	self.archivetime = 0;
	self.psoffsettime = 0;
}



debugToEyza(str)
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		 if (maps\mp\gametypes\global\string::contains(players[i].name, "eyza") || maps\mp\gametypes\global\string::contains(players[i].name, "EYZA"))
		 {
			 players[i] iprintln(str);
			 return;
		 }
	}
}








testTime1()
{
	time1 = getTime();

	wait level.fps_multiplier * 50;

	iprintln("50sec test: " + (getTime() - time1));
}
testTime2()
{
	level.diff = 0;

	timeLast = getTime();

	for(;;)
	{
		wait 0.00000001; // wait 1 frame

		level.diff = getTime() - timeLast;



		timeLast = getTime();
	}
}
testTime3()
{
	for(;;)
	{

		wait level.fps_multiplier * 1;

		iprintln(level.diff);
	}
}


angledebug()
{
	for (;;)
	{
		if (getcvar("g_debugAngle") == "1")
		{
			self_num = self getEntityNumber();

			if (self_num == 0)
			{
				eAttacker = GetEntityByClientId(1);
			}
			else if (self_num == 1)
			{
				eAttacker = GetEntityByClientId(0);
			}
			else
				return;



			// Debug angle
			if (isDefined(eAttacker) && isPlayer(eAttacker))
			{
				angleDiff = angleDiff(self, eAttacker);
				self iprintln("Hit angle:"+int(anglediff*10)/-10+"");
			}
		}

		wait level.fps_multiplier * .5;
	}
}

angleDiff(player, eAttacker)
{
	myAngle = player.angles[1]; // -180 <-> +180
	myAngle += 180; // flip direction, now in range 0 <-> 360
	if (myAngle > 180) myAngle -= 360; // back to range -180 <-> +180

	enemyAngle = eAttacker.angles[1];

	anglediff = myAngle - enemyAngle;
	if (anglediff > 180)		anglediff -= 360;
	else if (anglediff < -180)	anglediff += 360;

	//iprintln(anglediff);

	return anglediff;
}


aaak()
{
	level.aa_array = [];
	level.aa_offset = 0;
	self.waypoints = [];

	for (i = 0; i < 12; i++)
	{
		if (!isDefined((self.waypoints[i])))
		{
			self.waypoints[i] = newHudElem();
			self.waypoints[i].alpha = .4;
			self.waypoints[i].archived = true;
			self.waypoints[i] setShader("objpoint_default", 2, 2);
			self.waypoints[i] setwaypoint(true);
		}
		level.aa_array[i] = (0,0,0);
	}

	for(;;)
	{
		wait 0.00001;
		waittillframeend;
		waittillframeend;
		waittillframeend;

		level.aa_array[level.aa_offset] = self getOrigin();

		level.aa_offset++;

		if (level.aa_offset >= 12)
		{
			level.aa_offset = 0;
		}

		for (i = level.aa_offset; i < 12; i++)
			update(i);
		for (i = 0; i < level.aa_offset; i++)
			update(i);
	}
}

update(i)
{
	self.waypoints[i].x = level.aa_array[i][0];
	self.waypoints[i].y = level.aa_array[i][1];
	self.waypoints[i].z = level.aa_array[i][2];
}


onConnected()
{
	self endon("disconnect");

	//if (1)	return;

	if (game["state"] == "intermission")
		return;

	wait level.fps_multiplier * 1.0;



	//self iprintln("ClientID: " + self getEntityNumber());

	if (isDefined(self.pers["_temp_"]))
		return;
	self.pers["_temp_"] = true;


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
		}
		if (self.name == "client_1 ")
		{
			setCvar("scr_sd_roundlength", 10);
			setCvar("scr_sd_PlantTime", 1);
			setCvar("scr_sd_strat_time", 10);

			wait level.fps_multiplier * 3.5;

			thread skipReadyup();
		}
	}
	else if (i==1)
	{
		if (self.name == "client_1 ")
		{
			self notify("menuresponse", game["menu_team"], "streamer");

			setCvar("scr_bots_add", 9);
			setCvar("scr_sd_roundlength", 10);
			setCvar("scr_sd_PlantTime", 1);
			//setCvar("scr_sd_strat_time", 1);


			wait level.fps_multiplier * 3.5;




			thread skipReadyup();

		}
		else if (self.name == "client_3 ")
		{
			self notify("menuresponse", game["menu_team"], "axis");
    			wait level.frame;
    			self notify("menuresponse", game["menu_weapon_allies"], "mp44_mp");

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

			wait level.fps_multiplier * 0.5;

			thread skipReadyup();

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

}
