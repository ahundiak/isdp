/************************************************************************/
/*									*/
/*	   Bitstream demands that we encrypt the data in the outline	*/
/*	portion of the typeface files.  This is to protect their	*/
/*	copyrighted data.  The following routines have been written	*/
/*	for the encryption and decryption of the data.			*/
/*									*/
/*	   The encryption algorithm is very simple:			*/
/*		o  add 7						*/
/*		o  XOR with 0x1954					*/
/*		o  subtract 779						*/
/*									*/
/*	   to decrypt, these steps are reversed:			*/
/*		o  add 779						*/
/*		o  XOR with 0x1954					*/
/*		o  subtract 7						*/
/*									*/
/************************************************************************/

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSencryptBuff (buff, numWords)				*/
/*									*/
/*	  char16	*buff;		- pointer to the words to be	*/
/*					  encrypted			*/
/*	  int		numWords;	- number of words to encrypt	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine will encrypt the words in the buffer.  It should	*/
/*	  be done to the outline data before writing it.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

/*
$Log: FScrypt.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:21  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:33  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:35  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:50:55  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:29:21  root
 * COMMENT : Corresponds to Rel201.5 in 2.0.1 RCS
 *
 * Revision 201.5  1992/07/13  20:41:54  tim
 * COMMENT : added Log variable
 *
*/

#include "exsysdep.h"
#include "FSBmap.h"
#include "FFerrdef.h"

FSencryptBuff (buff, numWords)

	         Char16	*buff;
        unsigned int	 numWords;
{
    unsigned int    count;
/*
    Char16 a;
*/

    for (count = 0; count < numWords; count++, buff++)
    {
	*buff = (((*buff + 7) ^ 0x1954) - 779);
#ifdef BIG_ENDIAN
	Xconv_short(buff);
#endif
    }

    return ( FF_S_SUCCESS );
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSdecryptBuff (buff, numWords)				*/
/*									*/
/*	  char16	*buff;		- pointer to the words to be	*/
/*					  decrypted			*/
/*	  int		numWords;	- number of words to decrypt	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine will decrypt the words in the buffer.  It should	*/
/*	  be done to the outline data after reading it.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

FSdecryptBuff (buff, numWords)

	         Char16	*buff;
	unsigned int	 numWords;
{
    unsigned int count;
/*
    union {	uInt32	a;
		Char16	b[2];	} data;
*/

    for (count = 0; count < numWords; count++, buff++)
	*buff = (((*buff + 779) ^ 0x1954) - 7);

    return (FF_S_SUCCESS);
}

