#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
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
#include "comiscmac.h"
#include "ma.h"
#include "madef.h"
#include "msdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "igrdef.h"
#include "dpmacros.h"
#include "matypemx.h"
#include "matrlmx.h"
#include "maptscent.h"
#include "maptlnpro.h"
#include "maoptsxfo.h"
#include "ma2ptrcco.h"

/*
  HISTORY

Sudha  :  07/02/93  :  Modified for BSprototypes ansification

*/

struct rectangle_st
{ 
    struct DPele_header  elem;
    struct IGRline       alignment_line;
    IGRdouble            origin[3];
    IGRdouble            *poles;
};

extern IGRint DYaligned_rectangle(); 

/*
    This function takes the diagonal points of a rectangle along with a
    directional vector that lies along a side of the rectagle and produces
    a bspline curve.  The curve is then displayed dynamically and only moves
    parallel to the alignment vector.
*/


IGRint EFdyn_aligned_rectangle(msg, diag_pt1, diag_pt2, direction_vec,
                               alignment_vec, disp_attr)

IGRlong              *msg;
IGRdouble            *diag_pt1;
IGRdouble            *diag_pt2;
IGRdouble            *direction_vec;
IGRdouble            *alignment_vec;
struct IGRdisplay    *disp_attr;

{
    struct rectangle_st      rectangle_data;
    struct IGRbsp_curve      bsplinecrv;
    IGRdouble                pole_buff[15],  /* stub poles for bspline  */
                             knot_buff[15],  /* stub knots for bspline  */
                             point1[3],
                             point2[3];
    struct IGResbc           bsp_ele_spec;
    IGRlong                  num_pts;
    IGRint                   rc,             /* return code             */
                             index;
    IGRboolean               status;         /* return code             */

    rc = MSSUCC;

    /* call math function to get bspline curve */

    bsplinecrv.poles = pole_buff;         
    bsplinecrv.knots = knot_buff;

    status = MA2ptrcconstr(msg, diag_pt1, diag_pt2, direction_vec,
                           &bsplinecrv);

    if (1 & status & *msg)
    {
        bsp_ele_spec.is_polydis = FALSE;
        bsp_ele_spec.is_curvedis = TRUE;

        dp$build_dis_buffer(buffer = &rectangle_data.elem,
                            type = IGRBC,
                            display_att = disp_attr,
                            ele_spec_att = (struct IGResbc *)&bsp_ele_spec,
                            geometry = (struct IGRbsp_curve *)&bsplinecrv);

        num_pts = 4;

        status = MAptscentroid(msg, pole_buff, &num_pts, rectangle_data.origin);

        if (1 & status & *msg)
        {
            OM_BLOCK_MOVE(rectangle_data.origin, point1,
                          sizeof(IGRdouble) * 3);

            for (index = 0; index < 3; index++)
                point2[index] = alignment_vec[index] + point1[index];

            rectangle_data.alignment_line.point1 = point1;
            rectangle_data.alignment_line.point2 = point2;
            rectangle_data.poles = pole_buff;

            dp$dynamics(dyn_fun =  DYaligned_rectangle,
                        information = &rectangle_data);
        }
        else
            rc = MSFAIL;
    }
    else
        rc = MSFAIL;

    return(rc);
}

IGRint DYaligned_rectangle(rectangle_data, cursor_pt, mtx, objects, num_objects,
                           buffers, num_buffers, dummy1, dummy2, dummy3,
                           dummy4, dummy5, dummy6)

struct rectangle_st *rectangle_data;
struct EX_button    *cursor_pt;
IGRdouble           *mtx;
struct GRid         **objects;
IGRint              *num_objects;
struct DPele_header **buffers;
IGRint              *num_buffers;
IGRchar             *dummy1;
IGRchar             *dummy2;
IGRchar             *dummy3;
IGRchar             **dummy4;
IGRchar             **dummy5;
IGRchar             **dummy6;
{

    IGRlong         msg,
                    num_pts;
    IGRint          index;
    IGRdouble       proj_pt[3],
                    tparm,
                    delta_vec[3],
                    trans_matrix[16];
    IGRshort        matrix_type;
    IGRboolean      status;

    /* project the cursor point onto the alignment line and translates the
     * rectangle points to move the rectangle to its new position
     */

    status = MAptlnproj(&msg, &cursor_pt->x, &rectangle_data->alignment_line,
                        proj_pt, &tparm);

    if (1 & status & msg)
    {
        /* build a translation matrix that goes from the rectangles current
         * position to the projection point position
         */

        for (index = 0; index < 3; index++)
            delta_vec[index] = proj_pt[index] - rectangle_data->origin[index];

        MAtrlmx(&msg, delta_vec, trans_matrix);

        /* translate the poles of the bspline curve */

        MAtypemx(&msg, trans_matrix, &matrix_type);
        num_pts = 5;

        status = MAoptsxform(&msg, &num_pts, &matrix_type, trans_matrix,
                             rectangle_data->poles, rectangle_data->poles);

        if (1 & status & msg)
        {
            /* the projected point is the element's new origin */

            OM_BLOCK_MOVE(proj_pt, rectangle_data->origin,
                          sizeof(IGRdouble) * 3);

            *buffers = &rectangle_data->elem;
            *num_buffers = 1;
        }
        else
            *num_buffers = 0;
    }
    else
        *num_buffers = 0;

    return(MSSUCC);
}
