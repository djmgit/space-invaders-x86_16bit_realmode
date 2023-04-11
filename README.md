# Space Invaders in 8086 16 bit real mode assembly

This is an extremely basic and crude adaptation of the classic space invaders implemented in 8086 16bit real mode
using mode 13 graphics, purely for fun. Instead of the origianl game which has got a fleet of aliens moving across
screen, this implementation has only one alien which moves across screen and down on hitting right edge of screen.
Hitting the enemy resets its position. All game objects (player, enemy and bullets) are either rectangles or lines
aligned to X or Y axis which makes it even simpler to draw.

## Controls

**a**: Moves player left.

**d**: Moves player right.

**space**: Shoots bullet.

## Getting it to run

In order to run the game you need an emulator which can emulate 16 bit real mode code and provides VGA memory.
I use Qemu. Apart from the emulator you will require NASM assembler and Make.

- Clone this repositor and open it in terminal
- Run ```make graphics```
- Run ```make run```

This should open up Qemu's window with the game running in it.
