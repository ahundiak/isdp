/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRgenabsg

Description
    This routine generates the abstract data representation for a 3-D
    double precision cell header object and places the data in the 
    abstract geometry cache.

     *msg         IGRlong        completion message 
     *matrix_type IGRshort       type of transformation matrix
     matrix       IGRmatrix      transformation matrix
     **absgptr    IGRchar        pointer to abstract geometry buffer

History
    Gray Winn      05/05/88    Creation Date
\*/

class implementation GRdvattach;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "madef.h"
#include "gocmacros.h"
#include "grsymdef.h"

method GRgenabsg ( IGRlong *msg;
                   IGRshort *matrix_type;
                   IGRmatrix matrix;
                   IGRchar **absgptr)
{
    IGRlong           om_msg;
    IGRdouble         diag_pt[3];

    *msg = MSSUCC;

    diag_pt[0] = diag_pt[1] = diag_pt[2] = 0.0;

    om_msg = GR3dlbgenabsg ( msg,
                             matrix_type,
                             matrix,
                             me->matrix,
                             me->origin,
                             diag_pt,
                             diag_pt,
                             my_id,
                             OM_Gw_current_OS,
                             absgptr );
    return(om_msg);
}
end implementation GRdvattach;
