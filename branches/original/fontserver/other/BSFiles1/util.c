




/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/





/******************************** U T I L . C ********************************

    This module contains some utility functions.

 ****************************************************************************/



#include "../hfiles/stdef.h"




FUNCTION  fix  getln(fp, buf, count)  /* Get line into buffer, return length */

  FILE  *fp;                /* file pointer */
  char  *buf;               /* buffer for input line */
  fix15  count;             /* maximum length string returned in 'buf' */

/*  GETLN (FP, BUF, COUNT)
 *  Reads an entire line, including the line ending, from a file (or stdin)
 *  Returns a 0-terminated string in 'buf' with a maximum length of 'count'
 *      bytes. The line ending is NOT a part of the string.
 *  Will detect either  <LF>  or  <CR><LF>  as a line ending
 *  Return value = string length of 'buf'.  = -1 if EOF found and no input.
 */

    DECLARE
    register    int c, i;

    BEGIN

    i = 0;
    count--;
    while ((c = getc(fp)) != EOF && c != '\n')
        {
        if (i < count)
            buf[i] = c;
        i++;
        }
    if (c == EOF && i == 0)
        return(-1);
    if (i > count)  i = count;
    if (i > 0  &&  buf[i-1] == '\015')
        i--;                        /* Remove the <CR> at the line ending */
    buf[i] = '\0';
    return(i);
    END

FUNCTION  bool  yes_ans()

/*  YES_ANS ()
 *
 *  Reads a line from standard input
 *  Waits for a yes/no answer ('Y', 'y', 'N', or 'n')
 *  Returns TRUE if yes, FALSE if no
 */
    DECLARE
    char   *s;
    char    strg[4];
    fix     getln();

    BEGIN
    while (TRUE)
        {
        getln(stdin, strg, 4);
        s = strg;
        while (*s == ' ')
            s++;
        if ((*s & 0x5f) == 'Y')
            return(TRUE);
        if ((*s & 0x5f) == 'N')
            return(FALSE);
        }
    END

FUNCTION  void  mbyte (source, dest, count)
  char   *source;
  char   *dest;
  fix31   count;

/*  MBYTE (SOURCE, DEST, COUNT)
 *
 *  Arguments:
 *    source - address of source array
 *    dest - address of destination array
 *    count - number of bytes to be moved
 *  Returns:  nothing
 *
 *  Moves 'count' bytes from the source array to the destination array
 *  Error handling:
 *    If 'count' less than zero, does nothing
 *    Will crash if 'source', or 'dest' don't point to valid memory location
 */

    DECLARE
    fix31   i;
    char   *sarr, *darr;

    BEGIN
    if (count <= 0)
        return;

    if (source > dest)
        {
        for (i=0; i<count; i++)
            *dest++ = *source++;
        }
    else
        {
        sarr = (char *) (source + count);
        darr = (char *) (dest + count);
        for (i=0; i<count; i++)
            *(--darr) = *(--sarr);
        }

    return;
    END


FUNCTION ufix16  swap16(n)      /* 16-bit unsigned integer: swaps bytes */
  ufix16    n;

    DECLARE
    BEGIN
    return(((n & 0xff) << 8) + ((n & 0xff00) >> 8));
    END




FUNCTION ufix32  swap32(n)      /* 32-bit unsigned integer: interchanges
                                   1st & 4th, 2nd & 3rd bytes            */
  ufix32    n;

    DECLARE
    BEGIN
    return(((n & 0x000000ff) << 24) + ((n & 0x0000ff00) <<  8) +
           ((n & 0x00ff0000) >>  8) + ((n & 0xff000000) >> 24));
    END

FUNCTION  void  reverse16 (array, index, count)
  fix15    *array;
  fix31     index;
  fix31     count;

/*  REVERSE16 (ARRAY, INDEX, COUNT)
 *
 *  Arguments:
 *    array - address of source array
 *    index - offset into the array where swapping begins
 *    count - number of words in which byte order will be swapped
 *  Returns:  nothing
 *
 *  Reverses the byte order in an array of 16-bit numbers, starting
 *  with element 'index' for 'count' iterations
 */

    DECLARE
    char   *byte, ch;
    fix31   k;

    BEGIN
    byte = (char *)(array + index);
    for (k = 0;  k < count;  k++)
        {
        ch = *byte;
        *byte = *(byte + 1);
        *(++byte) = ch;
        byte++;
        }
    END


FUNCTION  void  reverse32 (array, index, count)
  fix31    *array;
  fix31     index;
  fix31     count;

/*  REVERSE32 (ARRAY, INDEX, COUNT)
 *
 *  Arguments:
 *    array - address of source array
 *    index - offset into the array where swapping begins
 *    count - number of words in which byte order will be swapped
 *  Returns:  nothing
 *
 *  Reverses the byte order in an array of 32-bit numbers, starting
 *  with element 'index' for 'count' iterations
 */

    DECLARE
    char   *byte, ch0, ch1;
    fix     k;

    BEGIN
    byte = (char *)(array + index);
    for (k = 0; k < count; k++)
        {
        ch0 = *byte;
        ch1 = *(byte + 1);
        *byte = *(byte + 3);
        *(byte + 1) = *(byte + 2);
        *(byte + 2) = ch1;
        *(byte + 3) = ch0;
        byte += 4;
        }
    END


FUNCTION  fix31  i_pow (base, exp)
  fix31     base;
  fix31     exp;

/*  REVERSE32 (ARRAY, INDEX, COUNT)
/*  I_POW (BASE, EXP)
 *
 *  Arguments:
 *    base - base
 *    exp  - exponent
 *  Returns:  the value of 'base' raised to the power 'exp'
 *    'base' and 'exp' must be long integers
 */

    DECLARE
    fix31   j, k;

    BEGIN
    for (k=1, j=0; j<exp; j++)
        k *= base;
    return(k);
    END
