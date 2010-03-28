/* $RCSfile: fscrypt.c $$Revision: 1.1 $$Date: 1990/07/02 16:06:35 $ Copyright (c) 1990 Intergraph Corp. */

#include "../hfiles/import.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"

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
/*	  int _FSEncryptBuff (buff, numWords)				*/
/*									*/
/*	  Char16	*buff;		- pointer to the words to be	*/
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

int _FSEncryptBuff (buff, numWords)
Char16	*buff;
int	numWords;
{
    Char16	*endBuff;

    for (endBuff = &buff[numWords]; buff < endBuff; buff++)
	*buff = (((*buff + 7) ^ 0x1954) - 779);

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSDecryptBuff (buff, numWords)				*/
/*									*/
/*	  Char16	*buff;		- pointer to the words to be	*/
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

int _FSDecryptBuff (Int16 *buff, int numWords)
{
    Int16	*endBuff;

    for (endBuff = &buff[numWords]; buff < endBuff; buff++)
	*buff = (((*buff + 779) ^ 0x1954) - 7);

    return (FS_NO_ERROR);
}

