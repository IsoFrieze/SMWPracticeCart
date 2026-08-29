echo f | xcopy /y "smw_3.58MHz.smc" "patched.smc"
asar --symbols=nocash patch.asm patched.smc
pause