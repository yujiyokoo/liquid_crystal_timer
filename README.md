# Liquid Crystal Timer

This is the code for a simple pomodoro-type timer I created with an Arduino Due, LiquidCrystal shield, and 2 LEDs (and resisters).

## Compatibility with your setup

The code contains hardcoded initialisation values for the liquid crystal sheald I had.
This is probably not campatible with your shield.

Also, this code uses LEDs connected to pin 53 and 52.
I used red and green LEDs with 150 ohm resisters.

## mruby-arduino

The mruby-arduino used here is my fork which contains support for the LiquidCrystal module.

## User instructions

The timer starts up paused at 25:00.
The 'up' button is _pause/resume_ and 'right' button is _next_, which switches between 'work' (25:00) and 'rest' (5:00) periods.

