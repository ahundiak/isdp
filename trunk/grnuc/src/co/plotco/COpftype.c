/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COpftype

Description
        This function will scan a file to determine whether it is
        an InterScript or IGDS file.

Algorithm
        InterScript - the file must have the characters "EP" in the
        first two bytes.

        IGDS - the first byte must equal 9, the second word must
        equal 766.

Synopsis
        int COpftype (filename, filetype)

        char *filename;     I   UNIX file specification
        int *filetype;      O   Plotfile type

Return Values
        COpftype()  TRUE                The specified file is a plotfile
                    FALSE               The specified file is not a plotfile
        filetype    PI_IGDS_FILE        IGDS file
                    PI_IGM_FILE         Interscript file
                    PI_UNKNOWN_FILE     The specified file is not a plotfile

History
        mrm     06/20/89    creation
                11/06/89    ifdef'ed out InterScript support
                02/17/92    fixed filetype arg to expect a pointer in order
                            to properly return the result 
*/

#include "exsysdep.h"
#ifndef STANDALONE
#include "coimport.h"
#endif
#include <stdio.h>
#include "pidef.h"

int COpftype (filename, filetype)
char *filename;
int *filetype;
{
    short buf[2];
#ifdef BIG_ENDIAN
    short swapped_short1, swapped_short2;
#endif
    int sts = FALSE;
    FILE *fp = NULL;
 
    *filetype = PI_UNKNOWN_FILE;

    /* open the file */

    if (fp = fopen (filename, "r"))
    {
        /* read a couple of words */

        if (fread (buf, sizeof (short), 2, fp) == 2)
        {
            /* check for an IGDS file - type 9, 766 words to follow */

#ifdef BIG_ENDIAN
            GRconv_short(&buf[0], &swapped_short1);
            GRconv_short(&buf[1], &swapped_short2);
            if ( (((swapped_short1 & 0x7f00) >> 8) == 9) &&
                   (swapped_short2 == 766) )
#else
            if ((((buf[0] & 0x7f00) >> 8) == 9) && (buf[1] == 766))
#endif
            {
                sts = TRUE;
                *filetype = PI_IGDS_FILE;
            }
#ifdef INTERSCRIPT
#ifdef BIG_ENDIAN
            else if (buf[0] == 0x5045)
#else
            else if (buf[0] == 0x4550) /* check for InterScript file - EP */
#endif
            {
                sts = TRUE;
                *filetype = PI_IGM_FILE;
            }
#endif
        }
        fclose (fp);
    }
    return (sts);
}
