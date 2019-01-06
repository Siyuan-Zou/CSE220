# Siyuan Zou
# siyzou
# 111639762

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################

.text

# Part I
init_game:
li $v0, -200
li $v1, -200
	
	#moving $a to $t preping for syscalls
	move $t0, $a0#file name
	move $t1, $a1#map struct
	move $t2, $a2#player struct
	
	#opening the map file
	li $v0, 13
	move $a0, $t0
	li $a1, 0
	li $a2, 0
	syscall
	move $t3, $v0#file descriptor
	beq $t3, -1, p1_error
	
	#begin to read file
	addi $sp, $sp, -1
	move $a0, $t3
	move $a1, $sp
	li $a2, 1
	
	#reading 1st byte of row
	li $v0, 14
	syscall
	lbu $t4, ($sp)
	addi $t4, $t4, -48
	
	#reading 2nd byte of row
	li $v0, 14
	syscall
	lbu $t5, ($sp)
	addi $t5, $t5, -48
	
	#figure out how to store the row number as a byte
	li $t6, 10
	mul $t4, $t4, $t6
	add $t6, $t4, $t5
	sb $t6, ($t1)
		
	#line break
	li $v0, 14
	syscall
	
	#reading 1st byte of col
	li $v0, 14
	syscall
	lbu $t4, ($sp)
	addi $t4, $t4, -48
	
	#reading 2nd byte of row
	li $v0, 14
	syscall
	lbu $t5, ($sp)
	addi $t5, $t5, -48
	
	#figure out how to store the col number as a byte
	li $t7, 10
	mul $t4, $t4, $t7
	add $t7, $t4, $t5
	sb $t7, 1($t1)
	
	#line break
	li $v0, 14
	syscall
	
	addi $t1, $t1, 2#first 2 byte has been stored
	#note $t6 = row, $t7 = col
	li $t8, 0
	row_loop:
		beq $t8, $t6, end_row_loop
		li $t9, 0
		col_loop:
			beq $t9, $t7, end_col_loop
			li $v0, 14
			syscall
			lbu $t4, ($sp)
			#check if $t4 is player
			beq $t4, 64, is_player #replace @ with ascii
			j not_player
			
			#storing player coordinate
			is_player:
				sb $t8, 0($t2)
				sb $t9, 1($t2)
			
			#store into map, this includes player coord thus no jump in is_player	
			not_player:
				ori $t4, $t4, 0x80#hidden
				sb $t4, ($t1)#store into map struct
				
			addi $t1, $t1, 1
			addi $t9, $t9, 1
			j col_loop
		end_col_loop:
			addi $t8, $t8, 1
			#skip line break
			li $v0, 14
			syscall
			j row_loop
	end_row_loop:
		#health into player struct
		li $v0, 14
		syscall
		lbu $t4, ($sp)
		addi $t4, $t4, -48
		
		li $v0, 14
		syscall
		lbu $t5, ($sp)
		addi $t5, $t5, -48
		
		li $t6, 10
		mul $t4, $t4, $t6
		add $t6, $t4, $t5
		sb $t6, 2($t2)
		
		#coin into player struct
		li $t9, 0
		sb $t9, 3($t2)
		
		#close file
		move $a0, $t3
		li $v0, 16
		syscall
		
		addi $sp, $sp, 1
		li $v0, 0
		j end_1
	p1_error:
		li $v0, -1
		j end_1
end_1:
jr $ra

# Part II
is_valid_cell:
li $v0, -200
li $v1, -200
	
	#row error
	bltz $a1, p2_error
	lbu $t0, 0($a0)
	bge $a1, $t0, p2_error
	
	#col error
	bltz $a2, p2_error
	lbu $t0, 1($a0)
	bge $a2, $t0, p2_error
	
	li $v0, 0
	j end_2
	
	p2_error:
		li $v0, -1
		j end_2

end_2:
jr $ra


# Part III
get_cell:
li $v0, -200
li $v1, -200
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	#check for validity
	jal is_valid_cell
	beq $v0, -1, p3_error
	
	lbu $t0, 1($a0)
	addi $a0, $a0, 2
	
	#row major calculation
	mul $t0, $t0, $a1
	add $t0, $t0, $a2
	
	#load desired byte
	add $a0, $a0, $t0
	lbu $v0, ($a0)
	j end_3
	
	p3_error:
		li $v0, -1
		j end_3
	
end_3:
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra


# Part IV
set_cell:
li $v0, -200
li $v1, -200

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	#check for validity
	jal is_valid_cell
	beq $v0, -1, p4_error
	
	lbu $t0, 1($a0)
	addi $a0, $a0, 2
	
	#row major calculation
	mul $t0, $t0, $a1
	add $t0, $t0, $a2
	
	#set desired byte
	add $a0, $a0, $t0
	sb $a3, ($a0)
	li $v0, 0
	j end_4
	
	p4_error:
		li $v0, -1
		j end_4
	
end_4:	
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra


# Part V
reveal_area:
li $v0, -200
li $v1, -200

	addi $sp, $sp, -4
	sw $ra, 0($sp)

	move $t9, $a0#map struct
	
	#initializing loop req
	addi $a1, $a1, -1#go to the start i
	addi $a2, $a2, -1#go to the start j
	move $t6, $a2
	li $t8, 0#i count
	reveal_i_loop:
		beq $t8, 3, end_reveal_i_loop
		li $t7, 0#j count
		move $a2, $t6
		reveal_j_loop:
			beq $t7, 3, end_reveal_j_loop
			
			#check valid
			move $a0, $t9#reset $a0
			jal is_valid_cell#check for valid cell
			beq $v0, -1, skip_reveal#when its invalid we go next
			
			#get_cell
			move $a0, $t9#reset $a0
			jal get_cell
			andi $a3, $v0, 0x7F#this will reveal the byte, if its already reveal then this will have no effect
			
			#set_cell
			move $a0, $t9#reset $a0
			jal set_cell
			
			skip_reveal:
				addi $a2, $a2, 1
				addi $t7, $t7, 1
				j reveal_j_loop
		end_reveal_j_loop:
			addi $a1, $a1, 1
			addi $t8, $t8, 1
			j reveal_i_loop
	end_reveal_i_loop:
	
end_5:
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

# Part VI
get_attack_target:
li $v0, -200
li $v1, -200

	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lbu $t9, 0($a1)#row_num of player
	lbu $t8, 1($a1)#col_num of player

	#check for direction
	beq $a2, 85, attack_up
	beq $a2, 68, attack_down
	beq $a2, 76, attack_left
	beq $a2, 82, attack_right
	j p6_error
	
	attack_up:
		addi $t9, $t9, -1
		move $a1, $t9
		move $a2, $t8
		jal get_cell
		beq $v0, 109, valid_target#monster m
		beq $v0, 66, valid_target#boss B
		beq $v0, 47, valid_target#door /
		j p6_error
	
	attack_down:
		addi $t9, $t9, 1
		move $a1, $t9
		move $a2, $t8
		jal get_cell
		beq $v0, 109, valid_target#monster m
		beq $v0, 66, valid_target#boss B
		beq $v0, 47, valid_target#door /
		j p6_error
		
	attack_left:
		addi $t8, $t8, -1
		move $a1, $t9
		move $a2, $t8
		jal get_cell
		beq $v0, 109, valid_target#monster m
		beq $v0, 66, valid_target#boss B
		beq $v0, 47, valid_target#door /
		j p6_error
		
	attack_right:
		addi $t8, $t8, 1
		move $a1, $t9
		move $a2, $t8
		jal get_cell
		beq $v0, 109, valid_target#monster m
		beq $v0, 66, valid_target#boss B
		beq $v0, 47, valid_target#door /
		j p6_error
	
	valid_target:
		j end_6
		
	p6_error:
		li $v0, -1
		j end_6
	
end_6:
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra


# Part VII
complete_attack:
li $v0, -200
li $v1, -200
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	#move argument
	move $t9, $a0#map struct
	move $t8, $a1#player struct
	move $t7, $a2#row_nums of attackable
	move $t6, $a3#col_nums of attackable
	
	move $a0, $t9
	move $a1, $t7
	move $a2, $t6
	jal get_cell
	beq $v0, 109, monster_branch
	beq $v0, 66, boss_branch
	beq $v0, 47, door_branch
	
	monster_branch:
		move $a0, $t9
		move $a1, $t7
		move $a2, $t6
		li $a3, '$'
		jal set_cell
		
		lb $t5, 2($t8)
		addi $t5, $t5, -1
		sb $t5, 2($t8)
		
		blez $t5, player_death#health is 0 or -1
		
		j end_7
	boss_branch:
		move $a0, $t9
		move $a1, $t7
		move $a2, $t6
		li $a3, '*'
		jal set_cell
		
		lb $t5, 2($t8)
		addi $t5, $t5, -2
		sb $t5, 2($t8)
		
		blez $t5, player_death#health is 0 or -1
		
		j end_7
	door_branch:
		move $a0, $t9
		move $a1, $t7
		move $a2, $t6
		li $a3, '.'
		jal set_cell
		
		j end_7
	player_death:
		move $a0, $t9
		lbu $a1, 0($t8)
		lbu $a2, 1($t8)
		li $a3, 'X'
		jal set_cell
		
		j end_7
	
end_7:	
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra


# Part VIII
monster_attacks:
li $v0, -200
li $v1, -200

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $t9, $a0#map struct
	lbu $t8, 0($a1)#player row
	lbu $t7, 1($a1)#player col
	
	li $t6, 0#dmg counter
	up_dmg:
		addi $t8, $t8, -1#move up
		move $a0, $t9#reset map struct
		move $a1, $t8#row
		move $a2, $t7#col
		jal get_cell
		beq $v0, 109, monster_dmg_up
		beq $v0, 66, boss_dmg_up
		j done_up_dmg
		monster_dmg_up:
			addi $t6, $t6, 1
			j done_up_dmg
		boss_dmg_up:
			addi $t6, $t6, 2
			j done_up_dmg
		done_up_dmg:
			addi $t8, $t8, 1#move back to player
			
	down_dmg:
		addi $t8, $t8, 1#move down
		move $a0, $t9#reset map struct
		move $a1, $t8#row
		move $a2, $t7#col
		jal get_cell
		beq $v0, 109, monster_dmg_down
		beq $v0, 66, boss_dmg_down
		j done_down_dmg
		monster_dmg_down:
			addi $t6, $t6, 1
			j done_down_dmg
		boss_dmg_down:
			addi $t6, $t6, 2
			j done_down_dmg
		done_down_dmg:
			addi $t8, $t8, -1#move back to player
			
	left_dmg:
		addi $t7, $t7, -1#move left
		move $a0, $t9#reset map struct
		move $a1, $t8#row
		move $a2, $t7#col
		jal get_cell
		beq $v0, 109, monster_dmg_left
		beq $v0, 66, boss_dmg_left
		j done_left_dmg
		monster_dmg_left:
			addi $t6, $t6, 1
			j done_left_dmg
		boss_dmg_left:
			addi $t6, $t6, 2
			j done_left_dmg
		done_left_dmg:
			addi $t7, $t7, 1#move back to player
			
	right_dmg:
		addi $t7, $t7, 1#move right
		move $a0, $t9#reset map struct
		move $a1, $t8#row
		move $a2, $t7#col
		jal get_cell
		beq $v0, 109, monster_dmg_right
		beq $v0, 66, boss_dmg_right
		j done_right_dmg
		monster_dmg_right:
			addi $t6, $t6, 1
			j done_right_dmg
		boss_dmg_right:
			addi $t6, $t6, 2
			j done_right_dmg
		done_right_dmg:
			addi $t7, $t7, -1#move back to player
	
	move $v0, $t6#return value
	
end_8:
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra


# Part IX
player_move:
li $v0, -200
li $v1, -200
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $t1, $a0#map struct
	move $t2, $a1#player struct
	move $t3, $a2#target row
	move $t4, $a3#target col
	
	jal monster_attacks
	move $a1, $t2#reset player struct
	lbu $t9, 2($a1)#get health
	sub $t9, $t9, $v0#dmg calc
	sb $t9, 2($a1)#set health
	blez $t9, player_have_died
	
	#if player didnt die then get target cell info
	move $a0, $t1#map struct
	move $a1, $t3#target row
	move $a2, $t4#target col
	jal get_cell
	beq $v0, 46, dot_target
	beq $v0, 36, dollar_target
	beq $v0, 42, gem_target
	beq $v0, 62, exit_target
	
	dot_target:
		move $a0, $t1
		lbu $a1, 0($t2)
		lbu $a2, 1($t2)
		li $a3, '.'
		jal set_cell
		
		sb $t3, 0($t2)#update player row
		sb $t4, 1($t2)#update player col
		
		move $a0, $t1
		move $a1, $t3
		move $a2, $t4
		li $a3, '@'
		jal set_cell
		
		li $v0, 0
		j end_9
		
	dollar_target:
		move $a0, $t1
		lbu $a1, 0($t2)
		lbu $a2, 1($t2)
		li $a3, '.'
		jal set_cell
		
		sb $t3, 0($t2)#update player row
		sb $t4, 1($t2)#update player col
		
		#increment money
		lb $t5, 3($t2)
		addi $t5, $t5, 1
		sb $t5, 3($t2)
		
		move $a0, $t1
		move $a1, $t3
		move $a2, $t4
		li $a3, '@'
		jal set_cell
		
		li $v0, 0
		j end_9
		
	gem_target:
		move $a0, $t1
		lbu $a1, 0($t2)
		lbu $a2, 1($t2)
		li $a3, '.'
		jal set_cell
		
		sb $t3, 0($t2)#update player row
		sb $t4, 1($t2)#update player col
		
		#increment money
		lbu $t5, 3($t2)
		addi $t5, $t5, 5
		sb $t5, 3($t2)
		
		move $a0, $t1
		move $a1, $t3
		move $a2, $t4
		li $a3, '@'
		jal set_cell
		
		li $v0, 0
		j end_9
		
	exit_target:
		move $a0, $t1
		lbu $a1, 0($t2)
		lbu $a2, 1($t2)
		li $a3, '.'
		jal set_cell
		
		sb $t3, 0($t2)#update player row
		sb $t4, 1($t2)#update player col
		
		move $a0, $t1
		move $a1, $t3
		move $a2, $t4
		li $a3, '@'
		jal set_cell
		
		li $v0, -1
		j end_9
	
	player_have_died:
		move $a0, $t1
		lbu $a1, 0($t2)
		lbu $a2, 1($t2)
		li $a3, 'X'
		jal set_cell
		li $v0, 0
		j end_9
		
end_9:
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra


# Part X
player_turn:
li $v0, -200
li $v1, -200

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $t1, $a0#map struct
	move $t2, $a1#player struct
	move $t3, $a2#char direction
	
	step_1:
		#check for direction
		beq $a2, 85, dir_up
		beq $a2, 68, dir_down
		beq $a2, 76, dir_left
		beq $a2, 82, dir_right
		li $v0, -1
		j end_10
		
	dir_up:
		lbu $t4, 0($t2)
		lbu $t5, 1($t2)
		addi $t4, $t4, -1
		j step_2
	dir_down:
		lbu $t4, 0($t2)
		lbu $t5, 1($t2)
		addi $t4, $t4, 1
		j step_2
	dir_left:
		lbu $t4, 0($t2)
		lbu $t5, 1($t2)
		addi $t5, $t5, -1
		j step_2
	dir_right:
		lbu $t4, 0($t2)
		lbu $t5, 1($t2)
		addi $t5, $t5, 1
		j step_2
	
	#check for validity
	step_2:
		move $a0, $t1
		move $a1, $t4
		move $a2, $t5
		jal is_valid_cell
		beqz $v0, step_3
		li $v0, 0
		j end_10
	
	#check if #
	step_3:
		move $a0, $t1
		move $a1, $t4
		move $a2, $t5
		jal get_cell
		beq $v0, 35, is_hashtag
		j step_4
		is_hashtag:
			li $v0, 0
			j end_10
	
	#attack or move
	step_4:
		move $a0, $t1
		move $a1, $t2
		move $a2, $t3
		jal get_attack_target
		beq $v0, 109, attackable#monster m
		beq $v0, 66, attackable#boss B
		beq $v0, 47, attackable#door / 
		j movable
		
		attackable:
			move $a0, $t1
			move $a1, $t2
			move $a2, $t4
			move $a3, $t5
			jal complete_attack
			li $v0, 0
			j end_10
		movable:
			move $a0, $t1
			move $a1, $t2
			move $a2, $t4
			move $a3, $t5
			jal player_move
			j end_10
			
end_10:
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra


# Part XI
flood_fill_reveal:
li $v0, -200
li $v1, -200

	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $fp, 20($sp)
	
	move $s0, $a0#map struct
	move $s1, $a1#row
	move $s2, $a2#col
	move $s3, $a3#visted[][]
	
	move $a0, $s0#map struct
	move $a1, $s1#row
	move $a2, $s2#col
	jal is_valid_cell
	beq $v0, -1, p11_error
	
	move $fp, $sp#fp=sp
	addi $sp, $sp, -8
	sw $s1, 0($sp)
	sw $s2, 4($sp)
	
	move $a0, $s0 
	lbu $t3, 1($a0)#total col M
	mul $t4, $t3, $s1#i*M
	add $t4, $t4, $s2#+j
	
	#bit array (1/8)*(i*M+j)
	li $t5, 8
	div $t4, $t5
	mflo $t5 #quotient
	mfhi $t6 #remainder
	
	move $a3, $s3
	add $a3, $a3, $t5
	lbu $t7, ($a3)
	srlv $t7, $t7, $t6
	ori $t7, $t7, 0x01
	sllv $t7, $t7, $t6
	sb $t7, ($a3)
	
	while:
		beq $sp, $fp, exit_while
		lw $t1, 0($sp)
		lw $t2, 4($sp)
		addi $sp, $sp, 8
		
		#get to be reveal
		move $a0, $s0
		move $a1, $t1
		move $a2, $t2
		jal get_cell
		andi $v0, $v0, 0x7F#reveal cell
		
		#set reveal
		move $a0, $s0
		move $a1, $t1
		move $a2, $t2
		move $a3, $v0
		jal set_cell
		
		#(-1,0)
		pair_1:
			li $t8, 0
			addi $t8, $t1, -1
			
			#get to be reveal
			move $a0, $s0
			move $a1, $t8
			move $a2, $t2
			jal get_cell
			andi $v0, $v0, 0x7F#reveal cell
			beq $v0, 46, is_empty_floor
			j pair_2
			
			is_empty_floor:
			move $a0, $s0 
			lbu $t3, 1($a0)#total col M
			mul $t4, $t3, $t8#i*M
			add $t4, $t4, $t2#+j
			
			#bit array (1/8)*(i*M+j)
			li $t5, 8
			div $t4, $t5
			mflo $t5 #quotient
			mfhi $t6 #remainder
			
			move $a3, $s3
			add $a3, $a3, $t5
			lbu $t7, ($a3)
			srlv $t7, $t7, $t6
			ori $t9, $t7, 0x01
			beq $t7, $t9, pair_2
			
			#when $t7 != $t9 meaning its not been visited
			ori $t7, $t7, 0x01
			sllv $t7, $t7, $t6
			sb $t7, ($a3)
			
			move $s1, $t8
			move $s2, $t2
			
			addi $sp, $sp, -8
			sw $s1, 0($sp)
			sw $s2, 4($sp)
			
		pair_2:	
			li $t8, 0
			addi $t8, $t1, 1
			
			#get to be reveal
			move $a0, $s0
			move $a1, $t8
			move $a2, $t2
			jal get_cell
			andi $v0, $v0, 0x7F#reveal cell
			beq $v0, 46, is_empty_floor_2
			j pair_3
			
			is_empty_floor_2:
			move $a0, $s0 
			lbu $t3, 1($a0)#total col M
			mul $t4, $t3, $t8#i*M
			add $t4, $t4, $t2#+j
			
			#bit array (1/8)*(i*M+j)
			li $t5, 8
			div $t4, $t5
			mflo $t5 #quotient
			mfhi $t6 #remainder
			
			move $a3, $s3
			add $a3, $a3, $t5
			lbu $t7, ($a3)
			srlv $t7, $t7, $t6
			ori $t9, $t7, 0x01
			beq $t7, $t9, pair_3
			
			#when $t7 != $t9 meaning its not been visited
			ori $t7, $t7, 0x01
			sllv $t7, $t7, $t6
			sb $t7, ($a3)
			
			move $s1, $t8
			move $s2, $t2
			
			addi $sp, $sp, -8
			sw $s1, 0($sp)
			sw $s2, 4($sp)
			
		pair_3:
			li $t8, 0
			addi $t8, $t2, -1
			
			#get to be reveal
			move $a0, $s0
			move $a1, $t1
			move $a2, $t8
			jal get_cell
			andi $v0, $v0, 0x7F#reveal cell
			beq $v0, 46, is_empty_floor_3
			j pair_4
			
			is_empty_floor_3:
			move $a0, $s0 
			lbu $t3, 1($a0)#total col M
			mul $t4, $t3, $t1#i*M
			add $t4, $t4, $t8#+j
			
			#bit array (1/8)*(i*M+j)
			li $t5, 8
			div $t4, $t5
			mflo $t5 #quotient
			mfhi $t6 #remainder
			
			move $a3, $s3
			add $a3, $a3, $t5
			lbu $t7, ($a3)
			srlv $t7, $t7, $t6
			ori $t9, $t7, 0x01
			beq $t7, $t9, pair_4
			
			#when $t7 != $t9 meaning its not been visited
			ori $t7, $t7, 0x01
			sllv $t7, $t7, $t6
			sb $t7, ($a3)
			
			move $s1, $t1
			move $s2, $t8
			
			addi $sp, $sp, -8
			sw $s1, 0($sp)
			sw $s2, 4($sp)
			
		pair_4:
			li $t8, 0
			addi $t8, $t2, 1
			
			#get to be reveal
			move $a0, $s0
			move $a1, $t1
			move $a2, $t8
			jal get_cell
			andi $v0, $v0, 0x7F#reveal cell
			beq $v0, 46, is_empty_floor_4
			j done_pair
			
			is_empty_floor_4:
			move $a0, $s0 
			lbu $t3, 1($a0)#total col M
			mul $t4, $t3, $t1#i*M
			add $t4, $t4, $t8#+j
			
			#bit array (1/8)*(i*M+j)
			li $t5, 8
			div $t4, $t5
			mflo $t5 #quotient
			mfhi $t6 #remainder
			
			move $a3, $s3
			add $a3, $a3, $t5
			lbu $t7, ($a3)
			srlv $t7, $t7, $t6
			ori $t9, $t7, 0x01
			beq $t7, $t9, done_pair
			
			#when $t7 != $t9 meaning its not been visited
			ori $t7, $t7, 0x01
			sllv $t7, $t7, $t6
			sb $t7, ($a3)
			
			move $s1, $t1
			move $s2, $t8
			
			addi $sp, $sp, -8
			sw $s1, 0($sp)
			sw $s2, 4($sp)
			
		done_pair:
			j while
			
	exit_while:
		li $v0, 0
		j end_11
	p11_error:
		li $v0, -1
		j end_11
		
end_11:
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $fp, 20($sp)
addi $sp, $sp, 24
jr $ra

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
