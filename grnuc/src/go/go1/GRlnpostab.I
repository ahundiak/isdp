/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRlinear
     METHOD NAME:  GRabsgcurve

     Abstract: 
		This method posts the abstract data representation
	for a linear object.  
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
	geometry form) of the linear object to its polyline 
	representation and  invokes the GRputpolyline method.
----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRpostabsg(IGRlong *msg; struct GRmd_env *md_env;
		  struct GRpost_info *post_info;
		  IGRchar *absptr; GRobjid *newobjid)

{
    IGRlong	  	OMmsg;		/* return status for method 	*/
    struct IGRbsp_curve *curve;		/* pntr to abstract geometry 	*/
    struct IGRpolyline  polyline;	/* the polyline to post		*/

/*
 *  initialize variables
 */

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;
	*newobjid = my_id;		/* object didn't change classes */
	curve = (struct IGRbsp_curve *)absptr; 

    	polyline.points = curve->poles;
	polyline.num_points = curve->num_poles;

	OMmsg = om$send(msg = message GRlinear.GRputpolyline
		(msg,md_env,post_info,&polyline,newobjid),
	    targetid = my_id);


    return(OMmsg);
}

end implementation GRlinear;
