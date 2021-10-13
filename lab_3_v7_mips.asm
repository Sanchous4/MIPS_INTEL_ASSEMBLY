.data
	A: .double 10.5
	B: .double 5.1
	S: .double 0.0
	ln_2: .double 0.6931
	v_8: .double 8.0
	v_1: .double 1.0
.text
	main:	
		jal power_2  # $f14 - 2^B
		jal max_value # $f16 - max(A*8,B)
		jal power_2_B_1_max # $f14 - 2^B-1 + max(A*8,B)
		
		mov.d $f12, $f14
		li $v0,3
		syscall
		
        li $v0,10
        syscall
        
        power_2_B_1_max:
        	ldc1 $f18, v_1
        	sub.d $f14,$f14,$f18
        	add.d $f14,$f14,$f16
        	jr $ra
        
        max_value:
        	ldc1 $f16, A
		ldc1 $f18, v_8    
		mul.d $f16,  $f16, $f18
		
		ldc1 $f18, B
		c.lt.d $f16, $f18    
		bc1t case           
		
		jr $ra
		case:
			mov.d $f16,$f18
		jr $ra
        
        power_2:
        	li $t6,1
		ldc1 $f14, S
		sw $ra, 8($gp)
      		loop:
          		beq $t6, 10, exit
          		move $t1,$t6
          		jal div_mult
          		
          		add.d $f14,$f14,$f6
          		
          		addi $t6,$t6,1
          		j loop
      		exit:
      			lw $ra, 8($gp) 
      			jr $ra
         
        div_mult:
        	sw $ra, 8($sp)
        	
		jal power_ln
		mov.d $f6, $f4
		jal power_B
		mov.d $f8, $f4
		jal factorial_int
		mov.d $f10, $f4
		
		div.d $f6,$f6,$f10		
		mul.d $f6,$f6,$f8
		
        	lw $ra, 8($sp)  
		jr $ra
        
        power_ln:
		ldc1 $f2, ln_2
		ldc1 $f4, ln_2	
		li $t0,1
      		loop_0:
          		beq $t0, $t1,exit_0
          		addi $t0,$t0,1
          		mul.d $f4, $f4, $f2
          		j loop_0
      		exit_0:
      			jr $ra
      	
      	power_B:
		ldc1 $f2, B
		ldc1 $f4, B	
		li $t0,1
      		loop_1:
          		beq $t0, $t1,exit_1
          		addi $t0,$t0,1
          		mul.d $f4, $f4, $f2
          		j loop_1
      		exit_1:
      			jr $ra
      	
      	factorial_int:	
		li $t0,1
		li $t3,1
      		loop_2:
          		bgt $t0, $t1,exit_2
          		mult $t3,$t0
          		mflo $t3
          		addi $t0,$t0,1
          		j loop_2
      		exit_2:
      			mtc1.d $t3, $f4
      			cvt.d.w $f4,$f4
      			jr $ra
      			
      			
# mov.d $f12, $f4
# li $v0,3
# syscall
