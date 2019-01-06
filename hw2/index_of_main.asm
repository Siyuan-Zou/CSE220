.include "hw2.asm"

.data
nl: .asciiz "\n"
index_of_out: .asciiz "index_of: "
test: .asciiz "helloworlzd"

.text
.globl main
main:
la $a0, index_of_out
li $v0, 4
syscall
la $a0, test
li $a1, 'd'
jal index_of
move $a0, $v0
li $v0, 1
syscall
la $a0, nl
li $v0, 4
syscall
li $v0, 10
syscall
