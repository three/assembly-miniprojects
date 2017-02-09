palcheck: palcheck.o
	ld -o palcheck palcheck.o

palcheck.o: palcheck.nasm
	nasm -felf64 palcheck.nasm
