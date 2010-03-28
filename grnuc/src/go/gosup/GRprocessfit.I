/* #######################    APOGEE COMPILED   ######################## */
class implementation GRlinear;

#include  "grimport.h"
#include  "igrdef.h"
#include  "msdef.h"
#include  "godef.h"
#include  "madef.h"
#include  "dpmacros.h"
#include  "dperr.h"
#include  "dpdef.h"

GRprocessfit(msg,type,matrix,sp_info,key,inf_line,linear,objid)

IGRlong *msg; 
IGRshort *type; 
IGRmatrix matrix;
struct DP_information *sp_info; 
OM_p_KEY_DESC key;
IGRint  inf_line;
IGRint  linear; 	
GRobjid *objid;
{
    IGRchar    *ptr;			/* pointer			*/

    IGRlong    OMmsg;			/* OM return value		*/

    IGRlong    i;			/* loop index			*/

    IGRint     action;

    IGRdouble  points[1500],
	       *range_ptr;

    GRrange    range;
 
    struct     DPele_header ele_header;	/* pointer to the structure for
					   display function		*/
    struct     IGRpolyline  py;
    struct     IGRbsp_curve *curve;

    extern IGRboolean MApyextents();	/* extents of polyline		*/
    extern IGRboolean GRtransrange();	/* translate range		*/

    *msg = MSSUCC;			/* initialize return codes	*/
    OMmsg = OM_S_SUCCESS;
    range_ptr = NULL;
					/* get range in proper format	*/
    if ( (key ) && (*type == MAIDMX) && (!inf_line) )
    {
	if (GRtransrange(msg,key,range))
	{
	    range_ptr = range;
	}
    }
    else
    {
	if (linear)
	{
	    if (GRabsg_test(msg,type,matrix,&OM_Gw_current_OS,objid,
		&ptr))
	    {
	        curve = (struct IGRbsp_curve *) ptr;
	    	py.points = curve->poles;
	    	py.num_points = curve->num_poles;
	    }
	    else
	    {
	    	py.points = points;
	    	py.num_points = 500;

			/* flag to indicate array sent in	*/
	    	action = 2;
	
	    	OMmsg = om$send(msg = message GRlinear.GRgetpolyline(
			msg,type,matrix,&action,&py),
		    senderid = *objid,
	    	    targetid = *objid);

	    }
    	    if ( (py.points) && (1 & OMmsg & *msg))
	    {
	    	if ( py.num_points < 2)
	    	{
		    for (i = 0; i < 3; ++i)
		    {
		    	points[i] = points[i+3] = py.points[i];
		    }
		    py.num_points = 2;
		    py.points = points;
	    	}
		else if (inf_line)
		{
		    py.num_points = 2;
		    py.points = &py.points[3];
		}

      		MApyextents(msg,&py,range,&range[3]);

		range_ptr = range;
	    }
	}
	if (!range_ptr)
	{
	    IGRboolean world = TRUE;

	    OMmsg = om$send
	    	(msg = message GRvg.GRgetrang
			(msg,type,matrix,&world,range),
		senderid = *objid,
	     	targetid = *objid);

	    if ( 1 & OMmsg & *msg)
	    {
		range_ptr = range;
	    }
    	}
    }
    if (range_ptr)
    { 
	enum GRdpmode mode = GRbd;

    	dp$build_dis_buffer(buffer = &ele_header,
	    geometry = NULL,
	    display_att = NULL,
	    range = range_ptr,
	    level = NULL);
		
        dp$dispelem(msg = msg, 
	    buffer = &ele_header, 
	    mode = mode, 
	    dp_info = sp_info);
    }
    else 
    {
	OMmsg = OM_E_ABORT;
	*msg = MSFAIL;
    }


    return (OMmsg);
}
end implementation GRlinear;
