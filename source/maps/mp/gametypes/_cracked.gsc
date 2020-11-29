#include maps\mp\gametypes\_callbacksetup;

init()
{
    if (!isDefined(game["is_cracked"]))
    {
      game["is_cracked"] = true;
      setCvar("pam_pbsv_cracked", "");
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

      // If player has defined guid, it means server is original and we have to set kicking for duplicate key
      setCvar("pam_pbsv_cracked", "pb_sv_guidRelax 0; set pam_pbsv_cracked \"\"");
    }
  }
}
