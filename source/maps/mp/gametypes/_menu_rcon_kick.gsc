#include maps\mp\gametypes\global\_global;

/*
This script will generate list of all players
*/

init()
{
	addEventListener("onConnected",     ::onConnected);

	addEventListener("onMenuResponse",  ::onMenuResponse);
}

onConnected()
{

}

/*
Called when command scriptmenuresponse is executed on client side
self is player that called scriptmenuresponse
Return true to indicate that menu response was handled in this function
*/
onMenuResponse(menu, response)
{
	if (menu != "ingame")
		return;

	if (response == "rcon_kick_refresh")
	{
		self thread generatePlayerList();
		return true;
	}
}

generatePlayerList()
{
    self endon("disconnect");


	allies = [];
	axis = [];
	spec = [];
	none = [];

	players = getentarray("player", "classname");
	for(p = 0; p < players.size; p++)
	{
		player = players[p];

		if (player.sessionteam == "allies")
			allies[allies.size] = player;
		else if (player.sessionteam == "axis")
			axis[axis.size] = player;
		else if (player.sessionteam == "spectator")
			spec[spec.size] = player;
		else
			none[none.size] = player;
	}

	/*
	team
	1 = allies
	2 = axis
	3 = neutral
	4 = heading
	*/

	max_lines = 22;

	i = 1;

	// Allies heading
	self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_team", "4");
	self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_name", "Allies");
	i++;
	if (allies.size > 0)
	{
		for(p = 0; p < allies.size; p++)
		{
			player = allies[p];
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_team", "1");
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_name", player.name);
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_kick", "rcon clientkick " + player GetEntityNumber() + "; wait 260; openscriptmenu ingame rcon_kick_refresh");
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_ban", "rcon tempBanClient " + player GetEntityNumber() + "; wait 260; openscriptmenu ingame rcon_kick_refresh");
			i++;
			if (i > max_lines) return;
		}
	}


	// Space
	self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_team", "0");
	i++;
	if (i > max_lines) return;
	//wait level.frame;

	// Axis heading
	self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_team", "4");
	self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_name", "Axis");
	i++;
	if (i > max_lines) return;

	if (axis.size > 0)
	{
		for(p = 0; p < axis.size; p++)
		{
			player = axis[p];
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_team", "2");
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_name", player.name);
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_kick", "rcon clientkick " + player GetEntityNumber() + "; wait 260; openscriptmenu ingame rcon_kick_refresh");
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_ban", "rcon tempBanClient " + player GetEntityNumber() + "; wait 260; openscriptmenu ingame rcon_kick_refresh");
			i++;
			if (i > max_lines) return;
		}
	}


	if (spec.size > 0)
	{
		// Space
		self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_team", "0");
		i++;
		if (i > max_lines) return;

		// Spectator heading
		self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_team", "4");
		self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_name", "Spectators");
		i++;
		if (i > max_lines) return;

		for(p = 0; p < spec.size; p++)
		{
			player = spec[p];
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_team", "3");
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_name", player.name);
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_kick", "rcon clientkick " + player GetEntityNumber() + "; wait 260; openscriptmenu ingame rcon_kick_refresh");
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_ban", "rcon tempBanClient " + player GetEntityNumber() + "; wait 260; openscriptmenu ingame rcon_kick_refresh");
			i++;
			if (i > max_lines) return;
		}
	}



	if (none.size > 0)
	{
		// Space
		self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_team", "0");
		i++;
		if (i > max_lines) return;

		// None heading
		self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_team", "4");
		self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_name", "Selecting team");
		i++;
		if (i > max_lines) return;

		for(p = 0; p < none.size; p++)
		{
			player = none[p];
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_team", "3");
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_name", player.name);
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_kick", "rcon clientkick " + player GetEntityNumber() + "; wait 260; openscriptmenu ingame rcon_kick_refresh");
			self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_ban", "rcon tempBanClient " + player GetEntityNumber() + "; wait 260; openscriptmenu ingame rcon_kick_refresh");
			i++;
			if (i > max_lines) return;
		}
	}


	// Rest is space
	for (; i <= max_lines; i++)
	{
		self setClientCvarIfChanged("ui_rcon_kick_line_"+i+"_team", "0");
		//wait level.frame;
	}


}
