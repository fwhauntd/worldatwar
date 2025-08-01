#include common_scripts\utility;
#include maps\_utility;
#include maps\_hud_util;

init()
{
	precachestring(&"SCRIPT_PLATFORM_CHEAT_USETOSLOWMO");
	precacheShellshock("chaplincheat");
	level.vision_cheat_enabled = false;
	level.tire_explosion = false;
	level.cheatStates = [];
	level.cheatFuncs = [];
	level.cheatDvars = [];
	level.cheatBobAmpOriginal = GetDvar("bg_bobAmplitudeStanding");
	level.cheatShowSlowMoHint = 0;
	if (!isdefined(level._effect))
		level._effect = [];
	level._effect["grain_test"] = loadfx("misc/grain_test");
	flag_init("has_cheated");
	level.visionSets["bw"] = false;
	level.visionSets["invert"] = false;
	level.visionSets["contrast"] = false;
	level.visionSets["chaplin"] = false;
	level thread death_monitor();
	flag_init("disable_slowmo_cheat");
    level thread velocity_hud\velocityhud::init();
}

player_init()
{
	self thread specialFeaturesMenu();
	players = get_players();
	if (self == players[0])
	{
		self slowmo_system_init();
	}
}

death_monitor()
{
	setDvars_based_on_varibles();
	while (1)
	{
		if (issaverecentlyloaded())
			setDvars_based_on_varibles();
		wait 0.1;
	}
}

setDvars_based_on_varibles()
{		
	for (index = 0; index < level.cheatDvars.size; index++)
		setDvar(level.cheatDvars[index], level.cheatStates[level.cheatDvars[index]]);

	if (!isdefined(level.credits_active) || !level.credits_active)
	{
		setdvar("credits_active", "0");
		setdvar("credits_load", "0");
	}
}

addCheat(toggleDvar, cheatFunc)
{
	setDvar(toggleDvar, 0);
	level.cheatStates[toggleDvar] = getDvarInt(toggleDvar);
	level.cheatFuncs[toggleDvar] = cheatFunc;

	if (level.cheatStates[toggleDvar])
		[[cheatFunc]](level.cheatStates[toggleDvar]);
}

checkCheatChanged(toggleDvar)
{
	cheatValue = getDvarInt(toggleDvar);
	if (level.cheatStates[toggleDvar] == cheatValue)
		return;

	if (cheatValue)
		flag_set("has_cheated");

	level.cheatStates[toggleDvar] = cheatValue;

	[[level.cheatFuncs[toggleDvar]]](cheatValue);
}

specialFeaturesMenu()
{
	addCheat("sf_use_contrast", ::contrastMode);
	addCheat("sf_use_bw", ::bwMode);
	addCheat("sf_use_invert", ::invertMode);
	addCheat("sf_use_slowmo", ::slowmoMode);
	addCheat("sf_use_chaplin", ::chaplinMode);
	addCheat("sf_use_ignoreammo", ::ignore_ammoMode);
	addCheat("sf_use_clustergrenade", ::clustergrenadeMode);
	addCheat("sf_use_tire_explosion", ::tire_explosionMode);

	level.cheatDvars = getArrayKeys(level.cheatStates);

	for (;;)
	{
		for (index = 0; index < level.cheatDvars.size; index++)
			checkCheatChanged(level.cheatDvars[index]);

		wait 0.5;
	}
}

tire_explosionMode(cheatValue)
{
	if (cheatValue)
		level.tire_explosion = true;
	else
		level.tire_explosion = false;
}

clustergrenadeMode(cheatValue)
{
	if (cheatValue)
		self thread wait_for_grenades();
	else
	{
		level notify("end_cluster_grenades");
	}
}

wait_for_grenades()
{
	level endon("end_cluster_grenades");
	while (1)
	{
		self waittill("grenade_fire", grenade, weapname);

		if (weapname != "fraggrenade")
			continue;

		grenade thread create_clusterGrenade();
	}
}

create_clusterGrenade()
{
	prevorigin = self.origin;
	while (1)
	{
		if (!isdefined(self))
			break;
		prevorigin = self.origin;
		wait .1;
	}

	prevorigin += (0,0,5);
	numSecondaries = 8;

	aiarray = getaiarray();
	if (aiarray.size == 0)
		return;

	ai = undefined;
	for (i = 0; i < aiarray.size; i++)
	{
		if (aiarray[i].team == "allies")
		{
			ai = aiarray[i];
			break;
		}
	}
	if (!isdefined(ai))
		ai = aiarray[0];

	oldweapon = ai.grenadeweapon;
	ai.grenadeweapon = "fraggrenade";

	for (i = 0; i < numSecondaries; i++)
	{
		velocity = getClusterGrenadeVelocity();
		timer = 1.5 + i / 6 + randomfloat(0.1);
		ai magicGrenadeManual(prevorigin, velocity, timer);
	}
	ai.grenadeweapon = oldweapon;
}

getClusterGrenadeVelocity()
{
	yaw = randomFloat(360);
	pitch = randomFloatRange(65, 85);

	amntz = sin(pitch);
	cospitch = cos(pitch);

	amntx = cos(yaw) * cospitch;
	amnty = sin(yaw) * cospitch;

	speed = randomFloatRange(400, 600);

	velocity = (amntx, amnty, amntz) * speed;
	return velocity;
}

ignore_ammoMode(cheatValue)
{
	if (level.script == "ac130")
		return;

	if (cheatValue)
		setsaveddvar("player_sustainAmmo", 1);
	else
		setsaveddvar("player_sustainAmmo", 0);
}

contrastMode(cheatValue)
{
	level.visionSets["contrast"] = !!cheatValue;
	applyVisionSets();
}

bwMode(cheatValue)
{
	level.visionSets["bw"] = !!cheatValue;
	applyVisionSets();
}

invertMode(cheatValue)
{
	level.visionSets["invert"] = !!cheatValue;
	applyVisionSets();
}

applyVisionSets()
{
	if (level.script == "ac130")
		return;

	visionSet = "";
	if (level.visionSets["bw"])
		visionSet += "_bw";
	if (level.visionSets["invert"])
		visionSet += "_invert";
	if (level.visionSets["contrast"])
		visionSet += "_contrast";

	if (level.visionSets["chaplin"])
	{
		level.vision_cheat_enabled = true;
		visionSetNaked("sepia", 0.5);
	}
	else if (visionSet != "")
	{
		level.vision_cheat_enabled = true;
		visionSetNaked("cheat" + visionSet, 1.0);
	}
	else
	{
		level.vision_cheat_enabled = false;
		visionSetNaked(level.lvl_visionset, 3.0);
	}
}

slowmo_system_init()
{
	if (!IsDefined(level.slowmo))
	{
		level.slowmo = spawnstruct();

		slowmo_system_defaults();

		level.slowmo.speed_current = level.slowmo.speed_norm;
		level.slowmo.lerp_interval = .05;
		level.slowmo.lerping = 0;
	}
}

slowmo_system_defaults()
{
	level.slowmo.lerp_time_in = 0.0;
	level.slowmo.lerp_time_out = .25;
	level.slowmo.speed_slow = 0.4;
	level.slowmo.speed_norm = 1.0;
}

slowmo_check_system()
{
	return true;
}

slowmo_hintprint()
{
	if (level.cheatShowSlowMoHint != 0)
	{
		level.cheatShowSlowMoHint = 0;
		return;
	}

	if (!level.console)
		return;

	level.cheatShowSlowMoHint = 1;
	myTextSize = 1.6;

	myHintBack = createIcon("black", 650, 30);
	myHintBack.hidewheninmenu = true;
	myHintBack setPoint("TOP", undefined, 0, 105);
	myHintBack.alpha = .2;
	myHintBack.sort = 0;

	myHintString = createFontString("objective", myTextSize);
	myHintString.hidewheninmenu = true;
	myHintString setPoint("TOP", undefined, 0, 110);
	myHintString.sort = 0.5;
	myHintString setText(&"SCRIPT_PLATFORM_CHEAT_USETOSLOWMO");

	for (cycles = 0; cycles < 100; cycles++)
	{
		if (level.cheatShowSlowMoHint != 1)
			break;
		if (isDefined(level.hintElem))
			break;
		wait 0.1;
	}

	level.cheatShowSlowMoHint = 0;
	myHintBack Destroy();
	myHintString Destroy();
}

slowmoMode(cheatValue)
{
	if (cheatValue)
	{
		level.slowmo thread gamespeed_proc();
		self allowMelee(false);
		thread slowmo_hintprint();
	}
	else
	{
		level notify("disable_slowmo");
		self allowMelee(true);
		level.slowmo thread gamespeed_reset();
		level.cheatShowSlowMoHint = 0;
	}
}

gamespeed_proc()
{
	level endon("disable_slowmo");

	self thread gamespeed_reset_on_death();

	while (1)
	{
		self waittill("action_notify_melee");
		level.cheatShowSlowMoHint = 0;

		if (!flag("disable_slowmo_cheat"))
		{
			if (self.speed_current < level.slowmo.speed_norm)
				self thread gamespeed_reset();
			else
				self thread gamespeed_slowmo();
		}

		waittillframeend;
	}
}

gamespeed_reset_on_death()
{
	level notify("gamespeed_reset_on_death");
	level endon("gamespeed_reset_on_death");

	self waittill("death");
	self thread gamespeed_reset();
}

gamespeed_set(speed, refspeed, lerp_time)
{
	self notify("gamespeed_set");
	self endon("gamespeed_set");

	default_range = (speed - refspeed);
	actual_range = (speed - self.speed_current);
	actual_rangebytime = actual_range * lerp_time;

	if (!default_range)
		return;

	time = (actual_rangebytime / default_range);

	interval = self.lerp_interval;
	cycles = int(time / interval);
	if (!cycles)
		cycles = 1;
	increment = (actual_range / cycles);
	self.lerping = time;

	while (cycles)
	{
		self.speed_current += increment;
		settimescale(self.speed_current);
		cycles--;
		self.lerping -= interval;
		wait interval;
	}

	self.speed_current = speed;
	settimescale(self.speed_current);
	self.lerping = 0;
}

gamespeed_slowmo()
{
	gamespeed_set(self.speed_slow, self.speed_norm, self.lerp_time_in);
}

gamespeed_reset()
{
	gamespeed_set(self.speed_norm, self.speed_slow, self.lerp_time_out);
}

chaplinMode(cheatValue)
{
	if (cheatValue)
	{
		println("Chaplin started!");

		SetSavedDvar("chaplincheat", "1");
		level.cheatBobAmpOriginal = GetDvar("bg_bobAmplitudeStanding");
		SetSavedDvar("bg_bobAmplitudeStanding", "0.02 0.014");

		MusicStop(0, true);
		level.visionSets["chaplin"] = true;

		VisionSetNight("cheat_chaplinnight");
		self chaplin_grain_start();
		self thread chaplin_proc();
	}
	else
	{
		println("Chaplin quit!");

		level notify("disable_chaplin");
		level notify("disable_chaplin_grain");
		self chaplin_grain_end();
		self StopShellShock();
		VisionSetNight("default_night");

		level.visionSets["chaplin"] = false;
		MusicStop(0, true);

		SetSavedDvar("bg_bobAmplitudeStanding", level.cheatBobAmpOriginal);
		SetSavedDvar("chaplincheat", "0");

		if (!flag("disable_slowmo_cheat"))
			SetTimeScale(1.0);
	}

	applyVisionSets();
}

chaplin_titlecard_create_background()
{
	overlay = newHudElem();
	overlay.x = 0;
	overlay.y = 0;
	overlay setshader("black", 640, 480);
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = 1;
	overlay.foreground = true;
	overlay.sort = 0;

	return overlay;
}

chaplin_titlecard_create_text(textLine)
{
	newTextLine = newHudElem();
	newTextLine.x = 0;
	newTextLine.y = -40;
	newTextLine.alignX = "center";
	newTextLine.alignY = "middle";
	newTextLine.horzAlign = "center";
	newTextLine.vertAlign = "middle";
	newTextLine.foreground = true;
	newTextLine setText(textLine);
	newTextLine.fontscale = 3;
	newTextLine.alpha = 1;
	newTextLine.sort = 1;
	newTextLine.color = (0.976, 0.796, 0.412);

	return newTextLine;
}

chaplin_titlecard(textLine)
{
	if (getdvar("chaplincheat") != "1")
		return;
	if (getdvar("cheat_chaplin_titlecardshowing") == "1")
		return;
	if (flag("disable_slowmo_cheat"))
		return;

	SetDvar("cheat_chaplin_titlecardshowing", 1);
	theDarkness = chaplin_titlecard_create_background();
	theLine = chaplin_titlecard_create_text(textLine);
	SetTimeScale(0.05);

	wait 0.15;

	SetTimeScale(1);
	theDarkness Destroy();
	theLine Destroy();
	SetDvar("cheat_chaplin_titlecardshowing", 0);
}

chaplin_proc()
{
	level endon("disable_chaplin");

	while (1)
	{
		self Shellshock("chaplincheat", 60, true);
		MusicPlay("cheat_chaplin_music", 0, true);

		wait 0.5;

		if (!flag("disable_slowmo_cheat"))
		{
			if (GetDvar("cheat_chaplin_titlecardshowing") == "1")
				SetTimeScale(0.05);
			else
				SetTimeScale(1.7);
		}
	}
}

chaplin_grain_start()
{
	self.cheatGrainLooper = spawn("script_model", self geteye());
	self.cheatGrainLooper setmodel("tag_origin");
	self.cheatGrainLooper hide();
	PlayFXOnTag(level._effect["grain_test"], self.cheatGrainLooper, "tag_origin");
	self thread chaplin_grain_proc();
}

chaplin_grain_end()
{
	if (!IsDefined(self.cheatGrainLooper))
		return;
	self.cheatGrainLooper Delete();
}

chaplin_grain_proc()
{
	level endon("disable_chaplin_grain");

	while (1)
	{
		self.cheatGrainLooper.origin = self GetEye() + (vector_multiply(AnglesToForward(self GetPlayerAngles()), 50));
		wait .01;
	}
}

is_cheating()
{
	for (i = 0; i < level.cheatDvars.size; i++)
		if (level.cheatStates[level.cheatDvars[i]])
			return true;
	return false;
}
