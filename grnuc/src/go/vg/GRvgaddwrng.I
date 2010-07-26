/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRvg

     METHOD NAME:  GRaddwrng

     Abstract:   This method adds an object to the R-tree
		 with respect to its range.

-----
%SC%    

     GRaddwrng ( msg, md_env )

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env	  struct GRmd_env  object's environment information

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure


-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  none.

     Methods:  GRgetrange
	       GRownaddwrng
	       GRmdaddwrng

-----
%RL%

     RELATIONS REFERENCED:  to_cpx

-----
%NB%

     NOTES:  none

-----
%CH%

     CHANGE HISTORY:
	
	KMO     02/10/87 : Design date.
	KMO	02/10/87 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method gets the range of the object and then
	adds the object to the R-tree with respect to its
	range.  If the object has an owner, the owner is
	notified to add the object to the R-tree.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "OMmacros.h"

method GRaddwrng(IGRlong *msg; struct GRmd_env *md_env)
{

    IGRboolean	world = FALSE;	/* indicates don't apply env matrix */
    IGRlong	OMmsg;		/* OM return status		    */
    GRrange	range;		/* range of object		    */


    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    if ( ! ( IF_NULL_OBJID(md_env->md_id.objid) ||
            (me->properties & GRNOT_IN_RTREE)))
    {
	/*
	 *  get the range of the object
 	 */

	OMmsg = om$send ( mode = OM_e_wrt_object,
			   msg = message GRvg.GRgetrang ( msg,
				 &md_env->md_env.matrix_type,
				 md_env->md_env.matrix, &world, range ),
			   senderid = my_id,
			   targetid = my_id );

	if ( (1 & OMmsg) )
	{
	    /*
	     *  Check for owner, the owner will add the object to 
	     *  the R-tree. The function adds the object to the 
	     *  rtree if the owner does not. 
 	     */

	    OMmsg = GRowneradd(msg,md_env,&my_id,&md_env->md_id.osnum,
		range);
	}
    }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_RTREE_MANIPULATION);

    return(OMmsg);
}
end implementation GRvg;
