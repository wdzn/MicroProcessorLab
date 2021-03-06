	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	arr1: .byte 0x19, 0x34, 0x14, 0x32, 0x52, 0x23, 0x61, 0x29
	arr2: .byte 0x18, 0x17, 0x33, 0x16, 0xFA, 0x20, 0x55, 0xAC
	#arr1: .word 0x19, 0x34, 0x14, 0x32, 0x52, 0x23, 0x61, 0x29
	#arr2: .word 0x18, 0x17, 0x33, 0x16, 0xFA, 0x20, 0x55, 0xAC

.text
.global main

main:
	ldr R0, =arr1
	bl do_sort
	ldr r0, =arr2
	bl do_sort

L: b L

do_sort:
	movs R1, #0
loopa:
	cmp R1, #7
	beq outa

	neg R5, R1
	add R5, R5, #7
	movs R2, #0
loopb:
	cmp R2, R5
	beq outb

	add R6, R2, #1
	ldrb R3, [R0, R2]
	ldrb R4, [R0, R6]
	#mov R7, R2
	#mov R8, R6
	#lsl R7, #2
	#lsl R8, #2
	#ldr R3, [R0, R7]
	#ldr R4, [R0, R8]

	cmp R3, R4
	bge noswap
	#ble noswap
	strb R4, [R0, R2]
	strb R3, [R0, R6]
	#str R4, [R0, R7]
	#str R3, [R0, R8]

noswap:
	add R2, R2, #1
	b loopb
outb:
	add R1, R1, #1
	b loopa
outa:
	bx lr
