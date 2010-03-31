/* ###################   APOGEE COMPILED   ################## */
/* #################   APOGEE  COMPILED   ######################### */
/* ************************************************************************

Description

 This method returns itself as the graphic object corresponding to the
 element in the graph.

Arguments
 Input

 Output
  go:  the graphic object corresponding to this associative element
  mat_type:  matrix type of the graphic object's environment matrix
  matrix:  environment matrix of the graphic object

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.

History
 04/08/91 : WBC : Creation date.
 Sudha   06/01/93    modified to handle BSprototype headers

*********************************************************************** */

class implementation GAcurve;

#include "EMS.h"
#include "maidmx.h"

method ASreturn_go(struct GRid *go; IGRshort *mat_type; IGRdouble *matrix)
{
    IGRlong rc;

    if (matrix && mat_type)
    {
        MAidmx(&rc, matrix);
        *mat_type = MAIDMX;
    }

    go->objid = my_id;
    go->osnum = OM_Gw_current_OS;

    return(OM_S_SUCCESS);
}
end implementation GAcurve;
