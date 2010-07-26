/*
Name
        LCblptlocate

Description
	This routine will calculate the range that is passed to the Rtree
	when a boreline locate is in operation.  It is done by making a 
	bore vector out of the point passed in by using the window's 
	view volume.

Bugs
	Currently clipping flags are not supported properly.

History
	rc      07/20/87    Started documenation.
        mrm     02/29/92    Leap Day - Oh boy!!  Always return a value
        scw     07/10/92    Ansi conversion
*/

class  implementation Root;

#include "grimport.h"
#include "OMminimum.h"
#include "OMindex.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "lcpriv.h"
#include "msdef.h"

from IGEgragad import DPrngbox;

#argsused
IGRint LCblptlocate (rc, event1, attributes, stack, mod, tolerance,
                     action_handler, act_args, classptr, locate_args, user_arg)

IGRlong             *rc;                /* return code                     */
struct GRevent      *event1;            /* return from GRgetevent          */
struct GRlc_locate  *attributes;        /* contains class & level info     */
struct GRlc_stack   *stack;             /* pointer to "stack"              */
struct GRmd_env     *mod;               /* current module information      */
IGRdouble           *tolerance;         /* current tolerance               */
IGRchar             (*action_handler)();
IGRchar             *act_args;
GRlc_classptrs      classptr;
IGRchar             *locate_args;
IGRchar             *user_arg;
{
    IGRchar                 *locate_params = NULL;
    IGRshort                dimension;
    IGRint                  ii, jj, kk, flags;       
    IGRlong                 sts, msg;
    IGRlong                 which_error;
    IGRlong                 retb1;
    IGRlong                 number_points;
    IGRdouble               points[24];
    IGRdouble               vwmat[16];
    IGRdouble               scale;
    IGRdouble               line_pt[6];
    IGRdouble               vvol[6];
    IGRdouble               max, min;
    IGRdouble               *temp_pt;
    enum GRlocate_types     locate_type;
    struct IGRline          line;
    struct GRlc_bl_loc      bl_loc_params;
    struct GRlc_pt_loc      pt_loc_params;
    struct var_list         list_var[5];
    struct LC_action_args   *act_ptr;


    sts = FALSE;
    act_ptr = (struct LC_action_args *) (locate_args);

    if (act_ptr->type == GR_bl_loc)
    {
        /*
         *  Set up structure necessary for LCquery
         */

        bl_loc_params.datapoint.x = event1->event.button.x;
        bl_loc_params.datapoint.y = event1->event.button.y;
        bl_loc_params.datapoint.z = event1->event.button.z;
        bl_loc_params.obj_attr = *attributes;    
        bl_loc_params.datapoint.objid = event1->event.button.objid;
        stack->window.objid = event1->event.button.objid;
        stack->window.osnum = mod->md_id.osnum;
        stack->module = mod->md_id;
        bl_loc_params.datapoint.osnum = mod->md_id.osnum;
        line.point1 = &line_pt[0];
        line.point2 = &line_pt[3];
        bl_loc_params.boreline = line;

        /* 
         *  Calculate range by first constructing a boreline,
         *  take it to view, put in z's of view volume, 
         *  build 4 points around each endpoint by point + dit/vvol -> vwport
         *  take these points to world, accumulate highs and lows 
         */

        /*
         *  From the gadget inquire the view volume to viewport scale, the
         *  world to view matrix, view volume, and the gragad flags.
         */

        list_var[0].var            = VVOL_VIEWPORT_SCALE;
        list_var[0].var_ptr        = (IGRchar*)&scale;
        list_var[0].num_bytes      = sizeof(IGRdouble);
        list_var[0].bytes_returned = &retb1;

        list_var[1].var            = WLD_TO_VIEW;
        list_var[1].var_ptr        = (IGRchar*)vwmat;
        list_var[1].num_bytes      = sizeof(IGRdouble)*16;
        list_var[1].bytes_returned = &retb1;

        list_var[2].var            = VW_VOLUME;
        list_var[2].var_ptr        = (IGRchar*)vvol;
        list_var[2].num_bytes      = sizeof(IGRdouble)*6;
        list_var[2].bytes_returned = &retb1;

        list_var[3].var            = GRAGAD_FLAGS;
        list_var[3].var_ptr        = (IGRchar *)&flags;
        list_var[3].num_bytes      = sizeof(IGRint);
        list_var[3].bytes_returned = &retb1;

        list_var[4].var            = END_PARAM;
        list_var[4].var_ptr        = NULL;
        list_var[4].num_bytes      = 0;
        list_var[4].bytes_returned = NULL;

        *rc = dp$inq_set_gragad (msg = rc,
    				 osnum = stack->window.osnum,
    				 gragad_objid = stack->window.objid,
    				 which_error = &which_error,
    				 var_list = list_var);
        if (!(1&*rc))
        {
           *rc = 0; 
           return (0);
        }

        /*
         *  Find the correct tolerance.
         */

        *tolerance /= scale;
        bl_loc_params.tolerance = *tolerance;

        /*
         *  Should a skew scan be done or a regular scan through the rtree?
         *  If the AXIS_WLD_ALIGN is set then a regular scan will be done.
         */

        if (flags & AXIS_WLD_ALIGN)
        {
            bl_loc_params.is_ortho = 1;
        }
        else
        {
	    bl_loc_params.is_ortho = 0;
        }

        /*
         *  Calculations for range box
         */

        line_pt[0] = event1->event.button.x;
        line_pt[1] = event1->event.button.y;
        line_pt[2] = event1->event.button.z;

        DPlocbrln (rc, line_pt, stack->window.objid, stack->window.osnum,
                   &line);

        /*
         *  Take points to view coordinate system
         */

        number_points = 2;
        MAptsxform (rc, &number_points, vwmat, line_pt, line_pt);

        /*
         *   Build the cubes around the endpoints of the line.
         *          8 points. (in view coordinate system)
         */

        temp_pt = points;

        *temp_pt++ = line_pt[0] + *tolerance;
        *temp_pt++ = line_pt[1] + *tolerance;
        *temp_pt++ = line_pt[2];

        *temp_pt++ = line_pt[0] - *tolerance;
        *temp_pt++ = line_pt[1] + *tolerance;
        *temp_pt++ = line_pt[2];

        *temp_pt++ = line_pt[0] - *tolerance;
        *temp_pt++ = line_pt[1] - *tolerance;
        *temp_pt++ = line_pt[2];

        *temp_pt++ = line_pt[0] + *tolerance;
        *temp_pt++ = line_pt[1] - *tolerance;
        *temp_pt++ = line_pt[2];

        *temp_pt++ = line_pt[3] + *tolerance;
        *temp_pt++ = line_pt[4] + *tolerance;
        *temp_pt++ = line_pt[5];

        *temp_pt++ = line_pt[3] - *tolerance;
        *temp_pt++ = line_pt[4] + *tolerance;
        *temp_pt++ = line_pt[5];

        *temp_pt++ = line_pt[3] - *tolerance;
        *temp_pt++ = line_pt[4] - *tolerance;
        *temp_pt++ = line_pt[5];

        *temp_pt++ = line_pt[3] + *tolerance;
        *temp_pt++ = line_pt[4] - *tolerance;
        *temp_pt   = line_pt[5];

        dimension = 4;

        /*
         *  Find matrix to go from view coordinat system to world woordinate
         *  system.
         */

        MAinvmx (rc, &dimension, vwmat, vwmat);
    
        /*
         *  Take points to world coordinate system
         */

        number_points = 8;
        MAptsxform (rc, &number_points, vwmat, points, points);

        /*
         *  Take boreline to world coordinate system
         */

        number_points = 2;
        MAptsxform (rc, &number_points, vwmat, line_pt, line_pt);

        /*
         *  accumulate high's and low's
         */

        /*
         *  This loop is for regular ranges.
         */

        for (jj = 0; jj < 3; jj++)    /* for x,y,z coordinate */
        {
            min = max = points[jj];
            for (ii = 0, kk = jj; ii < 8; ii++, kk += 3)
            {
                min = ( points[kk] < min ) ? points[kk] : min;
                max = ( points[kk] > max ) ? points[kk] : max;
            }
            bl_loc_params.upd_range[jj] = min;
            bl_loc_params.upd_range[jj + 3] = max;
        }

        /*
         *  This loop is for skew scans
         */

        for (jj = 0; jj < 3; jj++)    /* for x,y,z coordinate */
        {
            min = max = points[jj];
            for (ii = 0, kk = jj; ii < 4; ii++, kk += 3)
            {
                min = ( points[kk] < min ) ? points[kk] : min;
                max = ( points[kk] > max ) ? points[kk] : max;
            }
            bl_loc_params.skew_range[jj] = min;
            bl_loc_params.skew_range[jj + 3] = max;
        }

        locate_type = GR_bl_loc;
        locate_params = (IGRchar*)&bl_loc_params;
    }
    else if (act_ptr->type == GR_pt_loc)
    {
        /*
         *  Set up structure for LCquery.
         */

        pt_loc_params.datapoint.x = event1->event.button.x;
        pt_loc_params.datapoint.y = event1->event.button.y;
        pt_loc_params.datapoint.z = event1->event.button.z;
        
        pt_loc_params.datapoint.objid = stack->window.objid = 
                                    event1->event.button.objid;
        stack->module = mod->md_id;
        pt_loc_params.datapoint.osnum = stack->window.osnum = mod->md_id.osnum;
        pt_loc_params.obj_attr = *attributes;


        /*
         *  Ask the window to calculate the range.
         */

        *rc = om$send (mode = OM_e_wrt_object, 
                       msg = message IGEgragad.DPrngbox
                            (&msg, &pt_loc_params.datapoint.x, 
                             &pt_loc_params.datapoint.y, 
                             &pt_loc_params.datapoint.z, 
                             tolerance, &(pt_loc_params.upd_range[0])), 
                       senderid = NULL_OBJID, 
                       targetid = pt_loc_params.datapoint.objid, 
                       targetos = pt_loc_params.datapoint.osnum);
        if (!(1&*rc))
        {
            om$report_error(sts = *rc);
            *rc = 0;
            return (0);
        }
        else if (!(1&msg))
        {
            *rc = 0;
            return (0);
        }

        pt_loc_params.tolerance = pt_loc_params.upd_range[0] /
                                  pt_loc_params.datapoint.x ;

        locate_type = GR_pt_loc;
        locate_params = (IGRchar*)&pt_loc_params;
    }

    if (locate_params)
    {
        /* invoke the scan through the rtree */
            
        sts = LCquery(rc, mod, &locate_type, locate_params,
                      action_handler, act_args, classptr, NULL, locate_args);
    }
    else
    {
        /* invalid args */
        *rc = MSINARG;
        sts = FALSE;
    }

    return(sts & 1);
}
end implementation Root;
