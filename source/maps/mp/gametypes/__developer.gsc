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


obj()
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

		self.pers["_temp_"] = true;

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
