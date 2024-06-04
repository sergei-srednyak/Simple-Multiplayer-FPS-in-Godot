# Multiplayer-FPS-in-Godot

This game was made in Godot 4.2.1

To host:
1. Open with Godot
2. Go to Project -> Export..
3. Pick the present you want, or download one
4. Hit "Export Project"(NOT ANYTHING ELSE)
5. Export WITH DEBUG
6. Run game with debug(depending on how you export, this could vary)
7. Make sure UPNP is enabled on your router
8. Click host then navigate to the debug window, there should be an IP address for others to join
9. If there are errors, it should be printed on the debug window, errors reference: https://docs.godotengine.org/en/stable/classes/class_upnp.html#enumerations
10. Give this address to others

Setting up multiplayer may take a moment

To join:

Export the game with steps above, then open the game and type the IP in the address bar and click join

Joining also may take time

# Know issues:
1. Sprint effects don't stop on unsprint sometimes
2. To see the crouch effects you have to move
3. Animations for switching do not work well while firing
