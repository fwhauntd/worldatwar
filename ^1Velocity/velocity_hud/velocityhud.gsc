#include common_scripts\utility;
#include maps\_utility;
#include maps\_hud_util;

init()
{
    level thread on_player_connect();
}

on_player_connect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread on_player_spawn();
        player thread on_connect();
    }
}

on_player_spawn()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("spawned_player");
        self thread on_spawn();

        self.score = 777777;
    }
}

on_connect()
{
    self endon("disconnect");
    self._y = -50;
    self thread speed_meter();
}

on_spawn()
{
    self endon("disconnect");
    self endon("spawned_player");
}

speed_meter()
{
    self endon("disconnect");
    SpeedMeter = self init_hud("center");
    SpeedMeter.label = "^7";
    self thread delete_hud_on_notify(SpeedMeter, "disconnect");
	SpeedMeter fadeOverTime(1);
	SpeedMeter.alpha = 1;
    for(;;)
    {
        wait 0.05;
        SpeedMeter SetValue(int(Length(self GetVelocity())));
    }
}

init_hud(_alignment)
{
    if(IsPlayer(self))
    {
        hud = newClientHudElem(self);
        hud.owner = self;
    }
    else
    {
        hud = newHudElem();
    }
    
    hud.alpha = 0;
    hud.x = self._x;
    hud.y = self._y;
    self._y += 10;
    hud hud_set_alignment(_alignment);
    return hud;
}

hud_set_alignment(_alignment)
{

    if(!isdefined(_alignment))
    {
        self.horzalign = "center_adjustable";
        self.alignx = "center";
        self.vertalign = "top_adjustable";
        self.alignx = "top";
        return;
    }

    alignments = strTok(_alignment, "_");
    if(is_valid_horzalign(alignments[0]))
    {
        self.horzalign = alignments[0];
        self.alignx = alignments[0];
        if(level.debug) level thread IPrintLn_All("^2horizontal alignment: ^5"+alignments[0]);
    }
    else
    {
        self.horzalign = "center_adjustable";
        self.alignx = "center";
        level thread IPrintLn_All("^1Invalid horizontal alignment: ^5"+alignments[0]);
    }

    if(is_valid_vertalign(alignments[1]))
    {
        self.vertalign = alignments[1];
        self.aligny = alignments[1];
        if(level.debug) level thread IPrintLn_All("^2Vertical alignment: ^5"+alignments[1]);
    }
    else
    {
        self.vertalign = "top_adjustable";
        self.aligny = "top";
        level thread IPrintLn_All("^1Invalid vertical alignment: ^5"+alignments[1]);
    }
}

is_valid_horzalign(_align)
{
    return _align == "left" || _align == "center" || _align == "right";
}

is_valid_vertalign(_align)
{
    return _align == "top" || _align == "middle" || _align == "bottom";    
}

delete_hud_on_notify(hud, str_notify)
{
    self waittill(str_notify);
    hud Destroy();
}

print_connects()
{
    for(;;)
    {
        level waittill("connected", player);
        level thread IPrintLn_All("New player connected: ^5"+player.playername);
    }
}

IPrintLn_All(text)
{
    players = GetPlayers();
    for(i=0; i<players.size; i++)
    {
        players[i] IPrintLn(text);
    }
}

IPrintLnBold_All(text)
{
    players = GetPlayers();
    for(i=0; i<players.size; i++)
    {
        players[i] IPrintLnBold(text);
    }
}