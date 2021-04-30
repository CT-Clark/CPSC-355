/*
Author: Cody Clark
Student ID: 30010560
CPSC 355, Assignment 3
*/

	/*
	This is a program written in assembly to impliment the insertion sort algorithm
	as described in the C code example. This also features a mixed congruential algorithm
	implimented to give a string of random numbers based on a seed.
	*/

fmt1:	.string "\nSorted array:\n"
fmt2:	.string "v[%d]: %d\n"

	.balign 4
	.global main

	// M4 MACROS
	define(SIZE, 50)
	define(v_base_r, x19)
	define(indexi_r, w20)
	define(indexj_r, w21)
	define(ran_r, w22)
	define(temp_r, w23)
	define(mul_r, w24)
	define(fp, x29)
	define(lr, x30)

	// Stack Variable sizes and locations
	i_size = 4       // Index i is a 4 byte int
	i_s = 16         // Memory location of i
	j_size = 4       // Index j is a 4 byte int
	j_s = 20         // Memory location of j
	r_size = 4       // Random number is a 4 byte int
	r_s = 24         // Memory location of the random number
	t_size = 4       // temp is a 4 byte int
	t_s = 28         // Memory location of temp
	iv_size = 50 * 4 // 50 int array
	iv_s = 36        // Memory location of the array
	alloc = -(16 + i_size + j_size + iv_size + r_size + t_size) & -16 // Allocates the necessary number of bytes to RAM
	dealloc = -alloc // Deallocates all of the memory used when exiting the program

main:	stp   fp, lr, [sp, alloc]! // Allocates enough bytes to the stack to hold all of the stack variables
	mov   fp, sp               // Points to the frame pointer to the stack pointer register

	// Initialize index i to 0, seeds the random function
init1:	mov   indexi_r, 0         // Sets index i to 0
	str   indexi_r, [fp, i_s] // Stores 0 in index i location in stack
	mov   ran_r, 69           // Sets the seed for the random number generator
	str   ran_r, [fp, r_s]    // Stores 22 in ran_r location in stack
	mov   mul_r, 169          // Multiplier of random number generator is 169
	add   v_base_r, fp, iv_s  // Calculates the base address for the v array

	// Creates an array of 50 random elements
array:	ldr   indexi_r, [fp, i_s]  // Load the value of index i

	// Uses a mixed congruential generator algorithm to generate random numbers
	ldr   ran_r, [fp, r_s]     // Loads the last random number
	mul   ran_r, ran_r, mul_r  // Calculate the new random number
	add   ran_r, ran_r, 11     // Sets the increment of the random number generator
	and   ran_r, ran_r, 0xFF   // Converts the random number into a 4 byte int by bitmasking

	// Print new random variable and index
	adrp  x0, fmt2
	add   x0, x0, :lo12:fmt2
	mov   w1, indexi_r
	mov   w2, ran_r
	bl    printf

	// Store all of the necessary info back into the stack
	str   ran_r, [fp, r_s]	                  // Stores the new random number for next time
	str   ran_r, [v_base_r, indexi_r, SXTW 2] // Stores the random number in the v[i] stack variable

	add   indexi_r, indexi_r, 1               // Increments i by 1
	str   indexi_r, [fp, i_s]                 // Stores the new i
	cmp   indexi_r, SIZE
	b.ge  init2                               // If i >= 50, stop adding elements into the v array and sort them

	b array // Repeat the random variable creation progress if i < 50

	// Initialize index i to 1
init2:	mov   indexi_r, 1
	str   indexi_r, [fp, i_s]
	
	// Sorts the array of random numbers using an insertion sort algorithm
sort_a: ldr   indexi_r, [fp, i_s]                   // Loads the current index i
	str   indexi_r, [fp, j_s]                   // Stores index i into index j's place in the stack
	ldr   temp_r, [v_base_r, indexi_r, SXTW 2]  // Loads v[i] and assigns it to a temp variable
	str   temp_r, [fp, t_s]

sort_b:	ldr   indexj_r, [fp, j_s]               // Loads the index of j
	sub   w26, indexj_r, 1
	ldr   w27, [v_base_r, w26, SXTW 2]      // Loads v[j-1]
	ldr   temp_r, [fp, t_s]
	cmp   temp_r, w27                       // Compares v[i] with v[j-1]
	b.gt  cont                              // If v[i] > v[j-1], skip to cont
	str   w27, [v_base_r, indexj_r, SXTW 2] // Otherwise v[j] is replaced by v[j-1]
	
	sub   indexj_r, indexj_r, 1                 // j--
	cmp   indexj_r, 0                         
	str   indexj_r, [fp, j_s]
	b.gt  sort_b                                // If j <= 0, loop again
	

cont:	str   temp_r, [v_base_r, indexj_r, SXTW 2]  // v[j] is replaced by v[i]
	str   indexj_r, [fp, j_s]

	ldr   indexi_r, [fp, i_s]   // Loads index i
	add   indexi_r, indexi_r, 1 // i++
	cmp   indexi_r, SIZE        
	str   indexi_r, [fp, i_s]
	b.lt  sort_a                // If i < 50, loop again

	// Resets index i
init3:	mov   indexi_r, 0
	str   indexi_r, [fp, i_s]

	// Prints out "Sorted array: "
	adrp  x0, fmt1
	add   x0, x0, :lo12:fmt1
	bl    printf
	
	// Loads the current element in the v array at v[i] and then prints it
result:	ldr   indexi_r, [fp, i_s]                    // Loads index i
	ldr   temp_r, [v_base_r, indexi_r, SXTW 2] // Loads element at v[i]

	// Prints the loaded element
	adrp  x0, fmt2
	add   x0, x0, :lo12:fmt2
	mov   w1, indexi_r
	mov   w2, temp_r
	bl    printf

	// Increments the index to the next sorted element
	add   indexi_r, indexi_r, 1
	cmp   indexi_r, SIZE
	str   indexi_r, [fp, i_s]
	b.lt  result                // If index i < 50 then this repeats the loop

	// Ends the program
	ldp   fp, lr, [sp], dealloc
	ret
