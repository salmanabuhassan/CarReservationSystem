.data
login: .asciiz "Please enter your username and password\nusername:"
login2: .asciiz "password:"
user: .asciiz "admin\n"
password: .asciiz "123\n"
succeed: .asciiz "Welcome!"
fail: .asciiz "Mismatch!\n"
input1: .space 10
input2: .space 10
CarStatus: .asciiz "11111112222222333333"
Option: .asciiz "Input an option(1-4)\n1.Reserved Car\n2.Collected Car\n3.Returned Car\n4.Logout\n"
Model : .asciiz "WAJA    WIRA    IRIZ    SAGA    MYVI    ALZA    AXIA    ARUS    X3      X5      Z3      I7      VIOS    CHR     RUSH    AE86    JAZZ    HRV     CRV     CRZ     "
input3: .space 3
NoCar_Model: .asciiz "No Model\n"
Update1: .asciiz "Choose no car and the update\nNo:"
Update2: .asciiz "Action(1(Rsv),2(Col),3(Rtn)):"
input4: .space 4
input5: .space 3
error : .asciiz "Not within range!Please enter again."
.globl main

.text
main:

Displaylogin: 
li $v0, 4
la $a0, login
syscall

jal getInput		#get username and password
la $a0,user             #pass user and input1 for verification
la $a1,input1		
jal Verify

beq $v0,$zero,ok_user    #check result for username  
li $v0,4
la $a0,fail
syscall
j Displaylogin

ok_user: 
la $a0,password #if username match, now we verify the password and the input entered by user
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

##################################AFTER LOGIN######################
ChooseOption:
li $v0, 4
la $a0, Option
syscall

#now take user input for viewing/updating
li $v0, 8
la $a0, input3
li $a1, 3
syscall
Checkinput:#If user input out of range of 1-4, insist user to input again
lb $t3,input3
beq $t3,49,InputCorrect
beq $t3,50,InputCorrect
beq $t3,51,InputCorrect
beq $t3,52,Exit
j ChooseOption
#Header for number and model of car of respective user input
InputCorrect:
li $v0,4
la $a0, NoCar_Model
syscall

#Loop for checking the CarStatus that match the user input and display it
li $t0, 0
li $t1, 20
la $t2,CarStatus
iterate:
beq $t0,$t1, endloop
lb $t3($t2)
lb $t4,input3
addi $t2,$t2,1
beq $t3,$t4, Car
addi $t0,$t0,1
j iterate


Car:
la $t5,Model
li $t6,0
LoopSearchCar:
beq $t6,$t0,ithCar
addi $t5,$t5,8
addi $t6,$t6,1
j LoopSearchCar
ithCar:
add $t7,$t5,$zero
#print the car number
li $v0,1
move $a0,$t0
addi $a0,$a0,1
syscall
#add two space for readability
jal PrintSpace
jal PrintSpace

#display the car
printCar:
lb $t8,($t7)
li $v0, 11
la $a0, ($t8)
addi $t7,$t7,1
syscall
lb $t9,($t7)
beq $t9,32,newline #if the model has been printout, and it meet the 'space' in ASCII which is 32 in decimal, go to newline
j printCar
#go to newline
newline:
addi $t0,$t0,1
li $v0, 11
li $a0, 10
syscall 
j iterate  ###fetching the next iteration
############After user input of what to view, this is where user must specify the update##############################
endloop: 
li $v0,4
la $a0, Update1
syscall
#take user input of no car
li $v0,8
la $a0,input4
li $a1,4
syscall

la $s0,input4
lb $t9, 0x00($s0)
lb $t8, 0x01($s0)
beq $t8,10,num1
beq $t9,10,UpdateCar
beq $t9,49,add10
beq $t9,50,add20

add10:
addi $t8,$t8,10
j UpdateCar

add20:
addi $t8,$t8,20
j UpdateCar
num1:
move $t8,$t9
UpdateCar:
la $s1,CarStatus
addi $t0,$zero,49
slti $t1,$t8, 69
beqz $t1,OutofRange

#Specify action display
li $v0,4
la $a0, Update2
syscall

#for update specific action
li $v0, 8
la $a0, input5 
li $a1, 3
syscall

iterate1:
beq $t0,$t8, updateStatus
addi $t0,$t0,1
add $s1,$s1,1
j iterate1


updateStatus:
lb $t7,input5
sb $t7,0($s1)
j ChooseOption 



#Tell the program is done
Exit:
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
    sub $t5,$t3,$t4     #compare two bytes  
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
    
PrintSpace:
li $v0, 11
li $a0, 32  
syscall
jr $ra

#should the input number not in the system
OutofRange:
li $v0,4
la $a0, error
syscall
j endloop
