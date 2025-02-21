# Simple Multiplayer FPS in Godot
![icon](https://github.com/sergei-srednyak/Multiplayer-FPS-in-Godot/assets/152813286/6b3df1f1-0944-40fc-a29c-a9493d993620)
### Description
Simple multiplayer FPS game made in Godot. It features the ability to host your own and join other games.

Very basic first person controller with sprinting and crouching(both somewhat glitchy).

It also includes three weapons that you can switch between.

Instructions in game.

This game was made in Godot 4.2.1

### To host:
1. Open with Godot
2. Go to Project -> Export..
3. Pick the present you want, or download one
4. Export WITH DEBUG, under "Debug" set "Export Console Wrapper" to Debug only
5. Hit "Export Project" (NOT ANYTHING ELSE)
6. Run game with debug (depending on how you export, this could vary)
7. Make sure UPNP is enabled on your router
8. Click host then navigate to the debug window, there should be an IP address for others to join
9. If there are errors, it should be printed on the debug window, errors reference: https://docs.godotengine.org/en/stable/classes/class_upnp.html#enumerations
10. Give this address to others

Setting up multiplayer may take a moment

### To join:

Export the game with steps above, then open the game and type the IP in the address bar and click join

Joining also may take time
