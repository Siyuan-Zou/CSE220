.include "hw2.asm"

.data
nl: .asciiz "\n"
charAt_out: .asciiz "char: "
test: .asciiz "helloworld"

.text
.globl main
main:
la $a0, charAt_out
li $v0, 4
syscall
la $a0, test
li $a1, 0
jal char_at
move $a0, $v0
li $v0, 1
syscall
la $a0, nl
li $v0, 4
syscall
li $v0, 10
syscall
