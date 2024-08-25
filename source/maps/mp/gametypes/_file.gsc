#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);
	registerCvarEx("I", "scr_file", "BOOL", 0);

	addEventListener("onConnected",  	::onConnected);

	if (!level.scr_file)
		return;

	level thread file();
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_file":
			level.scr_file = value;
			if (!isRegisterTime)
			{
				if (level.scr_file) // enabled
				{
					level thread file();
					players = getentarray("player", "classname");
					for(i = 0; i < players.size; i++)
					{
						player = players[i];
						player onConnected();
					}
				}
				else // disabled
				{
					level notify("file_stop");
					players = getentarray("player", "classname");
					for(i = 0; i < players.size; i++)
					{
						player = players[i];
						player notify("file_stop");
					}
				}
			}
			return true;
	}
	return false;
}

onConnected()
{
	if (!level.scr_file)
		return;

	self.streamerSystem_file_bulletImpactPos = undefined;
	self.streamerSystem_file_deathPosition = undefined;

	self thread player_loop();
}

player_loop()
{
	self endon("disconnect");
	self endon("file_stop");

	last_current = "none";
	last_clipAmmo = 0;
	while(1)
	{
		wait level.frame;

		self.streamerSystem_file_bulletImpactPos = undefined;

		if (!isAlive(self))
			continue;

		self.streamerSystem_file_deathPosition = self getOrigin();

		current = self getcurrentweapon();

		// Player dont have weapon - for example player is on ladder
		if(current == "none")
			continue;

		weapon1 = self getweaponslotweapon("primary");
		weapon2 = self getweaponslotweapon("primaryb");
		weapon1_clipAmmo = self getweaponslotclipammo("primary");
		weapon2_clipAmmo = self getweaponslotclipammo("primaryb");


		current_clipAmmo = -1;
		if(current == weapon1) current_clipAmmo = weapon1_clipAmmo;
		if(current == weapon2) current_clipAmmo = weapon2_clipAmmo;

		// Bullet fired
		if (last_current == current && current_clipAmmo < last_clipAmmo && current_clipAmmo >= 0)
		{
			//self iprintln(gettime() + " fired");
			self.streamerSystem_file_bulletImpactPos = self getLookingAtPosition();
		}

		// TODO MG firing

		last_current = current;
		last_clipAmmo = current_clipAmmo;
	}
}


file()
{
	level endon("file_stop");

	wait level.frame * 3; // wait untill players from previous round get connected

	i = 0;
	ip = getCvar("net_ip");
	port = getCvar("net_port");

	while(true)
	{
		wait level.frame;
		waittillframeend;

		// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
		resettimeout();

		players = getentarray("player", "classname");

		/*
			s = Scr_GetString(arg);
			len = strlen(s);
			FS_Write(s, len, level.openScriptIOFileHandles[filenum]);
			FS_Write(",", 1, level.openScriptIOFileHandles[filenum]);
		*/

		str = "1" + "\n";
		str = str + gettime() + "," + i + "," + level.gametype + "," + level.mapname + "," + players.size + "\n";

		for(p = 0; p < players.size; p++)
		{
			player = players[p];

			origin = player getOrigin();
			if (isDefined(player.streamerSystem_file_deathPosition) && !isAlive(player))
				origin = player.streamerSystem_file_deathPosition;
			angles = player getPlayerAngles();

			bulletImpactPos = "0,0,0";
			if (isDefined(player.streamerSystem_file_bulletImpactPos))
			{
				//player iprintln(gettime() + " fire printed");
				bulletImpactPos = player.streamerSystem_file_bulletImpactPos[0] + "," + player.streamerSystem_file_bulletImpactPos[1] + "," +  player.streamerSystem_file_bulletImpactPos[2];
			}

			team = player.sessionteam;
			if (isDefined(player.pers["team"]) && player.pers["team"] != "")
				team = player.pers["team"];

			str = str +
				player getEntityNumber() + "," +
				origin[0] + "," + origin[1] + "," + origin[2] + "," +
				angles[0] + "," + angles[1] + "," + angles[2] + "," +
				team + "," +
				player.health + "," +
				bulletImpactPos + "," +
				player.spectatorclient + "," +
				"\"" + player.name + "\"" + "\n";
		}

		str = str + level.streamerSystem_playerID + "\n";

		if (level.gametype == "sd")
		{
			if (isDefined(level.bombzoneA) && !level.bombplanted)
				str = str + level.bombzoneA[0] + "," + level.bombzoneA[1] + "," + level.bombzoneA[2] + "\n";
			else	str = str + "undefined\n";
			if (isDefined(level.bombzoneB) && !level.bombplanted)
				str = str + level.bombzoneB[0] + "," + level.bombzoneB[1] + "," + level.bombzoneB[2] + "\n";
			else	str = str + "undefined\n";

			if (level.bombplanted && !level.bombexploded)
			{
				str = str +
					level.bombmodel.origin[0] + "," + level.bombmodel.origin[1] + "," + level.bombmodel.origin[2] + "," +
					level.bombmodel.angles[0] + "," + level.bombmodel.angles[1] + "," + level.bombmodel.angles[2] + "\n";
			}
			else
				str = str + "undefined\n";
		}



		filenum = OpenFile( "ZPAM_" + ip + "_" + port + ".txt", "write");

		if (filenum == -1)
		{
			println("unable to open file");
			return;
		}

		FPrintLn(filenum, str);

		closeFile(filenum);

		i++;
	}
}

/*
loadFromFile() 
{
	filenum = OpenFile( "ZPAM_custom_ruleset.txt", "read");

	if (filenum < 0)
		return;

	line = 0;
	while(1)
	{
		line++;

		// Buffer line into memory and returns number of comma separated values in file
		args = freadln(filenum);
	
		// Exit if this was last
		if (args <= 0)
			break;

		arg1 = fgetarg(filenum, 0);

		println(arg1);

		if (startsWith(arg1, "//")) {
			// Ignore comments

		} else if (startsWith(toLower(arg1), "set")) {

			// Text must consists of 3 string separated by space
			// set scr_cvar "value"
			tokens = strTok(arg1, " ");
			if (tokens.size < 3)
				break;
			
			cvar = tokens[1];
			value = tokens[2];

			if (startsWith(value, "\"")) {
				value = getsubstr(value, 1, value.size - 2);
			} else {
				value = int(value);
			}

			//arr = ruleCvarDefault(arr, cvar, value);
			setcvar(cvar, value);
		}
	}

	closefile(filenum);
}
*/