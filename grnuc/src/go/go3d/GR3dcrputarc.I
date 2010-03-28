/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GR3dcircle
     METHOD NAME:  GRpostabsg

     Abstract: 
		This method posts the internal geometric
		representation for a circle into the
		instance data for a 3-D double precision
		version of a circle object.  The input to
		this routine includes a transformation 
		matrix that may be applied to the object
		before posting.
-----
%SC%    
	GRputarc(msg,md_info,post_info,absptr,newobjid)     
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_info    struct GRmd_env    structure defining the environment
					information
     *post_info  struct GRpost_info processing control information
     *arc    	struct IGRarc	    the arc to be posted 
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
       *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - GRSNOINVTRAN (severe) if input
				      matrix is not invertible
				    - GRSDGNEXCEED (severe) if range
				      exceeds design limits
				    - MSFAIL (severe) if failure
     *newobjid    GRobjid	 object id after posting new geometry
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:

     Methods:
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  If a failure occurs, the object's 
	     instance data will not be modified

	     If the circle becomes non-circular, a
	     new object is constructed for a GR3dellipse.
	     The GR3dcircle object is deleted.  Any
	     channel linkages will be moved to include
	     the new object.  The new object id will be
	     returned. 
-----
%CH%
     CHANGE HISTORY:

	MAS	10/07/87 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
This method applies the input transformation matrix (if it is not
an identity matrix) to the circle.  The geometry is checked to 
be certain it is still circular and if its range is within the
design file limits. If so, is posted into the instance data for 
the 3-D floating point circle.  

If it is no longer circular, a 3-D  ellipse (GR3dellipse) will be 
constructed.  The object id of this new object will be returned.

For both cases, the object will be reinserted into the r-tree if
the module id is not NULL_OBJID.

----*/
/*EH*/

class implementation GR3dcircle;

#include "grimport.h"
#include "madef.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "grerr.h"
#include "mapriv.h"

method GRputarc(IGRlong *msg; struct GRmd_env *md_info;
	struct GRpost_info *post_info; struct IGRarc *arc; 
	GRobjid *newobjid)
{
    IGRlong             OMmsg;		/* return status for method	*/

    struct IGRarc   	new_arc;	/* arc				*/

    IGRshort		chan_flag = 1;  /* indicator to preserve	*/
					/* channel linkages		*/
    IGRshort 		del_flag = 1;	/* indicator to delete orig obj */
    IGRdouble		roundoff = MAETA * 100000;

    OMmsg = OM_S_SUCCESS;		/* initialize variables		*/
    *msg = MSSUCC;

    *newobjid = my_id;   		/* assume class will not change */

 					/* transform to local coordinates*/
    OMmsg = GRxformarc(msg,&md_info->md_env.matrix_type,
		md_info->md_env.matrix,arc,&new_arc);

    if ( 1 & OMmsg & *msg)
    {
       	/*
	 *  check to see if object needs to change class
 	 * 
 	 *  if so,
 	 *	- if construct flag set, alter data and continue as normal
 	 *	- otherwise, construct a new object 
 	 *		- transfer all channel linkages to new object
 	 *		- delete original object
 	 */
	
	if ( new_arc.prim_axis != new_arc.sec_axis )
	{
	    if ((post_info->construct_flag) ||
		(MAabsolute(new_arc.prim_axis - new_arc.sec_axis) 
		    < roundoff * new_arc.prim_axis))
	    {
		/* if the object is being constructed or if the axis
		 * lengths are within tolerance of being equal,
		 * force the object to remain circular.
		 */

	        new_arc.prim_axis = new_arc.sec_axis =
		    (new_arc.prim_axis + new_arc.sec_axis) / 2;
	    }
	    else
	    {
		OMmsg = GRaltchgclass(msg,md_info,&my_id,"GR3dellipse",
		    &me->properties,arc,&chan_flag,&del_flag,newobjid);

		goto wrapup;
	    }
	}
					/* update range			*/
	OMmsg = GRcnupdrange(msg,me->origin,&new_arc,md_info,post_info,
		&me->properties,&my_id);

	if ( 1 & OMmsg)
	{				/* load instance data		*/
	    OMmsg = GRload3dconic(msg,&new_arc,me->origin,me->rot_matrix,
		NULL,NULL,&me->radius,NULL,&me->properties,post_info);
	}
    }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_POSTED);

wrapup:
    return(OMmsg);

}
end implementation GR3dcircle;
