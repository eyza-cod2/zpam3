#include maps\mp\gametypes\global\_global;

init()
{
    if (!isDefined(game["playerstats"]))
    {
      game["playerstats"] = [];
    }

    // Set all players unconnected
    resetConnectedStatus();

    addEventListener("onConnected",       ::onConnected);
    addEventListener("onDisconnect",      ::onDisconnect);
    addEventListener("onConnectedAll",    ::onConnectedAll);
    addEventListener("onJoinedTeam",    ::onJoinedTeam);

    //thread printThread();
}

resetConnectedStatus()
{
  for (i = 0; i < game["playerstats"].size; i++)
  {
    data = game["playerstats"][i];
    if (data["deleted"]) continue;
    game["playerstats"][i]["isConnected"] = false;
  }
}


onConnectedAll()
{
    level thread removeOld();
}

// Remove stats from disconnected players
removeOld()
{
  wait level.frame * 3; // wait untillplayers are fully proccesed on new round

  time = getTime();
  for (i = 0; i < game["playerstats"].size; i++)
  {
    data = game["playerstats"][i];

    //iprintln("Looping " + i + ": "+ data["name"] + "   " + data["isConnected"] + "  " + (time - data["lastTime"]));


    if (data["deleted"] || data["isConnected"]) continue;

    timeout = 2; // wait 5min by default
    if (game["is_public_mode"])
    	timeout = 0.1; // 6sec in public mode
    else if (isDefined(level.in_readyup) && level.in_readyup)
    	timeout = 5;

    // Delete data after x mins
    if ((time - data["lastTime"]) > (timeout * 60 * 1000))
    {
      game["playerstats"][i]["deleted"] = true;

      //wait level.fps_multiplier * 1;
      //iprintln("Deleting old player stats for " + game["playerstats"][i]["name"] + "   " + data["isConnected"] + "  " + (time - data["lastTime"]));
    }
  }
}

findData(name, entityId)
{
  for (i = 0; i < game["playerstats"].size; i++)
  {
    data = game["playerstats"][i];
    if (data["deleted"]) continue;

    if (isDefined(entityId))
    {
      if (data["name"] == name && data["entityId"] == entityId)
        return i;
    }
    else
    {
      if (data["name"] == name)
        return i;
    }
  }
  return -1;
}

handleRename()
{
  if (isDefined(self.pers["lastName"]))
  {
    if (self.pers["lastName"] != self.name)
    {
      //println("PLayer renamed");

      dataId = findData(self.pers["lastName"], self getEntityNumber());
      if (dataId >= 0)
      {
        // if we rename to name that is already in stat unconnected, we need to delete them
        dataId2 = findData(self.name);
        if (dataId2 >= 0 && game["playerstats"][dataId2]["isConnected"] == false)
        {
          game["playerstats"][dataId2]["deleted"] = true;
          //setCvar("sv_playerstats_" + dataId2 + "_deleted", 1);
        }

        game["playerstats"][dataId]["name"] = self.name;
        //setCvar("sv_playerstats_" + dataId + "_name", self.name);
      }

      self.pers["lastName"] = self.name;
    }
  }
  else
    self.pers["lastName"] = self.name;
}


getStatId()
{
  handleRename();

  return findData(self.name, self getEntityNumber());
}

getStats()
{
  id = self getStatId();

  if (id >= 0)
  {
    return game["playerstats"][id];
  }

  return undefined;
}


print()
{
  for (i = 0; i < game["playerstats"].size; i++)
  {
    data = game["playerstats"][i];
    if (data["deleted"] == false)
    {
      println("game[playerstats]["+i+"][entityId]    = " + data["entityId"]);
      println("game[playerstats]["+i+"][name]        = " + data["name"]);
      println("game[playerstats]["+i+"][isConnected] = " + data["isConnected"]);
      println("game[playerstats]["+i+"][lastTime]    = " + data["lastTime"]);
      println("game[playerstats]["+i+"][kills]       = " + data["kills"]);
      println("game[playerstats]["+i+"][damage]      = " + data["damage"]);
      println("game[playerstats]["+i+"][assists]     = " + data["assists"]);
      println("game[playerstats]["+i+"][deaths]      = " + data["deaths"]);
      println("game[playerstats]["+i+"][kills]       = " + data["score"]);
      println("game[playerstats]["+i+"][grenades]    = " + data["grenades"]);
      println("game[playerstats]["+i+"][plants]      = " + data["plants"]);
      println("game[playerstats]["+i+"][defuses]     = " + data["defuses"]);
    }
    else
    {
      println("game[playerstats]["+i+"] - deleted");
    }
    println("");
  }
}

printThread()
{
  setcvar("p", "0");

  for(;;)
  {
    wait level.fps_multiplier * 0.5;

    if (getcvar("p") == "1")
    {
      setcvar("p", "0");
      print();
    }
  }
}



onConnected()
{
	handleRename();

	id = self getEntityNumber();

	dataId = findData(self.name, id);
	if (dataId >= 0 && game["playerstats"][dataId]["isConnected"] == false) // note: isConnected is reseted every map_restart
	{
		game["playerstats"][dataId]["player"] = self;
		game["playerstats"][dataId]["isConnected"] = true;
		game["playerstats"][dataId]["team"] = self.sessionteam;
		game["playerstats"][dataId]["lastTime"] = getTime();

		self thread restoreScore(game["playerstats"][dataId]["kills"], game["playerstats"][dataId]["deaths"]);
	}
	else
	{
		// Player was not found via name and id, give other players connecting in same time time to identified them via name and id before this player will be found only by name.. (to avoid stat steal by duplicating name)
		waittillframeend;

		dataId = findData(self.name);
		if (dataId >= 0 && game["playerstats"][dataId]["isConnected"] == false)
		{
			game["playerstats"][dataId]["player"] = self;
			game["playerstats"][dataId]["entityId"] = id;
			game["playerstats"][dataId]["isConnected"] = true;
			game["playerstats"][dataId]["team"] = self.sessionteam;
			game["playerstats"][dataId]["lastTime"] = getTime();

			self thread restoreScore(game["playerstats"][dataId]["kills"], game["playerstats"][dataId]["deaths"]);
			//setCvar("sv_playerstats_" + dataId + "_entityId", id);
		}
		else
		{
			// Create new entry
			newIndex = game["playerstats"].size;
			game["playerstats"][newIndex]["id"] = newIndex;
			game["playerstats"][newIndex]["player"] = self;
			game["playerstats"][newIndex]["deleted"] = false;
			game["playerstats"][newIndex]["entityId"] = id;
			game["playerstats"][newIndex]["name"] = self.name;
			game["playerstats"][newIndex]["team"] = self.sessionteam;
			game["playerstats"][newIndex]["isConnected"] = true;
			game["playerstats"][newIndex]["lastTime"] = getTime();
			game["playerstats"][newIndex]["kills"] = 0;
			game["playerstats"][newIndex]["assists"] = 0;
			game["playerstats"][newIndex]["damage"] = 0;
			game["playerstats"][newIndex]["deaths"] = 0;
			game["playerstats"][newIndex]["score"] = 0.0;
			game["playerstats"][newIndex]["grenades"] = 0;
			game["playerstats"][newIndex]["plants"] = 0;
			game["playerstats"][newIndex]["defuses"] = 0;
		}
	}

}

onJoinedTeam(team)
{
	dataId = findData(self.name, self getEntityNumber());
	if (dataId >= 0)
	{
		game["playerstats"][dataId]["team"] = team;
	}
}


onDisconnect()
{
  dataId = findData(self.name, self getEntityNumber());
  if (dataId >= 0)
  {
    game["playerstats"][dataId]["isConnected"] = false;
    game["playerstats"][dataId]["player"] = undefined;
    game["playerstats"][dataId]["lastTime"] = getTime();
    game["playerstats"][dataId]["name"] = self.name;		// in case player renamed since connect
  }
}


restoreScore(kills, deaths)
{
  self endon("disconnect");

  wait level.frame; // wait untill score if properly initialized

  if (self.score == 0 && self.deaths == 0)
  {
    self.pers["score"] = kills;
    self.score = kills;

    self.pers["deaths"] = deaths;
    self.deaths = deaths;
  }
}


AddScore(score)
{
    dataId = self getStatId();
    if (dataId >= 0)
    {
      game["playerstats"][dataId]["score"] += score;
    }
}

AddAssist()
{
    dataId = self getStatId();
    if (dataId >= 0)
    {
      game["playerstats"][dataId]["assists"] += 1;
    }
}

AddDamage(iDamage)
{
    dataId = self getStatId();
    if (dataId >= 0)
    {
      game["playerstats"][dataId]["damage"] += iDamage;
    }
}


AddKill()
{
    dataId = self getStatId();
    if (dataId >= 0)
    {
      game["playerstats"][dataId]["kills"] += 1;
    }
}

AddDeath()
{
    dataId = self getStatId();
    if (dataId >= 0)
    {
      game["playerstats"][dataId]["deaths"] += 1;
    }
}

AddGrenade()
{
    dataId = self getStatId();
    if (dataId >= 0)
    {
      game["playerstats"][dataId]["grenades"] += 1;
    }
}

AddPlant()
{
    dataId = self getStatId();
    if (dataId >= 0)
    {
      game["playerstats"][dataId]["plants"] += 1;
    }
}

AddDefuse()
{
    dataId = self getStatId();
    if (dataId >= 0)
    {
      game["playerstats"][dataId]["defuses"] += 1;
    }
}
