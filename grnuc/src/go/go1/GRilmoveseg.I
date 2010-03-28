/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRinfline

     METHOD NAME:	GRmoveseg

     Abstract: 	This method redefines the geometric representation
	      of the linear object by moving an identified segment
	      in its geometry.  However, the override at infinite
	      line simply returns an error.	
-----
%SC%    

     GRmoveseg(msg,md_env,seg_locate,point,boreline)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env       GRmd_env	  environment information
     *seg_locate   GRparms	  locates the appropriate segment to
				  modify 
     point	   IGRpoint	  point on segment ('from' point)
     *boreline	   IGRline	  indicates new location for segment

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

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
	
	SDG	07/15/86 : Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method is overridden at infinite line to return an 
	error.  An infinite line is not a segmented linear object
	and should not be treated as such.  The move command should
	be used if the infinite line is to be altered.
----*/
/*EH*/

class implementation GRinfline;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRmoveseg(IGRlong *msg; struct GRmd_env *md_env; 
		struct GRparms *seg_locate; IGRpoint point; 
		struct IGRline *boreline)

{
	IGRlong	OMmsg;			/* OM return value		*/

	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);

	return(OMmsg);

}

end implementation GRinfline;
