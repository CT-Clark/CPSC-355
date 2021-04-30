	/*
	 * Author: Cody Clark
	 * Student ID: 30010560
	 * CPSC 355, Assignment 5a
	*/

	// GLOBAL VARIABLES
	.data
	.global head // head is a global variable
	.global tail // tail is a global variable
head:	.word   -1   // head is currently -1 because the queue is empty
tail:	.word   -1   // tail is currently -1 because the queue is empty

	.bss          // Initialize the values of the queue to 0
	.global queue // queue is a global variable
queue:	.skip   8 * 4 // Initializes an integer array of 8 elements
	
	.text
qOverflow:	.string "\nQueue overflow! Cannot enqueue into a full queue.\n"
qUnderflow:	.string "\nQueue underflow! Cannot dequeue from an empty queue.\n"
eQueue:		.string "\nEmpty queue\n"
cQueue:		.string "\nCurrent queue contents:\n"
qElement:	.string "  %d"
hQueue:		.string " <-- head of queue"
tQueue:		.string " <-- tail of queue"
newLine:	.string "\n"
	
	// CONSTANTS //
	define(QUEUESIZE, 8)
	define(MODMASK, 0x7)
	define(FALSE, 0)
	define(TRUE, 1)

	// SUBROUTINES //

	// Checks to see if the queue is empty. If it is, returns 1 (TRUE) otherwise returns 0 (FALSE)
	.balign 4
	.global queueEmpty
queueEmpty:
	stp   x29, x30, [sp, -16]!
	mov   x29, sp
	
	adrp  x0, head           // Calculate the address of the head
	add   x0, x0, :lo12:head
	ldr   w1, [x0]           // Load the value stored in head
	cmp   w1, -1             // Compares it with -1 (-1 means the queue is empty)
	b.eq  qETrue             // If it is empty, return 1 (TRUE)
	mov   w0, FALSE          // Otherwise return 0 (FALSE)

	ldp   x29, x30, [sp], 16
	ret

qETrue:	mov   w0, TRUE
	ldp   x29, x30, [sp], 16
	ret

	// Checks to see if the queue is full. If it is, returns a 1 (TRUE), otherwise returns a 0 (FALSE)
	.balign 4
	.global queueFull
queueFull:
	stp   x29, x30, [sp, -16]!
	mov   x29, sp
	
	adrp  x0, tail           // Calculates address of the tail
	add   x0, x0, :lo12:tail
	ldr   w1, [x0]           // Loads the tail value into x1
	add   w1, w1, 1          // Increments tail value
	and   w1, w1, MODMASK    // tail = ++tail & MODMASK
	adrp  x2, head           // Calculates address of the head
	add   x2, x2, :lo12:head
	ldr   w3, [x2]           // Loads the value stored in the head to x3

	cmp   w1, w3             // Compares the new value of the tail with the head
	b.eq  qFTrue             // If they're equal, return 1 (TRUE)
	mov   w0, FALSE          // Otherwise, return 0 (FALSE)
	ldp   x29, x30, [sp], 16
	ret

qFTrue:	mov   w0, TRUE
	ldp   x29, x30, [sp], 16
	ret

	// Removes and returns the head value from the queue, that is queue[0]
	.balign 4
	.global dequeue
dequeue:
	stp   x29, x30, [sp, -16]!
	mov   x29, sp
	
	bl    queueEmpty           // Check to see if the queue is empty
	cmp   w0, 1                // If it is...
	b.eq  qUnderflowMessage    // Print an error saying you can't dequeue an empty queue

	adrp  x0, head             // Calculate address of the head variable
	add   x0, x0, :lo12:head
	ldr   w3, [x0]             // Loads the value stored in the head
	adrp  x1, queue            // Calculate the address of the queue variable
	add   x1, x1, :lo12:queue
	ldr   w7, [x1, w3, SXTW 2] // temp var value = queue[head]
	adrp  x2, tail             // Calculate the address of the tail variable
	add   x2, x2, :lo12:tail
	ldr   w4, [x2]             // Load the value stored in tail
	cmp   w3, w4               // See if they're equal
	b.eq  dQTrue               // If they are, branch
	add   w3, w3, 1            // head += 1
	and   w3, w3, MODMASK      // head = ++head & MODMASK
	str   w3, [x0]             // Store the new head value
	b     contdq

	// If the queue only has one element, do this
dQTrue:	mov   w3, -1
	str   w3, [x0]             // head = -1
	str   w3, [x2]             // tail = -1

	// After operations have finished, return the temp var value and return to calling code
contdq:	mov   w0, w7               // Return value
	ldp   x29, x30, [sp], 16
	ret			   // Return to calling function

	// Error message if a user tries to dequeue an empty list
	// Returns a -1 if Underflow is detected
qUnderflowMessage:
	adrp  x0, qUnderflow
	add   x0, x0, :lo12:qUnderflow
	bl    printf
	mov   w0, -1 // Returns -1 to the main routine so that it can choose not to print a value
	ldp   x29, x30, [sp], 16
	ret

	// Adds an element to the tail of a queue array at location queue[tail]
	.balign 4
	.global enqueue
enqueue:
	stp   x29, x30, [sp, -(16 + 8) & -16]!
	mov   x29, sp

	str   x19, [x29, 16]       // Saves x19's state
	
	mov   w19, w0              // Protect the passed argument from being overwritten
	
	bl    queueFull            // See if the queue is full
	cmp   w0, 1   
	b.eq  qFullError           // If it is, print an error

	bl    queueEmpty           // See if the queue is empty
	cmp   w0, 1
	b.ne  eQFalse              // If it's not, use the MODMASK
	
	// Otherwise, head = tail = 0
	adrp  x0, head             // Calculate the address of the head
	add   x0, x0, :lo12:head 
	mov   w7, 0                // temp variable = 0
	str   w7, [x0]             // Store 0 in the head variable
	adrp  x1, tail             // Calculate the address of the tail
	add   x1, x1, :lo12:tail 
	str   w7, [x1]             // Store 0 in the tail variable
	b     contq

	// The queue is not empty
eQFalse:
	adrp  x1, tail             // Calculate the address of the tail
	add   x1, x1, :lo12:tail
	ldr   w2, [x1]             // Load the value stored in the tail
	add   w2, w2, 1            // Increment it by 1
	and   w2, w2, MODMASK      // Apply a bitmask of 0x7 to it
	str   w2, [x1]             // Store that value back as the new tail value
	
contq:	adrp  x0, queue            // Calculate the address of the queue array
	add   x0, x0, :lo12:queue
	ldr   w2, [x1]              // Load the value stored in tail
	str   w19, [x0, w2, SXTW 2] // Store the value passed to this subroutine at queue[tail]

	ldr   x19, [x29, 16]        // Restore x19 state

	ldp   x29, x30, [sp], -(-(16 + 8) & -16)
	ret

	// Prints out an error if the queue is full and returns to the calling program
qFullError:
	adrp  x0, qOverflow
	add   x0, x0, :lo12:qOverflow
	bl    printf

	ldr   x19, [x29, 16]       // Restore x19 state
	ldp   x29, x30, [sp], -(-(16 + 8) & -16)
	ret

	// Displays the elements of the queue
	.balign 4
	.global display
display:
	stp   x29, x30, [sp, -(16 + 48) & -16]!
	mov   x29, sp

	// Saving the states of registers
	str   x19, [x29, 16]
	str   x20, [x29, 24]
	str   x21, [x29, 32]
	str   x22, [x29, 40]
	str   x23, [x29, 48]
	str   x24, [x29, 56]
	
	bl    queueEmpty	  // See if the queue is empty
	cmp   w0, 1		  // If it is, print that fact and return to calling code
	b.eq  dEQ

	adrp  x0, tail		  // Calculates the address of the tail variable
	add   x0, x0, :lo12:tail 
	adrp  x1, head            // Calculates the address of the head variable
	add   x1, x1, :lo12:head
	ldr   w19, [x0]           // tail
	ldr   w20, [x1]           // head
	mov   w21, w19		  // count = tail
	sub   w21, w21, w20       // count = tail - head
	add   w21, w21, 1         // count = tail - head + 1

	cmp   w21, 0		  // See if count > 0
	b.gt  dCont1		  // If it is, don't add the QUEUESIZE to it
	add   w21, w21, QUEUESIZE
	
dCont1:	adrp  x0, cQueue	  // Prints out "Current queue contents:"
	add   x0, x0, :lo12:cQueue
	bl    printf

	mov   w22, w20 		  // i = head
	mov   w23, 0   		  // j = 0

	b     test

dloop:	adrp  x0, queue		     // Calculates the address of the queue
	add   x0, x0, :lo12:queue
	ldr   w24, [x0, w22, SXTW 2] // Loads queue[i]

	adrp  x0, qElement	     // Prints out queue[i]
	add   x0, x0, :lo12:qElement
	mov   w1, w24
	bl    printf

	cmp   w22, w20		     // Checks whether i == head
	b.ne  dCont2                 // If it is, print out " <-- head of queue"
	adrp  x0, hQueue
	add   x0, x0, :lo12:hQueue
	bl    printf

dCont2:	cmp   w22, w19               // Checks whether i == tail
	b.ne  dCont3                 // If it is, print out " <-- tail of queue"
	adrp  x0, tQueue
	add   x0, x0, :lo12:tQueue
	bl    printf

dCont3:	adrp  x0, newLine            // Prints out a new line
	add   x0, x0, :lo12:newLine
	bl    printf

	add   w22, w22, 1            // ++i
	and   w22, w22, MODMASK      // i = ++i & MODMASK
	add   w23, w23, 1            // j++

test:	cmp   w23, w21               // Loop if j < count
	b.lt  dloop

	// Restoring register states
	ldr   x19, [x29, 16]
	ldr   x20, [x29, 24]
	ldr   x21, [x29, 32]
	ldr   x22, [x29, 40]
	ldr   x23, [x29, 48]
	ldr   x24, [x29, 56]
	
	ldp   x29, x30, [sp], -(-(16 + 48) & -16)
	ret                          // Return to calling code
	
dEQ:	adrp  x0, eQueue             // Print out that the queue is empty
	add   x0, x0, :lo12:eQueue 
	bl    printf
	ldp   x29, x30, [sp], -(-(16 + 48) & -16)                 // Return to calling code
	ret

