/*
Author:	 Cody Clark
Student ID: 30010560
CPSC-355 Assignment 4
*/

//--------------------------//
//      INITIALIZATION      //
//--------------------------//	
	
// Strings which require no variables
fmt1:		.string "Initial pyramid values:\n"
fmt2:		.string "\nChanged pyramid values:\n"

// Strings for the print_p subroutine
print_p1:	.string "Pyramid %s origin = (%d, %d)\n"
print_p2:	.string "\tBase width = %d  Base length = %d\n"
print_p3:	.string "\tHeight = %d\n"
print_p4:	.string "\tVolume = %d\n\n"

// Strings for pyramid names
first:		.string "first"
second:		.string "second"

	// M4 Macros
	define(FALSE, 0)
	define(TRUE, 1)
	define(p_base_r, x19)      // The first pyramid struct's base address register
	define(np_base_r, x9)      // newPyramid temp struct base address register
	define(result_base_r, x10) // equalSize local variable result's base address register

	// Points
	point_x = 0
	point_y = 4

	// Dimensions
	width = 0
	length = 4

	// Pyramid
	height = 0      // One int
	volume = 4      // One int
	origin = 8      // Two ints
	base = 16       // Two ints
	p_size = 24     // 6 ints in total for each pyramid

	alloc = -(16 + p_size * 2) & -16 // Allocates enough room on stack for both pyramids
	dealloc = -alloc                 // Deallocates all RAM memory used
	p1_s = 16                        // Memory address for the first pyramid
	p2_s = (16 + p_size)             // Memory address for the second pyramid
	np_s = 16 + p_size * 2           // Memory address for the local pyramid variable in newPyramid()
	result_s = 16 + p_size * 3       // Memory address for the local result variable in equalSize 

	.balign 4    			 // Program is quadword aligned
	.global main  			 // Main subroutine is visible to the OS

//------------------------//
//      MAIN PROGRAM      //
//------------------------//
	
main:	stp   x29, x30, [sp, alloc]!     // Allocates enough memory to the stack
	mov   x29, sp

	// Initialize first pyramid struct
	add   x8, x29, p1_s              // Passes the address of the first pyramid into an argument
	bl    newPyramid	         // Calls the newPyramid subroutine which returns a pyramid struct
p1set:	
	// Initialize second pyramid struct
	add   x8, x29, p2_s		 // Passes the address of the second pyramid into an argument
	bl    newPyramid		 // Calls the newPyramid subroutine which returns a pyramid struct
p2set:	
	// Prints string "Initial pyramid values: "
	adrp  x0, fmt1
	add   x0, x0, :lo12:fmt1
	bl    printf

	// Prints the values of the first pyramid
	adrp  x0, first            // Passes the string "first" in as an arg
	add   x0, x0, :lo12:first
	add   x1, x29, p1_s        // Address of the first pyramid
	bl    printPyramid
	
	// Prints the values of the second pyramid	
	adrp  x0, second
	add   x0, x0, :lo12:second
	add   x1, x29, p2_s
	bl    printPyramid

	// If the value of the first and second pyramid are the same, change that
	add   x0, x29, p1_s // 1st argument is the address for pyramid 1
	add   x1, x29, p2_s // 2nd argument is the address for pyramid 2
	bl    equalSize     // Ask if they're equal
	cmp   w9, TRUE      // Result of equalSize is stored in w9
	b.ne  cont          // If pyramids are not equal, don't change anything, else call move and scale subroutines

	// Move the first pyramid -5 coordinates in the x direction and 7 coordinates in the y direction
	add   x0, x29, p1_s // 1st arg, address of the first pyramid
	mov   w1, -5        // 2nd arg, the change of the x origin point
	mov   w2, 7         // 3rd arg, the change of the y origin point
	bl    move          // Calls the move subroutine
p1c:	
	// Enlarge the second pyramid by a factor of 3
	add   x0, x29, p2_s // 1st arg, address of the second pyramid
	mov   w1, 3         // 2nd arg, the factor to enlarge the pyramid by
	bl    scale         // Calls the scale subroutine
p2c:	
cont:	// Prints string "Changed pyramid values: "
	adrp  x0, fmt2
	add   x0, x0, :lo12:fmt2
	bl    printf

	// Prints the values of the first pyramid
	adrp  x0, first
	add   x0, x0, :lo12:first
	add   x1, x29, p1_s
	bl    printPyramid

	// Prints the values of the second pyramid
	adrp  x0, second
	add   x0, x0, :lo12:second
	add   x1, x29, p2_s
	bl    printPyramid

end:	ldp   x29, x30, [sp], -(-(16 + p_size * 2) & -16) // Returns the allocated memory from the stack
	ret

//-----------------------//
//	SUBROUTINES      //
//-----------------------//

// Moves the coordinates of a pyramid struct
// Takes a pyramid struct's address, an int to change origin's x value, and an int to change origin's y value as arguments	
move:	stp   x29, x30, [sp, -16]!        // Allocates enough room for the stack frame only
	mov   x29, sp

	ldr   w11, [x0, origin + point_x] // Loads the signed int of origin point x
	add   w11, w11, w1                // Increments it by the second argument
	str   w11, [x0, origin + point_x] // Stores the int

	ldr   w11, [x0, origin + point_y] // Same as above but with origin point y
	add   w11, w11, w2
	str   w11, [x0, origin + point_y]

	ldp   x29, x30, [sp], 16          // Releases the memory used
	ret                               // Return to the calling subroutine (Main in this case)

// Changes the dimensions of a pyramid struct
// Takes a pyramid struct's address and an int factor as arguments
scale:	stp   x29, x30, [sp, -16]! // Allocates enough memory to stack for the stack frame only
	mov   x29, sp

	// Loads the width, multiplies it by the second argument, then stores it
	ldr   w11, [x0, base + width]
	mul   w11, w11, w1
	str   w11, [x0, base + width]

	// Loads the length, multiplies it by the second argument, then stores it
	ldr   w12, [x0, base + length]
	mul   w12, w12, w1
	str   w12, [x0, base + length]

	// Loads the height, multiplies it by the second argument, then stores it
	ldr   w13, [x0, height]
	mul   w13, w13, w1
	str   w13, [x0, height]

	// Calculates new volume of the pyramid, then stores it
	mov   w14, 3
	mul   w11, w11, w12
	mul   w11, w11, w13
	sdiv  w11, w11, w14
	str   w11, [x0, volume]

	ldp   x29, x30, [sp], 16 // Releases the allocated memory
	ret                      // Returns to the calling subroutine, (main in this case)

// Prints out the dimensions and location of a pyramid struct
// Uses x28 as the register to hold the address of the pyramid struct
// Takes a string and a pyramid struct's address as arguments
printPyramid:
	alloc = -(16 + 8) & -16
	dealloc = -alloc
	stp   x29, x30, [sp, alloc]!
	mov   x29, sp

	str   x28, [x29, 16] // Saves the contents of x28
	mov   x28, x1 	     // Tranfers the base address of the pyramid struct to a
                             // register that won't be overwritten by the printf function
	mov   x1, x0         // Moves the string argument into the second argument to be passed to the printf function
	
	// Prints the origin coordinates of a pyramid struct
	adrp  x0, print_p1
	add   x0, x0, :lo12:print_p1
	ldr   w2, [x28, origin + point_x]
	ldr   w3, [x28, origin + point_y]
	bl    printf

	// Prints the base dimensions of a pyramid struct
	adrp  x0, print_p2
	add   x0, x0, :lo12:print_p2
	ldr   w1, [x28, base + width]
	ldr   w2, [x28, base + length]
	bl    printf

	// Prints the height of a pyramid struct
	adrp  x0, print_p3
	add   x0, x0, :lo12:print_p3
	ldr   w1, [x28, height]
	bl    printf

	// Prints the volume of a pyramid struct
	adrp  x0, print_p4
	add   x0, x0, :lo12:print_p4
	ldr   w1, [x28, volume]
	bl    printf

	ldr   x28, [x29, 16]          // Restores the contents of x28
	ldp   x29, x30, [sp], dealloc // Deallocates memory used for the local variable and stack frame
	ret                           // Returns to the calling subroutine, (main) in this case

// Takes 2 pyramid structs as arguments and determines if they have similar dimensions
// Return TRUE or FALSE in w9
equalSize:
	alloc = -(16 + 4) & -16      // Amount of space in RAM for the stack frame and the result local variable
	dealloc = -alloc             // Amount of memory to release
	
	stp   x29, x30, [sp, alloc]! // Allocates the proper amount of space in RAM
	mov   x29, sp

	add   result_base_r, x29, result_s   // Calculates the base address of the result local variable

	str   wzr, [result_base_r, result_s] // Initializes the result to 0 (FALSE)

	// Asks if the width is equal
	ldr   w9, [x0, base + width]
	ldr   w11, [x1, base + width]
	cmp   w9, w11
	b.ne  result                   // If they're not, skip to the result and the result is FALSE

	// Asks if the length is equal
	ldr   w9, [x0, base + length]
	ldr   w11, [x1, base + length]
	cmp   w9, w11
	b.ne  result                   // If they're not, skip to the result and the result is FALSE

	// Asks if the height is equal
	ldr   w9, [x0, height]
	ldr   w11, [x1, height]
	cmp   w9, w11                  // If they're not, skip to the result and the result is FALSE
	b.ne  result

	// If you haven't branched yet, then the pyramids are equal, set the result to TRUE
	mov   w9, TRUE
	str   w9, [result_base_r, result_s] // Stores the TRUE result
	
result:	ldr   w9, [result_base_r, result_s] // Loads the result, whether TRUE or FALSE
	ldp   x29, x30, [sp], dealloc       // Releases allocated memory
	ret                                 // Returns to the calling subroutine, (main) in this case

// This subroutine returns a new instance of a pyramid struct
newPyramid:
	stp   x29, x30, [sp, -(16 + p_size) & -16]! // Allocates enough RAM for a new pyramid struct and stack frame
	mov   x29, sp

	mov   x10, x8                               // Transfers the address of the pyramid struct into a safer register
	
	add   np_base_r, x29, np_s                  // Calculates address in RAM of temp pyramid

	str   wzr, [np_base_r, origin + point_x]    // point_x = 0
	str   wzr, [np_base_r, origin + point_y]    // point_y = 0
	
	mov   w14, 2
	str   w14, [np_base_r, base + width]        // width = 2
	str   w14, [np_base_r, base + length]       // length = 2

	mov   w15, 3
	str   w15, [np_base_r, height]              // height = 2

	mov   w14, 2
	mov   w15, 3
	mul   w14, w14, w14                         // Width(2) * Length(2)
	mul   w14, w14, w15                         // 4 * Height(3)
	sdiv  w15, w14, w15                         // 12 / 3
	
	str   w15, [np_base_r, volume]              // volume = 2 * 2 * 3 / 3 = 4

	// Loads x and y value in temp pyramid's stack location
	// Assigns it to current pyramid in main's x and y location
	ldr   w11, [np_base_r, origin + point_x]
	str   w11, [x10, origin + point_x]
	ldr   w11, [np_base_r, origin + point_y]
	str   w11, [x10, origin + point_y]

	// Same as above but with width and length
	ldr   w11, [np_base_r, base + width]
	str   w11, [x10, base + width]
	ldr   w11, [np_base_r, base + length]
	str   w11, [x10, base + length]

	// Same as above but with height
	ldr   w11, [np_base_r, height]
	str   w11, [x10, height]

	// Same as above but with volume
	ldr   w11, [np_base_r, volume]
	str   w11, [x10, volume]

	ldp   x29, x30, [sp], -(-(16 + p_size) & -16) // Frees used RAM memory
	ret                                           // Returns to the calling subroutine, (main) in this case


	
