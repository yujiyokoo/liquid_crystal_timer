all: liquid_crystal_rb_timer.c

liquid_crystal_rb_timer.c: liquid_crystal_rb_timer.rb
	mrbc -Bliquid_crystal_rb_timer -oliquid_crystal_rb_timer.c liquid_crystal_rb_timer.rb
