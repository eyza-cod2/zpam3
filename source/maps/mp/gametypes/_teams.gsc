#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("scr_teambalance", "INT", 0); 	        // Auto Team Balancing - number of difference between number of players // NOTE: restart needed


	addEventListener("onStartGameType", 	::onStartGameType);
	addEventListener("onConnected",    	::onConnected);
    	addEventListener("onDisconnect",    	::onDisconnect);
    	addEventListener("onJoinedAlliesAxis",  ::onJoinedAlliesAxis);
        addEventListener("onJoinedSpectator",   ::onJoinedSpectator);
	addEventListener("onJoinedStreamer",  ::onJoinedStreamer);
}


// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_teambalance": 	level.scr_teambalance = value; return true;
	}
	return false;
}

// Called after the <gametype>.gsc::main() and <map>.gsc::main() scripts are called
// At this point game specific variables are defined (like game["allies"], game["axis"], game["american_soldiertype"], ...)
// Called again for every round in round-based gameplay
onStartGameType()
{
	if (game["firstInit"])
	{
		precacheString(&"MP_AMERICAN");
		precacheString(&"MP_BRITISH");
		precacheString(&"MP_RUSSIAN");

		switch(game["allies"])
		{
			case "american":
				precacheShader("mpflag_american");
				break;

			case "british":
				precacheShader("mpflag_british");
				break;

			case "russian":
				precacheShader("mpflag_russian");
				break;
		}

		assert(game["axis"] == "german");
		precacheShader("mpflag_german");
		precacheShader("mpflag_spectator");
	}

	level.teambalancetimer = 0;

	// Precache players character models
	setPlayerModels();

	// Monitor teams for rebalance
	thread watchBalance();
}


onConnected()
{
	self endon("disconnect");

	// Wait till response about downloaded mod from player is received - we know player is not in lag
	while (!self.pers["modDownloaded"])
		wait level.frame;

	self updateAutoAssignCvar();
	level thread updateTeamChangeCvars();
}

onDisconnect()
{
	// Fixed bug, when max team limit is reached and player disconnect, other players was unable to select team
	level thread updateTeamChangeCvars();
}

onJoinedAlliesAxis()
{
	self updateTeamTime();

	self updateAutoAssignCvar();
	level thread updateTeamChangeCvars();
}

onJoinedSpectator()
{
	self.pers["teamTime"] = undefined;

	self updateAutoAssignCvar();
	level thread updateTeamChangeCvars();
}

onJoinedStreamer()
{
	self.pers["teamTime"] = undefined;

	self updateAutoAssignCvar();
	level thread updateTeamChangeCvars();
}



watchBalance()
{
	if(level.gametype != "dm")
	{
		level.teamlimit = level.maxclients / 2;

		wait level.fps_multiplier * .15;

		if(level.gametype == "sd")
		{
			if(level.scr_teambalance > 0)
			{
		    	if(isdefined(game["BalanceTeamsNextRound"]))
		    		iprintlnbold(&"MP_AUTOBALANCE_NEXT_ROUND");

				level waittill("restarting"); // called at the end of the sd round

				if(isdefined(game["BalanceTeamsNextRound"]))
				{
					level balanceTeams();
					game["BalanceTeamsNextRound"] = undefined;
				}
				else if(!getTeamBalance())
					game["BalanceTeamsNextRound"] = true;
			}
		}
		else
		{
			for(;;)
			{
				if(level.scr_teambalance > 0)
				{
					if(!getTeamBalance())
					{
						iprintlnbold(&"MP_AUTOBALANCE_SECONDS", 15);
					    	wait level.fps_multiplier * 15;

						if(!getTeamBalance())
							level balanceTeams();
					}

					wait level.fps_multiplier * 59;
				}

				wait level.fps_multiplier * 1;
			}
		}
	}
}






updateTeamTime()
{
	if(level.gametype == "sd")
		self.pers["teamTime"] = game["timepassed"] + ((getTime() - level.starttime) / 1000) / 60.0;
	else
		self.pers["teamTime"] = (gettime() / 1000);
}



getTeamBalance()
{
	level.team["allies"] = 0;
	level.team["axis"] = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(players[i].pers["team"] == "allies")
			level.team["allies"]++;
		else if(players[i].pers["team"] == "axis")
			level.team["axis"]++;
	}

	if((level.team["allies"] > (level.team["axis"] + level.scr_teambalance)) || (level.team["axis"] > (level.team["allies"] + level.scr_teambalance)))
		return false;
	else
		return true;
}

balanceTeams()
{
	iprintlnbold(&"MP_AUTOBALANCE_NOW");
	//Create/Clear the team arrays
	AlliedPlayers = [];
	AxisPlayers = [];

	// Populate the team arrays
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(!isdefined(players[i].pers["teamTime"]))
			continue;

		if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
			AlliedPlayers[AlliedPlayers.size] = players[i];
		else if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "axis"))
			AxisPlayers[AxisPlayers.size] = players[i];
	}

	MostRecent = undefined;

	while((AlliedPlayers.size > (AxisPlayers.size + 1)) || (AxisPlayers.size > (AlliedPlayers.size + 1)))
	{
		if(AlliedPlayers.size > (AxisPlayers.size + 1))
		{
			// Move the player that's been on the team the shortest ammount of time (highest teamTime value)
			for(j = 0; j < AlliedPlayers.size; j++)
			{
				if(isdefined(AlliedPlayers[j].dont_auto_balance))
					continue;

				if(!isdefined(MostRecent))
					MostRecent = AlliedPlayers[j];
				else if(AlliedPlayers[j].pers["teamTime"] > MostRecent.pers["teamTime"])
					MostRecent = AlliedPlayers[j];
			}

			// Join axis
			MostRecent [[level.axis]]();
			MostRecent updateTeamTime();
		}
		else if(AxisPlayers.size > (AlliedPlayers.size + 1))
		{
			// Move the player that's been on the team the shortest ammount of time (highest teamTime value)
			for(j = 0; j < AxisPlayers.size; j++)
			{
				if(isdefined(AxisPlayers[j].dont_auto_balance))
					continue;

				if(!isdefined(MostRecent))
					MostRecent = AxisPlayers[j];
				else if(AxisPlayers[j].pers["teamTime"] > MostRecent.pers["teamTime"])
					MostRecent = AxisPlayers[j];
			}

			// Join allies
			MostRecent [[level.allies]]();
			MostRecent updateTeamTime();
		}

		MostRecent = undefined;
		AlliedPlayers = [];
		AxisPlayers = [];

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
				AlliedPlayers[AlliedPlayers.size] = players[i];
			else if((isdefined(players[i].pers["team"])) &&(players[i].pers["team"] == "axis"))
				AxisPlayers[AxisPlayers.size] = players[i];
		}
	}
}


// Called when level.allies or level.axis menu function is called
getJoinTeamPermissions(team)
{
	if (game["state"] == "intermission")
		return false;
	if (level.in_readyup)
		return true;

	teamcount = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		// If team is team we want, count it
		if(player.pers["team"] == team)
			teamcount++;
	}

	if(teamcount < level.teamlimit)
		return true;
	else
		return false;
}

// Visibility of Change Team -> American | German
// Called onConnect, onJoinspectator, onJoinTeam
/*level*/
updateTeamChangeCvars()
{
	waittillframeend; // wait until player is fully connected / disconnected / spawned

	players = CountPlayers();

	// 0 - invisible, 1 - visible, 2 - visible not clickable
	joinallies = 2;
	joinaxis = 2;

	if(level.in_readyup || level.gametype == "dm" || level.gametype == "strat" || level.maxclients < 2)
	{
		joinallies = 1; // 0 - invisible, 1 - visible, 2 - visible not clickable
		joinaxis = 1;
	}
	else
	{
		if(players["allies"] < level.teamlimit)
			joinallies = 1;

		if(players["axis"] < level.teamlimit)
			joinaxis = 1;
	}

	players = getentarray("player", "classname");

	for(i = 0; i < players.size; i++)
	{
		player = players[i];


		if(player.pers["team"] == "allies")
		{
			if(!isdefined(player.allow_joinallies) || player.allow_joinallies != 2)
			{
				player.allow_joinallies = 2;
				player setClientCvar2("ui_allow_joinallies", player.allow_joinallies);
			}

			if(!isdefined(player.allow_joinaxis) || player.allow_joinaxis != joinaxis)
			{
				player.allow_joinaxis = joinaxis;
				player setClientCvar2("ui_allow_joinaxis", player.allow_joinaxis);
			}
		}
		else if(player.pers["team"] == "axis")
		{
			if(!isdefined(player.allow_joinallies) || player.allow_joinallies != joinallies)
			{
				player.allow_joinallies = joinallies;
				player setClientCvar2("ui_allow_joinallies", player.allow_joinallies);
			}

			if(!isdefined(player.allow_joinaxis) || player.allow_joinaxis != 2)
			{
				player.allow_joinaxis = 2;
				player setClientCvar2("ui_allow_joinaxis", player.allow_joinaxis);
			}
		}
		else // spectator, streamer, none
		{
			if(!isdefined(player.allow_joinallies) || player.allow_joinallies != joinallies)
			{
				player.allow_joinallies = joinallies;
				player setClientCvar2("ui_allow_joinallies", player.allow_joinallies);
			}

			if(!isdefined(player.allow_joinaxis) || player.allow_joinaxis != joinaxis)
			{
				player.allow_joinaxis = joinaxis;
				player setClientCvar2("ui_allow_joinaxis", player.allow_joinaxis);
			}
		}


		player setClientCvar2("ui_allow_joinstreamer", level.streamerSystem);
	}
}

updateAutoAssignCvar()
{
	// If we are in allies or axis team, disable auto-assing
	if(self.pers["team"] == "allies" || self.pers["team"] == "axis")
		self setClientCvar2("ui_allow_joinauto", "2"); // disable
	else
		self setClientCvar2("ui_allow_joinauto", "1"); // enable
}



setPlayerModels()
{
	switch(game["allies"])
	{
		case "british":
			if(isdefined(game["british_soldiertype"]) && game["british_soldiertype"] == "africa")
			{
				mptype\british_africa::precache();
				game["allies_model"] = mptype\british_africa::main;
			}
			else
			{
				mptype\british_normandy::precache();
				game["allies_model"] = mptype\british_normandy::main;
			}
			break;

		case "russian":
			if(isdefined(game["russian_soldiertype"]) && game["russian_soldiertype"] == "padded")
			{
				mptype\russian_padded::precache();
				game["allies_model"] = mptype\russian_padded::main;
			}
			else
			{
				mptype\russian_coat::precache();
				game["allies_model"] = mptype\russian_coat::main;
			}
			break;

		case "american":
		default:
			mptype\american_normandy::precache();
			game["allies_model"] = mptype\american_normandy::main;
	}

	if(isdefined(game["german_soldiertype"]) && game["german_soldiertype"] == "winterdark")
	{
		mptype\german_winterdark::precache();
		game["axis_model"] = mptype\german_winterdark::main;
	}
	else if(isdefined(game["german_soldiertype"]) && game["german_soldiertype"] == "winterlight")
	{
		mptype\german_winterlight::precache();
		game["axis_model"] = mptype\german_winterlight::main;
	}
	else if(isdefined(game["german_soldiertype"]) && game["german_soldiertype"] == "africa")
	{
		mptype\german_africa::precache();
		game["axis_model"] = mptype\german_africa::main;
	}
	else
	{
		mptype\german_normandy::precache();
		game["axis_model"] = mptype\german_normandy::main;
	}
}

model()
{
	self detachAll();

	if(self.pers["team"] == "allies")
		[[game["allies_model"] ]]();
	else if(self.pers["team"] == "axis")
		[[game["axis_model"] ]]();

	self.pers["savedmodel"] = maps\mp\_utility::saveModel();
}

CountPlayers()
{
	//chad
	players = getentarray("player", "classname");
	allies = 0;
	axis = 0;
	for(i = 0; i < players.size; i++)
	{
		if(players[i].pers["team"] == "allies")
			allies++;
		else if(players[i].pers["team"] == "axis")
			axis++;
	}
	players["allies"] = allies;
	players["axis"] = axis;
	return players;
}

// This is for compatibility reasons only - some custom maps call this function
addTestClients()
{
}
