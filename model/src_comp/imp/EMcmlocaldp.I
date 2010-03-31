class implementation EMScomposite;

#include "EMScc.h"
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   EMScomposite
     METHOD NAME:   GRlocaldp

     Abstract: 	    This method performs a regular display even though
                    local display is requested as local display does
                    not make sense for a composite class objects.

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
-----
%CH%

     CHANGE HISTORY:
        dhm     04/05/88    Added GR_NOTIFY_LISTENERS.	
	
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	On the graphics class, merely call GRdisbyoid (same code as
	in GRdisplay).
----*/
/*EH*/

#include "EMSmsgdef.h"
#include "grerr.h"
#include "dpmacros.h"
#include "godef.h"
#include "gocmacros.h"

method  GRlocaldp(IGRlong *msg; IGRshort *mx_type; IGRmatrix
   		  matrix; struct GRparms *parm; enum GRdpmode *mode; 
		  struct GRid *display_info; IGRshort 
		  *display_location; IGRshort *display_flag)
{
	IGRlong  OM_stat, msg_loc;

	*msg = EMS_S_Success;
   	OM_stat = OM_S_SUCCESS;

    OM_stat = om$send(mode = OM_e_wrt_message,
                      msg = message GRgraphics.GRlocaldp(&msg_loc, mx_type,
                            matrix, parm, mode, display_info,
                            display_location, display_flag),
                      senderid = my_id,
                      targetid = my_id);
    if (! (1 & OM_stat & (*msg)))
    {
        OM_stat = OM_E_ABORT;
        *msg = EMS_E_Fail;
    }

    GR_NOTIFY_LISTENERS(msg, &OM_stat, GR_DISPLAYED);
	return (OM_stat);
}

end implementation EMScomposite;
