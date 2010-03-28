/* #######################    APOGEE COMPILED   ######################## */

class implementation Root;

/*
Abstract
	This function will get the geom_parms of a particular
	grapics object.  Types currently supported are true projection
	and apparent projection.

History
	7/20/87	Started documentation.
  scw  07/13/92 Ansi conversion

*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "dpdef.h"
#include "dp.h"
#include "exdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "lcdef.h"
#include "lc.h"
#include "msdef.h"
#include "dpmacros.h"

from GRgraphics import GRptproject;
from GRgraphics import GRlnproject;
from GRgraphics import GRapprojpt;

LCget_parms (x, y, z, type, proj_objid, proj_osnum, window_id, window_os,
             proj_point, geom_parms, matrix_type, matrix)
IGRdouble      x,
               y,
               z;
IGRint         type;
OM_S_OBJID     proj_objid, 
               window_id;
OMuword        proj_osnum, 
               window_os;
IGRpoint       proj_point;
IGRshort       matrix_type;
IGRmatrix      matrix;
struct GRparms *geom_parms;
{
IGRint           ret_code = 1;
IGRlong          sts,
                 retb1,
                 which_error,
                 msg;
IGRdouble        vwmat[16];
IGRpoint         pt,
                 pt1,
                 pt2;
struct GRparms   temp_parms;
struct var_list  list_var[2];
struct IGRline   line;

    pt[0] = x;
    pt[1] = y;
    pt[2] = z;

/*
 *	This is the case taken for a point projection.  This occurs when
 *	a point locate is being done.
 */

    if (type == LC_PTPROJECT) {
        sts = om$send (mode = OM_e_wrt_object, 
                 msg = message GRgraphics.GRptproject (&msg, 
                       &matrix_type,
                        matrix, 
                        pt,
                        proj_point,
                        geom_parms), 
                 senderid = NULL_OBJID,
                 targetid = proj_objid,
                 targetos = proj_osnum);

         if (!(1&sts)) {
             om$report_error (sts = sts);
             ret_code = 0;
             goto ERROR_WRAP;
         }
    }

/*
 *	In the remaining two cases the view rotation matrix is needed to form
 *	the boreline that is projected onto the element.  So inquire this
 *	from the window.
 */

    else {
        list_var[0].var            = VIEW_ROTATION;
        list_var[0].var_ptr        = (IGRchar *)vwmat;
        list_var[0].num_bytes      = sizeof(IGRdouble)*16;
        list_var[0].bytes_returned = &retb1;

        list_var[1].var            = END_PARAM;
        list_var[1].var_ptr        = NULL;
        list_var[1].num_bytes      = 0;
        list_var[1].bytes_returned = NULL;
  
        sts = dp$inq_set_gragad (msg = &msg,
                osnum = window_os,
                gragad_objid = window_id,
  	        which_error = &which_error,
	       var_list = list_var);

        if (!(1&sts)) {
            ret_code = 0;
            goto ERROR_WRAP;
        }
 
        line.point1 = pt1;
        line.point2 = pt2;

        MAbrlnconstr (&sts, pt, vwmat, &line);

/*
 *	This type is taken in case of a boreline locate and a segment
 *	highlight request.  It will project the line onto the element or
 *	any of its extensions.
 */

        if (type == LC_APPARENT) {
            sts = om$send (mode = OM_e_wrt_object,
                 msg = message GRgraphics.GRapprojpt (&msg,
                       &matrix_type,
                        matrix,
                        geom_parms,
                       &line,
                        proj_point,
                       &temp_parms),
                 senderid = NULL_OBJID,
                 targetid = proj_objid,
                 targetos = proj_osnum);

            if (!(1&sts)) {
                om$report_error (sts = sts);
                ret_code = 0;
                goto ERROR_WRAP;
            }
            *geom_parms = temp_parms;        
        }

/*
 *	This case is take in case of a boreline locate and an element 
 *	highlight.  This will project the point onto the element.
 */

        else {
        IGRdouble              t;
            sts = om$send (mode = OM_e_wrt_object, 
                 msg = message GRgraphics.GRlnproject (&msg, 
                       &matrix_type,
                        matrix, 
                       &line,
                        pt,
                        proj_point,
                       &t,
                        geom_parms), 
                  senderid = NULL_OBJID,
                  targetid = proj_objid,
                  targetos = proj_osnum);

             if (!(1&sts)) {
                 om$report_error (sts = sts);
                 ret_code = 0;
                 goto ERROR_WRAP;
             }
        }
    }
ERROR_WRAP:
    return (ret_code);
}

end implementation Root;
