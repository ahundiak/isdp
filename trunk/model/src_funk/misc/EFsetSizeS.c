/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
NAME

    EFsetSizeS -- set character string to desired size

SYNOPSIS

    # include "bstypes.h"
    # include "EMSerrordef.h"

    BSrc EFsetSizeS (size, buffer)
    int size;
    char buffer[];

DESCRIPTION

    This function makes the length of the string in buffer size
    bytes long.

    If the length of the string is less than size, this function
    adds spaces as needed to make the length of the string in
    buffer a null-terminated string which is size characters
    long.

    If the length of the string is more than size, it is
    truncated.

    If the length of the string is size, nothing is done.

ARGUMENTS

    size:  desired string length.

    buffer:  space containing string.  Should be big enough to
    accomodate a NULL-terminated string of length size.

RETURN VALUES

    EMS_S_Success if the string was not changed.

    EMS_I_Success if the string was lengthened.

    EMS_I_Modified if the string was shortened.

HISTORY

    5-Jan-1987  J. Brooke King:  Creation.
*/

# include <stdio.h>
                        /* we do i/o */
# include "bstypes.h"
                        /* BSrc */
# include "EMSerrordef.h"
                        /* EMS message codes */
# include "EMSjbklogic.h"
                        /* logical definitions */

BSrc EFsetSizeS (size, buffer)
int size;
char buffer[];
{
    BSrc value = EMS_S_Success;
    int len;

    len = strlen (buffer);
    if (size > len)
    {
        int ii;

        for (ii = len; ii < size; buffer[ii++] = ' ');
        buffer[size] = '\0';
        value = EMS_I_Success;
    }
    else if (size < len)
    {
        buffer[size] = '\0';
        value = EMS_I_Modified;
    }

    return value;
}
