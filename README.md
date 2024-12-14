# Source SDK 2013 - Engine Update

Source SDK 2013 MP with the changes required to work on the latest version of the source engine, such as TF2 and HL2MP
If you're running an reasonably up to date version community version of the SDK you only need to look at this commit [this commit](https://github.com/nooodles-ahh/source-sdk-engine-update/commit/b33d6194cbc0c38545bf6a0d285a70031a8c5900), if not I can't help you.
If you have any thing that patches or detours things in the engine or other dynamic libraries, disable those or find the new signatures.

This will hopefully be redundant in a few months.

# HL2DM on linux
Because whoever is currently incharge of updating the game fucked up you can't actually launch it, the required files you need to copy over are provided in `mp/game/` and `mp/game/bin`. Make sure you mark hl2_linux and hl2.sh as executable

# Blue particles on linux
Some particles will be blue because I haven't patched all the renderers in particles.a. This is caused due to ToGL requiring red and blue to be switched which.
