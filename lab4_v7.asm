.data

	foundValuesString:
		.asciiz "Element amount: "
	foundPreviousElementValueString:
		.asciiz "\nValue of previous element: "
	foundPreviousElementAddressString:
		.asciiz "\nAddress of previous element: "
	notFoundValuesString:
		.asciiz "No suitable elements."
	notFoundPreviousElementString:
		.asciiz "\nNo previous element."

	someArray: 	.word 1, 2, 3, 4
			.word 5, 8, 7, 8
			.word 9, 50, 8, 12
			.word 13, 14, 10, 0

	numberIndexs: .word 4
	sizeRow: .word 2 # -2
	sizeColumn: .word 2 # -2
	.eqv DATA_SIZE 4
.text
	main:		
		la $a0, someArray
		lw $a1, sizeColumn
		lw $a2, sizeRow
		lw $a3, numberIndexs

		jal findValues
		
		bgtz $t0, foundValues
		la $a0, notFoundValuesString
      		li $v0, 4
      		syscall 
      		j endProgram
		foundValues:
			la $a0, foundValuesString
      			li $v0, 4
      			syscall 
			move $a0, $t0
			li $v0, 1
			syscall
		
		beq $t0, 1, notfoundPreviousValue
		
		la $a0, foundPreviousElementAddressString
      		li $v0, 4
      		syscall 
		move $a0, $t1
      		li $v0, 34
      		syscall
		
		lw $t1, ($t1)
		la $a0, foundPreviousElementValueString
      		li $v0, 4
      		syscall 
      		move $a0, $t1
		li $v0, 1
		syscall
		j endProgram
		
		notfoundPreviousValue:
			la $a0, notFoundPreviousElementString
      			li $v0, 4
      			syscall 
		
		endProgram:
			li $v0, 10
			syscall

	nextElement:
		# addr = baseAddr + (rowIndex * columnSize + colIndex) * dataSize
		
		# li $t0, 0 #Index
		# li $t1, 0 #Column
		
		# Get element
		mul $t8, $t0, $a3 	# rowIndex * columnSize
		add $t8, $t8, $t1 	# + colIndex
		mul $t8, $t8, DATA_SIZE # * dataSize
		add $t8, $t8, $a0 	# + baseAddr
		
		add $t0, $t0, 1 # shift index
		add $t1, $t1, 1 # shift index
		jr $ra
	
	multElements:
		sw $ra, 8($gp)
		# Load diagonal
		jal nextElement
		lw $t3, ($t8)
		jal nextElement
		move $t4, $t8
		jal nextElement
		lw $t5, ($t8)
		mul $t3, $t3, $t5
		# Reset entry points(index,column)
		sub $t0, $t0, 3
		sub $t1, $t1, 3
		lw $ra, 8($gp)
		jr $ra
	
	checkNoteElements:
		lw $t5, ($t4)
		beq $t5, $t3, addMatch
		j EndChecker
		addMatch:
			add $v0, $v0, 1 # Add Match
			bge $v0, 2, noteFormerValue # Condition to start noting former value
			move $t6, $t4 # Save former value
			j EndChecker
			noteFormerValue:
				move $t9, $t6 # Note former value
	
		EndChecker:
			jr $ra
	
	findValues:
		sw $ra, 8($sp)	
		li $v0, 0 # Sum relevant values
		li $t9, 0 # Former value
		li $t1, 0 # indexColumn
		li $t0, 0 # indexRow
		columnLoop:
			indexLoop:
				jal multElements
				jal checkNoteElements
				add $t1, $t1, 1
				beq $t1, $a1, ContinueColumnLoop
				j indexLoop
			ContinueColumnLoop:
				li $t1, 0
				add $t0, $t0, 1
				beq $t0, $a2, endColumnLoop
				j columnLoop
		endColumnLoop:
			move $t0, $v0
			move $t1, $t9
			lw $ra, 8($sp)
			jr $ra
