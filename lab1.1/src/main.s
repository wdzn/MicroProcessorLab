	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	result: .byte 0

.text
.global main
	.equ X, 0xABCD
	.equ Y, 0xEFAB

main:
	ldr R0, =X
	ldr R1, =Y
	ldr R2, =result
	bl hamm
	str R3, [R2]
L:b L

hamm:
	eor R0, R0, R1
	movs R1, #0
	movs R3, #0
loop:
	cmp R0, #0
	beq out

	movs R1, R0
	and R1, R1, #1
	add R3, R3, R1
	lsr R0, #1
	b loop
out:
	bx lr
