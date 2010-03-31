/*
    Abstract:  This function checks the located line to see if the accept
               prompt needs to be changed to request a point to identify
               one of the end segments.  This is necessary if the located line
               has more that one segment and the end segments are not parallel.


  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification

*/

#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "bsparameters.h"
#include "bserr.h"
#include "ECmsg.h"
#include "bslenvecsq.h"
#include "bscrossp.h"


IGRint EFselect_end_segment(msg, select_args, my_args)

IGRlong               *msg;
struct LC_select_args *select_args;
IGRchar               *my_args;
{
    extern IGRlong EFget_cut_line_segs();
    IGRlong rc;
    IGRint  sts,
            num_segments,
            index,
            end_seg_index;
    IGRpoint  *segments,
               vector1,
               vector2,
               crossvector;
    IGRdouble  tolerance,
               length;
    IGRboolean message_flag;

    segments = NULL;
    message_flag = *(IGRboolean *) my_args;  /* flag to indicate whether to
                                                use the "alternative" accept
                                                message if the end segments of
                                                the line are parallel */

    if (message_flag)
        select_args->acc_key = EMS_P_IdSlProcRj;

    rc = EFget_cut_line_segs(msg,
                             &select_args->stack->entry[0].located_obj,
                             &select_args->stack->entry[0].module_info,
                             &num_segments, &segments);
    if (1 & rc & *msg)
    {
        if (num_segments > 1)
        {
            /* determine if the end segments are parallel */

            end_seg_index = (num_segments * 2) - 1;

            for (index = 0; index < 3; index++)
            {
                vector1[index] = segments[1][index] -
                                 segments[0][index];
                vector2[index] = segments[end_seg_index][index] -
                                 segments[end_seg_index - 1][index];
            }

            BSEXTRACTPAR(&sts, BSTOLSQCOLLINVEC, tolerance);
            BScrossp(msg, vector1, vector2, crossvector);
            length = BSlenvecsq(msg, crossvector);

            if (length > tolerance)
            {
                select_args->acc_key = EMS_P_AcLnDfFlDrRj;
            }
        }
    }

    if (segments)
        om$dealloc(ptr = segments);

    sts = lc$select(msg = msg,
                    args = select_args,
                    user_data = my_args);

    return(sts);
}


