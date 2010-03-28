/* #######################    APOGEE COMPILED   ######################## */
/*
Name
   GRget_put_orientation

Description
   Depending on the get_put flag, this method will get the
   value of the drawing view attachment's orientation or set
   it.

Arguments
   *msg           IGRlong    o   completion code 
    get_flag      IGRint     o   1/read, 0/write
   *orient        IGRint     o   the orientation of the dr. view attachment


Return Value
   MSSUCC   -   Too simple to fail.
   

History
   Jack  06/15/92  Creation

*/

class implementation GRdvattach;

#include "grimport.h"
#include "msdef.h"

method GRget_put_orientation(IGRlong *msg;
                              IGRint  get_flag;
                              IGRint *orient)
{

    if( get_flag )
      *orient = me->orientation;
    else me->orientation = *orient;  

    return(MSSUCC);
}
end implementation GRdvattach;
