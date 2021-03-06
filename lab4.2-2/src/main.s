	.syntax unified
	.cpu cortex-m4
	.thumb
.data
//TODO: put your student id here
	student_id: .byte 0, 7, 1, 3, 4, 0, 7
.text
	.global main
	// GPIO
	.equ	RCC_AHB2ENR,	0x4002104C
	.equ	GPIOC_MODER,	0x48000800
	.equ	GPIOC_OTYPER,	0x48000804
	.equ	GPIOC_OSPEEDER,	0x48000808
	.equ	GPIOC_PUPDR,	0x4800080C
	.equ	GPIOC_IDR,		0x48000810
	.equ	GPIOC_ODR,		0x48000814
	.equ	GPIOC_BSRR,		0x48000818  // set bit
	.equ	GPIOC_BRR,		0x48000828  // clear bit

	// Din, CS, CLK offset
	.equ 	DIN,	        0b1 	// PC0
	.equ	CS,		        0b10	// PC1
	.equ	CLK,	        0b100	// PC2

	// MAX7219
	.equ	DECODE,			0x09    // Decode control
	.equ	INTENSITY,		0x0A    // Brightness
	.equ	SCAN_LIMIT,		0x0B    // How many digits to display
	.equ	SHUT_DOWN,		0x0C    //
	.equ	DISPLAY_TEST,	0x0F    //

main:
	BL    gpio_init
	BL    max7219_init

display:

	// set first digit to blank
	MOV   R0, #0b1000
	MOV   R1, #0b00001111
	PUSH  { LR }
	BL    send_message
	POP   { LR }

	MOV   R3, #0

display_loop:
	TEQ   R3, #7
	BEQ   display_end

	LDR   R1, =student_id
	ADD   R1, R3
	LDRB  R1, [R1]

	MOV   R0, #0x07
	SUB   R0, R3
	PUSH  { R3 }
	BL    send_message
	POP   { R3 }

	ADD   R3, #1
	B     display_loop

display_end:
	// Nothing to do

program_end:
	B     program_end

gpio_init:
	// enable GPIOC
	LDR   R1, =RCC_AHB2ENR
	LDR   R0, =0b100
	STR   R0, [R1]

	// set PC0-2 as output
	LDR   R1, =GPIOC_MODER
	LDR   R2, [R1]
	AND   R2, #0xFFFFFFC0 // clear right 6 bits
	ORR   R2, #0b010101
	STR   R2, [R1]

	// set PC0-2 as high speed
	LDR   R1, =GPIOC_OSPEEDER
	LDR   R2, [R1]
	LDR   R8, =0xFFFFFC00
	AND   R2, R8
	LDR   R0, =0b101010
	ORR   R2, R0
	STR   R0, [R1]

	BX LR

max7219_init:
	PUSH  {LR}

    // enable code B decode since character A-F is not used
	LDR   R0, =DECODE
	LDR   R1, =0xFF
	BL    send_message

	// normal operation
	LDR   R0, =DISPLAY_TEST
	LDR   R1, =0x0
	BL    send_message

	// brightest
	LDR   R0, =INTENSITY
	LDR   R1, =0xF
	BL    send_message

	// light up 8 digits
	LDR   R0, =SCAN_LIMIT
	LDR   R1, =0x7
	BL    send_message

	// no shutdown
	LDR   R0, =SHUT_DOWN
	LDR   R1, =0x1
	BL    send_message

	POP   {LR}
	BX    LR

// Given address (R0) and data (R1), send message to MAX7219.
send_message:
	LSL	  R0, #8
	ORR   R0, R1

	LDR   R1, =DIN
	LDR   R2, =CS
	LDR   R3, =CLK
	LDR   R4, =GPIOC_BSRR
	LDR   R5, =GPIOC_BRR
	LDR   R6, =0xF        // the R6-th bit is sent

	STR   R2, [R5]        // clear CS

send_loop:
    STR   R3, [R5] // clear clock
    LDR   R7, =1
    LSL   R7, R6
    ANDS  R7, R0
    ITE NE
    STRNE R1, [R4] // the bit is set
    STREQ R1, [R5] // the bit is not set
    STR   R3, [R4] // set clock

	TEQ   R6, #0
	BEQ   send_done
    sub   R6, #1
	B     send_loop

send_done:
    STR   R2, [R4]  // set CS
    STR   R3, [R5]  // clear clock
	BX LR
