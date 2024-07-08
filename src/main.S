.syntax unified
.global main

.type main, %function
main:    
bl init_leds
ldr r5, =image
mov r6, #0                 @initialise loop counter
mov r7, #0                 @initialise letter counter
ldr r8, =length
ldr r8, [r8]               @get the word length

preloop:
ldr r10, =random_speed_toggle             
ldr r10, [r10]                  
ldr r11, = random_brightness_toggle       @load in 'toggle' data structures enablers 
ldr r11, [r11]
cmp r10, r11              
beq preloop_speed_and_brightness   @case where both speed and brightness are toggled off
cmp r10, #1
beq preloop_speed             @case where only speed is toggled off
cmp r11, #1
beq preloop_brightness        @case where only brightness is toggled off
b preloop_standard           @if no toggles, default to randomly generated speed & brightness

@no toggles, speed and brightness randomised
preloop_standard:          
bl random_delay     @use this function to get a random number in r3
mov r4, r3        @move r3 to a safe register
bl random_modulation    @use this function to get a random number in r0 for the modulation delays.
mov r9, r0              @move r0 to a safe register
b looper

@if speed is toggled off
preloop_speed:
ldr r10, =random_speed_toggle 
ldr r4, [r10, 4]        @get the manual input speed into r4
bl random_modulation    @the rest is the same
mov r9, r0       
b looper

@if brightness is toggled off
preloop_brightness:
ldr r11, = random_brightness_toggle
bl random_delay    @speed is random 
mov r4, r3          
ldr r9, [r11, 4]  @get manual input brightness in r9
b looper           

@if both speed and brightness are toggled off
preloop_speed_and_brightness:
ldr r10, =random_speed_toggle 
ldr r11, = random_brightness_toggle
ldr r4, [r10, 4]        @get the manual input speed into r4
ldr r9, [r11, 4]  @also get manual input brightness in r9
b looper

looper:
cmp r6, r4           @use the random number (or manual input) in r4 as the loop condition 
beq next_word         @break after the # of loops, go to next_word function
mov r0, 0b00001
bl write_column_pins    
ldr r0, [r5]
bl write_row_pins         @activate 1st column
mov r0, r9                @get random modulation delay number
bl delay                  

bl clearer

mov r0, 0b00010           
bl write_column_pins 
ldr r0, [r5,4]
bl write_row_pins            @activate 2nd column
mov r0, r9                
bl delay                  

bl clearer

mov r0, 0b00100             
bl write_column_pins 
ldr r0, [r5,8]
bl write_row_pins            @activate 3rd column
mov r0, r9                
bl delay 

bl clearer

mov r0, 0b01000          
bl write_column_pins 
ldr r0, [r5, 12]
bl write_row_pins           @activate 4th column
mov r0, r9                
bl delay 

bl clearer

mov r0, 0b10000             
bl write_column_pins  
ldr r0, [r5, 16]            
bl write_row_pins         @activate 5th column
mov r0, r9                
bl delay 

bl clearer

add r6, r6, #1              @increment loop counter

b looper

next_word:
add r7, r7, #1          @increment letter counter
add r5, r5, #20         @move r5 to the next array in 'image'
mov r6, #0              @reset loop counter
cmp r7, r8
beq restart_loop          @end loop if all letters in 'image' reached
b preloop                @else restart loop with next letter memory in r5

restart_loop:
    b main             @restart pattern after all letters reached
.size main, .-main


.data

@data structure to scan from
@each array represents a letter or character
image:
  .word 0b11111, 0b10101, 0b10101, 0b10101, 0b10101
  .word 0b11111, 0b00010, 0b00100, 0b01000, 0b11111 
  .word 0b11111, 0b10000, 0b10000, 0b10000, 0b10000
  .word 0b10001, 0b10001, 0b11111, 0b10001, 0b10001
  .word 0b11111, 0b10001, 0b10101, 0b10101, 0b11101
  .word 0b11111, 0b00100, 0b00100, 0b00100, 0b11111
  .word 0b00001, 0b00001, 0b11111, 0b00001, 0b00001
  .word 0b11111, 0b10101, 0b10101, 0b10101, 0b10101
  .word 0b11111, 0b00010, 0b00100, 0b01000, 0b11111
  .word 0b11101, 0b10101, 0b10101, 0b10101, 0b10111
  .word 0b11111, 0b10001, 0b10001, 0b10001, 0b11111
  .word 0b11101, 0b10101, 0b10101, 0b10101, 0b10111
  .word 0b10101, 0b10101, 0b10101, 0b10101, 0b11111

@number of letters/characters in the pattern
length:
  .word 13

@Toggle the random speed, or manually input a speed 
@If the first word is 1, the function doesn't use random speed. 
@Second part is the manual speed input, only used if first word = 1.
@should be between around 50 - 250 for ideal result
@if first word is 0, the function defaults to using random generator 
@to determine speed between displaying each character. 
random_speed_toggle:
.word 0
.word 200

@Toggle the random brightness, or manually input a brightness 
@If the first word is 1, the function doesn't use random brightness. 
@Second part is the manual brightness input, only used if first word = 1.
@should be between around 200 - 5000 for ideal result
@if first word is 2, the function defaults to using random generator 
@to determine the brightness of each character.
random_brightness_toggle:
.word 2
.word 4000
