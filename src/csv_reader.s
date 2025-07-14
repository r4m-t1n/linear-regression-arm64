.global _start

.data
filename:    .asciz "data.csv"
buffer:      .skip 1024

.bss
fd:          .skip 8

.text
_start:
	mov x0, -100 	    	// this folder
	adr x1, filename
	mov x2, 0
	mov x3, 0
	mov x8, 56 		        // openat syscall
	svc 0

	adr x1, fd 		        // address of file descriptor from fd to x2
	str x0, [x1] 	    	// file descriptor from x1 to x0

	ldr x0, [x1] 	    	// load register x0 from x1
	adr x1, buffer 		    // address of buffer to x1
	mov x2, 1024
	mov x8, 63		        // read syscall
	svc #0
	mov x3, x0	        	// read bytes

    mov x0, 1               // stdout
    adr x1, buffer
    mov x2, x3              // byte size
    mov x8, 64              // write syscall
    svc 0

    adr x19, buffer         // address of buffer to x19
    mov x20, #0             // current index
    mov x21, x3             // bytes to x3

split_loop:
    cmp x20, x21            // compare current index with bytes
    b.ge close_file         // if current index >= bytes, exit

    ldrb w22, [x19, x20]    // load byte (buffer + index) to w22

    cmp w22, #0x2C          // comma
    b.eq  handle_delimiter

    cmp w22, #0x3B          // semicolon
    b.eq  handle_delimiter

    cmp w22, #0x0A          // new line (\n)
    b.eq  handle_newline

    add x20, x20, #1        // next index
    b split_loop            // back to the beginning of loop

handle_delimiter:
    add x20, x20, #1        // next index
    b split_loop            // back to the beginning of loop

handle_newline:
    add x20, x20, #1        // next index
    b split_loop            // back to the beginning of loop

close_file:
	adr x1, fd		        // get the openat file descriptor
	ldr x0, [x1]	      	// file descriptor to x0
	mov x8, 57	        	// close syscall
	svc 0

exit:
	mov x0, 0
	mov x8, 93      		// exit syscall
	svc 0
