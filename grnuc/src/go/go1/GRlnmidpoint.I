/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRlinear

     METHOD NAME:  GRmidpoint

     Abstract:   This routine finds the midpoint of
		 the given graphics object.  If the
		 object is segmented, then the midpoint
		 of the selected segment is returned.
-----
%SC%    

     GRmidpoint(msg,matrix_type,matrix,ref_parms,midpoint)

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
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     midpoint	  IGRpoint	 desired midpoint
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	MAptattparm
		MAutoparms

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
	
	KMO     04/09/86 : Design date.
	KMO	05/01/86 : Creation date.
	Carlos  03/23/92 : ref_parms->u will default to 0.5 if not
			   provided (fix for TR92n2865).
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This routine will determine the midpoint of the input
	graphics object.  If the object is segmented and the
	desired segment is identified via the ref_parms, then
	the midpoint of the segment will be found.
----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "godef.h"

extern    IGRboolean    MAptattparm();
extern    IGRboolean    MAutoparms();

method GRmidpoint(IGRlong *msg; IGRshort *matrix_type;
	    	  IGRmatrix matrix; struct GRparms *ref_parms;
		  IGRpoint midpoint)

{
    IGRlong 		status;		/* return status for method	*/
    IGRchar		*buffer;	/* pointer to dynamic buffer	*/
    struct IGRline	internal_line;
    struct IGRbsp_curve *curve;
    IGRdouble		tparm;
    IGRlong		segnum;
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

	if ( curve->num_poles == 2 )
	{
	    internal_line.point1 = &curve->poles[0];
	    internal_line.point2 = &curve->poles[3];
        }
        else
        {

	    /*
	     *  determine which segment was selected
	     *  for the midpoint calculation
	     */
	    IGRdouble middle = 0.5; /* will take the middle one if NULL was passed */ 

	    if ( 1 & MAutoparms(&internal_msg,curve, ref_parms ? &ref_parms->u : &middle,
				&segnum,&tparm) )
	    {
		internal_line.point1 = &curve->poles[(segnum - 1) * 3];
		internal_line.point2 = &curve->poles[segnum * 3];
	    }
	    else
	    {
		*msg = MSFAIL;
		status = OM_E_ABORT;
		goto wrapup;
	    }
	}

/*
 *  find the requested midpoint
 */
 
	tparm = 0.5;

	if (! (1 & MAptattparm(&internal_msg,&tparm,&internal_line,midpoint)))
	{
	    status = OM_E_ABORT;
	    *msg = MSFAIL;
	}

	
   
wrapup:
	return(status);

}

end implementation GRlinear;
