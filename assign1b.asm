/*
Author:	 Cody Clark
Student ID: 30010560
Class: CPSC-355 Computing Machinery
Date Last Edited: Oct 2, 2017

This is the second version of the first assignment.
This program calculates y = -4x^3 - 27x^2 + 5x + 45 for integer values of x, where -6 <= x <= 5
It tests for the maximum y value encountered after each iteration, and then prints the x, y, and max values to the console.
This version of the program uses m4 macros for readability.
It also uses the madd opcode and a pre-test loop conditional at the bottom of the loop for efficiency.

*/
// M4 MACROS                                                                                                                                    
define(x_r, x19)       // Defines the register that will hold the x value                                                                    
define(x_y, x20)       // Defines the register that will hold the y value                                                                    
define(term1_r, x21)   // The first term of our polynomial                                                                                   
define(term2_r, x22)   // The second term of our polynomial                                                                                  
define(term3_r, x23)   // The third term of our polynomial                                                                                   
define(term4_r, x24)   // The last term of our polynomial                                                                                    
define(coeff_r, x25)   // Defines the register that will be used to store our coefficients                                                   
define(curmax_r, x28)  // Defines the register to store the current maximum value    
define(fp, x29)        // Frame pointer register
define(lr, x30)        // Link register
	
fmt:	.string "x value: %d | y value: %d | Current Max: %d\n" // Formats the sring to be printed on each iteration

	.global main // Makes the main part of the program visible to the OS
	.balign 4    // Instructions will be word alligned

main:	stp   fp, lr, [sp, -16]! // Save FP and LR registers to stack, allocate 16 bytes, increment SP
	mov   fp, sp             // Updates fp to current stack pointer

	// INITIALIZATION
	mov  term4_r, 45                        // The last term will always be 45
	mov  x_r, -6                            // Initializes the first x value to -6
	mov  curmax_r, -0xFFFF                  // Initializes the current max value to something low to be overwritten

	b    test                               // Branches to the test outside the loop first for optimization

loop:	mul  term1_r, x_r, x_r                  // Squares x for the first term
	mul  term1_r, term1_r, x_r              // Cubes x for the first term
	
	mul  term2_r, x_r, x_r                  // Squares x for the second term

	mov  coeff_r, 5                         // Prepares the coefficient for the third term
	mul  term3_r, x_r, coeff_r              // Third term is now 5x

	mov  coeff_r, -4                        // Prepares the coefficient for the first term
	madd term1_r, term1_r, coeff_r, term3_r // Now we have -4x^3 + 5x
	mov  coeff_r, -27                       // Prepares the coefficient for the second term
	madd term2_r, term2_r, coeff_r, term4_r // Now we have -27x^2 + 45

	add  x_y, term1_r, term2_r              // Adds all of the terms together to get the y value

	cmp  x_y, curmax_r                      // Compares the y value with the current maximum value
	b.gt rep                                // If y > current maximum, then replace the current maximum with y
	
cont:	adrp x0, fmt           // Sets the first argument of printf's higher order bits 
	add  x0, x0, :lo12:fmt // Sets the first argument of printf's lower order bits 
	mov  x1, x_r           // Sets the current x value to be printed
	mov  x2, x_y           // Sets the current y value to be printed
	mov  x3, curmax_r      // Sets the current max value to be printed
	bl   printf            // Calls the printf() function
	
	add  x_r, x_r, 1 // Increment x by 1

test:	cmp  x_r, 5 // Examines where x > 5
	b.le loop   // Will repeat loop when x <= 5

done:	ldp  fp, lr, [sp], 16 // Restores fp and lr from stack
	ret                   // Returns to caller, exits the program

rep:	mov  curmax_r, x_y // Replace the current max value with the y value
	b    cont          // Continue with program after replacing max
