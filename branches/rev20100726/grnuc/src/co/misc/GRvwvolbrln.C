/*----
%GP% CODE CLASSIFICATION
----
%HD%
     FUNCTION NAME:  GRvwvolbrln

----
%AB%
     ABSTRACT:  This function returns a boreline that passes throught the
specified point and with "endpoints" that lie on the front (point1) and back
(point2) plane of the view volume of the specified window.
----
%CH%
     CHANGE HISTORY:    

        WBC : 02/08/92 : Creation date.
----
%PD%
----*/
/*EH*/

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "msdef.h"
#include "dpdef.h"
#include "dp.h"
#include "igrdef.h"
#include "dpmacros.h"
#include "exdef.h"
#include "codef.h"
#include <stdio.h>


IGRint GRvwvolbrln(msg, event, line)

IGRlong                 *msg;
struct  GRevent         *event;     /* event containing pt  */
struct  IGRline         *line;      /* boreline             */
{
    extern IGRboolean  MAlnplproj();

    IGRmatrix          wldvwmatrix;      /* world to view matrix      */
    IGRdouble          wldvwvolume[6],   /* view volume in world coordinates */
                       intersect_pts[6],
                       intersect_tparms[2],
                       plane_pt[3];
    struct IGRplane    plane;
    IGRlong            which_err,
                       status,     /* return status        */
                       ret_size;
    IGRint             b_status,   /* return status        */
                       index,
                       pt1_offset,
                       pt2_offset;
    struct var_list    var_list[3];
    IGRboolean         rc;

    b_status = FALSE;

    var_list[0].var = WLD_TO_VIEW;
    var_list[0].var_ptr = (IGRchar *) wldvwmatrix;
    var_list[0].num_bytes = sizeof(IGRmatrix);
    var_list[0].bytes_returned = &ret_size;

    var_list[1].var =  WLD_VOLUME;
    var_list[1].var_ptr = (IGRchar *) wldvwvolume;
    var_list[1].num_bytes = sizeof(IGRdouble) * 6;
    var_list[1].bytes_returned = &ret_size;

    var_list[2].var = END_PARAM;
  
    status = dp$inq_set_gragad(msg = msg,
                               osnum = event->event.button.osnum,
                               gragad_objid = event->event.button.objid,
                               which_error = &which_err,
                               var_list = var_list);
    if (1 & status & *msg)
    {
        /* get a boreline that passes through the event point and is normal
         * to the view
         */

        rc = GRbrlnconstr(msg, &event->event.button.x, wldvwmatrix, line);

        if (1 & rc & *msg)
        {
            /* find the intersection points of the boreline and the front
             * and back planes of the view's volume; the intersection point
             * that is closest to the user (has the greatest t parameter)
             * should be the first boreline point
             */

            plane.normal = &wldvwmatrix[8];

            for (index = 0; index < 2; index++)
            {
                plane.point = &wldvwvolume[index * 3];

                rc = MAlnplproj(msg, line, &plane, &intersect_pts[index * 3],
                                plane_pt, &intersect_tparms[index]);

                if (!(1 & rc & *msg))
                {
                    b_status = FALSE;
                    *msg = MSFAIL;
                    break;
                }
            }

            if (intersect_tparms[0] > intersect_tparms[1])
            {
                pt1_offset = 0;
                pt2_offset = 3;
            }
            else
            {
                pt1_offset = 3;
                pt2_offset = 0;
            }

            for (index = 0; index < 3; index++)
            {
                line->point1[index] = intersect_pts[index + pt1_offset];
                line->point2[index] = intersect_pts[index + pt2_offset];
            }
        }
        else  /* GRbrlnconstr failed */
        {
            b_status = FALSE;
            *msg = MSFAIL;
        }
    }
    else  /* dp$inq_set_gragad failed */
    {
        b_status = FALSE;
        *msg = MSFAIL;
    }

    return(b_status);
}
