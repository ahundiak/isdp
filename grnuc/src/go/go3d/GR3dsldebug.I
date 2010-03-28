/*
Name
        GR3dlinestr.debug

Description
        This method is overridden to dump instance data for this class.

History
        mrm     08/09/91    creation
*/

class implementation GR3dlinestr;

#include "OMmacros.h"

method debug()
{
    int sts, i, n;

    sts = om$send(mode = OM_e_wrt_message,
                  msg = message GRvg.debug(),
                  targetid = my_id);
    if (!(sts & 1)) om$report_error(sts = sts);
    n = om$dimension_of(varray = me->points);
    printf("GR3dlinestr->points contains %d points\n", n);
    for (i = 0; i < n; i++)
        printf("GR3dlinestr->points[0] = %g, %g, %g\n",
               me->points[i][0], me->points[i][1], me->points[i][2]);
    return(OM_S_SUCCESS);
}

end implementation GR3dlinestr;
