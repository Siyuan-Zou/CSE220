.data
map_filename: .asciiz "mapt.txt"
# num words for map: 45 = (num_rows * num_cols + 2) // 4 
# map is random garbage initially
.asciiz "Don't touch this region of memory"
map: .word 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 
.asciiz "Don't touch this"
# player struct is random garbage initially
player: .word 0x2912FECD
.asciiz "Don't touch this either"
# visited[][] bit vector will always be initialized with all zeroes
# num words for visited: 6 = (num_rows * num*cols) // 32 + 1
visited: .word 0 0 0 0 0 0
.asciiz "Really, please don't mess with this string"

welcome_msg: .asciiz "Welcome to MipsHack! Prepare for adventure!\n"
pos_str: .asciiz "Pos=["
health_str: .asciiz "] Health=["
coins_str: .asciiz "] Coins=["
your_move_str: .asciiz " Your Move: "
you_won_str: .asciiz "Congratulations! You have defeated your enemies and escaped with great riches!\n"
you_died_str: .asciiz "You died!\n"
you_failed_str: .asciiz "You have failed in your quest!\n"

.text
print_map:
la $t0, map  # the function does not need to take arguments

lbu $t1, 0($t0)
move $a0, $t1
li $v0, 1
syscall
li $v0, 11
li $a0, ' '
syscall
lbu $t2, 1($t0)
move $a0, $t2
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall
addi $t0, $t0, 2


li $v0, 11
li $t3, 0 #row = 0
print_map_loop:
    li $t4, 0 #col = 0
    bge $t3, $t1, print_map_loop.done
    print_map_inner_loop:
        bge $t4, $t2, print_map_inner_loop.done
        lbu $a0, 0($t0)
        andi $t5, $a0, 0x80
        beqz $t5, print_map_print
        li $a0, ' '
        print_map_print:
	syscall
	
	addi $t0, $t0, 1        
        addi $t4, $t4, 1
        j print_map_inner_loop
    print_map_inner_loop.done:
    li $a0, '\n'
    syscall
    addi $t3, $t3, 1 #row++
    j print_map_loop
print_map_loop.done:
jr $ra

print_map_unconditional:
la $t0, map  # the function does not need to take arguments

lbu $t1, 0($t0)
lbu $t2, 1($t0)
addi $t0, $t0, 2

li $v0, 11
li $t3, 0 #row = 0
print_map_u_loop:
    li $t4, 0 #col = 0
    bge $t3, $t1, print_map_u_loop.done
    print_map_u_inner_loop:
        bge $t4, $t2, print_map_u_inner_loop.done
        lbu $a0, 0($t0)
        andi $a0, $a0, 0x7F
	syscall
	addi $t0, $t0, 1        
        addi $t4, $t4, 1
        j print_map_u_inner_loop
    print_map_u_inner_loop.done:
    li $a0, '\n'
    syscall
    addi $t3, $t3, 1 #row++
    j print_map_u_loop
print_map_u_loop.done:
jr $ra

reveal_all:
la $t0, map  # the function does not need to take arguments

lbu $t1, 0($t0)
lbu $t2, 1($t0)
addi $t0, $t0, 2

li $t3, 0 #row = 0
reveal_all_loop:
    li $t4, 0 #col = 0
    bge $t3, $t1, reveal_all_loop.done
    reveal_all_inner_loop:
        bge $t4, $t2 reveal_all_inner_loop.done
        lbu $t5, 0($t0)
        andi $t5, $t5, 0x7F
	sb $t5, 0($t0)
	addi $t0, $t0, 1        
        addi $t4, $t4, 1
        j reveal_all_inner_loop
    reveal_all_inner_loop.done:
    addi $t3, $t3, 1 #row++
    j reveal_all_loop
reveal_all_loop.done:
jr $ra

print_player_info:
# the idea: print something like "Pos=[3,14] Health=[4] Coins=[1]"
la $t0, player

la $a0, pos_str
li $v0, 4
syscall

lbu $a0, 0($t0)
li $v0, 1
syscall

li $v0, 11
li $a0, ','
syscall

lbu $a0, 1($t0)
li $v0, 1
syscall

la $a0, health_str
li $v0, 4
syscall

lb $a0, 2($t0)
li $v0, 1
syscall

la $a0, coins_str
li $v0, 4
syscall

lbu $a0, 3($t0)
li $v0, 1
syscall

li $v0, 11
li $a0, ']'
syscall

li $a0, '\n'
syscall

jr $ra


.globl main
main:
la $a0, welcome_msg
li $v0, 4
syscall

# fill in arguments
la $a0, map_filename
la $a1, map
la $a2, player
jal init_game
#jal reveal_all
jal print_map
jal print_player_info
li $a0, '\n'
li $v0, 11
syscall
j part11_test

part2_test:
la $a0, map
li $a1, -3
li $a2, 0
jal is_valid_cell
move $a0, $v0
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
j exit

part3_test:
la $a0, map
li $a1, 3
li $a2, 2
jal get_cell
move $a0, $v0
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
j exit

part4_test:
la $a0, map
li $a1, 3
li $a2, 2
li $a3, '$'
jal set_cell
move $a0, $v0
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
j exit

part5_test:
la $a0, map
li $a1, 0
li $a2, 0
jal reveal_area
move $a0, $v0
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
jal print_map
j exit

part6_test:
la $a0, map
la $a1, player
li $a2, 'R'
jal get_attack_target
move $a0, $v0
li $v0, 11
syscall
li $a0, '\n'
li $v0, 11
syscall
j exit

part7_test:
la $a0, map
la $a1, player
li $a2, 3
li $a3, 6
jal complete_attack
jal print_map
jal print_player_info
li $a0, '\n'
li $v0, 11
syscall
j exit

part8_test:
la $a0, map
la $a1, player
jal monster_attacks
move $a0, $v0
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
j exit

part9_test:
la $a0, map
la $a1, player
li $a2, 0
li $a3, 7
jal player_move
move $a0, $v0
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
jal print_map
jal print_player_info
j exit

part10_test:
la $a0, map
la $a1, player
li $a2, 'U'
jal player_turn
move $a0, $v0
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
jal print_map
jal print_player_info
j exit

part11_test:
la $a0, map
li $a1, 2
li $a2, 2
la $a3, visited
jal flood_fill_reveal
li $a0, '\n'
li $v0, 11
syscall
jal print_map
j exit

# fill in arguments
jal reveal_area

li $s0, 0  # move = 0

game_loop:  # while player is not dead and move == 0:

jal print_map # takes no args

jal print_player_info # takes no args

# print prompt
la $a0, your_move_str
li $v0, 4
syscall

li $v0, 12  # read character from keyboard
syscall
move $s1, $v0  # $s1 has character entered
li $s0, 0  # move = 0

li $a0, '\n'
li $v0 11
syscall

# handle input: w, a, s or d
# map w, a, s, d  to  U, L, D, R and call player_turn()

# if move == 0, call reveal_area()  Otherwise, exit the loop.

j game_loop

game_over:
jal print_map
jal print_player_info
li $a0, '\n'
li $v0, 11
syscall

# choose between (1) player dead, (2) player escaped but lost, (3) player escaped and won

won:
la $a0, you_won_str
li $v0, 4
syscall
j exit

failed:
la $a0, you_failed_str
li $v0, 4
syscall
j exit

player_dead:
la $a0, you_died_str
li $v0, 4
syscall

exit:
li $v0, 10
syscall

.include "hw4.asm"
