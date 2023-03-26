all:
	nasm -f bin boot.asm -o boot.bin
	dd if=/dev/zero bs=512 count=1 >> ./boot.bin

graphics:
	nasm -f bin boot.asm -o boot.bin
	nasm -f bin game.asm -o game.bin
	dd if=./game.bin >> ./boot.bin
	dd if=/dev/zero bs=512 count=1 >> ./boot.bin

run:
	qemu-system-x86_64 -hda ./boot.bin
