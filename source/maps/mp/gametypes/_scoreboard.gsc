#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onStartGameType", ::onStartGameType);
}

// Called after the <gametype>.gsc::main() and <map>.gsc::main() scripts are called
// At this point game specific variables are defined (like game["allies"], game["axis"], game["american_soldiertype"], ...)
// Called again for every round in round-based gameplay
onStartGameType()
{
	if(game["firstInit"])
	{
		switch(game["allies"])
		{
			case "american":
				precacheShader("mpflag_american");
				break;

			case "british":
				precacheShader("mpflag_british");
				break;

			default:
				precacheShader("mpflag_russian");
				break;
		}
		precacheShader("mpflag_german");
		precacheShader("mpflag_spectator");
	}
	precacheShader("mpflag_spectator");



	switch(game["allies"])
	{
		case "american":
			setcvar("g_TeamName_Allies", &"MPUI_AMERICAN");
			setcvar("g_TeamColor_Allies", ".25 .75 .25");
			setcvar("g_ScoresBanner_Allies", "mpflag_american");
			break;

		case "british":
			setcvar("g_TeamName_Allies", &"MPUI_BRITISH");
			setcvar("g_TeamColor_Allies", ".25 .25 .75");
			setcvar("g_ScoresBanner_Allies", "mpflag_british");
			break;

		default:
			setcvar("g_TeamName_Allies", &"MPUI_RUSSIAN");
			setcvar("g_TeamColor_Allies", ".75 .25 .25");
			setcvar("g_ScoresBanner_Allies", "mpflag_russian");
			break;
	}

	setcvar("g_TeamName_Axis", &"MPUI_GERMAN");
	setcvar("g_TeamColor_Axis", ".6 .6 .6");
	setcvar("g_ScoresBanner_Axis", "mpflag_german");

	setcvar("g_ScoresBanner_None", "mpflag_spectator");
}
