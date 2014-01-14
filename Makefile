build: compileObjC
source = control.m
executable = control

compileObjC:
	@gcc -o $(executable) $(source) -framework IOKit -framework Cocoa

