/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "gr.h"
#include "godef.h"
#include "madef.h"
#include "go.h"
#include "mapriv.h"

GRload3dconic(msg,new_arc,origin,rot_matrix,start_angle,sweep_angle,
	prim_axis,sec_axis,properties,post_info)

IGRlong		*msg;
struct IGRarc   *new_arc;
IGRdouble	*origin;
IGRmatrix	rot_matrix;
IGRdouble	*start_angle;
IGRdouble	*sweep_angle;
IGRdouble	*prim_axis;
IGRdouble	*sec_axis;
IGRshort	*properties;
struct GRpost_info *post_info;
{
    IGRlong	OMmsg;
    IGRint	i;

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    if (! post_info->construct_flag)
    {
	*properties |= GRIS_MODIFIED;
    }

    *properties |= GRIS_PLANAR;
    if (start_angle && sweep_angle)
    {
	if ( MAabsolute (new_arc->sweep_angle - new_arc->start_angle)
	            < (2 * PI))
	{
	    *properties = *properties & (~ GRFILLED_DISPLAY);
	}
    }	   

    for (i =0; i < 3; ++i)		/* assign origin and matrix	*/
    {
	origin[i] = new_arc->origin[i];
	rot_matrix[i] = new_arc->rot_matrix[i];
	rot_matrix[i+3] = new_arc->rot_matrix[i+4];
	rot_matrix[i+6] = new_arc->rot_matrix[i+8];
    }
    if (start_angle)
    {
	*start_angle = new_arc->start_angle;
    }
    if (sweep_angle)
    {
	*sweep_angle = new_arc->sweep_angle;
    }
    if (prim_axis)
    {
	*prim_axis = new_arc->prim_axis;
    }
    if (sec_axis)
    {
	*sec_axis = new_arc->sec_axis;
    }

    return(OMmsg);
}
