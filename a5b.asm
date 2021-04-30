	// Author: Cody Clark
	// Student ID: 30010560
	// CPSC 355, Assignment 5b

	/*
	 * This program takes as input 2 integers in the command line when calling the program.
	 * It will then output the name of the month, the day with a proper suffix, and the season.
	 * Eg: ./a5b 11 23
	 *     November 23rd in Winter
	 *
	 * The format is mm dd
	*/

	define(argc_r, w19) // Number of arguments
	define(argv_r, x20) // Array of arguments
	define(m_r, w21)    // Month register
	define(d_r, w22)    // Day register
	define(su_r, w23)   // suffix register
	define(se_r, w24)   // season register
	define(base_r, x25) // base register

	.text
error:	.string "ERROR: That was not a valid date.\n"
error2:	.string "ERROR: usage: 5b mm dd\n"
st:	.string "st" // Numbers that end in 1
nd:	.string "nd" // Numbers that end in 2
rd:	.string "rd" // Numbers that end in 3
th:	.string "th" // Numbers that end in 4
date:	.string "%s %d%s is %s\n" // "Month DaySuffix in Season"

sum_m:	.string "Summer"
fal_m:	.string "Fall"
win_m:	.string "Winter"
spr_m:	.string "Spring"

jan_m:	.string "January"
feb_m:	.string "February"
mar_m:	.string "March"
apr_m:	.string "April"
may_m:	.string "May"
jun_m:	.string "June"
jul_m:	.string "July"
aug_m:	.string "August"
sep_m:	.string "September"
oct_m:	.string "October"
nov_m:	.string "November"
dec_m:	.string "December"

test:	.string "MONTH: %d\nDAY: %d"

	.data
	.balign 8
season_m:	.dword  win_m, spr_m, sum_m, fal_m
month_m:	.dword  jan_m, feb_m, mar_m, apr_m, may_m, jun_m, jul_m, aug_m, sep_m, oct_m, nov_m, dec_m
suffix_m:	.dword  st, nd, rd, th
	
	.text
	.balign 4
	.global main

main:	stp   x29, x30, [sp, -16]!
	mov   x29, sp

	mov   argc_r, w0      // Number of command line arguments
	mov   argv_r, x1      // Base address of the array of strings of command line arguments passed to the program

	cmp   argc_r, 3
	b.lt  err2_s

	ldr   x0, [argv_r, 8] // Load the month as the first argument string
	bl    atoi            // Convert the month string into an int
	mov   m_r, w0         // Move that temp int into the month register
	ldr   x0, [argv_r, 16] // Load the day as the first string argument
	bl    atoi
	mov   d_r, w0         // Move the temp int into the day register

	b     err_t           // Run an error check on both of the numbers

cont:
	// Checks for which suffix is appropriate
	// st
	cmp   d_r, 1
	b.eq  first
	cmp   d_r, 21
	b.eq  first
	cmp   d_r, 31
	b.eq  first

	// nd
	cmp   d_r, 2
	b.eq  second
	cmp   d_r, 22
	b.eq  second

	// rd
	cmp   d_r, 3
	b.eq  third
	cmp   d_r, 23
	b.eq  third

	// th
	b     else

	// These determine the offsets for the suffix array
	// The appropriate suffix has been determined to be st
first:	mov   su_r, 0
	b     next1

	// The appropriate suffix has been determined to be nd
second: mov   su_r, 1
	b     next1

	// The appropriate suffix has been determined to be rd
third:  mov   su_r, 2
	b     next1

	// The appropriate suffix has been determined to be th
else:   mov   su_r, 3
	
next1:	// Now we decide which season the date is in
	// Winter = Dec 21 => Mar 20
	// Spring = Mar 21 => June 20
	// Summer = Jun 21 => Sep 20
	// Fall   = Sep 21 => Dec 20

	cmp   m_r, 1
	b.eq  winter
	
	cmp   m_r, 2
	b.eq  winter

	cmp   m_r, 3
	b.eq  mar_dec

	cmp   m_r, 4
	b.eq  spring
	
	cmp   m_r, 5
	b.eq  spring

	cmp   m_r, 6
	b.eq  jun_dec

	cmp   m_r, 7
	b.eq  summer

	cmp   m_r, 8
	b.eq  summer

	cmp   m_r, 9
	b.eq  sep_dec

	cmp   m_r, 10
	b.eq  fall

	cmp   m_r, 11
	b.eq  fall

	cmp   m_r, 12
	b.eq  dec_dec

	// Decision subroutines
	// They decide which season a date is in during the months have have 2 seasons
mar_dec: 
	cmp   d_r, 21
	b.ge  spring
	b     winter

jun_dec:
	cmp   d_r, 21
	b.ge  summer
	b     spring

sep_dec:
	cmp   d_r, 21
	b.ge  fall
	b     summer

dec_dec:
	cmp   d_r, 21
	b.ge  winter
	b     fall

	// The seasons have been determined, decide the offset of the season array
winter: mov   se_r, 0
	b     print

spring: mov   se_r, 1
	b     print

summer: mov   se_r, 2
	b     print

fall:	mov   se_r, 3

	// Print the results
print:	adrp  x0, date
	add   x0, x0, :lo12:date

	// Loads the correct month string
	adrp  base_r, month_m
	add   base_r, base_r, :lo12:month_m
	sub   m_r, m_r, 1                   // Prepare the month index to use as an offset
	ldr   x1, [base_r, m_r, SXTW 3]

	// Loads the day integer
	mov   w2, d_r

	// Loads the correct suffix string
	adrp  base_r, suffix_m
	add   base_r, base_r, :lo12:suffix_m
	ldr   x3, [base_r, su_r, SXTW 3]

	// Loads the correct season string
	adrp  base_r, season_m
	add   base_r, base_r, :lo12:season_m
	ldr   x4, [base_r, se_r, SXTW 3]
	bl    printf
	
	b     end // End the program
	
	// This is the section for error checking
	// It'll make sure that the dates entered are real dates for each month
	// If less than 2 numbers have been entered then the garbage values will be out of range
	// Therefore the program will exit. 
err_t:	cmp   m_r, 12 // If the month number entered is greater than 12
	b.gt  err_s

	cmp   m_r, 1  // If the month number entered is less than 1 
	b.lt  err_s

	cmp   d_r, 1  // If the day number entered is less than 1
	b.lt  err_s

	cmp   d_r, 31 // If the day number enetered is more than 31
	b.gt  err_s

	// Examines which monh the date is in, and if that date is less than the number of days that month can possibly have
jan:	cmp   m_r, 1
	b.ne  feb
	cmp   d_r, 31
	b.le  cont
	b     err_s

	// February could possibly be a leap year, so 02 29 is possible
feb:	cmp   m_r, 2
	b.ne  mar
	cmp   d_r, 29
	b.le  cont
	b     err_s

mar:	cmp   m_r, 3
	b.ne  apr
	cmp   d_r, 31
	b.le  cont
	b     err_s

apr:	cmp   m_r, 4
	b.ne  may
	cmp   d_r, 30
	b.le  cont
	b     err_s

may:	cmp   m_r, 5
	b.ne  jun
	cmp   d_r, 31
	b.le  cont
	b     err_s

jun:	cmp   m_r, 6
	b.ne  jul
	cmp   d_r, 30
	b.le  cont
	b     err_s

jul:	cmp   m_r, 7
	b.ne  aug
	cmp   d_r, 31
	b.le  cont
	b     err_s

aug:	cmp   m_r, 8
	b.ne  sep
	cmp   d_r, 31
	b.le  cont
	b     err_s

sep:	cmp   m_r, 9
	b.ne  oct
	cmp   d_r, 30
	b.le  cont
	b     err_s

oct:	cmp   m_r, 10
	b.ne  nov
	cmp   d_r, 31
	b.le  cont
	b     err_s

nov:	cmp   m_r, 11
	b.ne  dec
	cmp   d_r, 30
	b.le  cont
	b     err_s

dec:	cmp   m_r, 12
	b.ne  err_s
	cmp   d_r, 31
	b.le  cont
	b     err_s

	// Prints "ERROR, NOT A REAL DATE" should the date entered not exist
err_s:	adrp  x0, error
	add   x0, x0, :lo12:error
	bl    printf
	b     end

err2_s:	adrp  x0, error2
	add   x0, x0, :lo12:error2
	bl    printf
	
end:	ldp   x29, x30, [sp], 16
	ret
