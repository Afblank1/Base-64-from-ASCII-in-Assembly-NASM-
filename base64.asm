;Aidan Bryar 2/6/2026 Base64 Encoder

section .data
	base64_table db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" ; This is the base 64 table used for lookup
	prompt db "Enter the string you want to encode: ", 10 ; Prompts the user for input
	prompt_len equ $ - prompt ; Constant value not stored in memory for easy lookup at runtime
	NL equ 10

section .bss
	input_buffer resb 300
	output_buffer resb 400 ; Output is input bytes * 3/4 for consistency

section .text
	global _start
