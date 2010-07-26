/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRlinear
     METHOD NAME: GRcentcurv

     Abstract: This routine returns the center of curvature of a 
	linear element as the centroid of the element.  If the
	element is a linestring it will be processed as a
	B-spline curve using the parent classes method.

-----
%SC%    

	 GRcentcurv( msg,mat_type,matrix,parms,center )
     
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     mat_type	  IGRshort	 environment matrix type
     matrix	  IGRmatrix      environment matrix
     parms	  struct GRparms parameter

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failure

     center	  IGRpoint	 centroid of element
     
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     
     Methods:
		GRcenter	     
-----
%RL%

     RELATIONS REFERENCED:
			  
-----
%NB%

     NOTES:
	Since linear element have no center of curvature (infinity), 
	this method simply invokes GRcenter to return the centroid
	of the element.
	   
-----
%CH%

     CHANGE HISTORY:
	
	RDH     01/20/88 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
This method invokes the GRcenter method on the object.

----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"

method GRcentcurv(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		  struct GRparms *parms; IGRpoint center)
{
    IGRlong 	OMmsg;
    IGRchar	classname[OM_K_MAXCLASS_LEN];

    om$get_classname(objid = my_id,
	classname = classname);

    OMmsg = om$is_ancestry_valid(subclassname = classname,
	superclassname = "GRlinestr");

    if (OMmsg != OM_I_INVANCESTRY)
    {
	OMmsg = om$send(
	    mode = OM_e_wrt_message,
	    msg =  message GRbspline.GRcentcurv
		(msg,mat_type,matrix,parms,center),
	    targetid = my_id);
    }
    else
    {
      	OMmsg =  om$send(
	    msg = message GRlinear.GRcenter(msg,mat_type,matrix,center),
	    targetid = my_id);
    }

    return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRlinear;
