all: test

powerset.o: powerset.nasm
	nasm -felf64 -o powerset.o powerset.nasm

test.o: test.c powerset.h
	gcc -c test.c

test: powerset.o test.o
	gcc -o test powerset.o test.o
