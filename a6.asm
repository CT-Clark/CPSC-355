/*
Author:	 Cody Clark
UCID:	 30010560
Course:	 CPSC-355 - Assignment 6
*/

/*
This program computes the cube root of positive real numbers using Newton's method.
*/

	define(argc_r, w20)		// Argument counter
	define(argv_r, x21)		// Address of the array of pointers to the arguments passed into command line
	define(fd_r, w19)		// File descriptor (-100 for current working directory here)
	define(buf_r, x22)		// Buffer base register
	define(input_r, d8)		// Register to store the input into calculations
	define(x_r, d9)			// X register in calculations
	define(y_r, d10)		// Y register in calculations
	define(dy_r, d12)		// dy register in calculations
	define(dxdy_r, d13)		// dx/dy register in calculations
	define(err_r, d14)		// Register to store the error limit in calculations
	define(absdy_r, d15)		// Register to store the absolute value of y to in calculations
	
	.text
input_file:		.string "INPUT FILE: %s\n"		     // Prints out the name of the input file
init_string:		.string "| INPUT VALUE  ||  CUBE ROOT   |\n|--------------||--------------|\n" // Header for the columns
result_string:		.string "| %.10lf || %.10lf |\n"	     // String to print out the input value and its cube root
open_error:		.string "There was an error opening file: %s\nExiting Program\n" // Opening error
close_error:		.string "There was an error closing the previously opened file. \nExiting Program\n" // Closing error
open_successful:	.string "File opened successfully.\n"        // Prints if the file was opened successfully
close_successful:	.string "File closed successfully.\n"	     // Prints if the file was closed successfully
negative_detected:	.string "A negative input number was detected. \nExiting Program\n"
	
three_m:		.double 0r3.0     // double floating point number used in initial guess and derivatives
err_m:			.double 0r1.0e-10 // abs(dy) must be less than this value to return an accurate calculation

	// Local variable offsets
	input_s = 16
	x_s = 24
	y_s = 32
	dy_s = 40
	dxdy_s = 48
	err_s = 56
	absdy_s = 64
	
	buf_size = 8			// Number of bytes in the buffer
	alloc = -(16 + buf_size) & -16  // Number of bytes to make room for in main
	dealloc = -alloc		
	buf_s = 16			// Offset of the buffer on the stack
	
	.balign 4
	.global main
main:	stp   x29, x30, [sp, alloc]!
	mov   x29, sp

	mov   argv_r, x1		// Copy argv (The array contains this file's name and the name of the input file)

	// Prints the name of the file to open
	mov   w23, 1			// The name of the file is located at argv[1] = argv[w23]
	adrp  x0, input_file
	add   x0, x0, :lo12:input_file
	ldr   x1, [argv_r, w23, SXTW 3] // Loads the name of the input file
	bl    printf

	// Opens the file supplied by the command line argument
	mov   w0, -100			// Use the current working directory for the file descriptor			
	ldr   x1, [argv_r, w23, SXTW 3] // The name of the file to open
	mov   w2, 0			// The file will be read only
	mov   w3, 0			// Not used
	mov   x8, 56			// openat I/O request
	svc   0				// Generates an exception
	mov   fd_r, w0			// Moves the unique integer of the ID into a register to be used later
	cmp   fd_r, 0			// Any errors would be returned as an int < 0
	b.ge  open_ok

	// If file wasn't opened successfully, print error message and exit the program
	adrp  x0, open_error
	add   x0, x0, :lo12:open_error
	ldr   x1, [argv_r, w23, SXTW 3]	// Loads the name of the input file
	bl    printf
	mov   w0, -1
	b     end

open_ok: nop
	// Prints that the file opened successfully
	adrp  x0, open_successful
	add   x0, x0, :lo12:open_successful
	bl    printf

	// Prints the column headers
	adrp  x0, init_string
	add   x0, x0, :lo12:init_string
	bl    printf

	add   buf_r, x29, buf_s		// Calculates the address of the buffer

loop:	mov   w0, fd_r			// Moves the file ID into the first argument
	mov   x1, buf_r			// Second argument is the buffer base register
	mov   w2, buf_size		// Third argument is how many bytes to read from the buffer each time
	mov   x8, 63			// Read I/O request 
	svc   0				// Cause a system exception

	mov   w25, w0			// Store the number of bytes actually read into a register
	cmp   w25, buf_size		// If the number of bytes actually read is less than the buffer size, it's the EOF
	b.ne  close

	ldr   d0, [buf_r]		// Loads the value read from file and passes it to the calculations subroutine
	fcmp  d0, 0.0			// Terminates the program if a negative number is detected
	b.lt  neg_det
	bl    calculations		// Calculates the cube root and returns it in d0
	fmov  d1, d0			// The result should be moved from d0 to d1 to set up the print call

	adrp  x0, result_string
	add   x0, x0, :lo12:result_string
	ldr   d0, [buf_r]		// First argument to print is the original value
					// The second argument is the cube root and is already in d1
	bl    printf

	b     loop			// If it's not the end of the file, repeat

	// Will print out an error message and terminate the program if a negative input is detected
	// This program only deals with positive real numbers
neg_det: nop
	adrp  x0, negative_detected
	add   x0, x0, :lo12:negative_detected
	bl    printf

	// Closes the file
close:	mov   w0, fd_r			// Passes the file ID as the first argument
	mov   x8, 57			// Close I/O request
	svc   0				// Cause a system exception
	cmp   w0, 0			// If an error occured w0 < 0, display error message and terminate the program
	b.ge  close_ok

	// If the file wasn't saved successfully, print out an error and exit the program
	adrp  x0, close_error
	add   x0, x0, :lo12:close_error
	bl    printf
	mov   w0, -1
	b     end

close_ok: nop
	// Prints out that the file was closed successfully
	adrp  x0, close_successful
	add   x0, x0, :lo12:close_successful
	bl    printf
	mov   w0, 0

	// Exit the program
end:	ldp   x29, x30, [sp], dealloc
	ret

	.balign 4
calculations:
	stp   x29, x30, [sp, -(16 + 64) & -16]!
	mov   x29, sp

	// Stores the states of the callee-saved registers used in this subroutine
	str   input_r, [x29, input_s]
	str   x_r, [x29, x_s]
	str   y_r, [x29, y_s]
	str   dy_r, [x29, dy_s]
	str   dxdy_r, [x29, dxdy_s]
	str   err_r, [x29, err_s]
	str   absdy_r, [x29, absdy_s]

	fmov  input_r, d0 // Move the argument passed into the subroutine in a register so it won't be overwritten

	// Loads the value 3.0
	adrp  x0, three_m
	add   x0, x0, :lo12:three_m
	ldr   d1, [x0]

	fdiv  x_r, input_r, d1 // Sets up the initial guess. x = input / 3

	// Loads the value 1.0e-10 used to calculate the error limit
	adrp  x0, err_m
	add   x0, x0, :lo12:err_m
	ldr   err_r, [x0]
	fmul  err_r, err_r, input_r	// The limit for the error
	
	// Calculate the cube root
c_loop:	fmul  y_r, x_r, x_r		// y = x * x
	fmul  y_r, y_r, x_r		// y = x * x * x

	fsub  dy_r, y_r, input_r	// dy = y - input
	fmov  absdy_r, dy_r
	fabs  absdy_r, absdy_r		// |dy|, used for error limit checking

	fmul  dxdy_r, d1, x_r		// dx/dy = 3.0 * x
	fmul  dxdy_r, dxdy_r, x_r	// dx/dy = 3.0 * x * x

	fdiv  dy_r, dy_r, dxdy_r
	fsub  x_r, x_r, dy_r		// x = x - dy / (dy/dx)

	fcmp  absdy_r, err_r		// Check to see if |dy| < input * 1.0e-10
	b.lt  c_done			// If it isn't, repeat the calculations
	b     c_loop

c_done:	fmov  d0, x_r 			// Moves the result into a 0 register to return to calling code

	// Restore the states of the callee-saved registers
	ldr   input_r, [x29, input_s]
	ldr   x_r, [x29, x_s]
	ldr   y_r, [x29, y_s]
	ldr   dy_r, [x29, dy_s]
	ldr   dxdy_r, [x29, dxdy_s]
	ldr   err_r, [x29, err_s]
	ldr   absdy_r, [x29, absdy_s]

	// Return to calling code
	ldp   x29, x30, [sp], -(-(16 + 64) & -16)
	ret
