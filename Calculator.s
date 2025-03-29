.data
	msg_op_input:   .asciiz "Please enter your instruction.\n < to exit. + - * / ^ to do mathematical operations\n"
	msg_num_input:  .asciiz "\nPlease enter 2 numbers\n"
	msg_result:     .asciiz "The result is: " 
	msg_exit:       .asciiz "\nSee ya!\n"
	msg_newline:    .asciiz "\n"
	msg_error:      .asciiz "\nInvalid instruction. Please try again\n"

	jump_table:	.word case_mult, case_add, case_exit, case_sub, case_power, case_div # Jump table for the instructions
.text
.globl main

main:
	li $v0, 4  	        # Syscall for print_string
	la $a0, msg_op_input    # Load address of string into $a0
	syscall		        # Prints operation input message to the console

	li $v0, 12              # Syscall for read_char
	syscall                 # Takes the operation from the user
	move $t0, $v0		# Stores the character in $t0

	andi $t2, $t0, 0x0007   # Keeps only the last 3 bits and stores them in $t2

        # Check if valid (between 2-7)
        li $t1, 2
        blt $t2, $t1, default  	# If < 2, invalid
        li $t1, 7
        bgt $t2, $t1, default  	# If > 7, invalid
	li $t1, 4
	beq $t2, $t1, case_exit # Exits the application

        li $v0, 4               # Syscall for print_string
        la $a0, msg_num_input   # Load address of string into $a0
        syscall		        # Prints number input message to the console

	li $v0, 5               # Syscall for read_int
	syscall		        # Takes input 1 from the user
	move $t0, $v0           # Stores number 1 in $t0

	li $v0, 5               # Syscall for read_int
	syscall		        # Takes input 2 from the user
	move $t1, $v0	        # Stores number 2 in $t1

	# Compute jump table index (shift for word offset)
    	la $t3, jump_table
    	sub $t2, $t2, 2        	# Normalize (2 → 0, 3 → 1, 4 → 2, etc.)
    	sll $t2, $t2, 2        	# Multiply by 4 (word size)
    	add $t3, $t3, $t2      	# Add offset
    	lw $t4, 0($t3)         	# Load function address
    	jr $t4                 	# Jump to function

default:
	li $v0, 4               # Syscall for print_string
        la $a0, msg_error     	# Load address of string into $a0
        syscall		        # Prints error message to the console
	j main			# Resets application

case_add:
	add $t5, $t1, $t0       # Adds the 2 inputted numbers 
	j result                # Jumps to the output section

case_sub:
	sub $t5, $t1, $t0	# Subtracts the 2 inputted numbers
	j result		# Jumps to the output section

case_mult:
	mul $t5, $t1, $t0	# Multiplies the 2 outputted numbers
	j result		# Jumps to the output section

result:
	li $v0, 4               # Syscall for print_string
        la $a0, msg_result      # Load address of string into $a0
        syscall		        # Prints result message to the console
	
	li $v0, 1               # Syscall for print_int
	move $a0, $t5           # Moves the result from $t2 to $a0
	syscall	 	        # Prints the result to the console

	li $v0, 4               # Syscall for print_string
        la $a0, msg_newline     # Load address of string into $a0
        syscall		        # Prints an empty line to the console
	j main                  # Resets application

case_exit:
        li $v0, 4               # Syscall for print_string
        la $a0, msg_exit        # Load address of string into $a0
        syscall		        # Prints input message to the console


        li $v0, 10              # Syscall for exit
        syscall                 # Exit program
