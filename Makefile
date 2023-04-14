graphics:
	nasm -f bin boot.asm -o boot.bin
	nasm -f bin game.asm -o game.bin
	dd if=./game.bin >> ./boot.bin

run:
	qemu-system-x86_64 -hda ./boot.bin
