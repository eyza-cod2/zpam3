#include maps\mp\gametypes\global\_global;

// Source from maps/mp/pam/quickmessages.gsc
// content moved here

init()
{
	if(game["firstInit"])
	{
		precacheHeadIcon("talkingicon");
	}
}

quickcommands(response)
{
	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || self.pers["team"] == "none" || isdefined(self.spamdelay))
		return;

	self.spamdelay = true;

	if(self.pers["team"] == "allies")
	{
		switch(game["allies"])
		{
		case "american":
			switch(response)
			{
			case "1":
				soundalias = "US_mp_cmd_followme";
				saytext = &"QUICKMESSAGE_FOLLOW_ME";
				//saytext = "Follow Me!";
				break;

			case "2":
				soundalias = "US_mp_cmd_movein";
				saytext = &"QUICKMESSAGE_MOVE_IN";
				//saytext = "Move in!";
				break;

			case "3":
				soundalias = "US_mp_cmd_fallback";
				saytext = &"QUICKMESSAGE_FALL_BACK";
				//saytext = "Fall back!";
				break;

			case "4":
				soundalias = "US_mp_cmd_suppressfire";
				saytext = &"QUICKMESSAGE_SUPPRESSING_FIRE";
				//saytext = "Suppressing fire!";
				break;

			case "5":
				soundalias = "US_mp_cmd_attackleftflank";
				saytext = &"QUICKMESSAGE_ATTACK_LEFT_FLANK";
				//saytext = "Attack left flank!";
				break;

			case "6":
				soundalias = "US_mp_cmd_attackrightflank";
				saytext = &"QUICKMESSAGE_ATTACK_RIGHT_FLANK";
				//saytext = "Attack right flank!";
				break;

			case "7":
				soundalias = "US_mp_cmd_holdposition";
				saytext = &"QUICKMESSAGE_HOLD_THIS_POSITION";
				//saytext = "Hold this position!";
				break;

			default:
				assert(response == "8");
				soundalias = "US_mp_cmd_regroup";
				saytext = &"QUICKMESSAGE_REGROUP";
				//saytext = "Regroup!";
				break;
			}
			break;

		case "british":
			switch(response)
			{
			case "1":
				soundalias = "UK_mp_cmd_followme";
				saytext = &"QUICKMESSAGE_FOLLOW_ME";
				//saytext = "Follow Me!";
				break;

			case "2":
				soundalias = "UK_mp_cmd_movein";
				saytext = &"QUICKMESSAGE_MOVE_IN";
				//saytext = "Move in!";
				break;

			case "3":
				soundalias = "UK_mp_cmd_fallback";
				saytext = &"QUICKMESSAGE_FALL_BACK";
				//saytext = "Fall back!";
				break;

			case "4":
				soundalias = "UK_mp_cmd_suppressfire";
				saytext = &"QUICKMESSAGE_SUPPRESSING_FIRE";
				//saytext = "Suppressing fire!";
				break;

			case "5":
				soundalias = "UK_mp_cmd_attackleftflank";
				saytext = &"QUICKMESSAGE_ATTACK_LEFT_FLANK";
				//saytext = "Attack left flank!";
				break;

			case "6":
				soundalias = "UK_mp_cmd_attackrightflank";
				saytext = &"QUICKMESSAGE_ATTACK_RIGHT_FLANK";
				//saytext = "Attack right flank!";
				break;

			case "7":
				soundalias = "UK_mp_cmd_holdposition";
				saytext = &"QUICKMESSAGE_HOLD_THIS_POSITION";
				//saytext = "Hold this position!";
				break;

			default:
				assert(response == "8");
				soundalias = "UK_mp_cmd_regroup";
				saytext = &"QUICKMESSAGE_REGROUP";
				//saytext = "Regroup!";
				break;
			}
			break;

		default:
			assert(game["allies"] == "russian");
			switch(response)
			{
			case "1":
				soundalias = "RU_mp_cmd_followme";
				saytext = &"QUICKMESSAGE_FOLLOW_ME";
				//saytext = "Follow Me!";
				break;

			case "2":
				soundalias = "RU_mp_cmd_movein";
				saytext = &"QUICKMESSAGE_MOVE_IN";
				//saytext = "Move in!";
				break;

			case "3":
				soundalias = "RU_mp_cmd_fallback";
				saytext = &"QUICKMESSAGE_FALL_BACK";
				//saytext = "Fall back!";
				break;

			case "4":
				soundalias = "RU_mp_cmd_suppressfire";
				saytext = &"QUICKMESSAGE_SUPPRESSING_FIRE";
				//saytext = "Suppressing fire!";
				break;

			case "5":
				soundalias = "RU_mp_cmd_attackleftflank";
				saytext = &"QUICKMESSAGE_ATTACK_LEFT_FLANK";
				//saytext = "Attack left flank!";
				break;

			case "6":
				soundalias = "RU_mp_cmd_attackrightflank";
				saytext = &"QUICKMESSAGE_ATTACK_RIGHT_FLANK";
				//saytext = "Attack right flank!";
				break;

			case "7":
				soundalias = "RU_mp_cmd_holdposition";
				saytext = &"QUICKMESSAGE_HOLD_THIS_POSITION";
				//saytext = "Hold this position!";
				break;

			default:
				assert(response == "8");
				soundalias = "RU_mp_cmd_regroup";
				saytext = &"QUICKMESSAGE_REGROUP";
				//saytext = "Regroup!";
				break;
			}
			break;
		}
	}
	else
	{
		assert(self.pers["team"] == "axis");
		switch(game["axis"])
		{
		default:
			assert(game["axis"] == "german");
			switch(response)
			{
			case "1":
				soundalias = "GE_mp_cmd_followme";
				saytext = &"QUICKMESSAGE_FOLLOW_ME";
				//saytext = "Follow Me!";
				break;

			case "2":
				soundalias = "GE_mp_cmd_movein";
				saytext = &"QUICKMESSAGE_MOVE_IN";
				//saytext = "Move in!";
				break;

			case "3":
				soundalias = "GE_mp_cmd_fallback";
				saytext = &"QUICKMESSAGE_FALL_BACK";
				//saytext = "Fall back!";
				break;

			case "4":
				soundalias = "GE_mp_cmd_suppressfire";
				saytext = &"QUICKMESSAGE_SUPPRESSING_FIRE";
				//saytext = "Suppressing fire!";
				break;

			case "5":
				soundalias = "GE_mp_cmd_attackleftflank";
				saytext = &"QUICKMESSAGE_ATTACK_LEFT_FLANK";
				//saytext = "Attack left flank!";
				break;

			case "6":
				soundalias = "GE_mp_cmd_attackrightflank";
				saytext = &"QUICKMESSAGE_ATTACK_RIGHT_FLANK";
				//saytext = "Attack right flank!";
				break;

			case "7":
				soundalias = "GE_mp_cmd_holdposition";
				saytext = &"QUICKMESSAGE_HOLD_THIS_POSITION";
				//saytext = "Hold this position!";
				break;

			default:
				assert(response == "8");
				soundalias = "GE_mp_cmd_regroup";
				saytext = &"QUICKMESSAGE_REGROUP";
				//saytext = "Regroup!";
				break;
			}
			break;
		}
	}

	self saveHeadIcon();
	self doQuickMessage(soundalias, saytext);

	wait level.fps_multiplier * 2;
	self.spamdelay = undefined;
	self restoreHeadIcon();
}

quickstatements(response)
{
	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || self.pers["team"] == "none" || isdefined(self.spamdelay))
		return;

	self.spamdelay = true;

	if(self.pers["team"] == "allies")
	{
		switch(game["allies"])
		{
		case "american":
			switch(response)
			{
			case "1":
				soundalias = "US_mp_stm_enemyspotted";
				saytext = &"QUICKMESSAGE_ENEMY_SPOTTED";
				//saytext = "Enemy spotted!";
				break;

			case "2":
				soundalias = "US_mp_stm_enemydown";
				saytext = &"QUICKMESSAGE_ENEMY_DOWN";
				//saytext = "Enemy down!";
				break;

			case "3":
				soundalias = "US_mp_stm_iminposition";
				saytext = &"QUICKMESSAGE_IM_IN_POSITION";
				//saytext = "I'm in position.";
				break;

			case "4":
				soundalias = "US_mp_stm_areasecure";
				saytext = &"QUICKMESSAGE_AREA_SECURE";
				//saytext = "Area secure!";
				break;

			case "5":
				soundalias = "US_mp_stm_grenade";
				saytext = &"QUICKMESSAGE_GRENADE";
				//saytext = "Grenade!";
				break;

			case "6":
				soundalias = "US_mp_stm_sniper";
				saytext = &"QUICKMESSAGE_SNIPER";
				//saytext = "Sniper!";
				break;

			case "7":
				soundalias = "US_mp_stm_needreinforcements";
				saytext = &"QUICKMESSAGE_NEED_REINFORCEMENTS";
				//saytext = "Need reinforcements!";
				break;

			default:
				assert(response == "8");
				soundalias = "US_mp_stm_holdyourfire";
				saytext = &"QUICKMESSAGE_HOLD_YOUR_FIRE";
				//saytext = "Hold your fire!";
				break;
			}
			break;

		case "british":
			switch(response)
			{
			case "1":
				soundalias = "UK_mp_stm_enemyspotted";
				saytext = &"QUICKMESSAGE_ENEMY_SPOTTED";
				//saytext = "Enemy spotted!";
				break;

			case "2":
				soundalias = "UK_mp_stm_enemydown";
				saytext = &"QUICKMESSAGE_ENEMY_DOWN";
				//saytext = "Enemy down!";
				break;

			case "3":
				soundalias = "UK_mp_stm_iminposition";
				saytext = &"QUICKMESSAGE_IM_IN_POSITION";
				//saytext = "I'm in position.";
				break;

			case "4":
				soundalias = "UK_mp_stm_areasecure";
				saytext = &"QUICKMESSAGE_AREA_SECURE";
				//saytext = "Area secure!";
				break;

			case "5":
				soundalias = "UK_mp_stm_grenade";
				saytext = &"QUICKMESSAGE_GRENADE";
				//saytext = "Grenade!";
				break;

			case "6":
				soundalias = "UK_mp_stm_sniper";
				saytext = &"QUICKMESSAGE_SNIPER";
				//saytext = "Sniper!";
				break;

			case "7":
				soundalias = "UK_mp_stm_needreinforcements";
				saytext = &"QUICKMESSAGE_NEED_REINFORCEMENTS";
				//saytext = "Need reinforcements!";
				break;

			default:
				assert(response == "8");
				soundalias = "UK_mp_stm_holdyourfire";
				saytext = &"QUICKMESSAGE_HOLD_YOUR_FIRE";
				//saytext = "Hold your fire!";
				break;
			}
			break;

		default:
			assert(game["allies"] == "russian");
			switch(response)
			{
			case "1":
				soundalias = "RU_mp_stm_enemyspotted";
				saytext = &"QUICKMESSAGE_ENEMY_SPOTTED";
				//saytext = "Enemy spotted!";
				break;

			case "2":
				soundalias = "RU_mp_stm_enemydown";
				saytext = &"QUICKMESSAGE_ENEMY_DOWN";
				//saytext = "Enemy down!";
				break;

			case "3":
				soundalias = "RU_mp_stm_iminposition";
				saytext = &"QUICKMESSAGE_IM_IN_POSITION";
				//saytext = "I'm in position.";
				break;

			case "4":
				soundalias = "RU_mp_stm_areasecure";
				saytext = &"QUICKMESSAGE_AREA_SECURE";
				//saytext = "Area secure!";
				break;

			case "5":
				soundalias = "RU_mp_stm_grenade";
				saytext = &"QUICKMESSAGE_GRENADE";
				//saytext = "Grenade!";
				break;

			case "6":
				soundalias = "RU_mp_stm_sniper";
				saytext = &"QUICKMESSAGE_SNIPER";
				//saytext = "Sniper!";
				break;

			case "7":
				soundalias = "RU_mp_stm_needreinforcements";
				saytext = &"QUICKMESSAGE_NEED_REINFORCEMENTS";
				//saytext = "Need reinforcements!";
				break;

			default:
				assert(response == "8");
				soundalias = "RU_mp_stm_holdyourfire";
				saytext = &"QUICKMESSAGE_HOLD_YOUR_FIRE";
				//saytext = "Hold your fire!";
				break;
			}
			break;
		}
	}
	else
	{
		assert(self.pers["team"] == "axis");
		switch(game["axis"])
		{
		default:
			assert(game["axis"] == "german");
			switch(response)
			{
			case "1":
				soundalias = "GE_mp_stm_enemyspotted";
				saytext = &"QUICKMESSAGE_ENEMY_SPOTTED";
				//saytext = "Enemy spotted!";
				break;

			case "2":
				soundalias = "GE_mp_stm_enemydown";
				saytext = &"QUICKMESSAGE_ENEMY_DOWN";
				//saytext = "Enemy down!";
				break;

			case "3":
				soundalias = "GE_mp_stm_iminposition";
				saytext = &"QUICKMESSAGE_IM_IN_POSITION";
				//saytext = "I'm in position.";
				break;

			case "4":
				soundalias = "GE_mp_stm_areasecure";
				saytext = &"QUICKMESSAGE_AREA_SECURE";
				//saytext = "Area secure!";
				break;

			case "5":
				soundalias = "GE_mp_stm_grenade";
				saytext = &"QUICKMESSAGE_GRENADE";
				//saytext = "Grenade!";
				break;

			case "6":
				soundalias = "GE_mp_stm_sniper";
				saytext = &"QUICKMESSAGE_SNIPER";
				//saytext = "Sniper!";
				break;

			case "7":
				soundalias = "GE_mp_stm_needreinforcements";
				saytext = &"QUICKMESSAGE_NEED_REINFORCEMENTS";
				//saytext = "Need reinforcements!";
				break;

			default:
				assert(response == "8");
				soundalias = "GE_mp_stm_holdyourfire";
				saytext = &"QUICKMESSAGE_HOLD_YOUR_FIRE";
				//saytext = "Hold your fire!";
				break;
			}
			break;
		}
	}

	self saveHeadIcon();
	self doQuickMessage(soundalias, saytext);

	wait level.fps_multiplier * 2;
	self.spamdelay = undefined;
	self restoreHeadIcon();
}

quickresponses(response)
{
	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || self.pers["team"] == "none" || isdefined(self.spamdelay))
		return;

	self.spamdelay = true;

	if(self.pers["team"] == "allies")
	{
		switch(game["allies"])
		{
		case "american":
			switch(response)
			{
			case "1":
				soundalias = "US_mp_rsp_yessir";
				saytext = &"QUICKMESSAGE_YES_SIR";
				//saytext = "Yes Sir!";
				break;

			case "2":
				soundalias = "US_mp_rsp_nosir";
				saytext = &"QUICKMESSAGE_NO_SIR";
				//saytext = "No Sir!";
				break;

			case "3":
				soundalias = "US_mp_rsp_onmyway";
				saytext = &"QUICKMESSAGE_IM_ON_MY_WAY";
				//saytext = "On my way.";
				break;

			case "4":
				soundalias = "US_mp_rsp_sorry";
				saytext = &"QUICKMESSAGE_SORRY";
				//saytext = "Sorry.";
				break;

			case "5":
				soundalias = "US_mp_rsp_greatshot";
				saytext = &"QUICKMESSAGE_GREAT_SHOT";
				//saytext = "Great shot!";
				break;

			case "6":
				soundalias = "US_mp_rsp_tooklongenough";
				saytext = &"QUICKMESSAGE_TOOK_LONG_ENOUGH";
				//saytext = "Took long enough!";
				break;

			default:
				assert(response == "7");
				soundalias = "US_mp_rsp_areyoucrazy";
				saytext = &"QUICKMESSAGE_ARE_YOU_CRAZY";
				//saytext = "Are you crazy?";
				break;
			}
			break;

		case "british":
			switch(response)
			{
			case "1":
				soundalias = "UK_mp_rsp_yessir";
				saytext = &"QUICKMESSAGE_YES_SIR";
				//saytext = "Yes Sir!";
				break;

			case "2":
				soundalias = "UK_mp_rsp_nosir";
				saytext = &"QUICKMESSAGE_NO_SIR";
				//saytext = "No Sir!";
				break;

			case "3":
				soundalias = "UK_mp_rsp_onmyway";
				saytext = &"QUICKMESSAGE_IM_ON_MY_WAY";
				//saytext = "On my way.";
				break;

			case "4":
				soundalias = "UK_mp_rsp_sorry";
				saytext = &"QUICKMESSAGE_SORRY";
				//saytext = "Sorry.";
				break;

			case "5":
				soundalias = "UK_mp_rsp_greatshot";
				saytext = &"QUICKMESSAGE_GREAT_SHOT";
				//saytext = "Great shot!";
				break;

			case "6":
				soundalias = "UK_mp_rsp_tooklongenough";
				saytext = &"QUICKMESSAGE_TOOK_LONG_ENOUGH";
				//saytext = "Took long enough!";
				break;

			default:
				assert(response == "7");
				soundalias = "UK_mp_rsp_areyoucrazy";
				saytext = &"QUICKMESSAGE_ARE_YOU_CRAZY";
				//saytext = "Are you crazy?";
				break;
			}
			break;

		default:
			assert(game["allies"] == "russian");
			switch(response)
			{
			case "1":
				soundalias = "RU_mp_rsp_yessir";
				saytext = &"QUICKMESSAGE_YES_SIR";
				//saytext = "Yes Sir!";
				break;

			case "2":
				soundalias = "RU_mp_rsp_nosir";
				saytext = &"QUICKMESSAGE_NO_SIR";
				//saytext = "No Sir!";
				break;

			case "3":
				soundalias = "RU_mp_rsp_onmyway";
				saytext = &"QUICKMESSAGE_IM_ON_MY_WAY";
				//saytext = "On my way.";
				break;

			case "4":
				soundalias = "RU_mp_rsp_sorry";
				saytext = &"QUICKMESSAGE_SORRY";
				//saytext = "Sorry.";
				break;

			case "5":
				soundalias = "RU_mp_rsp_greatshot";
				saytext = &"QUICKMESSAGE_GREAT_SHOT";
				//saytext = "Great shot!";
				break;

			case "6":
				soundalias = "RU_mp_rsp_tooklongenough";
				saytext = &"QUICKMESSAGE_TOOK_LONG_ENOUGH";
				//saytext = "Took long enough!";
				break;

			default:
				assert(response == "7");
				soundalias = "RU_mp_rsp_areyoucrazy";
				saytext = &"QUICKMESSAGE_ARE_YOU_CRAZY";
				//saytext = "Are you crazy?";
				break;
			}
			break;
		}
	}
	else
	{
		assert(self.pers["team"] == "axis");
		switch(game["axis"])
		{
		default:
			assert(game["axis"] == "german");
			switch(response)
			{
			case "1":
				soundalias = "GE_mp_rsp_yessir";
				saytext = &"QUICKMESSAGE_YES_SIR";
				//saytext = "Yes Sir!";
				break;

			case "2":
				soundalias = "GE_mp_rsp_nosir";
				saytext = &"QUICKMESSAGE_NO_SIR";
				//saytext = "No Sir!";
				break;

			case "3":
				soundalias = "GE_mp_rsp_onmyway";
				saytext = &"QUICKMESSAGE_IM_ON_MY_WAY";
				//saytext = "On my way.";
				break;

			case "4":
				soundalias = "GE_mp_rsp_sorry";
				saytext = &"QUICKMESSAGE_SORRY";
				//saytext = "Sorry.";
				break;

			case "5":
				soundalias = "GE_mp_rsp_greatshot";
				saytext = &"QUICKMESSAGE_GREAT_SHOT";
				//saytext = "Great shot!";
				break;

			case "6":
				soundalias = "GE_mp_rsp_tooklongenough";
				saytext = &"QUICKMESSAGE_TOOK_LONG_ENOUGH";
				//saytext = "Took long enough!";
				break;

			default:
				assert(response == "7");
				soundalias = "GE_mp_rsp_areyoucrazy";
				saytext = &"QUICKMESSAGE_ARE_YOU_CRAZY";
				//saytext = "Are you crazy?";
				break;
			}
			break;
		}
	}

	self saveHeadIcon();
	self doQuickMessage(soundalias, saytext);

	wait level.fps_multiplier * 2;
	self.spamdelay = undefined;
	self restoreHeadIcon();
}

doQuickMessage(soundalias, saytext)
{
	if(self.sessionstate != "playing")
		return;

	if(isdefined(level.QuickMessageToAll) && level.QuickMessageToAll)
	{
		if ( !isDefined(level.in_strattime) || (isDefined(level.in_strattime) && !level.in_strattime) )
		{
			self.headiconteam = "none";
			self.headicon = "talkingicon";
		}

		self playSound(soundalias);
		self sayAll(saytext);
	}
	else
	{
		if(self.sessionteam == "allies")
			self.headiconteam = "allies";
		else if(self.sessionteam == "axis")
			self.headiconteam = "axis";

		if ( !isDefined(level.in_strattime) || (isDefined(level.in_strattime) && !level.in_strattime) )
			self.headicon = "talkingicon";

		self playSound(soundalias);
		self sayTeam(saytext);
		self pingPlayer();
	}
}

saveHeadIcon()
{
	if(isdefined(self.headicon))
		self.oldheadicon = self.headicon;

	if(isdefined(self.headiconteam))
		self.oldheadiconteam = self.headiconteam;
}

restoreHeadIcon()
{
	if(isdefined(self.oldheadicon))
		self.headicon = self.oldheadicon;

	if(isdefined(self.oldheadiconteam))
		self.headiconteam = self.oldheadiconteam;
}
