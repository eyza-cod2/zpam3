#include maps\mp\gametypes\_callbacksetup;

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

	i = 1;

	if (allies.size > 0)
	{
		// Allies heading
		self setClientCvar("ui_scoreboard_line_"+i+"_team", "4");
		self setClientCvar("ui_scoreboard_line_"+i+"_name", "Allies");
		i++;
		wait level.frame;

		for(p = 0; p < allies.size; p++)
		{
			player = allies[p];

			self setClientCvar("ui_scoreboard_line_"+i+"_team", "1");
			self setClientCvar("ui_scoreboard_line_"+i+"_name", player.name);
			self setClientCvar("ui_scoreboard_line_"+i+"_kick", "rcon clientkick " + player GetEntityNumber() + "; wait 260; openscriptmenu ingame rcon_kick_refresh");

			i++;
			wait level.frame;
		}
	}

	if (axis.size > 0)
	{
		// Space
		self setClientCvar("ui_scoreboard_line_"+i+"_team", "0");
		i++;

		// Axis heading
		self setClientCvar("ui_scoreboard_line_"+i+"_team", "4");
		self setClientCvar("ui_scoreboard_line_"+i+"_name", "Axis");
		i++;
		wait level.frame;

		for(p = 0; p < axis.size; p++)
		{
			player = axis[p];

			self setClientCvar("ui_scoreboard_line_"+i+"_team", "2");
			self setClientCvar("ui_scoreboard_line_"+i+"_name", player.name);
			self setClientCvar("ui_scoreboard_line_"+i+"_kick", "rcon clientkick " + player GetEntityNumber() + "; wait 260; openscriptmenu ingame rcon_kick_refresh");
			i++;
			wait level.frame;
		}
	}

	if (spec.size > 0)
	{
		// Space
		self setClientCvar("ui_scoreboard_line_"+i+"_team", "0");
		i++;

		// Spectator heading
		self setClientCvar("ui_scoreboard_line_"+i+"_team", "4");
		self setClientCvar("ui_scoreboard_line_"+i+"_name", "Spectators");
		i++;
		wait level.frame;

		for(p = 0; p < spec.size; p++)
		{
			player = spec[p];

			self setClientCvar("ui_scoreboard_line_"+i+"_team", "3");
			self setClientCvar("ui_scoreboard_line_"+i+"_name", player.name);
			self setClientCvar("ui_scoreboard_line_"+i+"_kick", "rcon clientkick " + player GetEntityNumber() + "; wait 260; openscriptmenu ingame rcon_kick_refresh");
			i++;
			wait level.frame;
		}
	}

	if (none.size > 0)
	{
		// Space
		self setClientCvar("ui_scoreboard_line_"+i+"_team", "0");
		i++;

		// None heading
		self setClientCvar("ui_scoreboard_line_"+i+"_team", "4");
		self setClientCvar("ui_scoreboard_line_"+i+"_name", "None");
		i++;
		wait level.frame;

		for(p = 0; p < none.size; p++)
		{
			player = none[p];

			self setClientCvar("ui_scoreboard_line_"+i+"_team", "3");
			self setClientCvar("ui_scoreboard_line_"+i+"_name", player.name);
			self setClientCvar("ui_scoreboard_line_"+i+"_kick", "rcon clientkick " + player GetEntityNumber() + "; wait 260; openscriptmenu ingame rcon_kick_refresh");
			i++;
			wait level.frame;
		}
	}


	// Rest is space
	for (; i <= 16; i++)
	{
		self setClientCvar("ui_scoreboard_line_"+i+"_team", "0");
		wait level.frame;
	}


}
