/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRreffile
     METHOD NAME: GRcptform

     Abstract: 
		This method copies and transforms an object.
-----
%SC%    

     GRcptform(msg,md_env,matrix,new_dsenv,newobjid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env	  GRmd_env	 original object's context info
     matrix	  IGRmatrix	 transformation matrix to be applied
				 to copy
     *new_dsenv   GRmd_env	 copied object's context info
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     *newobjid    GRobjid	 object id of copy
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:   none.

     Methods:	GRcopy
		GRxform
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  none.

-----
%CH%

     CHANGE HISTORY:
	
	KMO	03/19/86 : Creation date.
	KMO     03/27/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method copies the input object and transforms
	the copy using the input transformation matrix.
----*/
/*EH*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"

method GRcptform(IGRlong *msg; struct GRmd_env *obj_dsenv;
	 	 IGRmatrix matrix; struct GRmd_env *new_dsenv;
		 GRobjid *newobjid)
{
    IGRshort	mx_type;

    IGRlong	status;			/* method return status */

    GRobjid	new_reffile;

    struct GRmd_env local_env;


    /* initialize variables */

    *msg = MSSUCC;
    status = OM_S_SUCCESS;

    local_env = *new_dsenv;
    local_env.md_id.objid = NULL_OBJID;

    /* copy messaage will cause the GRclippoly and the GRreffile
     * objects to be copied. Do not put them in the R-tree.
     */

    status = om$send(mode = OM_e_wrt_object,
        msg = message GRgraphics.GRcopy
		(msg,obj_dsenv,&local_env,&new_reffile),
        senderid = my_id,
        targetid = my_id);

    if (status & 1 & *msg)
    {	
	/* xform the reffile object
	 */

	MAtypemx(msg,matrix,&mx_type);

    	status = om$send(mode = OM_e_wrt_object,
             	msg = message GRgraphics.GRxform
		    (msg,&local_env,&mx_type,matrix,newobjid),
             	senderid = my_id,
                targetid = new_reffile,
                targetos = local_env.md_id.osnum);

	if ( 1 & status & *msg)
	{
   	    status = om$send(
		    msg = message GRgraphics.GRaddwrng(msg,new_dsenv),
		    targetid = *newobjid,
		    targetos = new_dsenv->md_id.osnum);
	}
    }

    return(status);
}

end implementation GRreffile;
