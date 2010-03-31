/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
void EFtoggle(bits, word)

unsigned short bits, *word;
{
  unsigned short on, off;

  /*
   * Dtermine which of the bits in 'bits' are on and off in the word.
   */
  on = *word & bits;
  off = ~(*word) & bits;

  /*
   * Turn the on bits off and the off bits on.
   */
  *word &= ~on;
  *word |= off;
}

