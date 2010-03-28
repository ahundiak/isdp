/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract:
	This method creates a new object parallel to the 
  	original object.

Synopsis

 GRcpparallel(IGRlong *msg; IGRshort *mx_type, 
	IGRmatrix matrix; struct GRmd_env *offset_env;
	struct IGRline *direction_boreline; 
	struct IGRline *distance_boreline; 
	IGRdouble *distance; IGRboolean *apparent_flag;
     	IGRmatrix projection_matrix; GRobjid *objid)

	IGRlong *msg; 			return message
	IGRshort *mx_type, 		matrix type of original object
	IGRmatrix matrix; 		matrix for original object
	struct GRmd_env *offset_env;	environment for offset
	struct IGRline *direction_boreline; 
					boreline to indicate direction
					of offset
	struct IGRline *distance_boreline; 
					boreline to indicate distance 
					for offset ( send NULL pointer
					if sending distance)
	IGRdouble *distance; 		distance for offset (send NULL
					if sending distance_boreline)	
	IGRboolean *apparent_flag;	flag to indicate if the offset 
					is to be apparent
					 1 - do apparant offset
					 0 - offset in plane of element
     	IGRmatrix projection_matrix;   matrix to use for apparent offset
			NOTE: non-planar elements will always be an
			      apparent offset
	GRobjid *objid   	      	offset object's id

Description

	This method does a copy parallel of an object.  If the object
 	is not planar or the mode is apparent offset, the object will
	be flattened using the projection matrix before the offset 
	is done.  If the object is planar and the apparent flag is
	not set, the offset will be in the plane of the element.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
     	MSFAIL - error occured

Notes
	None.
History
	MAS  	08/04/88 	Design date.

*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "mapriv.h"
#include "godef.h"
#include "gocmacros.h"
#include "grownmacros.h"
#include "bsparameters.h"
#include "bserr.h"

extern    IGRboolean    MAdetplane();
extern	  IGRboolean	MAptsxform();
extern	  IGRboolean	MAlnbcproj();
extern	  IGRboolean	MAlnplproj();
extern	  IGRboolean	MAunitvc();

#define DIR_NOT_KNOWN 0
#define NO_FILLET 0
#define NO_LOOPS 2

method  GRcpparallel(IGRlong *msg; IGRshort *mx_type;
	IGRmatrix matrix; struct GRmd_env *offset_env;
	struct IGRline *direction_boreline; 
	struct IGRline *distance_boreline; 
	IGRdouble *distance; IGRboolean *apparent_flag;
     	IGRmatrix projection_matrix; GRobjid *objid)
{
    IGRchar 	*absgptr;		/* abstract geometry pointer	*/
    IGRshort	chan_flag,
		del_flag,
                new_props;

    IGRboolean  right;
    IGRboolean  b_status;

    IGRlong	OMmsg;			/* OM return value		*/
    IGRlong 	msg1;			/* local completion code	*/
    IGRlong 	bsrc;

    IGRint  	name;
    IGRint 	i;			/* loop counter			*/

    IGRdouble	u,t;
    IGRdouble 	tol,			/* planarity tolerance		*/
		dist;

    IGRpoint	curve_pt,
		line_pt,
		plane_pt,
		normal,
		in_norm,
		dir_pt;

    IGRchar 	classname [OM_K_MAXCLASS_LEN]; 

    struct IGRbsp_curve *curve,		/* pointer to B-spline curve	*/
		*offset_curve;

    struct IGRplane plane;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;
    offset_curve = NULL;

    GRgetabsg(&msg1,mx_type,matrix,&absgptr,i);
    
    if ( 1 & msg1)
    {
	curve = (struct IGRbsp_curve *) absgptr;
	
	name = BSTOLLENVEC;
	BSxtractpar(&bsrc,name,&tol);

    	if( bsrc == BSSUCC )
    	{
	    plane.point = plane_pt;
	    plane.normal = normal;

	    b_status = MAbcunweight(msg,curve);
     	    if ( (! curve->planar) || *apparent_flag)
	    {
	    	if (MAptsxform(msg,&curve->num_poles,projection_matrix,
			curve->poles,curve->poles))
		{
	    	    MAdetplane(msg,&curve->poles[0],
			&curve->num_poles,&tol,&plane);
		   
		    curve->planar = 1;
		}
	    }
	    else
	    {
	    	MAdetplane(msg,&curve->poles[0],&curve->num_poles,
			&tol,&plane);
	    }	
	    if ( ! ( 1 & *msg))
	    {
	        OMmsg = OM_E_ABORT;
	 	goto wrapup;
	    }

	    /* if the user has not sent in a distance, compute the 
	     * distance for offset.
	     */

	    b_status = MAbcweight(&msg1,curve); 
	
	    if ( ! distance)
	    {
		/* project to the flattened B-spline
		 */

        	if (MAlnbcproj(msg,distance_boreline,curve,&tol,
			line_pt,curve_pt,&t,&u) )
		{
		    MA2ptdis(msg,line_pt,curve_pt,&dist);
		}
		else
		{
		    *msg = MSFAIL;
		    OMmsg = OM_E_ABORT;
		    goto wrapup;
		}
	    }
	    else
	    {
		dist = *distance;
	    }	

	    /* now determine the offset direction point as needed
	     * by the math routine. Project the direction boreline
	     * to the plane of the element.
	     */
		
	    if (!MAlnplproj(msg,direction_boreline,&plane,line_pt,dir_pt,
			&t))
	    {
		*msg = MSFAIL;
		OMmsg = OM_E_ABORT;
		goto wrapup;
	    }

	    /* call the routine to produce the offset curve
	     */

	    BScvoffsetd(curve,dist,dir_pt,DIR_NOT_KNOWN,NO_FILLET,
		NO_LOOPS,&right,in_norm,&offset_curve,&i,NULL,&bsrc);

	    if (bsrc != BSSUCC)
	    {
		*msg = MSFAIL;
		OMmsg = OM_E_ABORT;
		goto wrapup;
	    }

	    /* construct the new offset curve
	     */

	    om$get_classname(objid = my_id,
		classname = classname);

            /* clear the not-in-rtree and symbology override bits and set
             * the new bit as is done in the method GRcopy
             */

            new_props = me->properties & ~(GRNOT_IN_RTREE | DEHAS_OVERRIDE) |
                        GRIS_NEW;
	    chan_flag = FALSE;
	    del_flag = FALSE;

	    GRchgclass(msg, offset_env, &my_id, classname, &new_props,
			offset_curve, &chan_flag, &del_flag, objid);

            if ( 1 & *msg)
	    {
	        gr$add_to_active_owner(	msg = msg,
					mod_env = offset_env,
					objid = *objid);
		
	        if (! (1 & *msg))
	        {
			*msg = MSFAIL;
	  		OMmsg = OM_E_ABORT;
	    	}	    
	    }
	    else
	    {
		*msg = MSFAIL;
	  	OMmsg = OM_E_ABORT;
	    }	    
	}
	else
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	}
    }
    else
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
    }

wrapup:

    GRabsg_del_all();			/* clear the cache		*/

    if (offset_curve)			/* dealloc the curve		*/
    {
	BSfreecv(&msg1,offset_curve);
    }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_COPIED);

    return(OMmsg);
}

end implementation GRbspline;
