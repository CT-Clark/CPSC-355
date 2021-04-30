/*
Author:	 Cody Clark
Student ID: 30010560
*/

string1:	.string "multiplier = 0x%08x (%d) multiplicand = 0x%08x %d\n\n" // First string to be printed
string2:	.string "product = 0x%08x multiplier = 0x%08x\n"                // Second string to be printed
string3:	.string "64-bit result = 0x%0161x %ld\n"                        // Third string to be printed

	.balign 4    // Ensures instructions are properly aligned
	.global main // Makes the main subroutine visible to the OS

	// M4 MACROS
	define(multiplier, w19)   // Multiplier
	define(multiplicand, w20) // Multiplicand
	define(product, w21)      // Product
	define(i, w22)            // Counter
	define(negative, w23)     // Negative state of multiplier
	define(result, x24)       // End result
	define(temp1, x25)        // Temporary register for typecasting
	define(temp2, x26)        // Temporary register for typecasting
	define(bitshift1, w27)    // Singular bitshifting register
	
main:	stp   x29, x30, [sp, -16]! // Saves state by allocating memory and storing register contents to stack
	mov   x29, sp              // Moves the stack pointer to the frame pointer register

	// INITIALIZATION //
	mov   multiplicand, -16384 // Initialize multiplicand
	mov   multiplier, -64      // Initialize multiplier
	mov   product, 0           // Initialize product
	mov   bitshift1, 1         // Initialize singular bitshift
	mov   negative, 0          // Initialize negative state of multiplier

	// Print out initial values of variables
	adrp  x0, string1           // Formats upper bits
	add   x0, x0, :lo12:string1 // Formats lower bits
	mov   w1, multiplier   // Multiplier in hex
	mov   w2, multiplier   // Multiplier in integer
	mov   w3, multiplicand // Multiplicand in hex
	mov   w4, multiplicand // Multiplicand in integer
	bl    printf           // Calls printf function

	// Determine if multiplier is negative
	cmp   multiplier, 0 // Set flags
	b.lt  negate        // Set the negative variable to true if multiplier < 0
	b     loop1         // Skip the negation if multiplier > 0

negate: mov   negative, 1 // If multiplier is negative, negative is true

loop1:  tst   multiplier, 0x1 // Asks if the multiplier is odd
	b.ne  chpr1           // Branch if it is
	b     cont1           // Ignore if it isn't

chpr1:	add   product, product, multiplicand // Change the product, add the multiplicand to it

cont1:  asr   multiplier, multiplier, bitshift1 // Shift right by 1 bit

	tst   product, 0x1 // Asks if the product is odd
	b.ne  orrr         // If product is odd, OR the multiplier with 0x80000000
	b     annd         // If product is even, AND the multiplier with 0x7FFFFFFF
	
orrr:	orr   multiplier, multiplier, 0x80000000 // If product is odd, apply OR operation
	b     cont2                              // Skip AND operation

annd:	and   multiplier, multiplier, 0x7FFFFFFF // If product is even, apply AND operation

cont2:	asr   product, product, bitshift1 // Bit shift the product right by 1 

	add   i, i, 1 // Increment i
	cmp   i, 32   // Ask if i is still within limits
	b.lt  loop1   // Loop back if i < 32
	
	cmp   negative, 1    // If negative is set to true
	b.eq  chpr2          // Change the product again by subtracting the multiplicand from it
	b     cont3          // Otherwise skip the change

chpr2:	sub   product, product, multiplicand // Changing the product

cont3:  // Print out the current product and multiplier
	adrp  x0, string2           // Formats upper bits
	add   x0, x0, :lo12:string2 // Formats lower bits
	mov   w1, product           // Displays product in hex form
	mov   w2, multiplier        // Displays multiplier in hex form
	bl    printf                // Calls print function

	sxtw  temp1, product           // Convert product to 64 bits
	mov   x27, 32                  // Number of bits to bitshift by  
	lsl   temp1, temp1, x27        // Move product left by 32 bits
	sxtw  temp2, multiplier        // Change the multiplier to 64 bits
	and   temp2, temp2, 0xFFFFFFFF // Bitmask the multiplier with -1
	add   result, temp1, temp2     // Add the bitmasked multiplier and the bitshifted product together

	// Print out the results
	adrp  x0, string3           // Formats upper bits
	add   x0, x0, :lo12:string3 // Formats lower bits
	mov   x1, result            // Displays result in 64-bit form
	mov   x2, result            // Displays results as an integer
	bl    printf

done:	ldp   x29, x30, [sp], 16 // Save state
	ret                      // Returns to caller, ending program
