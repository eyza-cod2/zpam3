#include maps\mp\gametypes\_callbacksetup;

// This is called only if developer_script is set to 1
init()
{
	//setCvar("developer", 2);
    //setcvar("developer_script", 1); // keep set it to 1


    //addEventListener("onConnected",     ::onConnected);


	//level thread shot();

	//setCvar("testing", 1);

	//precacheShellShock("pain");

	//level thread fx();

	//thread skipReadyup();

	//level thread trig();



/*
	j = 0;
	/#
	for (i = 0; i < 1024; i++)
	{
		entity = GetEntByNum( i );

		if (isDefined(entity) && isDefined(entity.origin))
		{
			underAroof1 = spawn("script_model", entity.origin);
			//underAroof1.angles = (0, 58, 0);
			underAroof1 setmodel("xmodel/caen_fence_post_1");

			j++;
		}
	}

	println(j);
	#/
*/

	// spawn( "trigger_radius", position, spawn flags, radius, height )
	//tree_collision = spawn("trigger_radius", (3002, 1973, 130), 0, 35, 5); // truck right
	//tree_collision setcontents(1);
/*
	tree_collision = spawn("trigger_radius", (3011, 1946, 130), 0, 35, 5); // truck left
	tree_collision setcontents(1);
*/
	// 152 = bedna nahore
	// 84  = track podlaha



/*

	underAroof1 = spawn("script_model",(1506, 2213, 115));
	underAroof1.angles = (51, 328, 90);
	underAroof1 setmodel("xmodel/toujane_underA_bug");
*/



	//setCvar("id", 1);


/*

	tree_collision = spawn("trigger_radius", (2987, 1948, 106), 0, 50, 40); // under a roof bug 2. stair top
	tree_collision setcontents(1);

	tree_collision thread moving_obj("1");
*/

	setcvar("sg_debug", "0");
}

potencionalInfiniteLoopTest()
{
	for(i = 0; i < 10000; i++)
	{
		wait level.fps_multiplier * 0.1;

		println("a");
	}
}

skipReadyup()
{
	wait level.fps_multiplier * 7;

	if (level.in_readyup)
	{
		game["Do_Ready_up"] = 0;
		level.in_readyup = 0;
		map_restart(true);
	}
}


moving_obj(id)
{
	origin = self getOrigin();

	newobjpoint = newHudElem();
	newobjpoint.name = "A";
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

shot()
{
	for(;;)
	{
		wait level.frame;

		if (getCvar("shot") != "")
		{
			players = getentarray("player", "classname");
			for(p = 0; p < players.size; p++)
			{
				players[p] setClientCvar("exec_cmd", "+attack; -attack");
				players[p] openMenu(game["menu_exec_cmd"]);
				players[p] closeMenu();
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




onConnected()
{

	//self thread obj();

	wait level.fps_multiplier * 1;
/*
self setClientCvar("cl_maxpackets", "1");

	self setClientCvar("exec_cmd", "+right; +forward; +moveleft; +leanleft; cl_yawspeed 50; cg_thirdperson 3");
	self openMenu(game["menu_exec_cmd"]);
	self closeMenu();
*/




	if (isDefined(self.pers["_temp_"]))
		return;

		//self closeMenu();
		//self closeInGameMenu();


		self.pers["_temp_"] = true;


return;

	        wait level.fps_multiplier * 0.3;

	    	self notify("menuresponse", game["menu_serverinfo"], "close");
	    	wait level.frame;

	    	self notify("menuresponse", game["menu_team"], "allies");
	    	wait level.frame;
	    	self notify("menuresponse", game["menu_weapon_allies"], "m1garand_mp");


	        wait level.frame;

				self.pers["killer"] = 1;


	    	//self notify("menuresponse", "ingame", "serveroptions");
	        wait level.frame;
	    	//self notify("menuresponse", "server_options", "open");


	        //thread maps\mp\gametypes\_hud::ScoreBoard(true);
	        //thread maps\mp\gametypes\_hud::NextRound(10000);
	        //thread maps\mp\gametypes\_hud::TeamSwap();
	        //thread maps\mp\gametypes\_hud::Timeout();
	        //thread maps\mp\gametypes\_hud::Matchover();

}
