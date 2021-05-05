#include maps\mp\gametypes\global\_global;

init()
{
    if (!isDefined(game["is_cracked"]))
    {
      game["is_cracked"] = true;
    }

    // In punkbuster is disabled, guid is always 0 and we are unable to check if server is cracked
    if (getCvarInt("sv_punkbuster") == 0)
    {
      game["is_cracked"] = false;
      return;
    }

    if (!level.in_readyup)
      return;

    addEventListener("onConnected",     ::onConnected);
}

onConnected()
{
  if (game["is_cracked"])
  {
    if (self getGuid() != 0)
    {
      game["is_cracked"] = false;
    }
  }
}
