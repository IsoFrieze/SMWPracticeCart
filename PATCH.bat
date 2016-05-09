echo f | xcopy /y "SMW.smc" "patched.smc"
asar patch.asm patched.smc
pause