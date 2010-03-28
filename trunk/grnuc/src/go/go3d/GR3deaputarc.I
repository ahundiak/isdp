/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GR3dellarc
     METHOD NAME:  GRpostabsg

     Abstract: 
		This method posts the instance data for	a 3-D double 
		precision version of a elliptical arc object.  The
		input to this routine includes a transformation 
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

-----
%CH%

     CHANGE HISTORY:

	MAS	10/07/87 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method applies the input transformation matrix
	(if it is not an identity matrix) to the input 
	elliptical arc.  The object is checked to be certain the
	range is within the design file limits.

	The object will be reinserted into the
	R-tree.

----*/
/*EH*/

class implementation GR3dellarc;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "grerr.h"
#include "mapriv.h"
#include "godef.h"
#include "gocmacros.h"

method GRputarc(IGRlong *msg; struct GRmd_env *md_info;
	struct GRpost_info *post_info; struct IGRarc *arc; 
	GRobjid *newobjid)
{
    IGRlong             OMmsg;		/* return status for method	*/

    struct IGRarc   	new_arc;	/* arc				*/

    OMmsg = OM_S_SUCCESS;		/* initialize variables		*/
    *msg = MSSUCC;

    *newobjid = my_id;   		/* assume class will not change */

 					/* transform to local coordinates*/
    OMmsg = GRxformarc(msg,&md_info->md_env.matrix_type,
		md_info->md_env.matrix,arc,&new_arc);

    if ( 1 & OMmsg & *msg)
    {
					/* update range			*/
	OMmsg = GRcnupdrange(msg,NULL,&new_arc,md_info,post_info,
		&me->properties,&my_id);

	if ( 1 & OMmsg)
	{				/* load instance data		*/
	    OMmsg = GRload3dconic(msg,&new_arc,me->origin,me->rot_matrix,
		&me->start_angle,&me->sweep_angle,&me->prim_axis,
		&me->sec_axis,&me->properties,post_info);
	}
    }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_POSTED);


    return(OMmsg);
}
end implementation GR3dellarc;
