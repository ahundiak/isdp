/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: 	GRlbsys
     METHOD NAME:	GRlocate_processing

     Abstract: 	This method will check to see if the graphics object
		passes the class list check and the tolerance check.
		
-----
%SC%    

     GRlocate_processing(msg,cvl,path,path_position,owner_elig,
			comp_elig)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
       *cvl	   GRlc_cvl	 structure containing all locate info
       path[]	   GRlc_path	 path information about the object
       *path_position IGRint	 position of object in path array
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
  	*msg	   IGRlong	 completion code
       path[]	   GRlc_path	 path information about the object
       *path_position IGRint	 position of object in path array
       *owner_elig IGRint	 indicator of whether owner is eligible
       *comp_elig  IGRint	 indicator of whether component is
				 eligible

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:

     Methods:
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
	
	MAS	11/30/87 : Design date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation GRlbsys;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "dpmacros.h"
#include "bserr.h"
#include "lcmacros.h"

method GRlocate_processing(IGRlong *msg; struct GRlc_cvl *cvl;
	struct GRlc_path *path; IGRint *path_position,
	*owner_elig, *comp_elig)
{
    IGRlong   OMmsg;		/* OM return value                  */
    IGRlong   msg1;  	        /* local return message             */

    struct IGRlbsys   *lbsys;  	/* abstract geometry pointer        */

    IGRint	check_geom,
		eligible_flag;

    OMmsg = OM_S_SUCCESS;
    cvl->msg = MSSUCC;
    *msg = MSSUCC;

    OMmsg = GRcheckcrit(msg,&my_id,cvl->classes,
		path,path_position,comp_elig,&eligible_flag,
		&check_geom);

    if ( 1 & OMmsg )
    {
        if (eligible_flag || *owner_elig)
        {
 	    /* if the object or its owner is eligible, 
	     * process the geometry, if it has not already been processed.
             */

            if (check_geom)
	    {
    					/* Get the abstract geometry.	*/
 	        GRgetabsg(&msg1, &cvl->module.md_env.matrix_type, 
                    cvl->module.md_env.matrix, (char **)&lbsys, i);
      
    	        if (1 & msg1)
    	        {
	            OMmsg = GRlbgeomchk(msg,cvl,lbsys,&eligible_flag,path,
			path_position);

	        }
		else
		{
		    OMmsg = OM_E_ABORT;
		}
   	    }
	    if ( 1 & OMmsg)
	    {
	        OMmsg = GRacthand(msg,cvl,path,path_position,&eligible_flag);
	    }

	}
    }

    GR_NOTIFY_LISTENERS(cvl->msg,&OMmsg,GR_LOCATED);
        

   return( OMmsg );
}

end implementation GRlbsys;
