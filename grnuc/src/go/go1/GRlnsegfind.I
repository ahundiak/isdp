/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRlinear
     METHOD NAME:  GRsegfind

     Abstract:   This routine finds the desired
		 segment of the given linear
		 graphics object.  
-----
%SC%    

     GRsegfind(msg,matrix_type,matrix,ref_parms,point1,point2)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	  type of transformation matrix
     matrix	   IGRmatrix	  input transformation matrix
     *ref_parms	   GRparms	  parameters identifying segment

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     point1	   IGRpoint	 beginning point of selected segment
     point2	   IGRpoint	 ending point of selected segment
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:   MAutoparms

     Methods:   
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  
-----
%CH%

     CHANGE HISTORY:
	
	KMO     05/07/86 : Design date.
	KMO	05/07/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This routine will determine which segment is desired
	by evaluating the parameters in the input structure.
	Then the endpoints of the selected segment will be
	returned.

----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "godef.h"

extern    IGRboolean    MAutoparms();

method GRsegfind(IGRlong *msg; IGRshort *matrix_type;
	    	  IGRmatrix matrix; struct GRparms *ref_parms;
		  IGRpoint point1,point2)

{
    IGRlong 		status;		/* return status for method	*/
    IGRchar		*buffer;	/* pointer to dynamic buffer	*/
    struct IGRbsp_curve *curve;
    IGRdouble		tparm;
    IGRlong		segnum;
    IGRlong		i;
    IGRlong		internal_msg;

/*
 *  initialize variables
 */

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

/*
 *  get abstract geometry of object
 */

    GRgetabsg(&internal_msg,matrix_type,matrix,&buffer,i);
 
    if (! (1 & internal_msg))
    {
	*msg = MSFAIL;
	status = OM_E_ABORT;
	goto wrapup;
    }  

    curve = (struct IGRbsp_curve *)buffer;

    /*
     *  determine which segment was selected
     *  for the midpoint calculation
     */

    if ( 1 & MAutoparms(&internal_msg,curve,&ref_parms->u,&segnum,&tparm) )
    {
	if ( segnum < 1 )
	{
	    status = OM_E_ABORT;
	    *msg = MSFAIL;
	    goto wrapup;
	}
	
	for ( i=0; i<3; ++i )
	{
	    point1[i] = curve->poles[((segnum - 1) * 3) + i];
	    point2[i] = curve->poles[(segnum * 3) + i];
	}
    }
    else
    {
	status = OM_E_ABORT;
	*msg = MSFAIL;
    }

	

wrapup:
    
	return(status);

}

end implementation GRlinear;
