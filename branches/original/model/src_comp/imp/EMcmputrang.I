class implementation EMScomposite;

#include "EMScc.h"
#include "msdef.h" /* MS message codes */
#include "msmacros.h"

method GRputrang(long *msg; GRrange range)
/*
Description 
    This is a dummy method. The range has been taken out of instance
    data.

Return values
    *msg  MSSUCC if all goes well

Notes
    If the range is requested through GRgetrang then the range will be
    computed.

History
    DLB 03/26/87 creation...
*/
{
 *msg = MSSUCC;
 return(OM_S_SUCCESS);
}
end implementation EMScomposite;

