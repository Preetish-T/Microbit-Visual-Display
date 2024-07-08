@ Utility functions and symbols
.syntax unified
@ --------------------- Module Interface --------------------

@ Function exports:
.global random_delay, modulo, clearer, random_modulation

@ --------------------- Implementation --------------------

@function to generate a random number between 70 and 266
@uses the inbuilt microbit random number generator
@no input, returns the random number in register 3
.type random_delay, %function
random_delay:
push {lr}
ldr r1, =0x4000D000         @address of random number generator in microbit
mov r2, #1
mov r0, 0x10000
bl delay
str r2, [r1]          @start the random number generator
mov r0, 0x10000
bl delay
str r2, [r1, 4]       @stop the random number generator
mov r0, 0x10000
bl delay 
ldr r3, [r1, 0x508]     @this offset returns the randomly generated number
mov r1, r3
mov r2, #50
bl modulo          @get the product of randomly generated number modulo with 50
mov r2, #4
mul r3, r3, r2          @quadruple the product and add 70
add r3, r3, #70         
pop {lr}     
bx lr                   
.size random_delay, .-random_delay

@function to generate a random number between 50 and 2450
@uses the inbuilt microbit random number generator
@no input, returns the random number in register 0
.type random_modulation, %function
random_modulation:
push {lr}
ldr r1, =0x4000D000         @address of random number generator in microbit
mov r2, #1
mov r0, 0x10000
bl delay
str r2, [r1]          @start the random number generator
mov r0, 0x10000
bl delay
str r2, [r1, 4]       @stop the random number generator
mov r0, 0x10000
bl delay 
ldr r3, [r1, 0x508]     @this offset returns the randomly generated number
mov r1, r3
mov r2, #50
bl modulo          @get the product of randomly generated number modulo with 50
mov r2, #75
mul r0, r2, r3      @multiply mod product with 75, store in r0
pop {lr}     
bx lr 
.size random_modulation, .-random_modulation

@function to get the modulo
@r1 is the divident, r2 is the divisor, r3 is the product
.type modulo, %function
modulo:
  push {lr}
  udiv r0, r1, r2        
  mls r0, r0, r2, r1      
  mov r3, r0            @store mod product in r3  
  pop {lr}     
  bx lr
.size modulo, .-modulo

@function to clear the entire led board
@no inputs, no returns (to registers)
.type clearer, %function
clearer:
  push {lr}
  mov r0, 0b00000
  bl write_column_pins     @clear everything
  mov r0, 0b00000 
  bl write_row_pins 
  mov r0, 0x1500
  bl delay                @delay to let current dissipate
  pop {lr}
  bx lr               @return to caller
.size clearer, .-clearer
