/*
 * FOR Project PATHWAY
 *     Sanjay  : Creation
 */

/*
 * OVERVIEW
 *     This file contains the functions for manipulation of the bits.
 *
 * NOTES
 *     pos argument in the following functions is the starting position
 *     of bit from the right most position. Number of bits 'nbits'  is
 *     starting from 'pos' moving to right. 
 *
 *      ____________________________________________________________
 *     |  |  |  | ........                               |   |  |  |
 *     |__|__|__|________________________________________|___|__|__|
 *
 *   ...  n+1   n                                          2   1   0
 *                                 <--- pos 
 *                                      nbits --->
 */

/*
 * NAME 
 *    pwGetBits
 *
 * ABSTRACT 
 *    Returns the 'nbits' from the word from the given position 'pos'.
 *
 * SYNOPSIS
 *    unsigned int   word    I  Word 
 *    int            pos     I  From position 
 *    int            nbits   I  Number of bits need to be returned
 *
 * DESCRIPTION
 *
 * NOTES
 *
 * RETURN VALUES
 *    Bits from the given position.
 */ 

unsigned pwGetBits
( 
  unsigned word, 
  int pos, 
  int nbits 
)
{
   return  ( word >> (pos - nbits + 1) ) & ~(~0 << nbits) ;
}

/*
 * NAME
 *    pwSetBits
 *
 * ABSTRACT
 *    Sets the 'nbits' from in word from the given position 'pos' with the 
 *    given 'mask'.
 *
 * SYNOPSIS
 *    unsigned int   word    I/O  Word
 *    int            pos      I   From position
 *    int            nbits    I   Number of bits need to be set
 *    int            mask     I   Mask which need to be set
 *
 * DESCRIPTION
 *
 * NOTES
 *
 * RETURN VALUES
 *    None.
 */

void pwSetBits
( 
  unsigned *word, 
  int pos, 
  int nbits, 
  int mask 
)
{
   *word = ( *word & ~(~(~0 << nbits) << (pos - nbits + 1)) ) | 
           ( (mask & ~(~0 << nbits)) << (pos - nbits + 1) );
}

