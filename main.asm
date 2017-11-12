.data
.text
	main:
	addi $a0, $0, 1000
	addi $a1, $0, 2000
	addi $a2, $0, 3000
	jal Divide
	j Finish
	mulPositive:
	#Input register: $a0, $a1, $a2
	#Output register: $s0, $s1, $s2
	#Condition to use: MSB $a0, $a2 is 0
	#$v0 is MSR, $v1 is MiSR, $v2 is LSR
	#$a0 is MSR, $a1 is LSR
		#First, store a0, a1, a2 on stack
		addi $sp, $sp, -12
		sw $a0,0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		#Mulplication $a2 with $a1, store lo into $s2, hi into $s1
		multu $a2, $a1
		mflo $s2
		mfhi $s1
		#Mulplication $a2 with $a0, store lo into $t1, hi into $s0
		multu $a2, $a0
		mfhi $s0
		mflo $t1
		#Sum $s1, $t1 will be store into $s0, first check this overflow?
		addu $t0, $s1, $t1
		#check sum $s1, $t1 is overflow?
		slt $t3, $t0, $s1 #if sum less than $s1 or $t1
		bne $t3, $zero, Overflow
		sltu $t3, $t0, $t1
		bne $t3, $zero, Overflow
		addu $s1, $0, $t0
		j Next
		Overflow:
		addu $s1, $0, $t0
		addi $s0, $s0, 1
		j Next	
		
		Next:
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		addi $sp, $sp, 12
		jr $ra
		
	mulNormal:
	#Input register: $a0, $a1, $a2
	#Output register: $s0, $s1, $s2
	#$v0 is MSR, $v1 is MiSR, $v2 is LSR
	#$a0 is MSR, $a1 is LSR
	#First store a0, a1, a2 on stack
		addi $sp, $sp, -16
		sw $a0,0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		sw $ra, 12($sp)
		
		addi $t0, $0, 1
		sll $t0, $t0, 31
		
		#Check sign of two numbers
		and $t1, $t0, $a0
		and $t2, $t0, $a2
		addu $t3, $t1, $t2
		#If t3 is zero, two number the same sign
		beq $t3, $zero, SameSign
		bne $t1, $0, signa0 #If t1=1 change sign $a0$a1 else change sign $a2
		nor $a2, $a2, $a2
		addu $a2, $a2, 1
		j SameSign
		signa0:
			jal ChangeSign64bit
			add $a0, $v0, $0
			add $a1, $v1, $0
		SameSign:
		jal mulPositive
		#Set sign for result follow $t3
		bne $t3, $0, changesign#if t3==1 then changesign result
		j L
		changesign:
			add $a0, $s0, $0
			add $a1, $s1, $0
			add $a2, $s2, $0
			jal ChangeSignResult
		L:
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $ra, 12($sp)
		addi $sp, $sp, 16
		jr $ra
	ChangeSignResult:
		addi $sp, $sp, -28
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		sw $t0, 12($sp)
		sw $t1, 16($sp)
		sw $t2, 20($sp)
		sw $t3, 24($sp)
		#input: $a0, $a1, $a2
		#output: 2-Complement number represent of $a0, $a1, $a2 save to $s0, $s1,$s2
		nor $a2, $a2, $a2 	#Not a2, a1, a0
		nor $a1, $a1, $a1
		nor $a0, $a0, $a0
		
		addu $t0, $a2, 1 	#add a2 with 1 change 2-complement
		sltu $t1, $t0, $a2 	
		bne $t1, $zero, changeA1 #if t1==1, change a1
		addu $a2, $t0, $0  	#else update $a2
		j done		#and jumpto update $a1
		changeA1:
			addu $a2, $t0, $0 #update $a2 
			addu $t2, $a1, 1  #and add 1 to $a1
			sltu $t3, $t2, $a1 #if t3==1, change  a0
			bne $t3, $zero, changeA0
			addu $a1, $t2, $0
			j done
		changeA0:
			addu $a1, $t2, $0  		#update $a1
			addu $a0, $a0, 1		#and add 1 to $a0
		done:
		add $s0, $a0, $0
		add $s1, $a1, $0
		add $s2, $a2, $0
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $t0, 12($sp)
		lw $t1, 16($sp)
		lw $t2, 20($sp)
		lw $t3, 24($sp)
		addi $sp, $sp, 28
		jr $ra
	ChangeSign64bit:
		#Input $a0, $a1
		#Output $v0, $v1
		addi $sp, $sp, -16
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $t0, 8($sp)
		sw $t1, 12($sp)
		nor $a1, $a1, $a1
		nor $a0, $a0, $a0
		addu $t0, $a1, 1
		sltu $t1, $t0, $a1
		bne $t1, $0, changea0
		add $a1, $t0, $0
		j L1
		changea0:
			add $a1, $t0, $0
			addu $a0, $a0, $1
		L1:
		add $v0, $a0, $0
		add $v1, $a1, $0
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $t0, 8($sp)
		lw $t1, 12($sp)
		addi $sp, $sp, 16
		jr $ra
	Divide:
		#Input: $a0, $a1, $a2
		#Output: quotent: $s0, $s1, remainder: $s2
		#Output: ($a1,$a2)/($a2)
		addi $sp, $sp, -12
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		
		divu $s0, $a0, $a2
		remu $a0, $a0, $a2
		addi $t0, $0, 1
		sll $t0, $t0, 31
		divu $t1,$t0, $a2
		sll $t1, $t1, 1
		mulu $t1, $t1, $a0
		
		addu $t1, $t1, $a1
		divu $s1, $t1, $a2
		remu $s2, $t1, $a2
		
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		addi $sp, $sp, 12
		jr $ra
		
	Finish:	
		
		
		
		
		
