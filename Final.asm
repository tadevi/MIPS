.data
	arrIn: .word 0:32
	lengthIn: .word 0
	arrOut: .word 0:32
	lengthOut: .word 0
	signResult: .word 0
	sign: .word 0
	str: .asciiz "678"
	msg1: .asciiz "Nhap so nguyen 64 bit(toi da 20 chu so):\n"
	msg2: .asciiz "Nhap so nguyen 32 bit(toi da 10 chu so):\n"
	msg3: .asciiz "-"
.text
	main:
		li $a0, 5
		li $a1, 6
		li $a2, 7 
		li $a3, 10
		jal stringToArray
		jal arrayToRegister
	j Finish
		#Input: $a0, $a1, $a2
		#Output: $s0, $s1, $s2
		#Des: Multiply $a0$a1 with $a2 and store result in $s0$s1$s2
		#Note: Mul non-sign
		mulPositive:
			addi $sp, $sp, -24
			sw $a0, 0($sp)
			sw $a1, 4($sp)
			sw $a2, 8($sp)
			sw $t0, 12($sp)
			sw $t1, 16($sp)
			sw $t3, 20($sp)
			
			multu $a2, $a1
			mflo $s2
			mfhi $s1
			
			multu $a2, $a0
			mfhi $s0
			mflo $t1
			
			addu $t0, $s1, $t1
			sltu $t3, $t0, $s1
			bne $t3, $0, mulPositive_Overflow
			sltu $t3, $t0, $t1
			bne $t3, $0, mulPositive_Overflow
			addu $s1, $0, $t0
			j mulPositive_Next
			mulPositive_Overflow:
			addu $s1, $0, $t0
			addu $s0, $s0, 1
			j mulPositive_Next
			mulPositive_Next:
			lw $a0, 0($sp)
			lw $a1, 4($sp)
			lw $a2, 8($sp)
			lw $t0, 12($sp)
			lw $t1, 16($sp)
			lw $t3, 20($sp)
			addi $sp, $sp, 24
			jr $ra
		jr $ra
		#Input: $a0, $a1, $a2
		#Output: $s0, $s1, $s2
		#Des: Multiply $a0$a1 with $a2 and store result in $s0$s1$s1
		#Note: Mul with signed register
		mulNormal:
			addi $sp, $sp, -40
			sw $a0, 0($sp)
			sw $a1, 4($sp)
			sw $a2, 8($sp)
			sw $ra, 12($sp)
			sw $t0, 16($sp)
			sw $t1, 20($sp)
			sw $t2, 24($sp)
			sw $t3, 28($sp)
			sw $t4, 32($sp)
			sw $t9, 36($sp)
			
			addi $t0, $0, 1
			sll $t0, $t0, 31
			
			and $t1, $t0, $a0
			and $t2, $t0, $a2
			addu $t3, $t1, $t2
			
			beq $t3, $0, mulNormal_SameSigned
			addi $t9, $0, 1
			sw $t9, signResult
			bne $t1, $0, mulNormal_changedA0
			nor $a2, $a2, $a2
			addu $a2, $a2, 1
			j mulNormal_SameSigned
			mulNormal_changedA0:
			jal changeSign64bit
			add $a0, $s0, $0
			add $a1, $s1, $0
			mulNormal_SameSigned:
			sw $0, signResult
			slt $t4, $a2, $0
			bne $t4, $0, mulNormal_TwoNegative
			jal mulPositive
			j mulNormal_done
			mulNormal_TwoNegative:
			jal changeSign64bit
			add $a0, $s0, $0
			add $a1, $s1, $0
			nor $a2, $a2, $a2
			addu $a2, $a2, 1
			jal mulPositive
			mulNormal_done:
			bne $t3, $0, mulNormal_changeResult
			j mulNormal_finish
			mulNormal_changeResult:
				add $a0, $s0, $0
				add $a1, $s1, $0
				add $a2, $s2, $0
				jal changeSignResult
			mulNormal_finish:
			lw $a0, 0($sp)
			lw $a1, 4($sp)
			lw $a2, 8($sp)
			lw $ra, 12($sp)
			lw $t0, 16($sp)
			lw $t1, 20($sp)
			lw $t2, 24($sp)
			lw $t3, 28($sp)
			lw $t4, 32($sp)
			lw $t9, 36($sp)
			addi $sp, $sp, 40
			jr $ra
		#Input: $a0, $a1
		#Output: $s0, $s1
		#Des: change sign $a0$a1
		changeSign64bit:
			addi $sp, $sp, -12
			sw $a0, 0($sp)
			sw $a1, 4($sp)
			sw $t0, 8($sp)
			
			nor $a1, $a1, $a1
			nor $a0, $a0, $a0
			
			addu $s1, $a1, 1
			addu $s0, $a0, $0
			
			sltu $t0, $s1, $a1
			bne $t0, $0, changeSign64bit_change
			j changeSign64bit_done
			changeSign64bit_change:
			addu $s0, $s0, 1
			changeSign64bit_done:
			lw $a0, 0($sp)
			lw $a1, 4($sp)
			lw $t0, 8($sp)
			addi $sp, $sp, 12
			jr $ra
	#Input: $a0, $a1, $a2
	#Output: $s0, $s1, $s2
	#Des: change sign $a0$a1$a2 store $s0$s1$s2
	changeSignResult:
		addi $sp, $sp, -16
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		sw $t0, 12($sp)
		nor $a2, $a2, $a2
		nor $a1, $a1, $a1
		nor $a0, $a0, $a0
		addu $s2, $a2, 1
		add $s1, $a1, $0
		add $s0, $a0, $0
		
		sltu $t0, $s2, $a2
		bne $t0, $0, changeSignResult_changeS1
		j changeSignResult_done
		changeSignResult_changeS1:
		addu $s1, $s1, 1
		sltu $t0, $s1, $a1
		bne $t0, $0, changeSignResult_changeS0
		j changeSignResult_done
		changeSignResult_changeS0:
		addu $s0, $s0, 1
		changeSignResult_done:
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $t0, 12($sp)
		addi $sp, $sp, 16
		jr $ra
	#Input: $a0, $a1, $a2, $a3
	#Output: $a0$a1$a2 div $a3
	#Note: $a3 is 16 bits, remainder is store in $s3, quotient $s0$s1$s2
	divu16bit:
		addi $sp, $sp, -28
		sw $t0, 0($sp)
		sw $t1, 4($sp)
		sw $t2, 8($sp)
		sw $t3, 12($sp)
		sw $t4, 16($sp)
		sw $t5, 20($sp)
		sw $t6, 24($sp)
		
		#  $a0     $a1      $a2
		#$t1$t2 $t3$t4     $t5$t6
		#  $s0     $s1      $s2
		srl $t1, $a0, 16
		sll $t2, $a0, 16
		srl $t2, $t2, 16
		
		srl $t3, $a1, 16
		sll $t4, $a1, 16
		srl $t4, $t4, 16
		
		srl $t5, $a2, 16
		sll $t6, $a2, 16
		srl $t6, $t6, 16
		
		divu $t1, $a3
		mflo $t1
		mfhi $t0
		sll $t0, $t0, 16
		addu $t2, $t2, $t0
		
		divu $t2, $a3
		mflo $t2
		mfhi $t0
		sll $t0, $t0, 16
		addu $t3, $t3, $t0
		
		divu $t3, $a3
		mflo $t3
		mfhi $t0
		sll $t0, $t0, 16
		addu $t4, $t4, $t0
		
		divu $t4, $a3
		mflo $t4
		mfhi $t0
		sll $t0, $t0, 16
		addu $t5, $t5, $t0
		
		divu $t5, $a3
		mflo $t5
		mfhi $t0
		sll $t0, $t0, 16
		addu $t6, $t6, $t0
		
		divu $t6, $a3
		mflo $t6
		mfhi $s3

		or $s0, $0, $t2
		sll $t1, $t1, 16
		or $s0, $s0, $t1
		
		or $s1, $0, $t4
		sll $t3, $t3, 16
		or $s1, $s1, $t3
		
		or $s2, $0, $t6
		sll $t5, $t5, 16
		or $s2, $s2, $t5
			
		lw $t0, 0($sp)
		lw $t1, 4($sp)
		lw $t2, 8($sp)
		lw $t3, 12($sp)
		lw $t4, 16($sp)
		lw $t5, 20($sp)
		lw $t6, 24($sp)
		addi $sp, $sp, 28
		jr $ra
	#Input: $a0$a1$a2
	#Output: Array store coefficient of $a0$a1$a2
	#Note: $a0$a1$a2>0
	toArray:
		addi $sp, $sp, -36
		sw $t0, 0($sp)
		sw $t1, 4($sp)
		sw $t2, 8($sp)
		sw $t3, 12($sp)
		sw $ra, 16($sp)
		sw $a0, 20($sp)
		sw $a1, 24($sp)
		sw $a2, 28($sp)
		sw $a3, 32($sp)
		
		la $t0, arrOut
		addi $t1, $0, 0
		addi $a3, $0, 10
		blt $a0, $0, toArray_change
		j toArray_loop
		toArray_change:
		jal changeSignResult
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		
		toArray_loop:
		jal divu16bit
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		sll $t2, $t1, 2
		addu $t3, $t0, $t2 
		sw $s3, 0($t3)     
		addi $t1, $t1, 1
		bne $a0, $0, toArray_loop
		bne $a1, $0, toArray_loop
		bne $a2, $0, toArray_loop
		sw $t1, lengthOut
		lw $t0, 0($sp)
		lw $t1, 4($sp)
		lw $t2, 8($sp)
		lw $t3, 12($sp)
		lw $ra, 16($sp)
		lw $a0, 20($sp)
		lw $a1, 24($sp)
		lw $a2, 28($sp)
		lw $a3, 32($sp)
		addi $sp, $sp, 36
		jr $ra
	#Input: label arr
	#Output: arr to console	
	printDigit:
		add $sp, $sp, -20
		sw $a0, 0($sp)
		sw $t0, 4($sp)
		sw $t1, 8($sp)
		sw $t2, 12($sp)
		sw $t3, 16($sp)
		la $t0, arrOut
		lw $t1, lengthOut
		addi $t2, $t1, -1
		printDigit_loop:
		blt $t2, $0, printDigit_done
		sll $t3, $t2, 2
		add $t3, $t0, $t3
		lw $t3, 0($t3)
		
		li $v0, 1
		move $a0, $t3
		syscall
		addi $t2, $t2, -1
		j printDigit_loop
		printDigit_done:
		lw $a0, 0($sp)
		lw $t0, 4($sp)
		lw $t1, 8($sp)
		lw $t2, 12($sp)
		lw $t3, 16($sp)
		addi $sp, $sp, 20
		jr $ra
	#input: str label
	#output: arrIn array
	stringToArray:
			addi $sp, $sp, -32
			sw $a0, 0($sp)
			sw $a1, 4($sp)
			sw $t0, 8($sp)
			sw $t1, 12($sp)
			sw $t2, 16($sp)
			sw $t3, 20($sp)
			sw $t4, 24($sp)
			sw $t5, 28($sp)
			la $a0, str
			la $a1, arrIn
			
			addi $t0, $0, 0 #index of str
			addi $t1, $0, 0 #index of arr
			addi $s0, $0, 0 #flag is check input is negative or positive (0 is positive)
			
			
			addu $t2, $a0, $t0
			lb $t3, 0($t2)
			readString_tt:
			beq $t3,'-', readString_setsign
			j readString_con
			readString_setsign:
			addi $s0, $0, 1
			addi $t0, $t0, 1
			readString_con:
			addu $t2, $a0, $t0
			lb $t3, 0($t2)
			beq $t3, '\0', readString_end
			beq $t3, 10 ,readString_end
			sll $t4, $t1, 2
			addu $t4, $a1, $t4
			subi $t5, $t3,'0'
			sw $t5, 0($t4)
			addi $t0, $t0, 1
			addi $t1, $t1, 1
			j readString_tt
			readString_end:
			sw $s0, sign
			sw $t1, lengthIn
			
			lw $a0, 0($sp)
			lw $a1, 4($sp)
			lw $t0, 8($sp)
			lw $t1, 12($sp)
			lw $t2, 16($sp)
			lw $t3, 20($sp)
			lw $t4, 24($sp)
			lw $t5, 28($sp)
			addi $sp, $sp, 32
			jr $ra	
	divuArray:

		addi $sp, $sp, -32
		sw $t0, 0($sp)
		sw $t1, 4($sp)
		sw $t2, 8($sp)
		sw $t3, 12($sp)
		sw $t4, 16($sp)
		sw $t5, 20($sp)
		sw $t6, 24($sp)
		sw $a0, 28($sp)
		
		addi $t0, $0, 0 #index counter
		lw $t1, lengthIn #length of array
		la $a0, arrIn
		addi $s0, $t1, -1
		divuArray_loop:
		beq $t0, $t1, divuArray_done
		beq $t0, $s0, divuArray_outerloop
		sll $t2, $t0, 2
		addu $t2, $t2, $a0
		lw $t3, 0($t2) #arr[i]
		addi $t4, $t0, 1
		sll $t4, $t4, 2
		addu $t4, $t4, $a0
		lw $t5, 0($t4) #arr[i+1]
		andi $t6, $t3, 1 #arr[i]%2
		mulu $t6, $t6, 10 #arr[i]%2*10
		addu $t5, $t5, $t6
		sw $t5, 0($t4) #arr[i+1]+=arr[i]%2*10
		srl $t3, $t3, 1 #arr[i]/=2
		sw $t3, 0($t2)
		addi $t0, $t0, 1
		j divuArray_loop
		divuArray_outerloop:
		sll $t2, $t0, 2
		addu $t2, $t2, $a0
		lw $t3, 0($t2) #arr[i]
		andi $s0, $t3, 1
		srl $t3, $t3, 1
		sw $t3, 0($t2)
		divuArray_done:
		lw $t0, 0($sp)
		lw $t1, 4($sp)
		lw $t2, 8($sp)
		lw $t3, 12($sp)
		lw $t4, 16($sp)
		lw $t5, 20($sp)
		lw $t6, 24($sp)
		lw $a0, 28($sp)
		addi $sp, $sp, 32
		jr $ra
	arrayToRegister:
		#input: arr is label of array store integers
		#	length is label length of array
		#ouput: 64 bit numbers store in $s0(MSR), $s1(LSR)
			addi $sp, $sp, -20
			sw $t0, 0($sp)
			sw $a0, 4($sp)
			sw $a1, 8($sp)
			sw $a2, 12($sp)
			sw $ra, 16($sp)
			addi $t0, $0, 0
			li $a1, 32
			addi $a2, $a1, -1
			arrayToRegister_loop:
			beq $t0, $a1, arrayToRegister_outloop
			jal divuArray
			sll $v0, $v0, 31
			or $s1, $v0, $s1
			beq $t0, $a2, arrayToRegister_outloop
			srl $s1, $s1,1
			addi $t0, $t0, 1
			j arrayToRegister_loop
			arrayToRegister_outloop:
			addi $t0, $0, 0
			arrayToRegister_NextLoop:
			beq $t0, $a1, arrayToRegister_done
			jal divuArray
			sll $v0, $v0, 31
			or $s0, $v0, $s0
			beq $t0, $a2, arrayToRegister_done
			srl $s0, $s0,1
			addi $t0, $t0, 1
			j arrayToRegister_NextLoop
			arrayToRegister_done:
			lw $t0, sign
			bne $t0, 0, arrayToRegister_changesign
			j arrayToRegister_finish
			arrayToRegister_changesign:
			add $a0, $0, $s0
			add $a1, $0, $s1
			jal changeSign64bit
			arrayToRegister_finish:
			lw $t0, 0($sp)
			lw $a0, 4($sp)
			lw $a1, 8($sp)
			lw $a2, 12($sp)
			lw $ra, 16($sp)
			addi $sp, $sp, 20
			jr $ra
	Finish:
