/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
NAME

    EFgetln -- read the rest of a line of a stream into a buffer

SYNOPSIS

    # include <stdio.h>
    # include "EMSerrordef.h"

    BSrc EFgetln (fp, size, buffer)
    FILE *fp;
    int size;
    char buffer[];

DESCRIPTION

    This function reads from the stream until fills buffer with a
    null-terminated string or until it reaches a newline or an
    end of file marker, whichever came first.  If it stopped by
    reaching a newline, it leaves the newline in the stream.  If
    it stopped before the line was complete because a string of
    length size-1 was read, the rest of the line is left in the
    stream.

RETURN VALUES

    EMS_S_Success if a line is read.

    EMS_I_Success if the stream is at EOF.

    EMS_E_Fail if size <= 0.

HISTORY

    25-Nov-1986  Creation by J. Brooke King
*/

# include <stdio.h>
                        /* we do i/o */
# include "bstypes.h"
                        /* BSrc */
# include "EMSerrordef.h"
                        /* EMS message codes */
# include "EMSjbklogic.h"
                        /* logical definitions */

BSrc EFgetln (fp, size, buffer)
FILE *fp;
int size;
char buffer[];
{
    BSrc value = EMS_E_Fail;
    char cc;
    int ii;

    if (size > 0)
    {
        if (feof (fp))
        {
            value = EMS_I_Success;
        }
        else
        {
            cc = getc (fp);
            for (ii = 0; cc != '\n' AND cc != EOF AND ii < size - 1;
                ii++, cc = getc(fp))
            {   
                buffer[ii] = cc;
            }

            if (cc IS '\n') (void)ungetc (cc, fp);
            buffer[ii] = '\0';

            value = EMS_S_Success;
        }
    }

    return value;
}
