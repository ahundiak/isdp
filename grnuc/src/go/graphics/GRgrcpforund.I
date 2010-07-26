/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRgraphics

     METHOD NAME:  GRcpforundo

     Abstract:  This method makes a copy of the object
		and saves all information about it for
		undo.

-----
%SC%    

    GRcpforundo ( msg, obj_env, new_env, delete, new_objid )

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *obj_env	struct GRmd_env	 evironment information for object

     *new_env	 struct GRmd_env environment info of new object

     *delete    IGRboolean	 flag indicating operation being
				 performed on object
				 0 - not delete
			  	 1 - delete

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

     *new_objid  struct GRid	 object id of copied object
				 if NULL, the method failed

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  none.

     Methods:  GRremwrng
	       copy_chan
-----
%RL%

     RELATIONS REFERENCED:  to_cpx
			    owners
-----
%NB%

     NOTES:  If new_objid returns with a NULL value,
	     then the copy of the original could not
	     be completed successfully.
-----
%CH%

     CHANGE HISTORY:
	
	KMO     02/12/87 : Design date.
	KMO	02/12/87 : Creation date.
        HGB     07/06/93 : Don't return failure if the owner channel is empty
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	The object is saved for undo in one of two ways.

		1)  If the delete flag is set, then the
		    object is left in the object space
		    but taken out of the R-tree.

		2)  If the delete flag is not set, then
		    the object is copied including all
		    of its channel connections.  The
		    original object is taken out of the
		    R-tree and the copy is not put in the
		    R-tree.

----*/
/*EH*/

class implementation GRgraphics;

#include "grimport.h"
#include "msdef.h"

method GRcpforundo(IGRlong *msg; struct GRmd_env *obj_env, *new_env;
	         IGRboolean *delete; GRobjid *new_objid)
{

	IGRlong		status;		/* OM return code         */
	OM_S_CHANSELECT chan_sel;

/*
 *  initialize completion codes
 */

	*msg = MSSUCC;
	status = OM_S_SUCCESS;
	*new_objid = NULL;

/*
 *  remove the object from the R-tree
 */

	status = om$send ( mode = OM_e_wrt_object,
			   msg = message GRgraphics.GRremwrng ( msg, obj_env ),
			   senderid = my_id,
			   targetid = my_id );

/* 
 *  determine how to save the object
 */

	if ( 1 & status )
	{
	    if ( *delete )
	    {
	        /*
	         *  the object is being deleted,
	         *  therefore just return its id
	         */

		*new_objid = my_id;
	    }
	    else
	    {
	        /*
	         *  the object is being saved for an operation
	         *  other than delete; therefore, make a copy
	         *  of the original object, copy the channel
	         *  connections of the original object to the
		 *  new object
	         */	    
	
		status = om$construct_and_copy ( objid = my_id,
			 obj_osnum = obj_env->md_id.osnum,
			 osnum = new_env->md_id.osnum,
			 p_objid = new_objid );

		if ( 1 & status )
		{

		    /*
		     *  copy the "to_owner" channel connections
		     */

		    chan_sel.type = OM_e_name;
		    chan_sel.u_sel.name = "GRconnector.to_owner";

		    status = om$send ( mode = OM_e_wrt_object,
				       msg = message Root.copy_chan (
				             chan_sel, my_id,
					     obj_env->md_id.osnum,
					     chan_sel ),
				       senderid = my_id,
				       targetid = *new_objid,
				       targetos = new_env->md_id.osnum );
				       
                    /*
                     * An empty channel should return success; it is ok
                     * not to have an owner.
                     */
                    if (status == OM_E_INVCHAN)
                      status = OM_S_SUCCESS;
		}
	    }
	}	

	return(status);
}

end implementation GRgraphics;
