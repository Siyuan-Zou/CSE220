.text
.globl main
main:
li $a0, 0
li $a1, 0
jal get_adfgvx_coords

beq $v0, -1, print_int
move $a0, $v0
li $v0, 11
syscall
li $a0, ' '
syscall
move $a0, $v1
syscall
li $a0, '\n'
syscall

print_int:
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, ' '
syscall
li $v0, 1
move $a0, $v1
syscall
li $v0, 11
li $a0, '\n'
syscall

li $v0, 10
syscall

.include "hw3.asm"
