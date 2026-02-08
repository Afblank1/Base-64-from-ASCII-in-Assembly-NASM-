;Aidan Bryar 2/6/2026 Base64 Encoder

section .data
	base64_table db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" ; This is the base 64 table used for lookup
	prompt db "Enter the string you want to encode: ", 10 ; Prompts the user for input
	prompt_len equ $ - prompt ; Constant value not stored in memory for easy lookup at runtime
	NL equ 10

section .bss
	input_buffer resb 300
	output_buffer resb 400 ; Output is input bytes * 4/3 for consistency

section .text
	global _start

_start:
	
	mov rax, 1          ;Output System Call
	mov rdi, 1
	mov rsi, prompt
	mov rdx, prompt_len
	syscall
	
	xor rax, rax        ;Get user input with System Call
	xor rdi, rdi     
	mov rsi, input_buffer
	mov rdx, 300
	syscall
	
	dec rax ; Ignore the newline character from Enter 
	mov rdi, output_buffer ; Memory address for the output to be stored
	mov rcx, rax ; Move length of user input into rcx
	mov rsi, input_buffer ; Restore rsi 


.encoding_loop:
	cmp rcx, 3 ; Check if input contains at least 3 bytes left, if not jump to padding
	jl .pad
	xor rax, rax 
	mov ah, [rsi]
	shl rax, 8 ; Makes it so format is in Big Endian lowest memory address is the leftmost: [byte 0, byte 1, byte 2] | Little Endian: [byte2, byte 1, byte 0] "ah" register is the upper byte of the lowest 2 bytes while al is the lowest byte.
	mov ah, [rsi + 1]
	mov al, [rsi + 2]
	
	mov rbx, rax
	and rbx, 0x3F ; High order 6 bit mask: [0011 1111] to extract first 6 bits
	movzx r8, byte [base64_table + rbx] ; Get the nth byte from our base64 table by going to the byte indicated by rbx decimal value
	mov [rdi + 3], r8b ; Move the lowest bit in r8 into the 4th spot in memory present in rdi

	shr rax, 6
	mov rbx, rax
	and rbx, 0x3F
	movzx r8, byte [base64_table + rbx]
	mov [rdi + 2], r8b
	

	shr rax, 6
	mov rbx, rax
	and rbx, 0x3F
	movzx r8, byte [base64_table + rbx]
	mov [rdi + 1], r8b


	shr rax, 6
	mov rbx, rax
	and rbx, 0x3F
	movzx r8, byte [base64_table + rbx]
	mov [rdi], r8b

	add rsi, 3 ; Adds 3 to the pointer that 
	add rdi, 4 ; Adds 4 to the pointer to the output allowing us to fill the next 4 characters. For each 3 bytes (3 chars) we get 4 base64 characters  
	sub rcx, 3 ; Subtracts from input length till it is less than 3 then we pad 
	jmp .encoding_loop


.pad:
	cmp rcx, 0
	je .print ; Prints right away if no padding is needed
  
	xor rax, rax
	cmp rcx, 1
	je .one_byte ; If a 1 bit length is left in the input we need to do different shifts 
	
	mov ah, [rsi]
	mov al, [rsi + 1]
	shl rax, 8


	mov rbx, rax
	shr rbx, 6
	and rbx, 0x3F
	movzx r8, byte [base64_table + rbx]
	mov [rdi + 2], r8b
  
	mov rbx, rax
	shr rbx, 12
	and rbx, 0x3F
	movzx r8, byte [base64_table + rbx]
	mov [rdi + 1], r8b

	mov rbx, rax
	shr rbx, 18
	and rbx, 0x3F
	movzx r8, byte [base64_table + rbx]
	mov [rdi], r8b
	
	mov byte [rdi + 3], "=" ; Add "=" to pad, we only need one since we can get 3 base64 characters from 2 bytes 
  add rdi, 4
	jmp .print

.one_byte:
	
	mov al, [rsi]
	shl rax, 16

	mov rbx, rax
	shr rbx, 12
	and rbx, 0x3F
	movzx r8, byte [base64_table + rbx]
	mov [rdi + 1], r8b

	mov rbx, rax
	shr rbx, 18
	and rbx, 0x3F
	movzx r8, byte [base64_table + rbx]
	mov [rdi], r8b

	mov byte [rdi + 2], '='
  mov byte [rdi + 3], '='
	add rdi, 4

.print:
	
	mov byte [rdi], 10
	inc rdi
	mov rdx, rdi
	sub rdx, output_buffer ; Calculate length for syscall

	mov rax, 1
	mov rdi, 1
	mov rsi, output_buffer
	syscall 

.exit:
	mov rax, 60
	xor rdi, rdi  
	syscall 
	
