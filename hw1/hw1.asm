# Siyuan Zou
# SIYZOU
# 111639762

.data
# Command-line arguments
num_args: .word 0
addr_arg0: .word 0
addr_arg1: .word 0
addr_arg2: .word 0
addr_arg3: .word 0
no_args: .asciiz "You must provide at least one command-line argument.\n"

# Error messages
invalid_operation_error: .asciiz "INVALID_OPERATION\n"
invalid_args_error: .asciiz "INVALID_ARGS\n"

# Output strings
zero_str: .asciiz "Zero\n"
neg_infinity_str: .asciiz "-Inf\n"
pos_infinity_str: .asciiz "+Inf\n"
NaN_str: .asciiz "NaN\n"
floating_point_str: .asciiz "_2*2^"

# Miscellaneous strings
nl: .asciiz "\n"

# Put your additional .data declarations here, if any.
bin_0: .asciiz "0000"
bin_1: .asciiz "0001"
bin_2: .asciiz "0010"
bin_3: .asciiz "0011"
bin_4: .asciiz "0100"
bin_5: .asciiz "0101"
bin_6: .asciiz "0110"
bin_7: .asciiz "0111"
bin_8: .asciiz "1000"
bin_9: .asciiz "1001"
bin_A: .asciiz "1010"
bin_B: .asciiz "1011"
bin_C: .asciiz "1100"
bin_D: .asciiz "1101"
bin_E: .asciiz "1110"
bin_F: .asciiz "1111"

array:	.word bin_0,bin_1,bin_2,bin_3,bin_4,bin_5,bin_6,bin_7,bin_8,bin_9,bin_A,bin_B,bin_C,bin_D,bin_E,bin_F
length:	.word 16

F_bin_str: .asciiz "********************************"
hmm: .word 0

C_str: .asciiz "********************************" #decimal to binary max length 32 bits

# Main program starts here
.text
.globl main
main:
    # Do not modify any of the code before the label named "start_coding_here"
    # Begin: save command-line arguments to main memory
    sw $a0, num_args
    beq $a0, 0, zero_args
    beq $a0, 1, one_arg
    beq $a0, 2, two_args
    beq $a0, 3, three_args
four_args:
    lw $t0, 12($a1)
    sw $t0, addr_arg3
three_args:
    lw $t0, 8($a1)
    sw $t0, addr_arg2
two_args:
    lw $t0, 4($a1)
    sw $t0, addr_arg1
one_arg:
    lw $t0, 0($a1)
    sw $t0, addr_arg0
    j start_coding_here
zero_args:
    la $a0, no_args
    li $v0, 4
    syscall
    j exit
    # End: save command-line arguments to main memory
    
start_coding_here:
    # Start the assignment by writing your code here
    li $t1, 'F' #Load Char F
    li $t2, 'C' #Load Char C
    li $t3, '2' #Load Char 2
    
    lw $t4, addr_arg0 #Load argument0
    lbu $t5, 0($t4) #Load first character

check_F: 
    bne $t1, $t5, not_F #Argument1 not equal to F
    lbu $t6, 1($t4) #Load second character
    bne $t6, $0, invalid_operation #Second character exist
    j is_F

check_C:
    bne $t2, $t5, not_C #Argument1 not equal to C
    lbu $t6, 1($t4) #Load second character
    bne $t6, $0, invalid_operation #Second character exist
    j is_C
    
check_2:    
    bne $t3, $t5, not_2 #Argument1 not equal to 2
    lbu $t6, 1($t4) #Load second character
    bne $t6, $0, invalid_operation #Second character exist
    j is_2
    
not_F:
    j check_C

not_C:
    j check_2
    
not_2:
    j invalid_operation
    
invalid_operation:
    #Print INVALID_OPERATION
    li $v0, 4
    la $a0, invalid_operation_error
    syscall
    j exit
    
invalid_args:
    #Print INVALID_ARGS
    li $v0, 4
    la $a0, invalid_args_error
    syscall
    j exit
    
is_F:
    lw $t1, addr_arg1 #Load argument1
    beq $t1, $0, invalid_args #Check if there is argument1
    
    lw $t2, addr_arg2 #Load argument2
    bne $t2, $0, invalid_args #Check if exceed the total required argument
    
    li $t0, 0 #Length count
    count_loop_F:
        lbu $t3, 0($t1) #Load byte of argument1
        
        beq $t3, $0, end_count_F #When byte reach the end
        
        validate_F:
            #Validate if bit is between 48-57 or 65-70 ascii values
            blt $t3, 48, invalid_args
            blt $t3, 58, continue_F
            
            blt $t3, 65, invalid_args
            bgt $t3, 70, invalid_args
            bgt $t3, 64, continue_F
        
        continue_F:
            addi $t1, $t1, 1 #Increase word position by 1
            addi $t0, $t0, 1 #Increase counter by 1
            j count_loop_F
    
    end_count_F:
    	bne $t0, 8, invalid_args #If count != 8, then invalid args
        
        lw $t1, addr_arg1 #Reload argument1
    	lbu $t2, 0($t1) #Load first byte
    	
    	beq $t2, '0', check_if_zero
    	beq $t2, '8', check_if_zero
    	
    	beq $t2, '7', check_if_inf
    	beq $t2, 'F', check_if_inf
    	
    	j not_special
    	
    check_if_zero:
    	lbu $t9, 1($t1)
    	
    	beq $t9, $0, is_zero #When byte reach the end
    	
    	bne $t9, '0', not_special #When its not 00000000 or 80000000
    	
    	addi $t1, $t1, 1 #Increase word position by 1
    	
    	j check_if_zero
    is_zero:
        #Print Zero
    	li $v0, 4
    	la $a0, zero_str
   	syscall
    	j exit
    
    check_if_inf:
    	lbu $t9, 1($t1) #Load second byte
    	bne $t9, 'F', not_special #check if second byte = 'F', if not the hexadecimal is not special
    	lbu $t9, 2($t1) #Load third byte
    	
    	bgt $t9, 56, is_NaN #When its 7F9***** or FF9*****
    	beq $t9, '8', inf_loop #When its 7F8***** or FF8*****
    	blt $t9, 56, not_special #When its 7F7***** or FF7*****
    	
    	inf_loop:
    	    lbu $t9, 3($t1) #Load fourth byte
    	    beq $t9, $0, check_neg_or_pos #When byte reach the end
    	
    	    bne $t9, '0', is_NaN #When its 7F8***** or FF8***** where * !=0
    	
    	    addi $t1, $t1, 1 #Increase word position by 1
    	    j inf_loop
    	    
    	check_neg_or_pos:
    	    #Reload because $t1 has been incremented due to loop
    	    lw $t1, addr_arg1 #Reload argument1
    	    lbu $t9, 0($t1) #Load first byte
    	    
    	    #This work because its been check once in the beginning already
    	    beq $t9, '7', is_pos_inf #When first byte is 7 its +inf
    	    beq $t9, 'F', is_neg_inf #When first byte is F its -inf
    	is_pos_inf:
    	    #Print +inf
    	    li $v0, 4
    	    la $a0, pos_infinity_str
   	    syscall
    	    j exit
    	is_neg_inf:
    	    #Print -inf 
    	    li $v0, 4
    	    la $a0, neg_infinity_str
   	    syscall
    	    j exit
    	    
    is_NaN:
        #Print NaN
    	li $v0, 4
    	la $a0, NaN_str
        syscall
    	j exit
    	
    not_special:
        la $s1, F_bin_str
    	lw $t1, addr_arg1 #Reload argument1
    	
    	reload_array: 
    	    la $t2, array #$t2 will to point elements of array
    	    
    	not_special_loop:
    	    lbu $t3, 0($t1) #Load byte of argument1
            	
       	    beq $t3, $0, end_not_special_loop #When byte reach the end
            
            bgt $t3, 57, sub_55 #not 0-9 goto A-F
            
            #0-9
            addi $t3, $t3, -48 #Get decimal value of character
            sll $t3, $t3, 2 #*4 to offset for the array
            add $t2, $t2, $t3 #Offset address pointer
            j continue_not_spec
            
            #A-F
            sub_55:
            	addi $t3, $t3, -55 #Get decimal value of character
            	sll $t3, $t3, 2 #*4 to offset for the array
            	add $t2, $t2, $t3 #Offset address pointer
            	
            continue_not_spec:
            	lw $t4, ($t2) #Load the corresponding binary representation from array
            	
            	bin_loop: 
            	    lbu $t5, 0($t4) #Load byte from binary
            	    beqz $t5, go_on
            	    sb $t5, ($s1) #Store into F_bin_str
            	    addi $t4, $t4, 1 #Increment $t4
            	    addi $s1, $s1, 1 #Increment the location of $s1 to store byte
            	    j bin_loop
   	    	
   	    	go_on:    
   		    la $t2, array #Reset the array so the $t2 is not offset
   		    
            addi $t1, $t1, 1 #Increment for next byte of the argument1
            j not_special_loop
        
        end_not_special_loop:
            la $s1, F_bin_str #Load the now 32 bit binary representation of the give hexadecimal
            lbu $t6, 0($s1)
            beq $t6, '0', not_special_print #Skip negative sign
            beq $t6, '1', not_special_neg #Print negative sign
            
            not_special_neg:
            	li $s2 '-'
            	move $a0, $s2
            	li $v0, 11
            	syscall
            not_special_print:
            	#Print 1.blank
            	li $s2 '1'
            	move $a0, $s2
            	li $v0, 11
            	syscall
            	
            	li $s2 '.'
            	move $a0, $s2
            	li $v0, 11
            	syscall
            	
            	mantissa_loop:
            	    #Print the 23 bit mantissa
            	    lbu $t6, 9($s1)
            	    beqz $t6, end_mantissa_loop
            	    
            	    move $a0, $t6
            	    li $v0, 11
            	    syscall
            	    
            	    addi $s1, $s1, 1
            	    j mantissa_loop
            	    
            	end_mantissa_loop:
            	    #Print the exponent _2*2^
            	    la $a0, floating_point_str
            	    li $v0, 4
            	    syscall
            	    
            	    
            	    la $s1, F_bin_str #Reload F_bin_str
            	    li $t7, 7 #Count down of 8 bits
            	    li $t8, 0 #Exponent output
            	    exponent_loop:
            	    	lbu $t6, 1($s1)
            	    	
            	    	#Calculation of adding the exponent decimal value
            	    	addi $t6, $t6, -48
            	    	sllv $t6, $t6, $t7
            	    	add $t8, $t8, $t6
            	    	
            	    	beqz $t7, end_exponent_loop
            	    	
            	    	addi $s1, $s1, 1 #Move to next bit
            	    	addi $t7, $t7, -1 #Counter--
            	    	j exponent_loop
            	    	
            	    end_exponent_loop:
            		addi $t8, $t8, -127 #Subtract 127
            		
            		#Print the exponent
            		move $a0, $t8
            		li $v0, 1
            	    	syscall
            	    	
            	    	la $a0, nl
    	    		li $v0, 4
    	    		syscall
    	    		
    			j exit
    
is_C:
    lw $t1, addr_arg1 #Load argument1, only digit so 0-9
    lw $t2, addr_arg2 #Load argument2, 2-10
    lw $t3, addr_arg3 #Load argument3, 2-10
    beq $t1, $0, invalid_args #Check if there is argument1
    beq $t2, $0, invalid_args #Check if there is argument2
    beq $t3, $0, invalid_args #Check if there is argument3
    
    lw $t4, 16($a1) #Loading argument4, which should not be there.
    bne $t4, $0, invalid_args #Check if exceed the total required argument
    
    lbu $t5, 0($t2) #First byte of argument 2
    beq $t5, '1' end_validation #digit 0-9 is always smaller than 10
    
    validate_normal:
        lbu $s0, 0($t1) #Load byte from argument1
        beqz $s0, end_validation #End when reached $s0 doesnt read anything
        
    	bge $s0, $t5, invalid_args #if the ascii of $s0 is >= $t5 invalid_args
    	
    	addi $t1, $t1, 1 #Increment by 1
    	j validate_normal
    	
    end_validation:
    	lbu $t6, 0($t3) #First byte of argument 3
    	beq $t6, $t5, print_as_is #if arg2 = arg3 same base just print
    	
    	lw $t1, addr_arg1 #Reload argument1
    	
    	addi $s2, $t5, -48 #the value for argument 2
    	lbu $s0, 0($t1) #byte 1 of arg1
    	addi $s0, $s0, -48 #the value for byte 1 of argument 1
    	
        beq $s2, 1, add_9
        bne $s2, 1, convert_decimal
        add_9:
            addi $s2, $s2, 9
            
    	convert_decimal:
    	    lbu $s1, 1($t1) #Load byte from argument1
    	    beqz $s1, end_decimal_convert
    	    
    	    mul $s0, $s0, $s2 #output*base
    	    addi $s1, $s1, -48 #convert byte to number
    	    add $s0, $s0, $s1 #add number
    	    
    	    addi $t1, $t1, 1 #Increment by 1
    	    j convert_decimal
    	end_decimal_convert:
    	    #if argument 3 is 10 skip divide_convert
    	    beq $t6, '1', print_decimal #base x->10, x!=10 then just print decimal
    	    
    	    addi $t6, $t6, -48
    	    la $s7, C_str
    	    li $s6, 0
    	    divide_convert:
    	    	div $s0, $t6
    	    	mfhi $s1 # reminder to $s1
    	    	mflo $s0 # quotient to $s0
    	    	
    	    	addi $s3, $s1, 48
    	    	
    	    	sb $s3, 0($s7)
    	    	addi $s7, $s7, 1
    	    	addi $s6, $s6, 1
    	    	
    	    	beqz $s0, end_divide_convert
    	    	
    	    	j divide_convert
    	    end_divide_convert:
    	    	la $s7, C_str
    	    	add $s7, $s7, $s6
    	    	print_c_str_loop:
    	    	    addi $s7, $s7, -1
    	    	    lbu $t1, 0($s7)
    	    	    
    	    	    move $a0, $t1
    	    	    li $v0, 11
    	    	    syscall
    	    	    
    	    	    addi $s6, $s6, -1
    	    	    beqz $s6, end_print_c_str_loop
    	    	    j print_c_str_loop
    	    	end_print_c_str_loop:
    	    	    la $a0, nl
    	    	    li $v0, 4
    	    	    syscall
    	    	    j exit    	    
    	    print_decimal:
    	    	move $a0, $s0
    	    	li $v0, 1
    	    	syscall
    	    	
    	    	la $a0, nl
    	    	li $v0, 4
    	    	syscall
    	    	j exit
    	    	
    	print_as_is:
    	    lw $a0, addr_arg1
    	    li $v0, 4
    	    syscall
    	    
    	    la $a0, nl
    	    li $v0, 4
    	    syscall
    j exit
    
is_2:
    lw $t1, addr_arg1 #Load argument1
    beq $t1, $0, invalid_args #Check if there is argument1
    
    lw $t2, addr_arg2 #Load argument2
    bne $t2, $0, invalid_args #Check if exceed the total required argument
    
    li $t0, 0 #Length count
    count_loop_2:
        lbu $t3, 0($t1) #Load byte of argument1
        
        beq $t3, $0, end_count_2 #When byte reach the end
        
        #Check if its only 0 or 1
        beq $t3, '0', continue_2 #If equal to 0 continue the loop
        bne $t3, '1', invalid_args #If not equal to 1 -> fails -> invalid args
        
        continue_2:
            addi $t1, $t1, 1 #Increase word position by 1
            addi $t0, $t0, 1 #Increase counter by 1
            j count_loop_2
    
    end_count_2:
    	bgt $t0, 32, invalid_args #If count > 32, then invalid args
    	
    	lw $t1, addr_arg1 #Reload argument1
    	lbu $t2, 0($t1) #Load first byte
    	
    	beq $t2, '0', positive #positive number
    	beq $t2, '1', negative #negative number
    	
    positive:
    	li $t3, 0 #Output number
    	li $t4, 48 #Ascii 0
    	positive_loop:
    	    lbu $t9, 1($t1)
    	    
    	    beq $t9, $0, end_positive_loop
    	    
    	    sll $t3, $t3, 1 #*2
    	    sub $t5, $t9, $t4 #convert byte to number
    	    add $t3, $t3, $t5 #add number
    	    
    	    addi $t1, $t1, 1 #Increase word position by 1
    	   
    	    j positive_loop
    	    
    	end_positive_loop:
    	    #Print Result
    	    move $a0, $t3
            li $v0, 1
    	    syscall
    	    
    	    la $a0, nl
    	    li $v0, 4
    	    syscall
    	j exit
    negative:
    	li $t3, 0 #Output number
    	li $t4, 48 #Ascii 0
    	
    	beq $t0, 32, no_Negate
    	
    	li $t5, 1
    	addi $t0, $t0, -1 #Sub 1 from count
    	sllv $t3, $t5, $t0 #Calculate 2^count-1 and store it into the output.
    	
    	li $t5, -1
    	mul $t3, $t3, $t5 #Negate
    	
    	j negative_loop
    	
    	#Since 2^31 is already negative and you cannot negate that or else there will be an overflow
    	no_Negate:
    	    li $t5, 1
    	    addi $t0, $t0, -1 #Sub 1 from count
    	    sllv $t3, $t5, $t0 #Calculate 2^count-1 and store it into the output.
    	    
    	    j negative_loop
    	
    	negative_loop:
    	    lbu $t9, 1($t1)
    	    addi $t0, $t0, -1 #Sub 1 from count
    	    
    	    beq $t9, $0, end_negative_loop
    	    
    	    sub $t5, $t9, $t4 #convert byte to number
    	    sllv $t5, $t5, $t0 #Multiply bit with corresponding 2^x
    	    add $t3, $t3, $t5 #Add to output
    	    
    	    addi $t1, $t1, 1 #Increase word position by 1
    	    j negative_loop
    	    
    	end_negative_loop:
    	    #Print Result
    	    move $a0, $t3
            li $v0, 1
    	    syscall
    	    
    	    la $a0, nl
    	    li $v0, 4
    	    syscall
        j exit
exit:
    li $v0, 10   # terminate program
    syscall
