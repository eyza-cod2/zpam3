#include maps\mp\gametypes\_callbacksetup;

Init()
{
	// Map voting
	if(!level.mapvote)
		return;

	level.mapvotetime = 13;
	//level.mapvotereplay	= 0;
}

Initialize()
{
	if(!level.mapvote)
		return;

	level.mapvotehudoffset = 30;

	// Small wait
	wait level.fps_multiplier * .5;

	// Create HUD
	CreateHud();

	// Start mapvote thread
	thread RunMapVote();

	// Wait for voting to finish
	level waittill("VotingComplete");

	// Delete HUD
	DeleteHud();
}


CreateHud()
{
	level.vote_hud_bgnd = newHudElem();
	level.vote_hud_bgnd.archived = false;
	level.vote_hud_bgnd.alpha = .7;
	level.vote_hud_bgnd.x = 205;
	level.vote_hud_bgnd.y = level.mapvotehudoffset + 17;
	level.vote_hud_bgnd.sort = 9000;
	level.vote_hud_bgnd.color = (0,0,0);
	level.vote_hud_bgnd setShader("white", 260, 140);

	level.vote_header = newHudElem();
	level.vote_header.archived = false;
	level.vote_header.alpha = .3;
	level.vote_header.x = 208;
	level.vote_header.y = level.mapvotehudoffset + 19;
	level.vote_header.sort = 9001;
	level.vote_header setShader("white", 254, 21);

	level.vote_headerText = newHudElem();
	level.vote_headerText.archived = false;
	level.vote_headerText.x = 210;
	level.vote_headerText.y = level.mapvotehudoffset + 21;
	level.vote_headerText.sort = 9998;
	level.vote_headerText.label = game["MapVoteHeader"];
	level.vote_headerText.fontscale = 1.3;

	level.vote_leftline = newHudElem();
	level.vote_leftline.archived = false;
	level.vote_leftline.alpha = .3;
	level.vote_leftline.x = 207;
	level.vote_leftline.y = level.mapvotehudoffset + 19;
	level.vote_leftline.sort = 9001;
	level.vote_leftline setShader("white", 1, 135);

	level.vote_rightline = newHudElem();
	level.vote_rightline.archived = false;
	level.vote_rightline.alpha = .3;
	level.vote_rightline.x = 462;
	level.vote_rightline.y = level.mapvotehudoffset + 19;
	level.vote_rightline.sort = 9001;
	level.vote_rightline setShader("white", 1, 135);

	level.vote_bottomline = newHudElem();
	level.vote_bottomline.archived = false;
	level.vote_bottomline.alpha = .3;
	level.vote_bottomline.x = 207;
	level.vote_bottomline.y = level.mapvotehudoffset + 154;
	level.vote_bottomline.sort = 9001;
	level.vote_bottomline setShader("white", 256, 1);

	level.vote_hud_timeleft = newHudElem();
	level.vote_hud_timeleft.archived = false;
	level.vote_hud_timeleft.x = 400;
	level.vote_hud_timeleft.y = level.mapvotehudoffset + 26;
	level.vote_hud_timeleft.sort = 9998;
	level.vote_hud_timeleft.fontscale = .8;
	level.vote_hud_timeleft.label = game["TimeLeft"];
	level.vote_hud_timeleft setValue( level.mapvotetime );

	level.vote_hud_instructions = newHudElem();
	level.vote_hud_instructions.archived = false;
	level.vote_hud_instructions.x = 340;
	level.vote_hud_instructions.y = level.mapvotehudoffset + 56;
	level.vote_hud_instructions.sort = 9998;
	level.vote_hud_instructions.fontscale = 1;
	level.vote_hud_instructions.label = game["MapVote"];
	level.vote_hud_instructions.alignX = "center";
	level.vote_hud_instructions.alignY = "middle";

	level.vote_map1 = newHudElem();
	level.vote_map1.archived = false;
	level.vote_map1.x = 434;
	level.vote_map1.y = level.mapvotehudoffset + 69;
	level.vote_map1.sort = 9998;

	level.vote_map2 = newHudElem();
	level.vote_map2.archived = false;
	level.vote_map2.x = 434;
	level.vote_map2.y = level.mapvotehudoffset + 85;
	level.vote_map2.sort = 9998;

	level.vote_map3 = newHudElem();
	level.vote_map3.archived = false;
	level.vote_map3.x = 434;
	level.vote_map3.y = level.mapvotehudoffset + 101;
	level.vote_map3.sort = 9998;

	level.vote_map4 = newHudElem();
	level.vote_map4.archived = false;
	level.vote_map4.x = 434;
	level.vote_map4.y = level.mapvotehudoffset + 117;
	level.vote_map4.sort = 9998;

	level.vote_map5 = newHudElem();
	level.vote_map5.archived = false;
	level.vote_map5.x = 434;
	level.vote_map5.y = level.mapvotehudoffset + 133;
	level.vote_map5.sort = 9998;
}

RunMapVote()
{
	maps = undefined;
	x = undefined;

	currentmap = getcvar("mapname");
	currentgt = level.gametype;

	x = GetRandomMapRotation();
	if(isdefined(x))
	{
		if(isdefined(level.maps_in_vote))
			maps = level.maps_in_vote;
	}

	// Any maps?
	if(!isdefined(maps))
	{
		wait level.frame;
		level notify("VotingComplete");
		return;
	}

	// Fill all alternatives with the current map in case there is not enough unique maps
	for(j=0;j<5;j++)
	{
		level.mapcandidate[j]["map"] = currentmap;
		level.mapcandidate[j]["mapname"] = "Replay this map";
		level.mapcandidate[j]["gametype"] = currentgt;
		level.mapcandidate[j]["votes"] = 0;
	}

	//get candidates
	i = 0;
	for(j=0;j<5;j++)
	{
		// Skip current map and gametype combination
		if(maps[i]["map"] == currentmap && maps[i]["gametype"] == level.gametype)
			i++;

		// Any maps left?
		if(!isdefined(maps[i]))
			break;

		level.mapcandidate[j]["map"] = maps[i]["map"];
		level.mapcandidate[j]["mapname"] = getMapName(maps[i]["map"]);
		level.mapcandidate[j]["gametype"] = maps[i]["gametype"];
		level.mapcandidate[j]["votes"] = 0;

		i++;

		// Any maps left?
		if(!isdefined(maps[i]))
			break;

		// Keep current map as last alternative?
		if(level.mapvotereplay && j>2)
			break;
	}

	thread DisplayMapChoices();

	//start a voting thread per player
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
		players[i] thread PlayerVote();

	addEventListener("onConnected",     ::onConnected);

	thread VoteLogic();

	//Take a breath for players to restart with the map
	wait 0.1;
	level.mapended = true;
}

onConnected()
{
    self thread PlayerVote();
}


DeleteHud()
{
	level.vote_headerText destroy();
	level.vote_hud_timeleft destroy();
	level.vote_hud_instructions destroy();
	level.vote_map1 destroy();
	level.vote_map2 destroy();
	level.vote_map3 destroy();
	level.vote_map4 destroy();
	level.vote_map5 destroy();
	level.vote_hud_bgnd destroy();
	level.vote_header destroy();
	level.vote_leftline destroy();
	level.vote_rightline destroy();
	level.vote_bottomline destroy();

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
		if(isdefined(players[i].vote_indicator))
			players[i].vote_indicator destroy();
}

//Displays the map candidates
DisplayMapChoices()
{
	level endon("VotingDone");
	for(;;)
	{
		iprintlnbold(level.mapcandidate[0]["mapname"] + " (" + level.mapcandidate[0]["gametype"] +")");
		iprintlnbold(level.mapcandidate[1]["mapname"] + " (" + level.mapcandidate[1]["gametype"] +")");
		iprintlnbold(level.mapcandidate[2]["mapname"] + " (" + level.mapcandidate[2]["gametype"] +")");
		iprintlnbold(level.mapcandidate[3]["mapname"] + " (" + level.mapcandidate[3]["gametype"] +")");
		iprintlnbold(level.mapcandidate[4]["mapname"] + " (" + level.mapcandidate[4]["gametype"] +")");
		wait level.fps_multiplier * 7.8;
	}
}

//Changes the players vote as he hits the attack button and updates HUD
PlayerVote()
{
	level endon("VotingDone");
	self endon("disconnect");

	// Spawn as spectator
	self [[level.spawnSpectator]]();

	//remove the scoreboard
	self setClientCvar("g_scriptMainMenu", "");
	self closeMenu();

	self allowSpectateTeam("allies", false);
	self allowSpectateTeam("axis", false);
	self allowSpectateTeam("freelook", false);
	self allowSpectateTeam("none", true);


	colors[0] = (0  ,  0,  1);
	colors[1] = (0  ,0.5,  1);
	colors[2] = (0  ,  1,  1);
	colors[3] = (0  ,  1,0.5);
	colors[4] = (0  ,  1,  0);

	self.vote_indicator = newClientHudElem( self );
	self.vote_indicator.alignY = "middle";
	self.vote_indicator.x = 208;
	self.vote_indicator.y = level.mapvotehudoffset + 75;
	self.vote_indicator.archived = false;
	self.vote_indicator.sort = 9998;
	self.vote_indicator.alpha = 0;
	self.vote_indicator.color = colors[0];
	self.vote_indicator setShader("white", 254, 17);

	hasVoted = false;

	for (;;)
	{
		wait level.frame;

		if(self attackButtonPressed() == true)
		{
			// -- Added by Number7 --
			if(!hasVoted)
			{
				self.vote_indicator.alpha = .3;
				self.votechoice = 0;
				hasVoted = true;
			}
			else
				self.votechoice++;

			if (self.votechoice == 5)
				self.votechoice = 0;

			self iprintln("You have voted for ^2" + level.mapcandidate[self.votechoice]["mapname"] + " (" + level.mapcandidate[self.votechoice]["gametype"]+")");
			self.vote_indicator.y = level.mapvotehudoffset + 77 + self.votechoice * 16;
			self.vote_indicator.color = colors[self.votechoice];

			self playLocalSound("hq_score");
		}
		while(self attackButtonPressed() == true)
			wait level.frame;

		self.sessionstate = "spectator";
		self.spectatorclient = -1;
	}
}

//Determines winning map and sets rotation
VoteLogic()
{
	//Vote Timer
	for (;level.mapvotetime>=0;level.mapvotetime--)
	{
		for(j=0;j<10;j++)
		{
			// Count votes
			for(i=0;i<5;i++)	level.mapcandidate[i]["votes"] = 0;
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
				if(isdefined(players[i].votechoice))
					level.mapcandidate[players[i].votechoice]["votes"]++;

			// Update HUD
			level.vote_map1 setValue( level.mapcandidate[0]["votes"] );
			level.vote_map2 setValue( level.mapcandidate[1]["votes"] );
			level.vote_map3 setValue( level.mapcandidate[2]["votes"] );
			level.vote_map4 setValue( level.mapcandidate[3]["votes"] );
			level.vote_map5 setValue( level.mapcandidate[4]["votes"] );
			wait level.fps_multiplier * .1;
		}
		level.vote_hud_timeleft setValue( level.mapvotetime );
	}

	wait 0.2;

	newmapnum = 0;
	topvotes = 0;
	for(i=0;i<5;i++)
	{
		if (level.mapcandidate[i]["votes"] > topvotes)
		{
			newmapnum = i;
			topvotes = level.mapcandidate[i]["votes"];
		}
	}

	SetMapWinner(newmapnum);
}

//change the map rotation to represent the current selection
SetMapWinner(winner)
{
	map	= level.mapcandidate[winner]["map"];
	mapname	= level.mapcandidate[winner]["mapname"];
	gametype = level.mapcandidate[winner]["gametype"];

	setcvar("sv_maprotationcurrent", " gametype " + gametype + " map " + map);

	wait 0.1;

	// Stop threads
	level notify( "VotingDone" );

	// Wait for threads to die
	wait 0.05;

	// Announce winner
	iprintlnbold(" ");
	iprintlnbold(" ");
	iprintlnbold(" ");
	iprintlnbold("The winner is");
	iprintlnbold("^2" + mapname);
	iprintlnbold("^2" + GetGametypeName(gametype));

	// Fade HUD elements
	level.vote_headerText fadeOverTime (1);
	level.vote_hud_timeleft fadeOverTime (1);
	level.vote_hud_instructions fadeOverTime (1);
	level.vote_map1 fadeOverTime (1);
	level.vote_map2 fadeOverTime (1);
	level.vote_map3 fadeOverTime (1);
	level.vote_map4 fadeOverTime (1);
	level.vote_map5 fadeOverTime (1);
	level.vote_hud_bgnd fadeOverTime (1);
	level.vote_header fadeOverTime (1);
	level.vote_leftline fadeOverTime (1);
	level.vote_rightline fadeOverTime (1);
	level.vote_bottomline fadeOverTime (1);

	level.vote_headerText.alpha = 0;
	level.vote_hud_timeleft.alpha = 0;
	level.vote_hud_instructions.alpha = 0;
	level.vote_map1.alpha = 0;
	level.vote_map2.alpha = 0;
	level.vote_map3.alpha = 0;
	level.vote_map4.alpha = 0;
	level.vote_map5.alpha = 0;
	level.vote_hud_bgnd.alpha = 0;
	level.vote_header.alpha = 0;
	level.vote_leftline.alpha = 0;
	level.vote_rightline.alpha = 0;
	level.vote_bottomline.alpha = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(isdefined(players[i].vote_indicator))
		{
			players[i].vote_indicator fadeOverTime (1);
			players[i].vote_indicator.alpha = 0;
		}
	}

	// Show winning map for a few seconds
	wait level.fps_multiplier * 4;
	level notify( "VotingComplete" );
}

GetRandomMapRotation(random, current, number)
{
	maprot = strip(getcvar("sv_maprotation"));

	if(!isdefined(number))
		number = 0;

	// No map rotation setup!
	if(maprot == "")
		return undefined;

	// Explode entries into an array
	j=0;
	temparr2[j] = "";
	for(i=0;i<maprot.size;i++)
	{
		if(maprot[i]==" ")
		{
			j++;
			temparr2[j] = "";
		}
		else
			temparr2[j] += maprot[i];
	}

	// Remove empty elements (double spaces)
	temparr = [];
	for(i=0;i<temparr2.size;i++)
	{
		element = strip(temparr2[i]);
		if(element != "")
			temparr[temparr.size] = element;
	}

	level.maps_in_vote = [];
	lastgt = level.gametype;
	for(i=0;i<temparr.size;)
	{
		switch(temparr[i])
		{
			case "gametype":
				if(isdefined(temparr[i+1]))
					lastgt = temparr[i+1];
				i += 2;
				break;

			case "map":
				if(isdefined(temparr[i+1]))
				{
					level.maps_in_vote[level.maps_in_vote.size]["gametype"]	= lastgt;
					level.maps_in_vote[level.maps_in_vote.size-1]["map"] = temparr[i+1];
				}

				i += 2;
				break;

			// If code get here, then the maprotation is corrupt so we have to fix it
			default:
				iprintlnbold("Warning: Error detected in map rotation");

				if(isGametype(temparr[i]))
					lastgt = temparr[i];
				else
				{
					level.maps_in_vote[level.maps_in_vote.size]["gametype"]	= lastgt;
					level.maps_in_vote[level.maps_in_vote.size-1]["map"] = temparr[i];
				}


				i += 1;
				break;
		}
		if(number && level.maps_in_vote.size >= number)
			break;
	}

	// Shuffle the array 20 times
	for(k = 0; k < 20; k++)
	{
		for(i = 0; i < level.maps_in_vote.size; i++)
		{
			j = randomInt(level.maps_in_vote.size);
			element = level.maps_in_vote[i];
			level.maps_in_vote[i] = level.maps_in_vote[j];
			level.maps_in_vote[j] = element;
		}
	}

	return level.maps_in_vote;
}

// Strip blanks at start and end of string
strip(s)
{
	if(s=="")
		return "";

	s2="";
	s3="";

	i=0;
	while(i<s.size && s[i]==" ")
		i++;

	// String is just blanks?
	if(i==s.size)
		return "";

	for(;i<s.size;i++)
	{
		s2 += s[i];
	}

	i=s2.size-1;
	while(s2[i]==" " && i>0)
		i--;

	for(j=0;j<=i;j++)
	{
		s3 += s2[j];
	}

	return s3;
}

isGametype(gt)
{
	switch(gt)
	{
		case "dm":
		case "tdm":
		case "sd":
		case "hq":
		case "ctf":
		case "ihtf":
		case "wrz":
		case "zom":
		case "obj":
		case "ft":
		case "utd":
			return true;

		default:
			return false;
	}
}

getMapName(map)
{
	switch(map)
	{
		case "mp_farmhouse":
			mapname = "Beltot";
			break;

		case "mp_brecourt":
			mapname = "Brecourt";
			break;

		case "mp_burgundy":
			mapname = "Burgundy";
			break;

		case "mp_trainstation":
			mapname = "Caen";
			break;

		case "mp_carentan":
			mapname = "Carentan";
			break;

		case "mp_decoy":
			mapname = "El Alamein";
			break;

		case "mp_leningrad":
			mapname = "Leningrad";
			break;

		case "mp_matmata":
			mapname = "Matmata";
			break;

		case "mp_downtown":
			mapname = "Moscow";
			break;

		case "mp_harbor":
			mapname = "Rostov";
			break;

		case "mp_dawnville":
			mapname = "St. Mere Eglise";
			break;

		case "mp_railyard":
			mapname = "Stalingrad";
			break;

		case "mp_toujane":
			mapname = "Toujane";
			break;

		case "mp_breakout":
			mapname = "Villers-Bocage";
			break;

		case "mp_rhine":
			mapname = "Wallendar";
			break;

		default:
			mapname = map;
			break;
	}

	return mapname;
}

getGametypeName(gt)
{
	switch(gt)
	{
		case "dm":
			gtname = "Deathmatch";
			break;

		case "tdm":
			gtname = "Team Deathmatch";
			break;

		case "sd":
			gtname = "Search & Destroy";
			break;

		case "hq":
			gtname = "Headquarters";
			break;

		case "ctf":
			gtname = "Capture The Flag";
			break;

		case "ihtf":
			gtname = "Individual Hold The Flag";
			break;

		case "wrz":
			gtname = "War Zone";
			break;

		case "zom":
			gtname = "Zombies";
			break;

		case "obj":
			gtname = "Objetives";
			break;

		case "ft":
			gtname = "Freeze Tag";
			break;

		case "utd":
			gtname = "Domination";
			break;

		default:
			gtname = gt;
			break;
	}

	return gtname;
}
