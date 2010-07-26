/*
Name
        GRposition_form

Description
        This function positions a form near the edge of the screen.  The
        caller may specify which edge[s] to which to move with the input
        argument "position."

History
        mrm     10/25/91    creation
        mrm     03/11/92    call GRget_form_decoration to get decor size
        mrm     10/08/92    function changed to refer to an EXNUC version, 
                            which was cloned from the original here
*/

#include <FI.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"

IGRint GRposition_form(form, position)
Form   form;
IGRint position;
{
    return(EXposition_form(form, position));
}
