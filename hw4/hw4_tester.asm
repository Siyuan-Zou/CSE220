.data
map_filename: .asciiz "/home/eric/CSE220/hw4/map3.txt" #change to appropriate path
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
minus_one_str: .asciiz "Expected result: -1, Returned result: "
zero_str: .asciiz "Expected result: 0, Returned result: "
case_str: .asciiz "Expected result: "
returned_str: .asciiz ", Returned result: "
init_game_str: .asciiz "Testing init_game\n"
is_valid_cell_str: .asciiz "Testing is_valid_cell\n"
get_cell_str: .asciiz "Testing get_cell\n"
set_cell_str: .asciiz "Testing set_cell\n"
reveal_area_str: .asciiz "Testing reveal_area\n"
get_attack_target_str: .asciiz "Testing get_attack_target\n"
complete_attack_str: .asciiz "Testing complete_attack\n"
monster_attacks_str: .asciiz "Testing monster_attacks\n"
player_move_str: .asciiz "Testing player_move\n"
player_turn_str: .asciiz "Testing player_turn\n"
flood_fill_reveal_str: .asciiz "Testing flood_fill_reveal\n" 

.text
print_map:
la $t0, map  # the function does not need to take arguments

lbu $t1, 0($t0)
lbu $t2, 1($t0)
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

# test init_game
li $v0, 4
la $a0, init_game_str
syscall
la $a0, map_filename
la $a1, map
la $a2, player
jal init_game
jal print_map_unconditional
jal print_player_info

############################
#####test is_valid_cell#####
############################
li $v0, 4
la $a0, is_valid_cell_str
syscall

#valid_cell case 1: row = col = 0
li $v0, 4
la $a0, zero_str
syscall
la $a0, map
li $a1, 0
li $a2, 0
jal is_valid_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#valid_cell case 2: row = num_rows-1, col = num_cols-1
li $v0, 4
la $a0, zero_str
syscall
la $a0, map
li $a1, 6
li $a2, 24
jal is_valid_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#valid_cell case 3: row < 0, col = 0
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, -1
li $a2, 0
jal is_valid_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#valid_cell case 4: row = 0, col < 0 
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 0
li $a2, -1
jal is_valid_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#valid_cell case 5: row < 0, col < 0
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, -1
li $a2, -1
jal is_valid_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#valid_cell case 6: row = 0, col >= num_cols
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 0
li $a2, 25
jal is_valid_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#valid_cell case 7: row >= num_rows, col = 0
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 7
li $a2, 0
jal is_valid_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#valid_cell case 8: row >= num_rows, col >= num_cols 
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 7
li $a2, 25
jal is_valid_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#valid_cell case 9: row < 0, col >= num_cols 
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, -1
li $a2, 25
jal is_valid_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#valid_cell case 10: row >= num_rows, col < 0
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 7
li $a2, -1
jal is_valid_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall


############################
#######test get_cell########
############################
li $v0, 4
la $a0, get_cell_str
syscall

#get_cell case 1: row = col = 0
li $v0, 4
la $a0, case_str
syscall
li $v0, 11
li $a0, '#'
syscall
li $v0, 4
la $a0, returned_str
syscall
la $a0, map
li $a1, 0
li $a2, 0
jal get_cell
andi $a0, $v0, 0x7F
li $v0, 11
syscall
li $v0, 11
li $a0, '\n'
syscall

#get_cell case 2: row = num_rows-1, col = num_cols-1
li $v0, 4
la $a0, case_str
syscall
li $v0, 11
li $a0, '#'
syscall
li $v0, 4
la $a0, returned_str
syscall
la $a0, map
li $a1, 6
li $a2, 24
jal get_cell
andi $a0, $v0, 0x7F
li $v0, 11
syscall
li $v0, 11
li $a0, '\n'
syscall

#get_cell case 3: row < 0, col = 0
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, -1
li $a2, 0
jal get_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#get_cell case 4: row = 0, col < 0 
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 0
li $a2, -1
jal get_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#get_cell case 5: row < 0, col < 0
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, -1
li $a2, -1
jal get_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#get_cell case 6: row = 0, col >= num_cols
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 0
li $a2, 25
jal get_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#get_cell case 7: row >= num_rows, col = 0
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 7
li $a2, 0
jal get_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#get_cell case 8: row >= num_rows, col >= num_cols 
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 7
li $a2, 25
jal get_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#get_cell case 9: row < 0, col >= num_cols 
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, -1
li $a2, 25
jal get_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#get_cell case 10: row >= num_rows, col < 0
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 7
li $a2, -1
jal get_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

############################
#######test set_cell########
############################
li $v0, 4
la $a0, set_cell_str
syscall

#set_cell case 1: row = col = 0
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 0
li $a2, 0
li $a3, 'T'
jal set_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall
jal print_map_unconditional

#set_cell case 2: row = num_rows-1, col = num_cols-1
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 6
li $a2, 24
li $a3, 'T'
jal set_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall
jal print_map_unconditional

#set_cell case 3: row < 0, col = 0
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, -1
li $a2, 0
li $a3, 'T'
jal set_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#set_cell case 4: row = 0, col < 0 
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 0
li $a2, -1
li $a3, 'T'
jal set_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#set_cell case 5: row < 0, col < 0
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, -1
li $a2, -1
li $a3, 'T'
jal set_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#set_cell case 6: row = 0, col >= num_cols
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 0
li $a2, 25
li $a3, 'T'
jal set_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#set_cell case 7: row >= num_rows, col = 0
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 7
li $a2, 0
li $a3, 'T'
jal set_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#get_cell case 8: row >= num_rows, col >= num_cols 
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 7
li $a2, 25
li $a3, 'T'
jal set_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#get_cell case 9: row < 0, col >= num_cols 
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, -1
li $a2, 25
li $a3, 'T'
jal set_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#get_cell case 10: row >= num_rows, col < 0
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
li $a1, 7
li $a2, -1
li $a3, 'T'
jal set_cell
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

############################
#####test attack_target#####
############################
li $v0, 4
la $a0, get_attack_target_str
syscall

#attack_target case 1: player(1, 9) proper attack mob
li $v0, 4
la $a0, case_str
syscall
li $v0, 1
li $a0, 'm'
syscall
li $v0, 4
la $a0, returned_str
syscall
la $a0, map
li $a1, 1
li $a2, 6
li $a3, 'm'
jal set_cell
la $a0, map
la $a1, player
li $t0, 1
sb $t0, 0($a1)
li $t0, 7
sb $t0, 1($a1)
li $a2, 'L'
jal get_attack_target
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall


#attack_target case 2: player(1, 9) proper attack Boss
li $v0, 4
la $a0, case_str
syscall
li $v0, 1
li $a0, 'B'
syscall
li $v0, 4
la $a0, returned_str
syscall
la $a0, map
li $a1, 1
li $a2, 6
li $a3, 'B'
jal set_cell
la $a0, map
la $a1, player
li $t0, 1
sb $t0, 0($a1)
li $t0, 7
sb $t0, 1($a1)
li $a2, 'L'
jal get_attack_target
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#attack_target case 3: player(1, 9) proper attack Door
li $v0, 4
la $a0, case_str
syscall
li $v0, 1
li $a0, '/'
syscall
li $v0, 4
la $a0, returned_str
syscall
la $a0, map
li $a1, 1
li $a2, 6
li $a3, '/'
jal set_cell
la $a0, map
la $a1, player
li $t0, 1
sb $t0, 0($a1)
li $t0, 7
sb $t0, 1($a1)
li $a2, 'L'
jal get_attack_target
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#attack_target case 4: invalid direction
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
la $a1, player
li $a2, 'B'
jal get_attack_target
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#attack_target case 5: valid direction, invlid target cell
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
la $a1, player
li $a2, 'U'
jal get_attack_target
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#attack_target case 6: invalid target index
li $v0, 4
la $a0, minus_one_str
syscall
la $a0, map
la $a1, player
li $t0, 0
sb $t0, 0($a1)
li $t0, 7
sb $t0, 1($a1)
li $a2, 'U'
jal get_attack_target
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

############################
####test monster_attacks####
############################
li $v0, 4
la $a0, monster_attacks_str
syscall
jal init_game
jal reveal_all

#monster_attacks case 1: no monsters around
li $v0, 4
la $a0, zero_str
syscall
la $a0, map
la $a1, player
jal monster_attacks
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#monster_attacks case 2: three mobs around
li $v0, 4
la $a0, case_str
syscall
li $v0, 1
li $a0, 3
syscall
li $v0, 4
la $a0, returned_str
syscall
la $a0, map
la $a1, player
li $t0, 2
sb $t0, 0($a1)
li $t0, 7
sb $t0, 1($a1)
jal monster_attacks
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall

#monster_attacks case 3: one Boss around
li $v0, 4
la $a0, case_str
syscall
li $v0, 1
li $a0, 2
syscall
li $v0, 4
la $a0, returned_str
syscall
la $a0, map
la $a1, player
li $t0, 5
sb $t0, 0($a1)
li $t0, 2
sb $t0, 1($a1)
jal monster_attacks
move $a0, $v0
li $v0, 1
syscall
li $v0, 11
li $a0, '\n'
syscall


exit:
li $v0, 10
syscall


.include "hw4.asm"