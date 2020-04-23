#include maps\mp\gametypes\_callbacksetup;

// Source from maps/mp/pam/damagefeedback.gsc
// content moved here

init()
{
	precacheShader("damage_feedback");

	// NOTE: this is what?
	precacheRumble("damage_heavy");

    addEventListener("onConnected",     ::onConnected);
}

onConnected()
{
	self.hud_damagefeedback = newClientHudElem(self);
	self.hud_damagefeedback.horzAlign = "center";
	self.hud_damagefeedback.vertAlign = "middle";
	self.hud_damagefeedback.x = -12;
	self.hud_damagefeedback.y = -12;
	self.hud_damagefeedback.alpha = 0;
	self.hud_damagefeedback.archived = true;
	self.hud_damagefeedback setShader("damage_feedback", 24, 24);
}

updateDamageFeedback()
{
	if(isPlayer(self))
	{
		if (level.scr_show_hitblip)
		{
			self.hud_damagefeedback.alpha = 1;
			self.hud_damagefeedback fadeOverTime(1);
			self.hud_damagefeedback.alpha = 0;

			self playlocalsound("MP_hit_alert");
		}
	}
}
