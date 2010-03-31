/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
NAME

    EFreadln -- read from a stream until a newline is found

SYNOPSIS

    # include <stdio.h>
    # include "EMSerrordef.h"
    # include "bstypes.h"

    BSrc EFreadln (fp)
    FILE *fp;

DESCRIPTION

    This function reads from the stream until it reaches a
    newline or an end of file marker.  It leaves the file pointer
    positioned at the character after the newline.

RETURN VALUES

    EFreadln currently always returns EMS_S_Success.

HISTORY

    25-Nov-1986  Creation by J. Brooke King
*/

# include <stdio.h>
                        /* we do i/o */
# include "bstypes.h"
                        /* for BSrc typedef */
# include "EMSerrordef.h"
                        /* EMS message codes */
# include "EMSjbklogic.h"
                        /* logical definitions */

BSrc EFreadln (fp)
FILE *fp;
{
    char cc;

    if (NOT feof (fp)) do
    {
        cc = getc (fp);
    } while (cc != '\n' AND cc != EOF);

    return EMS_S_Success;
}
