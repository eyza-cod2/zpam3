#include maps\mp\gametypes\global\_global;

init()
{
	if(game["firstInit"])
	{
		precacheString2("STRING_VERSION_INFO", &"zPAM 3.22"); // ZPAM_RENAME
	}
}


// Info about PAM, league name
// Is removed at readyup after all players are ready
PAM_Header(fadein)
{
	// Another thread is running..
	if (isDefined(level.pam_header_visible))
		return;
	level.pam_header_visible = true;

	if (!isDefined(fadein))
		fadein = false;



	stringToShow = game["leagueString"];
	if (isDefined(game["leagueStringOvertime"]) && game["overtime_active"])
		stringToShow = game["leagueStringOvertime"];


	leaguelogo = undefined;
	pammode = undefined;
	if (game["leagueLogo"] == "")
	{
		// Cyber gamer SD league
		pammode = addHUD(10, 2, 1.2, (1,1,0), "left", "top", "left");
		if (fadein) pammode showHUDSmooth(.5);
		pammode setText(stringToShow);
	}
	else
	{
		leaguelogo = addHUD(7, 3, undefined, undefined, "left", "top", "left", "top");
		if (fadein) leaguelogo showHUDSmooth(.5);
		leaguelogo SetShader(game["leagueLogo"], 111, 28);

		pammode = addHUD(33, 15, 0.45, (1,1,1), "left", "top", "left");
		if (fadein) pammode showHUDSmooth(.5);
		pammode.font = "bigfixed"; // default bigfixed smallfixed
		pammode setText(stringToShow);
	}

	// zPAM v3.00
	pam_version = addHUD(-20, 25, 1.2, (0.8,1,1), "right", "top", "right");
	if (fadein) pam_version showHUDSmooth(.5);
	pam_version setText(game["STRING_VERSION_INFO"]);

	level waittill("pam_hud_delete");

	if (isDefined(leaguelogo)) leaguelogo thread removeHUDSmooth(0.5);
	if (isDefined(pammode)) pammode thread removeHUDSmooth(0.5);
	pam_version thread removeHUDSmooth(0.5);

	level.pam_header_visible = undefined;
}


PAM_Header_Delete()
{
	level notify("pam_hud_delete");
}
