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
get_adfgvx_coords:
li $v0, -200
li $v1, -200
	
	#If one error occur both $v0 and $v1 is -1
	blt $a0, 0, error_1
	blt $a1, 0, error_1
	bgt $a0, 5, error_1
	bgt $a1, 5, error_1
	
	addi $sp, $sp, -24
	li $s0, 'A'
	sw $s0, 0($sp)
	li $s0, 'D'
	sw $s0, 4($sp)
	li $s0, 'F'
	sw $s0, 8($sp)
	li $s0, 'G'
	sw $s0, 12($sp)
	li $s0, 'V'
	sw $s0, 16($sp)
	li $s0, 'X'
	sw $s0, 20($sp)
	
	sll $a0, $a0, 2
	sll $a1, $a1, 2
	
	li $t0, -1
	add $sp, $sp, $a0
	lw $v0, ($sp)
	mul $a0, $a0, $t0
	add $sp, $sp, $a0
	
	add $sp, $sp, $a1
	lw $v1, ($sp)
	mul $a1, $a1, $t0
	add $sp, $sp, $a1
	
	addi $sp, $sp, 24
	j end_1
	
	error_1:
		li $v0, -1
		li $v1, -1
end_1:
jr $ra

# Part II
search_adfgvx_grid:
li $v0, -200
li $v1, -200
	
	move $s0, $a0 #used to reset $a0
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	li $t0, 0 #row count
	li $t2, 0 #increment
	li $t3, 6 #(M*i+j) ->($t3*$t0+$t1)
	row_loop:
		li $t1, 0 #col count
		col_loop:
			mul $t2, $t3, $t0
			add $t2, $t2, $t1
			
			lw $a0, 0($sp)
			add $a0, $a0, $t2
			lbu $t4, ($a0)
			
			beq $t4, $a1, found_match
			
			beq $t1, 5, end_col_loop
			addi $t1, $t1, 1
			j col_loop
		end_col_loop:
			beq $t0, 5, end_row_loop
			addi $t0, $t0, 1
			j row_loop
	end_row_loop:
		li $v0, -1
		li $v1, -1
		j end_2
	found_match:
		move $v0, $t0
		move $v1, $t1	
			
end_2:
lw $a0, 0($sp)
addi $sp, $sp, 4
jr $ra

# Part III
map_plaintext:
li $v0, -200
li $v1, -200
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	
	li $t3, 6 #M $t3 stays the same through out as $t3 in search_adfgvx_grid is also 6
	li $t5, 0 #increment
	li $t6, 0 #i
	li $t7, 0 #j
	li $t8, 0 
	plaintext_loop:
		#using lw since we loading an address
		lw $a1, 8($sp)
		add $a1, $a1, $t8
		lbu $t9, ($a1)
		
		beqz $t9, end_plaintext_loop
		
		lw $a0, 4($sp) 
		move $a1, $t9
		jal search_adfgvx_grid
		
		move $a0, $v0
		move $a1, $v1
		jal get_adfgvx_coords
		
		beq $t7, 6, reset_i_j
		j append_ADFGVX_pair
		reset_i_j:
			addi $t6, $t6, 1
			li $t7, 0 #j
		
		append_ADFGVX_pair:
			lw $a2, 12($sp)
			mul $t5, $t3, $t6
			add $t5, $t5, $t7
			add $a2, $a2, $t5
			sb $v0, ($a2)
			addi $t7, $t7, 1
		
			lw $a2, 12($sp)
			mul $t5, $t3, $t6
			add $t5, $t5, $t7
			add $a2, $a2, $t5
			sb $v1, ($a2)
			addi $t7, $t7, 1
		
		addi $t8, $t8, 1
		j plaintext_loop
	end_plaintext_loop:
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		addi $sp, $sp, 16
end_3:
jr $ra

# Part IV
swap_matrix_columns:
li $v0, -200
li $v1, -200

	blez $a1, error_4
	blez $a2, error_4
	bltz $a3, error_4
	bge $a3, $a2, error_4
	lw $t0, 0($sp)
	bltz $t0, error_4
	bge $t0, $a2, error_4
	
	move $s0, $a0
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	li $t1, 0 #increment
	swap_col_loop:
		beq $t1, $a1, end_swap_col_loop
		addi $sp, $sp, -8
		
		move $a0, $s0 #reload char[][]
		mul $t2, $t1, $a2
		add $t2, $t2, $a3
		add $a0, $a0, $t2
		lbu $s1, ($a0)
		sb $s1, 0($sp)
		
		move $a0, $s0 #reload char[][]
		mul $t2, $t1, $a2
		add $t2, $t2, $t0
		add $a0, $a0, $t2
		lbu $s2, ($a0)
		sb $s2, 4($sp)
		
		move $a0, $s0 #reload char[][]
		mul $t2, $t1, $a2
		add $t2, $t2, $a3
		add $a0, $a0, $t2
		sb $s2, ($a0)
		
		move $a0, $s0 #reload char[][]
		mul $t2, $t1, $a2
		add $t2, $t2, $t0
		add $a0, $a0, $t2
		sb $s1, ($a0)
		
		addi $sp, $sp, 8
		
		addi $t1, $t1, 1
		j swap_col_loop
	end_swap_col_loop:
		li $v0, 0
		j end_4
	error_4:
		li $v0, -1

end_4:
lw $a0, 0($sp)
addi $sp, $sp, 4
jr $ra

# Part V
key_sort_matrix:
li $v0, -200
li $v1, -200
	
	#only $ra, key, and ele_size will change due to calling swap_col
	move $s0, $a3
	lw $s1, 0($sp)
	
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	
	li $t3, 0 #i
	bubble_i_loop:
		li $t4, 0 #j
		beq $t3, $a2, end_bubble_i_loop #$t3 = key length end.
		bubble_j_loop:
			sub $t9, $a2, $t3 #this will always reset $t9 to n-i
			addi $t9, $t9, -1
			beq $t4, $t9, end_bubble_j_loop
			lw $s0, 4($sp)
			lw $s1, 8($sp)
			addi $s2, $t4, 1 #j+1
			
			beq $s1, 1, byte_swap
			j word_swap
			byte_swap:
				add $s0, $s0, $t4
				lbu $t5, 0($s0)
				lbu $t6, 1($s0)
				ble $t5, $t6, end_of_swap
				
				move $t7, $t5
				sb $t6, 0($s0)
				sb $t7, 1($s0)
				
				move $a3, $t4
				addi $sp, $sp, -4
				sw $s2, ($sp) #j+1
				jal swap_matrix_columns
				addi $sp, $sp, 4
				j end_of_swap
			word_swap:
				sll $t5, $t4, 2
				add $s0, $s0, $t5
				lw $t5, 0($s0)
				lw $t6, 4($s0)
				
				ble $t5, $t6, end_of_swap
				
				move $t7, $t5
				sw $t6, 0($s0)
				sw $t7, 4($s0)
				
				move $a3, $t4
				addi $sp, $sp, -4
				sw $s2, ($sp) #j+1
				jal swap_matrix_columns
				addi $sp, $sp, 4
				j end_of_swap
			end_of_swap:
				addi $t4, $t4, 1
				j bubble_j_loop
		end_bubble_j_loop:
			addi $t3, $t3, 1
			j bubble_i_loop
	end_bubble_i_loop:
end_5:	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
addi $sp, $sp, 12
jr $ra

# Part VI
transpose:
li $v0, -200
li $v1, -200

	blez $a2, error_6
	blez $a3, error_6

	move $s0, $a0 #src to $s0
	move $s1, $a1 #dest to #s1
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $s1, 4($sp)

	li $t0, 0
	transpose_i:
		li $t1, 0
		beq $t0, $a2, end_transpose_i #i<N
		transpose_j:
		beq $t1, $a3, end_transpose_j #j<M
		
		mul $t2, $a3, $t0 #M*i
		add $t2, $t2, $t1 #+j
		
		move $a0, $s0 #src reset
		add $a0, $a0, $t2 #offset src matrix
		lbu $t3, ($a0) #load byte of matrix
		
		mul $t2, $a2, $t1 #N*j
		add $t2, $t2, $t0 #+i
		
		move $a1, $s1 #dest reset
		add $a1, $a1, $t2 #offset dest matrix
		sb $t3, ($a1)
		
		addi $t1, $t1, 1
		j transpose_j
		end_transpose_j:
			addi $t0, $t0, 1
			j transpose_i
	end_transpose_i:
		li $v0, 0
		j end_6
	error_6:
		li $v0, -1
end_6:
lw $s0, 0($sp)
lw $s1, 4($sp)	 
addi $sp, $sp, 8	
jr $ra

# Part VII
encrypt:
li $v0, -200
li $v1, -200
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $t9, $a1
	move $t8, $a2
	
	li $t0, 0 #length of plaintext
	len_of_plaintext_loop:
		lbu $t1, ($t9)
   		beqz $t1, end_len_of_plaintext_loop
		
		addi $t9, $t9, 1
    		addi $t0, $t0, 1
    		j len_of_plaintext_loop
    	end_len_of_plaintext_loop:
    	
    	li $t1, 0 #length of keyword
	len_of_keyword_loop:
		lbu $t2, ($t8)
   		beqz $t2, end_len_of_keyword_loop
		
		addi $t8, $t8, 1
    		addi $t1, $t1, 1
    		j len_of_keyword_loop
    	end_len_of_keyword_loop:
    		
    		sll $t0, $t0, 1
    		div $t0, $t1
    		mflo $t0
    		mfhi $t2
    		bnez $t2, plus1
    		j no_plus #if the division is w/o remainder
    		plus1:
    			addi $t0, $t0, 1 #act as ceiling
    		no_plus:
    		#currently $t0 is num_rows, $t1 is num_cols
    		
    		mul $t2, $t0, $t1 #dont save
    		
    		move $t9, $a0
    		
    		move $a0, $t2
		li $v0, 9
		syscall
		
		move $a0, $t9
		
		#reset $a0
		
		li $t3, 0
		li $t4, '*'
		move $t5, $v0
		fill_asterisk:
			beq $t3, $t2, end_fill_asterisk
			
			sb $t4, ($t5)
			
			addi $t5, $t5, 1
			addi $t3, $t3, 1
			j fill_asterisk
		end_fill_asterisk:
			move $s0, $t0 #saving num_rows
			move $s1, $t1 #saving num_cols
			move $s2, $a2 #saving keyword argument
			move $s3, $v0 #saving location of heap
			move $s4, $a0 #saving adfgvx_grid
			move $s5, $a1 #saving plaintext
			move $s6, $a3 #saving ciphertext
			
			#storing all required data
			addi $sp, $sp, -28
			sw $s0, 0($sp)
			sw $s1, 4($sp)
			sw $s2, 8($sp)
			sw $s3, 12($sp)
			sw $s4, 16($sp)
			sw $s5, 20($sp)
			sw $s6, 24($sp)
			
			move $a2, $v0
			jal map_plaintext
    			
    			#reload all data
			lw $s0, 0($sp)
			lw $s1, 4($sp)
			lw $s2, 8($sp)
			lw $s3, 12($sp)
			lw $s4, 16($sp)
			lw $s5, 20($sp)
			lw $s6, 24($sp)
			
			move $a0, $s3
			move $a1, $s0
			move $a2, $s1
			move $a3, $s2
			addi $sp, $sp, -4
			li $s7, 1
			sw $s7, 0($sp)
			jal key_sort_matrix
			addi $sp, $sp, 4
			
			lw $s0, 0($sp)
			lw $s1, 4($sp)
			lw $s2, 8($sp)
			lw $s3, 12($sp)
			lw $s4, 16($sp)
			lw $s5, 20($sp)
			lw $s6, 24($sp)
			
			#$a0 is still $a0
			move $a1, $s6
			move $a2, $s0
			move $a3, $s1
			jal transpose
			
			lw $t0, 0($sp)
			lw $t1, 4($sp)
			lw $a2, 8($sp)
			lw $a0, 16($sp)
			lw $a1, 20($sp)
			lw $s6, 24($sp)
			
			#null terminate the cipertext
			mul $t2, $t0, $t1
			add $s6, $s6, $t2
			li $t3, 0
			sb $t3, ($s6)
			lw $a3, 24($sp)
			
			lw $s0, 0($sp)
			lw $s1, 4($sp)
			lw $s2, 8($sp)
			lw $s3, 12($sp)
			lw $s4, 16($sp)
			lw $s5, 20($sp)
			lw $s6, 24($sp)
			addi $sp, $sp, 28
    			
end_7:
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

lookup_helper:

	beq $a0, 65, isA
	beq $a0, 68, isD
	beq $a0, 70, isF
	beq $a0, 71, isG
	beq $a0, 86, isV
	beq $a0, 88, isX
	li $v0, -1
	j end_lookup_helper
	isA:
		li $v0, 0
		j end_lookup_helper
	isD:
		li $v0, 1
		j end_lookup_helper
	isF:
		li $v0, 2
		j end_lookup_helper
	isG:
		li $v0, 3
		j end_lookup_helper
	isV:
		li $v0, 4
		j end_lookup_helper
	isX:
		li $v0, 5
		j end_lookup_helper
end_lookup_helper:
jr $ra

# Part VIII
lookup_char:
li $v0, -200
li $v1, -200

	move $s0, $a0 #saving adfgvx_grid
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	
	move $a0, $a1
	jal lookup_helper
	beq $v0, -1, error_8
	move $t0, $v0
	
	move $a0, $a2
	jal lookup_helper
	beq $v0, -1, error_8
	move $t1, $v0
	
	lw $s0, 4($sp)
	li $t2, 6
	mul $t2, $t2, $t0
	add $t2, $t2, $t1
	add $s0, $s0, $t2
	lbu $v1, ($s0)
	li $v0, 0
	j end_8

	error_8:
		li $v0, -1
		li $v1, 64
end_8:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
jr $ra

# Part IX
string_sort:
li $v0, -200
li $v1, -200
	
	move $s0, $a0
	
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	li $t0, 0 #length
	len_loop:
		lbu $t1, ($a0)
   		beqz $t1, end_len_loop
		
		addi $a0, $a0, 1
    		addi $t0, $t0, 1
    		j len_loop
    	end_len_loop:
		li $t1, 0 #i
		sort_i_loop:
			li $t2, 0
			beq $t1, $t0, end_i_loop
			sort_j_loop:
				sub $t3, $t0, $t1 #this will always reset $t3 to n-i
				addi $t3, $t3, -1
				beq $t2, $t3, end_j_loop
			
				move $a0, $s0
				add $a0, $a0, $t2
				lbu $t4, 0($a0)
				lbu $t5, 1($a0)
				ble $t4, $t5, no_swap
			
				move $t6, $t4
				sb $t5, 0($a0) 
				sb $t6, 1($a0)
				no_swap:
					addi $t2, $t2, 1
					j sort_j_loop
			end_j_loop:
				addi $t1, $t1, 1
				j sort_i_loop
		end_i_loop:
			lw $s0, 0($sp)
			addi $sp, $sp, 4
jr $ra

index_of:
#$a0 = string
#$a1 = ch

	li $v0, -200
	li $v1, -200
	
	li $t1, 0
	index_of_loop:
	    lbu $t0, ($a0)
	    beq $t0, $a1, end_index_of_loop
	    beqz $t0, index_of_error
	    
	    addi $t1, $t1, 1
	    addi $a0, $a0, 1
	    j index_of_loop
	end_index_of_loop:
	    move $v0, $t1
	    j endIndex
	index_of_error:
	    li $v0, -1
	endIndex:
	jr $ra

# Part X
decrypt:
li $v0, -200
li $v1, -200
	
	move $s0, $a0 #adfgvx
	move $s1, $a1 #cipertext
	move $s2, $a2 #keyword
	move $s3, $a3 #plaintext
	
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	li $t0, 0 #length of keyword
	len_of_keyword_loop_d:
		lbu $t1, ($a2)
   		beqz $t1, end_len_of_keyword_loop_d
		
		addi $a2, $a2, 1
    		addi $t0, $t0, 1
    		j len_of_keyword_loop_d
    	end_len_of_keyword_loop_d:
    		#allocate mem
    		move $a0, $t0
    		li $v0, 9
    		syscall
    		
    		#reload keyword
    		lw $a2, 12($sp)
    		
    		#storing location of heap_key
    		move $s4, $v0 #heap_key
    	heap_key:
    		lbu $t1, ($a2)
    		sb $t1, ($v0)
    		beqz $t1, end_heap_key
    		
    		addi $v0, $v0, 1
    		addi $a2, $a2, 1
    		j heap_key
    	end_heap_key:
    	move $s5, $t0 #storing the length of key
    	addi $sp, $sp, -8
    	sw $s4, 0($sp) #heap_keyword
    	sw $s5, 4($sp) #length_key
    	
    	#sorting heap_keyword
    	move $a0, $s4
    	jal string_sort
    	
    	#heap_keyword_indices
    	sll $t1, $t0, 2
    	move $a0, $t1
    	li $v0, 9
    	syscall
    	
    	move $s6, $v0 #saving heap_keyword_indices
    	addi $sp, $sp, -4
    	sw $s6, 0($sp)
    	
    	li $t9, 0
    	undo_sort:
    		beq $t9, $s5, end_undo_sort
    		
    		move $a0, $s2 #keyword into argument 1
    		lbu $a1, ($s4)
    		jal index_of
    		sw $v0, ($s6)
    		
    		addi $s6, $s6, 4
    		addi $t9, $t9, 1
    		addi $s4, $s4, 1
    		j undo_sort
    	end_undo_sort:
    	lw $s6, 0($sp) #heap_keyword_indices
    	addi $sp, $sp, 4
    	
	lw $s4, 0($sp) #heap_keyword
    	lw $s5, 4($sp) #length_key
	addi $sp, $sp, 8
	
    	#count length ciphertext
    	lw $s1, 8($sp)
    	li $t7, 0
    	ciphertext_length:
		lbu $t3, ($s1)
   		beqz $t3, end_ciphertext_length
		
		addi $s1, $s1, 1
    		addi $t7, $t7, 1
    		j ciphertext_length
    	end_ciphertext_length:
    	move $t9, $s5 #num_rows
    	div $t7, $s5
    	mflo $t8 #num_cols
    	
    	move $a0, $t2
    	li $v0, 9
    	syscall
    	
    	#reload
    	lw $a0, 8($sp)
    	move $a1, $v0
    	move $a2, $t9
    	move $a3, $t8
    	jal transpose
    	
    	#storing length of ciphertext
    	addi $sp, $sp, -4
    	sw $t7, ($sp)
    	
    	move $a0, $a1
    	move $a1, $t8
    	move $a2, $t9
    	move $a3, $s6
    	addi $sp, $sp, -4
	li $s7, 4
	sw $s7, 0($sp)
	jal key_sort_matrix
	addi $sp, $sp, 4
	
	
    	lw $t7, ($sp)
    	addi $sp, $sp, 4
    	
	lw $a3, 16($sp)
	move $t9, $a0
	li $t8, 0
	li $t6, '*'
	decode_loop:
		lbu $t0, ($t9)
		beq $t0, $t6, end_decode_loop
		lbu $t1, 1($t9)
		beq $t8, $t7, end_decode_loop
		
		lw $a0, 4($sp)
		move $a1, $t0
		move $a2, $t1
		jal lookup_char
		sb $v1, ($a3)
		
		addi $a3, $a3, 1
		addi $t9, $t9, 2
		addi $t8, $t8, 2
		j decode_loop
 	end_decode_loop:
 	li $t0, 0
 	sb $t0, ($a3)
end_10:
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)
	lw $a3, 16($sp)
	addi $sp, $sp, 20
jr $ra

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
