#include maps\mp\gametypes\global\_global;

/*
If you climb ladder or wall, the "weapon switch" sound was made only for 1st person player, it was silent for other players.
The sound is now removed completly - meaning if you climb ladder or wall, "weapon switch" sound is not played at all - same for everybody

PAM disabled playing weapon sound change in soundaliases and this script is plaing the sound manually

| --------------------------------------------------------------|
| PAM		| Action	| Ladder	| Climb wall	|
| --------------|---------------|---------------|---------------|
| Original 	| Client	| sound		| sound		|
| Original 	| Others	| -		| -		|
| --------------|---------------|---------------|---------------|
| zPAM3.32 	| Client	| -		| -		|
| zPAM3.32 	| Others	| -		| -		|
| --------------------------------------------------------------|

This sound is played only if you regularly and intentionally switch the weapon

*/


Init()
{
	addEventListener("onConnected",     ::onConnected);
}

onConnected()
{
	self thread bug_fix();
}



bug_fix()
{
	self endon("disconnect");

	currentLast = "none";
	aliveLast = false;
	weapon1Last = "none";
	weapon2Last = "none";

	for(;;)
	{
		weapon1 = self getweaponslotweapon("primary");
	    	weapon2 = self getweaponslotweapon("primaryb");

		current = self getcurrentweapon();
		alive = self.sessionstate == "playing";

		if (alive && aliveLast && current != currentLast && currentLast != "none" && current != "none" && weapon1 == weapon1Last && weapon2 == weapon2Last)
		{
			//self iprintln("^2Climb sound fix");

			self playSound("zpam_weap_raise");
		}

		currentLast = current;
		aliveLast = alive;
		weapon1Last = weapon1;
	    	weapon2Last = weapon2;

		wait level.frame;
	}
}
