# Space Invaders in 8086 16 bit real mode assembly

This is an extremely basic and crude adaptation of the classic space invaders implemented in 8086 16bit real mode
using mode 13 graphics, purely for fun. Unlike the original game which has got a fleet of aliens moving across
screen, this implementation has only one alien which moves across screen and down on hitting right edge of screen.
Hitting the enemy resets its position. All game objects (player, enemy and bullets) are either rectangles or lines
aligned to X or Y axis which makes it even simpler to draw.

![GIF](https://github.com/djmgit/space-invaders-x86_16bit_realmode/blob/master/doc_assets/sample.gif)

## Controls

**a**: Moves player left.

**d**: Moves player right.

**space**: Shoots bullet.

## Getting it to run

In order to run the game you need an emulator which can emulate 16 bit real mode code and provides VGA memory.
I use Qemu. Apart from the emulator you will require NASM assembler and Make.

- Clone this repository and open it in terminal
- Run ```make graphics```
- Run ```make run```

This should open up Qemu's window with the game running in it. 

### Whats happening in the Makefile?

First we individually assemble boot.asm and game.asm into binaries and then we simply append game.bin at the end of boot.bin. Both boot.bin and game.bin is 512B aligned. Running the game is simplying running the binary as qemu hda.

### Note

The flickering observed in the game is due to the fact that I have not yet added double buffering.
I am writing directly to VGA memory in order to render the graphics which is not a very ideal thing to do. Feel free to open a PR if you want to play around!

