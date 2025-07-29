World at War Tools
------------------

Tools for Call of Duty: World at War, made for speedrunning and gameplay analysis. All tools are HUD-based overlays.

Available:
- ^1Velocity           = Basic velocity HUD.

Coming Soon:
- ^1timer + velocity   = In-game timer with velocity HUD.
- ^1campaign_tool      = Timer + velocity HUD + split comparisons for Campaign.
- ^1zombie_tool        = Timer + velocity HUD + split comparisons for Zombies.
- ^1speedrun_tool      = Combined Campaign + Zombies tool (timer + velocity + splits).


Installation:
-------------
1. Press Win + R
2. Type: %localappdata%/activision/codwaw
3. Create a folder called: mods
4. Place the "^1Velocity" folder inside the mods folder
5. Load the mod from the in-game mod menu


HUD Positioning:
----------------
To move the velocity HUD:

    self._y = x;    // Vertical position
    self._x = x;    // Horizontal position

Valid positions for _x/_y:

    "center_top"
    "center"
    "center_bottom"
    "right_top"
    "right"
    "right_bottom"
    "left_top"
    "left"
    "left_bottom"


HUD Colors:
-----------
Change the "^7" prefix to modify the HUD text color:

    ^0 = Black
    ^1 = Red
    ^2 = Green
    ^3 = Yellow
    ^4 = Dark Blue
    ^5 = Light Blue
    ^6 = Pink
    ^7 = White
    ^8 = Grey
    ^9 = Brown


Notes:
------
This mod is not compiled, so anyone can update or change it. However, it was originally made for Campaign, and using it in Zombies is not recommended.

Zombies has issues because it treats the folder as a full mod. That means it expects all weapon files to be included manually. If the weapon data isn't there, it defaults to broken behavior.

Symptoms include:
- Seeing "found_a_step_trig" messages.
- Receiving a pink cowbell weapon with "OWN3D" writen in light blue on the side and called "default weapon".
- Some, if not all, wall weapons giving you the "default weapon" (which is the cowbell).

Known working weapons in Zombies:
- .357 Magnum
- Flamethrower
- PTRS-41
- Molotov
- Ray Gun

Most other weapons and all wall weapons will give you the default cowbell weapon unless specifically added to the mod folder and loaded correctly.
