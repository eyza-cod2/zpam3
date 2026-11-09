#include maps\mp\gametypes\global\_global;

// Call of Duty 2 birthday event (released Oct 25, 2005), enabled by scr_event_birthday (global/cvars.gsc)
// Party hats in team colors with "21" on the front, worn during ready-up. Nothing that affects the match.
// The hat is earned at the birthday poster (_birthday_poster.gsc): its first burst on the map throws 10 hats around it,
// a player picks one up by walking over it. It is kept for the whole map.
// Models are generated (by a tool outside the repository; rigid, bone j_helmet, attached like the stock helmets)

init()
{
	// Models are precached only when the event is enabled at the map start
	if (game["firstInit"])
	{
		game["party_hat_precached"] = level.scr_event_birthday;

		if (game["party_hat_precached"])
		{
			precacheModel("xmodel/zpam_party_hat_allies");
			precacheModel("xmodel/zpam_party_hat_axis");
		}
	}

	addEventListener("onSpawnedPlayer", ::onSpawnedPlayer);
}

isEnabled()
{
	return level.scr_event_birthday && isDefined(game["party_hat_precached"]) && game["party_hat_precached"];
}

// Called from _readyup::Start_Readyup_Mode, also when ready-up is started in the middle of the game (timeout)
readyupStarted()
{
	if (!isEnabled())
		return;

	// Players that are already alive (timeout)
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if (players[i].sessionstate == "playing" && players[i] hasPartyHat())
			players[i] attachPartyHat();
	}

	level waittill("rupover");

	// Map restart removes the hats, but ready-up in timeout does not restart the map
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
		players[i] detachPartyHat();
}

onSpawnedPlayer()
{
	// The spawn sets the player model again, which detaches all models
	self.party_hat = undefined;

	if (level.in_readyup && isEnabled() && self hasPartyHat())
		self attachPartyHat();
}

hasPartyHat()
{
	return isDefined(self.pers["party_hat"]) && self.pers["party_hat"];
}

// Called from _birthday_poster.gsc when the player picked up a hat thrown out of the poster
earnPartyHat()
{
	self.pers["party_hat"] = true;
	maps\mp\gametypes\_birthday_poster::debug(self.name + " earned a party hat");

	if (level.in_readyup && isEnabled() && self.sessionstate == "playing")
		self attachPartyHat();
}

// Hat model of the player's team, undefined for spectators
getPartyHatModel()
{
	if (self.pers["team"] == "allies")
		return "xmodel/zpam_party_hat_allies";
	if (self.pers["team"] == "axis")
		return "xmodel/zpam_party_hat_axis";
	return undefined;
}

attachPartyHat()
{
	if (isDefined(self.party_hat))
		return;

	model = self getPartyHatModel();
	if (!isDefined(model))
		return;
	if (self getAttachSize() >= 6)	// MAX_MODEL_ATTACHMENTS (head and helmet use 2, other mods may attach more)
	{
		maps\mp\gametypes\_birthday_poster::debug(self.name + ": party hat not attached, " + self getAttachSize() + " models attached already");
		return;
	}

	// Rigid model with bone j_helmet, attached like the stock helmets
	self attach(model, "", true);
	self.party_hat = model;
}

detachPartyHat()
{
	if (!isDefined(self.party_hat))
		return;

	self detach(self.party_hat, "");
	self.party_hat = undefined;
}
