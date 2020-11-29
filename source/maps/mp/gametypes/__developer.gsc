#include maps\mp\gametypes\_callbacksetup;

// This is called only if developer_script is set to 1
init()
{
	//setCvar("developer", 2);
    //setcvar("developer_script", 1); // keep set it to 1


  //addEventListener("onConnected",     ::onConnected);

		//thread skipReadyup();


		//level thread key();


	//level thread shot();

	//setCvar("testing", 1);

	//precacheShellShock("pain");

	//level thread fx();



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
	wait level.fps_multiplier * 5;

	if (level.in_readyup)
	{
		game["Do_Ready_up"] = 0;
		game["readyup_first_run"] = false;

		map_restart(true);
	}
}


showWaypoint()
{
	origin = self getOrigin();

	waypoint = newHudElem();

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

	waypoint destroy();
}


moving_obj(id)
{
	origin = self getOrigin();

	newobjpoint = newHudElem();
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
				players[p] setClientCvar("exec_cmd", "+attack; -attack");
				players[p] openMenu(game["menu_exec_cmd"]);		// open menu via script
				players[p] closeMenu();							// will only close menu opened by script


				players[p] setClientCvar("ui_match_round", level.ii);
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




onConnected()
{
	self endon("disconnect");
	//self thread obj();

	wait level.fps_multiplier * 1.2;


	self iprintln("ClientID: " + self getEntityNumber());

/*
	str = "set linedlouhystringjakokravavolesnadtoskousne1 1; set linedlouhystringjakokravavolesnadtoskousne2 2; set linedlouhystringjakokravavolesnadtoskousne3 3; set linedlouhystringjakokravavolesnadtoskousne4 4; set linedlouhystringjakokravavolesnadtoskousne5 5; set linedlouhystringjakokravavolesnadtoskousne6 6; set linedlouhystringjakokravavolesnadtoskousne7 7; set linedlouhystringjakokravavolesnadtoskousne8 8; set linedlouhystringjakokravavolesnadtoskousne9 9; set linedlouhystringjakokravavolesnadtoskousne10 10; set linedlouhystringjakokravavolesnadtoskousne11 11; set linedlouhystringjakokravavolesnadtoskousne12 12; set linedlouhystringjakokravavolesnadtoskousne4 4; set linedlouhystringjakokravavolesnadtoskousne5 5; set linedlouhystringjakokravavolesnadtoskousne6 6; set linedlouhystringjakokravavolesnadtoskousne7 7; set linedlouhystringjakokravavolesnadtoskousne8 8; set linedlouhystringjakokravavolesnadtoskousne9 9; set linedlouhystringjakokravavolesnadtoskousne9 9;";

	println(str.size);

	self setClientCvar("toexec", str);*/



/*
self setClientCvar("cl_maxpackets", "1");

	self setClientCvar("exec_cmd", "+right; +forward; +moveleft; +leanleft; cl_yawspeed 50; cg_thirdperson 3");
	self openMenu(game["menu_exec_cmd"]);
	self closeMenu();
*/
/*
	i = 1;
  s = "";

	while (i <= 24)
  {
    if ((i % 2) == 0)
  	   self setClientCvar("ui_scoreboard_line_"+i, "1");
    else
       self setClientCvar("ui_scoreboard_line_"+i, "2");

    s += i+"\n";

    i++;
  }

	self setClientCvar("ui_scoreboard_line_11", "^8Allies line 11");
  self setClientCvar("ui_scoreboard_line_14", "^9Axis line 14");

  self setClientCvar("ui_scoreboard_names", "###\n###\n###\n###\n###\n###\n###\n###\n###\n###\n###\n###\n###\n###\n###\n###\n###\n###\n###\n###\n");
	self setClientCvar("ui_scoreboard_scores", s);
	self setClientCvar("ui_scoreboard_kills", "aaa\nbbb\nccc\nddd\neee\nfff\nggg\nhhh\niii\njjj\naaa\nbbb\nccc\nddd\neee\nfff\nggg\nhhh\niii\njjj\n");
	self setClientCvar("ui_scoreboard_damages", "111\n222\n333\n444\n555\n666\n777\n888\n999\n000\n");
	self setClientCvar("ui_scoreboard_deaths", "111\n222\n333\n444\n555\n666\n777\n888\n999\n000\n");
	self setClientCvar("ui_scoreboard_plants", "111\n222\n333\n444\n555\n666\n777\n888\n999\n000\n");
	self setClientCvar("ui_scoreboard_defuses", "111\n222\n333\n444\n555\n666\n777\n888\n999\n000\n");

*/

  //self [[level.spawnIntermission]]();





	if (isDefined(self.pers["_temp_"]))
		return;




		//self closeMenu();
		//self closeInGameMenu();


		self.pers["_temp_"] = true;




	        //wait level.fps_multiplier * 0.3;

	    	self notify("menuresponse", game["menu_serverinfo"], "close");
	    	wait level.frame;


/*
				iprintln("############################################################################");
				iprintln("-"+self.name+"-");
				iprintln(self.name.size);
				iprintln("############################################################################");
*/

				if (self.name == "client_1 ")
				{
					self notify("menuresponse", game["menu_team"], "allies");
		    	wait level.frame;
		    	self notify("menuresponse", game["menu_weapon_allies"], "m1garand_mp");
				}
				else
				{
					self notify("menuresponse", game["menu_team"], "axis");
		    	wait level.frame;
		    	self notify("menuresponse", game["menu_weapon_allies"], "mp44_mp");
				}




	        wait level.frame*5;



					//self openMenu(game["menu_scoreboard"]);

/*

					body = self ClonePlayer(300000);

          body setcontents(1);

          body thread bodythread1();
          body thread bodythread2();

          //body SetLookAtEnt(self);


          entitiy = false;
          for (;;)
          {
            forward = anglestoforward(self getplayerangles());

            if (self IsLookingAt(body))
            {
              self iprintln("Our body!");
            }



            ForwardTrace = Bullettrace(self getEye(),self getEye()+(forward[0]*100000, forward[1]*100000, forward[2]*100000),true,self);

            if (isDefined(ForwardTrace["entity"]))
            {
              if (!entitiy)
              {
                if (ForwardTrace["entity"] == body)
                {
                  self iprintln("Out body!");
                }

                //entitiy = true;
              }
            }
            else
              entitiy = false;

            wait level.fps_multiplier * 0.2;
          }
*/

				self.pers["killer"] = 1;


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




	        //thread maps\mp\gametypes\_hud::ScoreBoard(true);
	        //thread maps\mp\gametypes\_hud::NextRound(10000);
	        //thread maps\mp\gametypes\_hud::TeamSwap();
	        //thread maps\mp\gametypes\_hud::Timeout();
	        //thread maps\mp\gametypes\_hud::Matchover();

}
