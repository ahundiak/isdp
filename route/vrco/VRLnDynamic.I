/* $Id: VRLnDynamic.I,v 1.1.1.1 2001/01/04 21:12:42 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco / VRLnDynamic.I
 *
 * Description:
 *	dynamic display of a pipe segment.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRLnDynamic.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/16  21:27:42  pinnacle
# Replaced: vrco/VRLnDynamic.I for:  by r240_int for route240
#
 *
 * History:
 *	02/11/89	momo	Design date
 *	01/15/96	tlb	Change VRline_params, VRLineDyn to static
 *
 *************************************************************************/

class implementation Root;

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igewindow.h"
#include "igrdef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "OMmacros.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "bstypes.h" 
#include "bsnorvec.h" 

#define VECT_SIZE 40
#define AS_DEBUG


static struct VRline_params 
{
  IGRdouble	          *LastPt;
  struct DPele_header     *header_line;
};


/*************************************************************************/

static
IGRint VRLineDyn( VRinfo,point,matrix,objects,num_objects,buffers,num_buffers,
                  dummy_in1,dummy_in2,dummy_in3,dummy_out1,dummy_out2,
                  dummy_out3 )

struct 		VRline_params	*VRinfo;
struct 		EX_button      	*point;
IGRdouble                   	*matrix;
struct 		GRid           	**objects;
IGRint                     	*num_objects;
struct 		DPele_header  	**buffers;
IGRint                       	*num_buffers;
IGRchar                      	*dummy_in1;
IGRchar                      	*dummy_in2;
IGRchar                      	*dummy_in3;
IGRchar                      	**dummy_out1;
IGRchar                      	**dummy_out2;
IGRchar                      	**dummy_out3;

{
IGRint			i, msg, status;    
IGRdouble		view_scale, vect_size, cur_pt[3], dNormal[3];
IGRlong 		which_error, bytes_returned;
struct 	win_var_list	var_list[2];
BSrc			rc;

var_list[0].var            = VVOL_VIEWPORT_SCALE;
var_list[0].var_ptr        = ( char *) &view_scale;  
var_list[0].num_bytes      = sizeof( IGRdouble );
var_list[0].bytes_returned = &bytes_returned;
var_list[1].var = END_PARAM;

status = dp$inq_set_gragad ( msg          = &msg,
			   osnum        = point->osnum,
			   gragad_objid = point->objid,
			   which_error  = &which_error,
			   var_list     = var_list );
as$status( action = RET_STATUS );

vect_size = VECT_SIZE / view_scale;


cur_pt[0] = point->x;
cur_pt[1] = point->y;
cur_pt[2] = point->z;
for (i=0;i<3;i++)
    dNormal [i] = cur_pt [i] - VRinfo->LastPt [i];
BSnorvec (&rc, dNormal);

for(i=0; i<3; i++ )
    {
    VRinfo->header_line->geometry.polyline->points[i]   = VRinfo->LastPt[i];
    VRinfo->header_line->geometry.polyline->points[i+3] =
	VRinfo->LastPt [i] + vect_size * dNormal [i];
    }

*buffers     = VRinfo->header_line;
*num_buffers = 1;

return OM_S_SUCCESS;

}

/****************************************************************************/

IGRint VRBlinear( LastPt, display )

IGRdouble		*LastPt;          
struct IGRdisplay       *display;          
{
IGRint		VRLineDyn (), i;
IGRdouble                  	pt_buffer[6];
struct       	IGRpolyline     polyline;
struct 	DPele_header	element;     
struct 	VRline_params	VRinfo;       
struct IGRdisplay	Display;


Display = *display;
Display.weight = 3;
polyline.num_points = 2;
polyline.points     = pt_buffer;

dp$build_dis_buffer(buffer      = &element,
		  type        = IGRPY,
		  display_att = &Display,
		  geometry    = &polyline );

VRinfo.header_line       = &element;
VRinfo.LastPt            = LastPt;

dp$dynamics( dyn_fun     = VRLineDyn,
	   information = &VRinfo );

} /* end function VRBlinear */

end implementation Root;


