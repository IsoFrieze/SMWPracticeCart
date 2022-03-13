# SMWPracticeCart
A hack of Super Mario World that makes practicing for speedrunning quicker, easier, and more fun.
See all the features of this romhack [here](http://www.dotsarecool.com/twitch/practice.html)!

# How to Patch
You'll need the ROM patcher, Asar (you can find it [here](https://www.smwcentral.net/?p=section&s=tools)), and a headered SMW (U) ROM (513kB).
1. Click the big green "Clone or download" button and select zip file.
2. Unzip that somewhere, and stick both `asar.exe` and your SMW ROM in the folder with `PATCH.bat`.
   - If you want to build the 3.58MHz version of the practice cart, first patch your SMW ROM with [this](http://www.dotsarecool.com/roms/smw_3.58MHz.bps) patch, and make sure the `!_F` variable in `patch.asm` is set to `$800000`.
   - If you aren't using the speed hack, make sure `!_F` is set to `$000000`. If this variable is not set correctly, you may get some glitchy artifacts.
3. Rename your ROM to `SMW.smc` and run the bat file. The patched ROM will be called `patched.smc`.
4. You can rename that and run that and put it on your SD card.