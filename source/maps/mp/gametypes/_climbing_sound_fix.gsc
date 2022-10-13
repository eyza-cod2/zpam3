#include maps\mp\gametypes\global\_global;

/*
If you climb ladder or wall, the "weapon switch" sound is made only for 1st person player, its silent for other players
If you hide weapon and you climb ladder or obstacle, no "weapon switch" sound is played, its silent for everybody

PAM disabled playing weapon sound change in soundaliases and this script is plaing the sound manually

| -----------------------------------------------------------------------------------------------
| PAM		| 		| 	Weapon normal state	| 	Weapon holded down	|
| PAM		| Action	| Ladder	| Climb wall	| Ladder entering | Climb wall	|
| --------------|---------------|---------------|---------------|-----------------|-------------|
| Original 	| Client	| sound		| sound		| -		  | -		|
| Original 	| Others	| -		| -		| -		  | -		|
| --------------|---------------|---------------|---------------|-----------------|--------------
| zPAM3.31 	| Client	| sound		| sound		| -		  | -		|
| zPAM3.31 	| Others	| sound		| sound		| -		  | -		|
| -----------------------------------------------------------------------------------------------

If players want to silently climb ladder or wall, they need to bug weapon by scrolling down 2x and hold left mouse (weapon holded down)
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

		if (alive && aliveLast && current != currentLast && currentLast != "none" && weapon1 == weapon1Last && weapon2 == weapon2Last)
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
