/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRclippoly
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
	
	MAS	03/19/86 : Creation date.
	MAS     03/27/86 : Design date.
        dhm     07/01/92 : ANSI conversion.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method copies the input object and transforms
	the copy using the input transformation matrix.
----*/
/*EH*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"

method GRcptform(IGRlong *msg; struct GRmd_env *obj_dsenv;
	 	 IGRmatrix matrix; struct GRmd_env *new_dsenv;
		 GRobjid *newobjid)
{
    IGRlong	OMmsg;			/* method return status */

    OM_S_CHANSELECT chan;

    GRobjid 	ref_objid;

    /* initialize variables */

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    OMmsg = om$make_chanselect(
	channame = "GRclippoly.to_attachment",
        p_chanselect = &chan);

    /* send the GRcptform message to the reference file and let
     * it handle the operation.  A copy operation applies to 
     * both objects.
     */

    if ( 1 & OMmsg)
    {
	OMmsg = om$send (
	    msg = message GRgraphics.GRcptform(msg,obj_dsenv,
		matrix,new_dsenv,&ref_objid),
	    p_chanselect = &chan,
	    from = 0,to = 0);

	if ( 1 & OMmsg)
	{
	    OM_S_OBJECT_LINKAGE list;
	    IGRuint	i;

	    chan.type = OM_e_name;
	    chan.u_sel.name =  "GRreffile.to_clip";

	    om$get_channel_objects(objid = ref_objid,
		p_chanselect = &chan,
	   	list = &list,
		size  = 1,
		count = &i);

	    *newobjid = list.S_objid;
	}	   
    }
    else
    {
	*msg = MSFAIL;
    }

    return(OMmsg);
}

end implementation GRclippoly;
