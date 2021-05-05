Init()
{
	// Common stuffs for all gametypes
	precacheShader("black");
	precacheShader("white");
	precacheShader("$levelBriefing"); // map image

	// Stopwatch
	precacheShader("hudStopwatch");
	precacheShader("hudStopwatchNeedle");

	precacheStatusIcon("hud_status_dead");
	precacheStatusIcon("hud_status_connecting");

	precacheString2("STRING_EMPTY", &" ");
}


// Use this function to safe precached string into game variable
precacheString2(gameName, string)
{
	game[gameName] = string;
	precacheString(game[gameName]);
}
