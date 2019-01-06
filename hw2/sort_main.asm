.include "sort_data.asm"
.include "hw2.asm"

.data
nl: .asciiz "\n"
sort_output: .asciiz  "sort output: "

.text
.globl main
main:
la $a0, sort_output
li $v0, 4
syscall
la $a0, all_cars
li $a1, 12
jal sort
move $a0, $v0
li $v0, 1
syscall
la $a0, nl
li $v0, 4
syscall
li $t9, 12
la $s4, all_cars
loop_cars:
	lw $t0, ($s4)
	move $a0, $t0
	li $v0, 4
	syscall
	li $a0, ' '
	li $v0, 11
	syscall
	addi $s4, $s4, 4
	lw $t0, ($s4)
	move $a0, $t0
	li $v0, 4
	syscall
	li $a0, ' '
	li $v0, 11
	syscall
	addi $s4, $s4, 4
	lw $t0, ($s4)
	move $a0, $t0
	li $v0, 4
	syscall
	li $a0, ' '
	li $v0, 11
	syscall
	addi $s4, $s4, 4
	lb $t0, ($s4)
	move $a0, $t0
	li $v0, 1
	syscall
	li $a0, ' '
	li $v0, 11
	syscall
	addi $s4, $s4, 1
	lb $t0, ($s4)
	move $a0, $t0
	li $v0, 1
	syscall
	li $a0, ' '
	li $v0, 11
	syscall
	addi $s4, $s4, 1
	lb $t0, ($s4)
	move $a0, $t0
	li $v0, 1
	syscall
	li $a0, ' '
	li $v0, 11
	syscall
	addi $s4, $s4, 1
	lb $t0, ($s4)
	move $a0, $t0
	li $v0, 1
	syscall
	li $a0, ' '
	li $v0, 11
	syscall 
	
	la $a0, nl
	li $v0, 4
	syscall
	
	addi $s4, $s4, 1

	addi $t9, $t9, -1
	beqz $t9, ending 

	j loop_cars

ending:
	la $a0, nl
	li $v0, 4
	syscall
	li $v0, 10
	syscall
	    	
