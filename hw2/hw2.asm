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

### Part I ###
index_of_car:
	li $v0, -200
	li $v1, -200
	move $t0, $a0 #move car array to $t0
	blez $a1, return_error #length ? 0
	bltz $a2, return_error #start index < 0
	bge $a2, $a1, return_error #start index ? length
	blt $a3, 1885, return_error #year < 1885
	
	li $t9, 16
	li $t8, 256
	li $t7, 0 #index
	mul $t1, $a2, $t9 #start_index*16 = offset
	add $t7, $t7, $a2 #reposition return index
        add $t0, $t0, $t1 #add offset
	index_of_car_loop:
	    addi $t0, $t0, 12 #add 12 to locate the year
	    lbu $t2, 0($t0) #first byte of year
	    lbu $t3, 1($t0) #second byte of year
	    mul $t3, $t3, $t8 #year calculation, second byte*256
	    add $t4, $t2, $t3 #add first byte with prev. calculation to get year.
            bge $t7, $a1, return_error #once index >= length, no car found.
            beq $t4, $a3, return_index #once match found, break and return
            
            addi $t7, $t7, 1 #i+=1
            addi $t0, $t0, 4 #move to next car
            
            j index_of_car_loop
	return_index:
	    move $v0, $t7
	    j end1
	
	return_error:
	    li $v0, -1

	end1:
	    jr $ra
	

### Part II ###
strcmp:
	li $v0, -200
	li $v1, -200
	move $t0, $a0 #str1 to $t0
	move $t1, $a1 #str2 to $t1
	lbu $t2, 0($t0)
	lbu $t3, 0($t1)
	beqz $t2, str1_empty #if str1 empty
	beqz $t3, str2_empty #if str2 empty but str1 is not
	li $t4, 0 #ascii result
	match_loop:
	    lbu $t2, 0($t0)
	    lbu $t3, 0($t1)
	    
	    sub $t4, $t2, $t3
	    
	    bnez $t4, found_mismatch #$t4 is not 0 they ascii difference
	    
	    add $t5, $t2, $t3 #ascii1+ascii2
	    beqz $t5, str_equal #$t5 is null+null = 0, both ended and are the same
	    
	    addi $t0, $t0, 1
            addi $t1, $t1, 1
            
            j match_loop
	found_mismatch:
	    move $v0, $t4
	j end2
	
	str1_empty:
	    beqz $t3, str_equal #if both empty
	    #return str2 length
	    li $t4, 0 #counter
	    str2_length:
	    	lbu $t3 0($t1)
	    	beqz $t3, end_s2_length
	    	addi $t1, $t1, 1
	    	addi $t4, $t4, 1
	    
	    	j str2_length
	    end_s2_length:
	    	li $t5, -1
	    	mul $t4, $t4, $t5
	    	move $v0, $t4
	    j end2
	str2_empty:
	    #return str1 length
	    li $t4, 0 #counter
	    str1_length:
	    	lbu $t2 0($t0)
	    	beqz $t2, end_s1_length
	    	addi $t0, $t0, 1
	    	addi $t4, $t4, 1
	    
	    	j str1_length
	    end_s1_length:
	    	move $v0, $t4
	    j end2
	str_equal:
	    li $v0, 0
	
	end2:
	    jr $ra


### Part III ###
memcpy:
	li $v0, -200
	li $v1, -200
	
	blez $a2, mem_error
	move $t0, $a0 #get src
	move $t1, $a2 #get counter
	memcpy_loop:
	    lbu $s7, 0($t0) #loading byte from t0
	    sb $s7, 0($a1) #storing byte to a1
	    
	    beq $t1, 1, end_memcpy_loop #equal to one because we do not want to store a null terminator into dezt
	    
	    addi $t0, $t0, 1
	    addi $a1, $a1, 1
	    addi $t1, $t1, -1
	    
	    j memcpy_loop
	end_memcpy_loop:
	    li $v0, 0
	    j end3
	mem_error:
	    li $v0, -1
	end3:
	    jr $ra

### Part IV ###
insert_car:
	#usable temp $t2-$t9 because memcoy uses $t0 and $t1
	li $v0, -200
	li $v1, -200
	
	bltz $a1, insert_error #length < 0
	bltz $a3, insert_error #index < 0
	bgt $a3, $a1, insert_error #index > length
	
	move $t0, $a1 #t0 now holds length ($t0 is fine here since its used only once)
	sub $t8, $t0, $a3 #Number of shifts
	sll $t2, $t0, 4 #t0 * 16
	
	move $s0, $a0 #start of car array
	move $t9, $a2 #new car
	
	addi $sp, $sp, -8
	sw $ra, 0($sp) #store return address
	sw $s0, 4($sp) #store the start of car array
	
	add $t3, $a0, $t2 #location to start the shift
	
	beqz $t8, no_shift
	#backward shifting of array
	shift_loop:
	    addi $a0, $t3, -16 #what to copy
	    move $a1, $t3 #location to copy to
	    li $a2, 16 #number of bytes to copy
	    jal memcpy
	    
	    addi $t8, $t8, -1 #number of shift--
	    beqz $t8, end_shift_loop
	    
	    addi $t3, $t3, -16 #next slot to copy to
	    
	    j shift_loop
	
	no_shift:
	    addi $t3, $t3, 16
	end_shift_loop:
	    addi $t3, $t3, -16
	    move $a0, $t9
	    move $a1, $t3
	    li $a2, 16
	    jal memcpy
	    
	    li $v0, 0
	    
	    lw $s0, 4($sp)
	    lw $ra, 0($sp)
	    addi $sp, $sp, 8
	    
	    move $a0, $s0
	    j end4
	insert_error:
	    li $v0, -1
	end4:
	    jr $ra
	

### Part V ###
most_damaged:
	li $v0, -200
	li $v1, -200
	blez $a2, most_dmg_error
	blez $a3, most_dmg_error
	move $t0, $a0 #car array
	li $v0, 0 #there is no error so there got to be an index to return to
	li $v1, -1 #cost cannot be negative so comparison with -1 is fine.\
	move $t5, $a2
	li $t4, 0 #index of car
	c_loop:
	    beqz $t5, c_loop_end 
	    lw $t2, ($t0)
	    li $t7, 0 #total cost
	    move $t1, $a1 #repair array reset
	    move $t6, $a3 #reset repair length
	    r_loop:
	    	beqz $t6, r_loop_end 
	    	lw $t9, ($t1)
	    	lw $t8, ($t9)
	    	beq $t8, $t2, sum_cost
	    	j next_repair
	    	sum_cost:
	    	    addi $t1, $t1, 8 #get to cost
	    	    lbu $t9, ($t1)
	    	    lbu $t8, 1($t1)
	    	    sll $t8, $t8, 8 #*256
	    	    add $t9, $t9, $t8 #cost calculation
	    	    add $t7, $t7, $t9 #add to total cost
	    	    addi $t1, $t1, 4 #get to next repair struct
	    	    addi $t6, $t6, -1
	    	    j r_loop
	    	next_repair:
	    	    addi $t1, $t1, 12
	    	    addi $t6, $t6, -1
	    	    j r_loop
	    r_loop_end:
	    	blt $v1, $t7, new_most_dmg
	    	j no_change
	    	new_most_dmg:
	    	    move $v0, $t4
	    	    move $v1, $t7
	    	no_change:
	    	    addi $t0, $t0, 16
	    	    addi $t4, $t4, 1
	    	    addi $t5, $t5, -1
	    	    j c_loop
	c_loop_end:
	    j end5
	most_dmg_error:
	    li $v0, -1
	    li $v1, -1
	end5:
	    jr $ra


### Part VI ###
sort:
	#usable temp $t2-$t9 because memcoy uses $t0 and $t1
	li $v0, -200
	li $v1, -200
	blez $a1, sort_error
	li $t2, 0 #sorted false
	
	move $s0, $a0 #start of car array
	move $s1, $a1 #car length
	
	addi $sp, $sp, -16
	sw $ra, 0($sp) #store return address
	sw $s0, 4($sp) #store the start of car array
	sw $s1, 8($sp) #store the start of car array
	
	sort_loop:
	    beq $t2, 1, end_sort_loop
	    li $t2, 1 #sorted true
	    
	    #Reset i, length-1, and car_array
	    li $t4, 1
	    move $t3, $s1 #car length
	    addi $t3, $t3, -1 #length-1
	    move $a0, $s0 #reset car array
	    addi $a0, $a0, 16
	    odd_loop:
	        bge $t4, $t3, end_odd_loop
	        
	        addi $a0, $a0, 12 #go to car[i]'s year
	    	lbu $t5, 0($a0) #first byte of year
	    	lbu $t6, 1($a0) #second byte of year
	    	sll $t6, $t6, 8 #year calculation, second byte*256
	    	add $t5, $t5, $t6 #add first byte with prev. calculation to get year.
	    	addi $a0, $a0, 16 #car[i+1]'s year
	    	lbu $t8, 0($a0) #first byte of year
	    	lbu $t9, 1($a0) #second byte of year
	    	sll $t9, $t9, 8 #year calculation, second byte*256
	    	add $t8, $t8, $t9 #add first byte with prev. calculation to get year.
	    	addi $a0, $a0, -28 #go to car[i]
	    	move $t7, $a0 #pointer at current $a0
	    	
	    	bgt $t5, $t8, odd_swap
	    	j no_odd_swap
	    	odd_swap:
	            li $t2, 0 #false
	            addi $sp, $sp, -16
	            
	            move $a1, $sp #sp will now hold car[i]
	            li $a2, 16
	            jal memcpy
	            
	            move $a1, $t7 #a1 is now car[i]
	            addi $t7, $t7, 16 #go to car[j]
	            move $a0, $t7
	            li $a2, 16
	            jal memcpy
	            
	            move $a1, $t7 #car[j]
	            move $a0, $sp #car[i]
	            jal memcpy
	            
	            addi $t7, $t7, -16
	            move $a0, $t7
	            
	            addi $sp, $sp, 16
	        no_odd_swap:
	        addi $t4, $t4, 2
	        addi $a0, $a0, 32 
	        j odd_loop
	    
	    end_odd_loop:
	    
	    #Reset i, length-1, and car_array
	    li $t4, 0
	    move $t3, $s1 #car length
	    addi $t3, $t3, -1 #length-1
	    move $a0, $s0 #reset car array
	    even_loop:
	        bge $t4, $t3, end_even_loop
	        
	        addi $a0, $a0, 12 #go to car[i]'s year
	    	lbu $t5, 0($a0) #first byte of year
	    	lbu $t6, 1($a0) #second byte of year
	    	sll $t6, $t6, 8 #year calculation, second byte*256
	    	add $t5, $t5, $t6 #add first byte with prev. calculation to get year.
	    	addi $a0, $a0, 16 #car[i+1]'s year
	    	lbu $t8, 0($a0) #first byte of year
	    	lbu $t9, 1($a0) #second byte of year
	    	sll $t9, $t9, 8 #year calculation, second byte*256
	    	add $t8, $t8, $t9 #add first byte with prev. calculation to get year.
	    	addi $a0, $a0, -28 #go to car[i]
	    	move $t7, $a0 #pointer at current $a0
	    	
	    	bgt $t5, $t8, even_swap
	    	j no_even_swap
	    	even_swap:
	            li $t2, 0 #false
	            addi $sp, $sp, -16
	            
	            move $a1, $sp #sp will now hold car[i]
	            li $a2, 16
	            jal memcpy
	            
	            move $a1, $t7 #a1 is now car[i]
	            addi $t7, $t7, 16 #go to car[j]
	            move $a0, $t7
	            li $a2, 16
	            jal memcpy
	            
	            move $a1, $t7 #car[j]
	            move $a0, $sp #car[i]
	            jal memcpy
	            
	            addi $t7, $t7, -16
	            move $a0, $t7
	            
	            addi $sp, $sp, 16
	        no_even_swap:
	        addi $t4, $t4, 2
	        addi $a0, $a0, 32
	        j even_loop
	    
	    end_even_loop:
	    j sort_loop
	end_sort_loop:
	    li $v0, 0
	    
	    lw $s1, 8($sp)
	    lw $s0, 4($sp)
	    lw $ra, 0($sp)
	    addi $sp, $sp, 16
	    
	    move $a0, $s0
	    move $a1, $s1
	    j end6
	sort_error:
	    li $v0, -1
	end6:
	    jr $ra


### Part VII ###
most_popular_feature:
	li $v0, -200
	li $v1, -200
	
	blez $a1, feature_error
	
	#$a2 = [1, 15]
	blt $a2, 1, feature_error
	bgt $a2, 15, feature_error 
	
	li $t0, 0 #convertables
	li $t1, 0 #hybrids
	li $t2, 0 #tinted windows
	li $t3, 0 #GPS
	
	move $t4, $a0
	move $t5, $a1
	move $t6, $a2
	
	feature_loop:
	    beqz $t5, end_feature_loop
	    addi $t4, $t4, 14
	    lbu $t7, ($t4)
	    convertables:
	    	andi $t9, $t6, 0x00000001
	    	bne $t9, 1, hybrids
	    	andi $t8, $t7, 0x00000001
	    	bne $t8, 1, hybrids
	    	addi $t0, $t0, 1
	    hybrids:
	    	andi $t9, $t6, 0x00000002
	    	bne $t9, 2, tinted_windows
	    	andi $t8, $t7, 0x00000002
	    	bne $t8, 2, tinted_windows
	    	addi $t1, $t1, 1
	    tinted_windows:
	    	andi $t9, $t6, 0x00000004
	    	bne $t9, 4, gps
	    	andi $t8, $t7, 0x00000004
	    	bne $t8, 4, gps
	    	addi $t2, $t2, 1
	    gps:
	    	andi $t9, $t6, 0x00000008
	    	bne $t9, 8, feature_continue
	    	andi $t8, $t7, 0x00000008
	    	bne $t8, 8, feature_continue
	    	addi $t3, $t3, 1
	    feature_continue:
	    	addi $t5, $t5, -1
	    	addi $t4, $t4, 2
	    	j feature_loop
	end_feature_loop:
	    li $t9, 0
	    add $t9, $t9, $t0
	    add $t9, $t9, $t1
	    add $t9, $t9, $t2
	    add $t9, $t9, $t3
	    
	    beqz $t9, feature_error
	    li $v0, 0
	    move_convertables:
	    	li $v0, 1
	    	ble $t0, $t1, move_hybrids
	    	ble $t0, $t2, move_tinted_windows
	    	ble $t0, $t3, move_gps
	    	j end7
	    move_hybrids:
	    	li $v0, 2
	    	ble $t1, $t2, move_tinted_windows
	    	ble $t1, $t3, move_gps
	    	j end7
	    move_tinted_windows:
	    	li $v0, 4
	    	ble $t2, $t3, move_gps
	    	j end7
	    move_gps:
	    	li $v0, 8
	    	j end7
	    	
	feature_error:
	    li $v0, -1
	end7:
	jr $ra
	

### Optional function: not required for the assignment ###
transliterate:
#a0 = str
#a1 = ch
	li $v0, -200
	li $v1, -200
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal index_of
	
	beq $v0, -1, endtransliterate
	
	li $t1, 10
	div $v0, $t1
	mfhi $v0
	
	endtransliterate:
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra


### Optional function: not required for the assignment ###
char_at:
#take 2 arguments $a0 = the string, $a1 = index
#assumptions: 
    #1. $a0 is not empty 
    #2. $a1 is not index out of bound
	li $v0, -200
	li $v1, -200
	
	bltz $a1, char_error
	
	add $a0, $a0, $a1
	lbu $t0, ($a0)
	move $v0, $t0
	j endChar
	
	char_error:
	    li $v0, -1
	endChar:
	jr $ra


### Optional function: not required for the assignment ###
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


### Part VIII ###
compute_check_digit:
	li $v0, -200
	li $v1, -200
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	move $t9, $a0 #vin
	move $t8, $a1 #map
	move $t7, $a2 #weights
	move $t6, $a3 #transliterate_str
	
	li $t5, 0 #sum
	li $t4, 0 #index
	check_digit_loop:
	    bge $t4, 17, end_check_digit_loop
	    move $a0, $t9
	    move $a1, $t4
	    jal char_at
	    
	    move $a0, $t6
	    move $a1, $v0
	    jal transliterate
	    
	    move $t3, $v0 #transliterate(vin.charAt(i), transliterate_str)
	    
	    move $a0, $t7
	    move $a1, $t4
	    jal char_at
	    
	    move $a0, $t8
	    move $a1, $v0
	    jal index_of
	    
	    move $t2, $v0
	    
	    mul $t3, $t3, $t2
	    add $t5, $t5, $t3
	    addi $t4, $t4, 1
	    j check_digit_loop
	    
	end_check_digit_loop:
	    li $t9, 11
	    div $t5, $t9
	    mfhi $a1
	    move $a0, $t8
	    jal char_at
	    
	end8:
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra	

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
