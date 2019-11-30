#PROJECT CAAL
.data
login: .asciiz "Please enter your username and password(Maximum 9char)\nusername:"
login2: .asciiz "password:"
user: .asciiz "admin\n"
password: .asciiz "123\n"
succeed: .asciiz "Welcome!"
fail: .asciiz "Mismatch username or password\n"
input1: .space 10
input2: .space 10
.globl main

.text
main:

Displaylogin: 
li $v0, 4
la $a0, login
syscall

jal getInput
la $a0,user             #pass user and input1 for verification
la $a1,input1		
jal Verify

beq $v0,$zero,ok_user    #check result for username  
li $v0,4
la $a0,fail
syscall
j Displaylogin

ok_user: 
la $a0,password #if username match, now we verify the password
la $a1,input2
jal Verify
beq $v0,$zero,match    #check result for password 
li $v0,4		 #this is the same code for checking username,just passing different parameter for password
la $a0,fail
syscall
j Displaylogin

match:
li $v0,4  
la $a0,succeed  
syscall  

##################################bwh ni..korang leh tambah function..lepas dh dpt login...kite display option die..ngn suruh 
########## user pilih option...yg akan bawak die gi tempat lain..boleh buat dlm function...supaye nampak terato##############


#Tell the program is done
li $v0 10
syscall



#Function for getting input from user
getInput:
li $v0, 8
la $a0, input1
li $a1, 10
syscall
li $v0, 4
la $a0, login2
syscall
li $v0, 8
la $a0, input2
li $a1, 10
syscall
jr $ra

#Function to verify username and password
Verify:

add $t1,$zero,$a0  #store username/password at $t1
add $t2,$zero,$a1

loop:  
    lb $t3($t1)         #load a byte from each string  
    lb $t4($t2)  
    beqz $t3,checkt2    #str1 end  
    beqz $t4,missmatch  
    slt $t5,$t3,$t4     #compare two bytes  
    bnez $t5,missmatch  
    addi $t1,$t1,1      #increment t1 and t2 to point to next byte  
    addi $t2,$t2,1  
    j loop  

missmatch:   
    addi $v0,$zero,1  
    j endfunction  
checkt2:  
    bnez $t4,missmatch  
    add $v0,$zero,$zero  

endfunction:  
    jr $ra    
