/*
 *  Description
 *    This file contains functions to swap bytes for the Sun.  It was
 *    "borrowed" from the InterPlot people.
 *
 *  History
 *    dhm    3/4/92    creation date
 */

/*******************************************************************************

    FILE

	UTByteOrder.c

    DESCRIPTION

	This file contains the functions that swap bytes for the sparc
	architecture.

    FUNCTIONS

	UTConvertShort
	UTConvertLong
	UTConvertDouble

*******************************************************************************/


#include "exsysdep.h"

/*******************************************************************************

    SYNOPSIS

	void UTConvertShort(num_swaps,buffer)

	int num_swaps;
	unsigned short *buffer;

    PARAMETERS

	NAME		ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
	----		-------------------------------------------------------

	num_swaps	(I)	Number of swaps

	buffer		(I/O)	Buffer of elements to be swapped

    RETURN VALUE

	void

    DESCRIPTION

	This routine swaps the bytes in each short of an array of shorts
	for the sparc.

    CHANGE HISTORY

	06/10/91 (mc )	Initial creation

	06/18/91 (mc )  Changed name from UTSwapShort to UTConvertShort
*******************************************************************************/
/* ARGSUSED */
void UTConvertShort(num_swaps,buffer)

int num_swaps;
unsigned short *buffer;
{
#ifdef BIG_ENDIAN
    unsigned char *char_ptr;
    union malign
    {
	unsigned short myshort;
	unsigned char mychar[2];
    };

    union malign holdspace;

    while (num_swaps-- > 0)
    {
	char_ptr = (unsigned char *)&buffer[num_swaps];
	holdspace.mychar[1] = char_ptr[0];
	holdspace.mychar[0] = char_ptr[1];
	buffer[num_swaps] = holdspace.myshort;
    }
#endif
    return;
}

/*******************************************************************************

    SYNOPSIS

        void UTConvertLong(num_swaps,buffer)

        int num_swaps;
        unsigned long *buffer;

    PARAMETERS

        NAME            ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----            -------------------------------------------------------

        num_swaps       (I)     Number of swaps

        buffer          (I/O)   Buffer of elements to be swapped

    RETURN VALUE

        void

    DESCRIPTION

        This routine swaps the bytes in each long for an array of longs
	for the sparc.

    CHANGE HISTORY

        06/10/91 (mc )  Initial creation

        06/18/91 (mc )  Changed name from UTSwapLong to UTConvertLong

*******************************************************************************/
/* ARGSUSED */
void UTConvertLong(num_swaps,buffer)

int num_swaps;
unsigned long *buffer;
{
#ifdef BIG_ENDIAN
    unsigned char *char_ptr;
    union malign
    {
        unsigned long mylong;
        unsigned char mychar[4];
    };

    union malign holdspace;

    while (num_swaps-- > 0)
    {
        char_ptr = (unsigned char *)&buffer[num_swaps];
        holdspace.mychar[3] = char_ptr[0];
        holdspace.mychar[2] = char_ptr[1];
        holdspace.mychar[1] = char_ptr[2];
        holdspace.mychar[0] = char_ptr[3];
        buffer[num_swaps] = holdspace.mylong;
    }
#endif
    return;
}

/*******************************************************************************


    SYNOPSIS

        void UTConvertDouble(num_swaps,buffer)

        int num_swaps;
        double *buffer;

    PARAMETERS

        NAME            ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----            -------------------------------------------------------

        num_swaps       (I)     Number of swaps

        buffer          (I/O)   Buffer of elements to be swapped

    RETURN VALUE

        void

    DESCRIPTION

        This routine swaps the bytes in each double for an array of doubles 
	for the sparc.

    CHANGE HISTORY

        06/10/91 (mc )  Initial creation

        06/18/91 (mc )  Changed name from UTSwapDouble to UTConvertDouble

*******************************************************************************/
/* ARGSUSED */
void UTConvertDouble(int num_swaps, double *buffer)

{
#ifdef BIG_ENDIAN
    unsigned char *char_ptr;
    union malign
    {
        double mydouble;
        unsigned char mychar[8];
    };

    union malign holdspace;

    while (num_swaps-- > 0)
    {
        char_ptr = (unsigned char *)&buffer[num_swaps];
	holdspace.mychar[7] = char_ptr[0];
        holdspace.mychar[6] = char_ptr[1];
        holdspace.mychar[5] = char_ptr[2];
        holdspace.mychar[4] = char_ptr[3];
        holdspace.mychar[3] = char_ptr[4];
        holdspace.mychar[2] = char_ptr[5];
        holdspace.mychar[1] = char_ptr[6];
        holdspace.mychar[0] = char_ptr[7];
        buffer[num_swaps] = holdspace.mydouble;
    }
#endif
    return;
}
