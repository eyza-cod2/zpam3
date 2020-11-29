#include maps\mp\gametypes\_callbacksetup;

init()
{
    wait level.fps_multiplier * 1; // wait a while before measuring lags

    level thread lagThread();
}

lagThread()
{
  time = gettime();
  for(;;)
  {
    wait level.frame;

    time2 = gettime();
    dif = (time2 - time) / 1000.0;

    //level.dif = "(" + time2 + " - " + time + ") = " + dif + "   >   " + level.frame;


    if (dif > level.frame)
    {
      count = dif / level.frame;

      players = getentarray("player", "classname");
      for(i = 0; i < players.size; i++)
    	{
    		player = players[i];
        //if (issubstr(player.name, "eyza") || getcvar("debug") != "") // TODO
          player iprintln("Server lag detected! ("+int(count)+" frames)");
    	}
    }

    time = time2;
  }
}
