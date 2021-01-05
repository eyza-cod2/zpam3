#include maps\mp\gametypes\_callbacksetup;

init()
{
    level.hud_readyup_offsetX = -50;
    level.hud_readyup_offsetY = 20;


    level.hud_scoreboard_offsetX = -35;
    level.hud_scoreboard_offsetY = 180 - 10;

    level.hud_stopwatch_offsetX = -35;
    level.hud_stopwatch_offsetY = 270;
}

// Info about PAM, league name
// Is removed at readyup after all players are ready
PAM_Header()
{
	// TO-DO: REMOVE in release
  /*
    notreleased1 = maps\mp\gametypes\_hud_system::addHUD(0, 3, 1.0, (1,1,0), "center", "top", "center", "top");
    notreleased1.alpha = 0.5;
    notreleased1 setText(game["STRING_NOT_RELEASED_1"]);

    notreleased2 = maps\mp\gametypes\_hud_system::addHUD(0, 16, 0.8, (1,1,0), "center", "top", "center", "top");
    notreleased2.alpha = 0.5;
    notreleased2 setText(game["STRING_NOT_RELEASED_2"]);
*/

    leaguelogo = undefined;
    pammode = undefined;
    if (game["leagueLogo"] == "")
    {
        // Cyber gamer SD league
        pammode = maps\mp\gametypes\_hud_system::addHUD(10, 2, 1.2, (1,1,0), "left", "top", "left");
    	pammode setText(game["leagueString"]);
    }
    else
    {
        leaguelogo = maps\mp\gametypes\_hud_system::addHUD(7, 3, undefined, undefined, "left", "top", "left", "top");
    	leaguelogo SetShader(game["leagueLogo"], 111, 28);

        pammode = maps\mp\gametypes\_hud_system::addHUD(33, 15, 0.45, (1,1,1), "left", "top", "left");
    	pammode.font = "bigfixed"; // default bigfixed smallfixed
    	pammode setText(game["leagueString"]);
    }

    // zPAM v3.00
    pam_version = maps\mp\gametypes\_hud_system::addHUD(-20, 25, 1.2, (0.8,1,1), "right", "top", "right");
  	pam_version setText(game["STRING_VERSION_INFO"]);
/*
    // Released 10/2015
    pam_released = maps\mp\gametypes\_hud_system::addHUD(-35, 39, 1, (0.8,1,1), "right", "top", "right");
	pam_released setText(game["STRING_RELEASED_INFO"]);
*/
    // Overtime mode
    overtimemode = undefined;
    if (game["overtime_active"])
    {
        overtimemode = maps\mp\gametypes\_hud_system::addHUD(0, 20, 1.4, (1,1,0), "center", "top", "center");
        overtimemode setText(game["STRING_OVERTIME_MODE"]);
        if (level.in_timeout)
            overtimemode.y += 20;
    }

    // Timeout mode
    timeoutmode = undefined;
    if(level.in_timeout)
    {
        timeoutmode = maps\mp\gametypes\_hud_system::addHUD(0, 20, 1.4, (1,1,0), "center", "top", "center");
        timeoutmode setText(game["timeouthead"]);
    }


    level waittill("hud_kill_header");


    // Remove hud elem
    if (isDefined(leaguelogo)) leaguelogo thread maps\mp\gametypes\_hud_system::removeHUDSmooth(1);
    pammode thread maps\mp\gametypes\_hud_system::removeHUDSmooth(1);
    pam_version thread maps\mp\gametypes\_hud_system::removeHUDSmooth(1);
    //pam_released thread maps\mp\gametypes\_hud_system::removeHUDSmooth(1);
    if (isDefined(overtimemode)) overtimemode thread maps\mp\gametypes\_hud_system::removeHUDSmooth(1);
    if (isDefined(timeoutmode)) timeoutmode thread maps\mp\gametypes\_hud_system::removeHUDSmooth(1);
}

PAM_Header_Kill()
{
    level notify("hud_kill_header");
}

// Is called in: next_round, is_halftime or map_ends
ScoreBoard(is_halftime_or_mapend)
{
	if (level.gametype == "dm")
		return;

    scorby = level.hud_scoreboard_offsetY;
	teamsy = level.hud_scoreboard_offsetY + 20;
	half1y = level.hud_scoreboard_offsetY + 35;
	half2y = level.hud_scoreboard_offsetY + 50;
    timery = level.hud_scoreboard_offsetY + 70;
    roundy = level.hud_scoreboard_offsetY + 85;

	// Match info
    scorebd = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX-50, scorby, 1.2, (.98, .827, .58), "center", "middle", "right");
	scorebd maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	scorebd setText(game["STRING_SCOREBOARD_TITLE"]);

    // My team
    team1 = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX-100, teamsy, 1.2, (.73, .99, .73), "left", "middle", "right");
	team1 maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	team1 setText(game["STRING_SCOREBOARD_TEAM1"]);

    // Enemy
    team2 = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX,     teamsy, 1.2, (.85, .99, .99), "right", "middle", "right");
	team2 maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	team2 setText(game["STRING_SCOREBOARD_TEAM2"]);

    // 1st Half
    firhalfscore = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX-50, half1y, 1.1, (.98, .827, .58), "center", "middle", "right");
	firhalfscore maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	firhalfscore setText(game["STRING_SCOREBOARD_FIRST_HALF"]);

    // 2nd Half
    sechalfscore = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX-50, half2y, 1.1, (.98, .827, .58), "center", "middle", "right");
	sechalfscore maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	sechalfscore setText(game["STRING_SCOREBOARD_SECOND_HALF"]);

    // Playing time
    playingtime = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX-100, timery, 1.1, (.98, .827, .58), "left", "middle", "right");
	playingtime maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	playingtime setText(game["STRING_SCOREBOARD_PLAYING_TIME"]);

    // 12:48
    timerColor = (1,1,0);
    timerValue = int((game["matchStartTime"] - getTime()) / 1000) + 0.9;
    if (is_halftime_or_mapend)
        timerColor = (.98, .827, .58);
    playingtimer = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX, timery, 1.1, timerColor, "right", "middle", "right");
    if (isDefined(game["matchStartTime"]))
	{
        playingtimer maps\mp\gametypes\_hud_system::showHUDSmooth(1);
    	playingtimer settimerup(timerValue);
    }

    // If this line may be showed and game is limited by rounds (it is not visible if it is limited by score)
    if (!is_halftime_or_mapend && (level.halfround > 0 || level.matchround > 0))
    {
        // Rounds remaining
        roundsremaining = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX-100, roundy, 1.1, (.98, .827, .58), "left", "middle", "right");
    	roundsremaining maps\mp\gametypes\_hud_system::showHUDSmooth(1);
        if (level.halfround && !game["is_halftime"])
    	    roundsremaining setText(game["STRING_SCOREBOARD_ROUNDS_TO_HALF"]);
        else
            roundsremaining setText(game["STRING_SCOREBOARD_ROUNDS_TO_END"]);

        // 6
        roundsremainingval = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX, roundy, 1.1, (1, 1, 0), "right", "middle", "right");
        roundsremainingval maps\mp\gametypes\_hud_system::showHUDSmooth(1);
        if (level.halfround && !game["is_halftime"])
            roundsremainingval setValue(level.halfround-game["roundsplayed"]);
        else
            roundsremainingval setValue(level.matchround - game["roundsplayed"]);
    }




    // Loop all players and print my-team info on the left, enemy on the right
    players = getentarray("player", "classname");
    for(i = 0; i < players.size; i++)
    {
    	player = players[i];

        team1FirstHalfScore = maps\mp\gametypes\_hud_system::addHUDClient(player, level.hud_scoreboard_offsetX-100, half1y, 1.2, (.73, .99, .73), "left", "middle", "right");
        team2FirstHalfScore = maps\mp\gametypes\_hud_system::addHUDClient(player, level.hud_scoreboard_offsetX,     half1y, 1.2, (.85, .99, .99), "right", "middle", "right");

        team1SecondHalfScore = maps\mp\gametypes\_hud_system::addHUDClient(player, level.hud_scoreboard_offsetX-100, half2y, 1.2, (.73, .99, .73), "left", "middle", "right");
        team2SecondHalfScore = maps\mp\gametypes\_hud_system::addHUDClient(player, level.hud_scoreboard_offsetX,     half2y, 1.2, (.85, .99, .99), "right", "middle", "right");

        team1FirstHalfScore maps\mp\gametypes\_hud_system::showHUDSmooth(1);
        team2FirstHalfScore maps\mp\gametypes\_hud_system::showHUDSmooth(1);
        team1SecondHalfScore maps\mp\gametypes\_hud_system::showHUDSmooth(1);
        team2SecondHalfScore maps\mp\gametypes\_hud_system::showHUDSmooth(1);

        // On the left is always score of my actual team
        if (player.pers["team"] == "allies")
        {
            if (game["is_halftime"])
            {
                team1FirstHalfScore setValue(game["half_1_axis_score"]);
                team2FirstHalfScore setValue(game["half_1_allies_score"]);

                team1SecondHalfScore setValue(game["half_2_allies_score"]);
                team2SecondHalfScore setValue(game["half_2_axis_score"]);
            }
            else
            {
                team1FirstHalfScore setValue(game["half_1_allies_score"]);
                team2FirstHalfScore setValue(game["half_1_axis_score"]);

                team1SecondHalfScore setText(game["STRING_SCOREBOARD_NO_SCORE"]);
                team2SecondHalfScore setText(game["STRING_SCOREBOARD_NO_SCORE"]);
            }
        }
        else
        {
            if (game["is_halftime"])
            {
                team1FirstHalfScore setValue(game["half_1_allies_score"]);
                team2FirstHalfScore setValue(game["half_1_axis_score"]);

                team1SecondHalfScore setValue(game["half_2_axis_score"]);
                team2SecondHalfScore setValue(game["half_2_allies_score"]);
            }
            else
            {
                team1FirstHalfScore setValue(game["half_1_axis_score"]);
                team2FirstHalfScore setValue(game["half_1_allies_score"]);

                team1SecondHalfScore setText(game["STRING_SCOREBOARD_NO_SCORE"]);
                team2SecondHalfScore setText(game["STRING_SCOREBOARD_NO_SCORE"]);
            }
        }
    }

    // Because there is no function to stop a timer, we will keep setting timer to specific value over and over again
    if (is_halftime_or_mapend)
    {
        for(;;)
        {
            wait level.fps_multiplier * 0.5;

            playingtimer settimerup(timerValue);
        }

    }
}

/*            __
  Round     (    )
    8      (  .   )
 Starting   ( __ )
*/
NextRound(time)
{
	if ( time < 3 )
		time = 3;

	// Round
    round = maps\mp\gametypes\_hud_system::addHUD(level.hud_stopwatch_offsetX-77, level.hud_stopwatch_offsetY +3, 1.2, (1,1,0), "center", "top", "right");
	round maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	round setText(game["STRING_NEXTROUND_ROUND"]);

	// 6
    roundnum = maps\mp\gametypes\_hud_system::addHUD(level.hud_stopwatch_offsetX-77, level.hud_stopwatch_offsetY +30, 1.4, (1,1,0), "center", "middle", "right");
	roundnum maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	roundnum setValue(game["roundsplayed"]+1);

	// Starting
    starting = maps\mp\gametypes\_hud_system::addHUD(level.hud_stopwatch_offsetX-77, level.hud_stopwatch_offsetY +58, 1.2, (1,1,0), "center", "bottom", "right");
	starting maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	starting setText(game["STRING_NEXTROUND_STARTING"]);

	// Ccount-down stopwatch
    stopwatch = maps\mp\gametypes\_hud_system::addHUD(level.hud_stopwatch_offsetX+3, level.hud_stopwatch_offsetY, undefined, undefined, "right", "top", "right");
	stopwatch maps\mp\gametypes\_hud_system::showHUDSmooth(1);
    stopwatch.sort = 4;
    stopwatch.foreground = true;  // above blackbg and visible if menu opened
	stopwatch setClock(time, 60, "hudStopwatch", 60, 60); // count down for 5 of 60 seconds, size is 64x64

    // Is killed when timeout is called while this is visible
    level waittill("hud_kill_nextround");

    round thread maps\mp\gametypes\_hud_system::removeHUDSmooth(1);
    roundnum thread maps\mp\gametypes\_hud_system::removeHUDSmooth(1);
    starting thread maps\mp\gametypes\_hud_system::removeHUDSmooth(1);
    stopwatch thread maps\mp\gametypes\_hud_system::removeHUDSmooth(1);
}

NextRound_Kill()
{
    level notify("hud_kill_nextround");
}

/*
        Halftime

      (scoreboard)

    Team auto switch
      Please wait
*/
// Called when halftime is called at the end of the round
TeamSwap()
{
    // Halftime
    halftime = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX-50, level.hud_scoreboard_offsetY - 20, 1.2, (1,1,0), "center", "middle", "right");
	halftime maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	halftime setText(game["STRING_HALFTIME"]);

	// Team auto switch
    switching = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX-50, level.hud_scoreboard_offsetY +90, 1.2, (1,1,0), "center", "middle", "right");
	switching maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	switching setText(game["STRING_TEAM_AUTO_SWITCH"]);

	// Please wait
    please_wait = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX-50, level.hud_scoreboard_offsetY +108, 1.2, (1,1,0), "center", "middle", "right");
	please_wait maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	please_wait setText(game["STRING_PLEASE_WAIT"]);
}

/*
        Time-out

      (scoreboard)

    Going to Time-out
       Please wait
*/
Timeout()
{
    // Time-out
    timeout = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX-50, level.hud_scoreboard_offsetY -20, 1.2, (1,1,0), "center", "middle", "right");
	timeout maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	timeout setText(game["STRING_TIMEOUT"]);

    // Going to Time-out
    going_timeout = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX-50, level.hud_scoreboard_offsetY +105, 1.2, (1,1,0), "center", "middle", "right");
	going_timeout maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	going_timeout setText(game["STRING_GOING_TO_TIMEOUT"]);

    // Please wait
    please_wait = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX-50, level.hud_scoreboard_offsetY +123, 1.2, (1,1,0), "center", "middle", "right");
	please_wait maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	please_wait setText(game["STRING_PLEASE_WAIT"]);
}


/*
     Allies win!

    (scoreboard)

Going to ScoreBoard
    Please wait
*/
Matchover(isOvertime)
{
    if (!isDefined(isOvertime))
        isOvertime = false;

	// Its a TIE | Axis win! | Allies win!
    teamwin = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX-50, level.hud_scoreboard_offsetY -20, 1.2, (1,1,0), "center", "middle", "right");
	teamwin maps\mp\gametypes\_hud_system::showHUDSmooth(1);

	if (level.gametype != "dm")
	{
		if (game["allies_score"] == game["axis_score"])
			teamwin setText(game["STRING_ITS_TIE"]);
		else if (game["axis_score"] > game["allies_score"])
			teamwin setText(game["STRING_AXIS_WIN"]);
		else
			teamwin setText(game["STRING_ALLIES_WIN"]);
	}

    // Going to scoreboard || Going to overtime
    goingto = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX-50, level.hud_scoreboard_offsetY +90, 1.2, (1,1,0), "center", "middle", "right");
	goingto maps\mp\gametypes\_hud_system::showHUDSmooth(1);
    if(isOvertime)
		goingto setText(game["STRING_GOING_TO_OVERTIME"]);
	else
		goingto setText(game["STRING_GOING_TO_SCOREBOARD"]);

    // Please wait
    please_wait = maps\mp\gametypes\_hud_system::addHUD(level.hud_scoreboard_offsetX-50, level.hud_scoreboard_offsetY +108, 1.2, (1,1,0), "center", "middle", "right");
	please_wait maps\mp\gametypes\_hud_system::showHUDSmooth(1);
	please_wait setText(game["STRING_PLEASE_WAIT"]);
}




// Black scren + timer countdown
Half_Start(time)
{
	if ( time < 3 )
		time = 3;

	// Black fullscreen backgound with animation
    blackbg = maps\mp\gametypes\_hud_system::addHUD(0, 0, undefined, undefined, "left", "top", "fullscreen", "fullscreen");
	blackbg.alpha = 0;
	blackbg FadeOverTime(2);
	blackbg.alpha = 0.75;
	blackbg.sort = -3;
	blackbg.foreground = true;
	blackbg SetShader("black", 640, 480);

	// Match begins in
    blackbgtimertext = maps\mp\gametypes\_hud_system::addHUD(0, 183, 1.35, (1,1,1), "center", "top", "center");
	blackbgtimertext maps\mp\gametypes\_hud_system::showHUDSmooth(1.5);
	blackbgtimertext.sort = -2;
	blackbgtimertext.foreground = true;
	if (level.in_timeout)
		blackbgtimertext SetText(game["STRING_READYUP_MATCH_RESUMES_IN"]);
	else if (game["is_halftime"])
		blackbgtimertext SetText(game["STRING_READYUP_MATCH_CONTINUES_IN"]);
	else
		blackbgtimertext SetText(game["STRING_READYUP_MATCH_BEGINS_IN"]);

	// Count down timer
    blackbgtimer = maps\mp\gametypes\_hud_system::addHUD(0, 200, 1.35, (1,1,1), "center", "top", "center");
	blackbgtimer maps\mp\gametypes\_hud_system::showHUDSmooth(1.5);
	blackbgtimer.sort = -1;
	blackbgtimer.foreground = true;
	blackbgtimer settimer(time-0.5);
}


StratTime(time)
{
	// Strat Time
    strattime = maps\mp\gametypes\_hud_system::addHUD(320, 450, 2, (.98, .827, .58), "center", "bottom");
	strattime setText(game["STRING_STRAT_TIME"]);

    // 0:05
    strat_clock = maps\mp\gametypes\_hud_system::addHUD(-25, 445, 2, (.98, .827, .58), "left", "top", "center_safearea", "top");
	strat_clock setTimer(time);


	wait level.fps_multiplier * time;


	strattime FadeOverTime(0.5);
	strattime.alpha = 0;

	strat_clock FadeOverTime(0.5);
	strat_clock.alpha = 0;

	strat_clock moveovertime(0.5);
	strat_clock.x = -80;

	wait level.fps_multiplier * 0.5;

	strattime destroy();
	strat_clock destroy();
}
