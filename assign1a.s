/*
Author:	 Cody Clark
Student ID: 30010560
Date Last Edited: Oct 2, 2017
Class: CPSC-355

This is the first, unoptimized version of assignment 1.
This program will calculate y = -4x^3 - 27x^2 + 5x + 45 for integer values of x, where -6 <= x <= 5
This version does NOT use m4 macros, nor does it use the madd or msub instructions.
Although less efficient this program places the pre-test loop contitional at the top of the loop.
*/
	
fmt:	.string "x value: %d | y value: %d | Current Max: %d\n" // Formats the string to be printed



	.global main // Makes the main method visible to the OS
	.balign 4    // Ensures instructions are properly aligned
	
main:   stp   x29, x30, [sp, -16]! // Save FP and LR registers to stack, allocate 16 bytes, increment SP
	mov   x29, sp              // Updates FP to to current stack pointer

	mov   x19, -6       // Sets the lowest/current x value
	mov   x28, -0xFFFF  // Sets the lowest value for the registry that will store the current MAX value
	
loop:	cmp   x19, 5        //compares if x is still in range
	b.gt  done          // If x is not in range, skip to the end

	mul   x21, x19, x19 // Squares x
	mul   x21, x21, x19 // Cubes x
	mov   x20, -4       // Sets the first coefficient to -4
	mul   x21, x20, x21 // Gets first term in polynomial (-4x^3)

	mul   x22, x19, x19 // Squares x
	mov   x20, 27       // Sets the second coefficient to 27
	mul   x22, x22, x20 // Gets second term in polynomial (27x^2)

	mov   x20, 5        // Sets the third coefficient to 5
	mul   x23, x19, x20 // Gets third term in polynomial (5x)

	sub   x21, x21, x22 // Subtracts 27x^2 from x21
	add   x21, x21, x23 // Adds 5x to x21
	add   x21, x21, 45  // Adds 45 to x21

	cmp   x21, x28      // Compares current y value with current max value
	b.gt  rep           // If y is larger than current max value, replae max value

cont:	adrp  x0, fmt           // Sets the variable for the higher order bits of the string
	add   x0, x0, :lo12:fmt // Sets the variable for the lower order bits of the string
	mov   x1, x19           // Adds the current X value to the string
	mov   x2, x21           // Adds the current Y value to the string
	mov   x3, x28           // Adds the current MAX value to the string
	bl    printf            // Function call to print the string
	
	
	add   x19, x19, 1   // Increments x by 1
	b     loop          // Loops back for an increase value of x

rep:	mov   x28, x21      // Replaces the current MAX value with the current Y value
	b     cont          // Returns to the main body of the program
	
done:	ldp   x29, x30, [sp], 16 // Restores the state
	ret                      // Returns to caller, exiting the program 

