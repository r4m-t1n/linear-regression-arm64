.global _start

.data
filename: .asciz "test.txt"
buffer:   .skip 1024

.bss
fd:       .skip 8

.text
_start:
	mov x0, -100 		// this folder
	adr x1, filename
	mov x2, 0
	mov x3, 0
	mov x8, 56 		// openat syscall
	svc 0

	adr x1, fd 		// address of file descriptor from fd to x2
	str x0, [x1] 		// file descriptor from x1 to x0

	ldr x0, [x1] 		// load register x0 from x1
	adr x1, buffer 		// address of buffer to x1
	mov x2, 1024
	mov x8, 63		// read syscall
	svc #0
	mov x3, x0		// read bytes

	mov x0, 1		// stdout
	adr x1, buffer
	mov x2, x3		// byte size
	mov x8, 64		// write syscall
	svc 0


	adr x1, fd		// get the openat file descriptor
	ldr x0, [x1]		// file descriptor to x0
	mov x8, 57		// close syscall
	svc 0

	mov x0, 0
	mov x8, 93		// exit syscall
	svc 0
