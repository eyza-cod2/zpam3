#include maps\mp\gametypes\global\_global;

/*
This script is used just to identify of some of the player is logged into rcon

For every player is generated unique user identification key
 - when player connects, cvar ui_rcon_hash is set to 'rcon set rcon_uuid xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
 - every time player open menu, cvar ui_rcon_hash is beeing executed via vstr
 - if player is logged into rcon, cvar rcon_uuid on server side is set, and by provided uuid is user identified

This is used only for text showing if player is logged in or not, is not used to do some restricted actions


These cvars are generated on client side:
ui_rcon_logged_in 	= 1 / 0
ui_rcon_hash 		= rcon set rcon_uuid xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


By eyza
*/

init()
{
	level.rconCvar = "rcon_uuid";

	level thread checkingRconCvarThread();

    addEventListener("onConnected",   ::onConnected);
}


onConnected()
{
    if (!isDefined(self.pers["rcon_logged_in"]))
    {
        self.pers["rcon_logged_in"] = false;
        self setClientCvar2("ui_rcon_logged_in", "0");
    }

	self generateUUID();
}

generateUUID()
{
    if (!isDefined(self.pers["rcon_uuid"]))
    {
        // Generate random hash
        avaibleChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789";
        hash = "";
        for (len = 0; len < 32; len++)
        {
            randIndex = randomintrange(0, avaibleChars.size);// Returns a random integer r, where min <= r < max
            hash = hash + "" + avaibleChars[randIndex];
        }


        // Loop players if generated hash accidentally exists (small probability, but may happend)
        players = getentarray("player", "classname");
        for(i = 0; i < players.size; i++)
        {
        	player = players[i];

            if (player != self && isDefined(player.pers["rcon_uuid"]) && player.pers["rcon_uuid"] == hash)
            {
                //println("uuid already exists________");
                self generateUUID();
                return;
            }
        }

        //println("uuid " + hash + " generated for player" +self.name);

        self.pers["rcon_uuid"] = hash;

        self setClientCvar2("ui_rcon_hash", "rcon set "+level.rconCvar+" "+ hash);
    }
    else
    {
        // Update vstr cvar because level.rconCvar may be changed
        self setClientCvar2("ui_rcon_hash", "rcon set "+level.rconCvar+" "+ self.pers["rcon_uuid"]);
    }
}

checkingRconCvarThread()
{
    // Define or reset cvar to default
    setCvar(level.rconCvar, "");

    //println("rcon cvar: " + level.rconCvar);

    for(;;)
    {
        wait level.fps_multiplier * 0.1;

        // Check if cvar is changed
        cvarValue = getCvar(level.rconCvar);
        if (cvarValue != "")
        {
            // Check if cvar value equals to UUID of some player
            players = getentarray("player", "classname");
            for(i = 0; i < players.size; i++)
            {
            	player = players[i];

                if (isDefined(player.pers["rcon_uuid"]) && cvarValue == player.pers["rcon_uuid"])
                {
                    // This player is player who set the correct uuid - so he has correct rcon password
                    player.pers["rcon_logged_in"] = true;

        			player iprintln("You are logged via rcon!");

        			player setClientCvar2("ui_rcon_logged_in", "1");

                    break;
                }
            }

            setCvar(level.rconCvar, "");
        }
    }
}
