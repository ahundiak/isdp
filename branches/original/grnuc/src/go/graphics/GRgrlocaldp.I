/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   GRgraphics
     METHOD NAME:   GRlocaldp

     Abstract: 	    This method displays a local area defined on a 
		    graphics object.

-----
%SC%    

     GRlocaldp(msg, type, matrix, parm, mode, display_info,
	       display_location,display_flag)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
      *type       IGRshort	 type of the matrix
      *matrix     IGRmatrix      environment transformation matrix
      *parm	  GRparms	 parametric description of local area
				 of object to be displayed
      *mode	  GRdpmode	 array of display modes:
				   mode[0] : mode for element
				   mode[1] : mode for extension
				 NOTE:
				   This applies only if 
				   display_flag == 0 (display object
				   and extensions), otherwise only
				   one mode is needed.
      *display_info GRid	 window/view information denoting 
				 where to display the object
      *display_location	  
		  IGRshort	 obsolete variable left for compatibility
      *display_flag	  
		  IGRshort	 flag to indicate what to display
				   0 : display both object and
				       extensions
				   1 : display extension only
				   2 : display element and 
				       extension

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

     Modules:
	    none.
     Methods:

-----
%RL%

     RELATIONS REFERENCED:
	     none.
-----
%NB%

     NOTES:
		For most graphics objects, local display defaults 
	to the same result as GRdisplay (display full geometry).  
	However for linear objects, only the segment identified by
	the given parm will be displayed.
-----
%CH%

     CHANGE HISTORY:
	
	REJ	04/09/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	On the graphics class, merely call GRdisbyoid (same code as
	in GRdisplay).
----*/
/*EH*/

class implementation GRgraphics;

#include "grimport.h"
#include "msdef.h"
#include "grerr.h"
#include "dpmacros.h"
#include "godef.h"
#include "gocmacros.h"

method  GRlocaldp(IGRlong *msg; IGRshort *mx_type; IGRmatrix
     		  matrix; struct GRparms *parm; enum GRdpmode *mode; 
		  struct GRid *display_info; IGRshort 
		  *display_location; IGRshort *display_flag)
{
	IGRlong  OMmsg;			/* OM return code	*/
	IGRlong  msg2;			/* return code		*/

	IGRmatrix *mx[1];		/* pointer to matrix	*/

	struct GRid go_objid;		/* info for GRdisbyoid	*/

	*msg = GRDEFAULT_USED;
     	OMmsg = OM_S_SUCCESS;

	if (*display_flag != 1)
	{
	    go_objid.objid = my_id;
	    go_objid.osnum = OM_Gw_current_OS;

	    mx[0]  = (IGRmatrix *) matrix;

	    OMmsg = dp$display(msg = &msg2,
			   objid = display_info->objid,
           		   osnum = display_info->osnum,
			   mode  = *mode,
			   oids   = &go_objid,
			   mtx_type = mx_type,		
			   matrix = mx);
	    if (! (1 & msg2))
	    {
	        OMmsg = OM_E_ABORT;
	        *msg = MSFAIL;
	    }
	}

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_DISPLAYED);

	return (OMmsg);
}

end implementation GRgraphics;
