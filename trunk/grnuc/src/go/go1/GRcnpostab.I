/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRconic
     METHOD NAME:  GRpostabsg

     Abstract: 
		This method posts the abstract data representation
	for a conic object.  
-----
%SC%    

     GRpostabsg(msg,md_env,post_info,absptr,newobjid)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------

     *md_env    struct GRmd_env      structure defining the transfor-
				      mation and other info about
				      the object
     *post_info struct GRpost_info   processing control information
     *absptr	IGRchar	  	     pointer to buffer containing
				      internal format representation
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
       *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - GRSNOINVTRAN (severe) if
				      input matrix is not invertible
			 	    - GRSDGNEXCEED (severe) if
				      range exceeds design limits
				    - MSFAIL (severe) if failure
      *newobjid   GRobjid	 used if object changes classes,
				    otherwise is same as my_id
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
    	     instance date will not be modified

	     If it is determined that the line
	     segment needs to change class, a
	     new object will be constructed, the
	     channel linkages of the original 
	     object will be transferred to the 
	     new object, and the original object
	     will be deleted.

-----
%CH%

     CHANGE HISTORY:
	MAS	10/19/87 : Design Date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method converts the internal format (abstract
	geometry form) of the conic object to its arc 
	representation and  invokes the GRputarc method.
----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
%safe
#include "math.h"
%endsafe

extern    IGRboolean    MAbctoar();
extern    IGRint        prt_crv();

method GRpostabsg(IGRlong *msg; struct GRmd_env *md_env;
		  struct GRpost_info *post_info;
		  IGRchar *absptr; GRobjid *newobjid)

{
    IGRlong	  	OMmsg,		/* return status for method 	*/
			msg1;
    struct IGRarc  	arc;		/* the arc to post		*/ 
    struct IGRbsp_curve *curve;

/*
 *  initialize variables
 */

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;
	*newobjid = my_id;		/* object didn't change classes */

	MAbctoar(&msg1,absptr,&arc);
        
	curve = (struct IGRbsp_curve *)absptr;

	if ( (curve->phy_closed == 1) && (arc.sweep_angle == (2 * PI)) )
		arc.start_angle = 0.0;

	if (1 & msg1)
	{
	    OMmsg = om$send(
		msg = message GRconic.GRputarc
			(msg,md_env,post_info,&arc,newobjid),
		targetid = my_id);
	}
	else
	{
	    OMmsg = OM_E_ABORT;
	    *msg = MSFAIL;
	}

    return(OMmsg);
}

end implementation GRconic;
