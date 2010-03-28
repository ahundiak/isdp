/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbspline
     METHOD NAME:	GRprismrel

     Abstract: 	This method determines the relationship of
		a curve prism or a right prism to a
		B-spline curve.  The type of prism is
		determined from the input variable,
		type prism.  
-----
%SC%    
 
 GRprismrel(msg,mx_type, matrix, prism_rel, type_prism, prism,
	    relationship)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *mx_type	  IGRshort	 type of matrix
     matrix	  IGRmatrix	 environment matrix
     *prism_rel	  IGRlong	 if NULL or TRUE_REL then return 
				 true relationship of the object to 
				 the prism; 
				 else check for the requested
				 relationship that is being checked.
				 The valid relationships are:
				 GO_INSIDE
				 GO_OUTSIDE
				 GO_OVERLAP
				 GO_INSIDE | GO_OVERLAP
				 GO_OUTSIDE | GO_OVERLAP
				 (defined in grgsdef.h)

     *type_prism  IGRshort	 type of prism 
				    	0 - right prism
					1 - curve prism

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	*msg	  IGRlong	 completion code
				    MSSUCC - successful completion
    				    GR_E_INV_REQUEST - requested 
					relationship was not met
				    MSFAIL - error occured
     *relationship IGRlong	 the relationship of the curve to
				    the right prism
					0 - curve is outside prism 
					1 - curve is inside prism
					2 - curve overlaps prism
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
		BScv_in_fnc
		BScvincvfnc	
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
	
	MAS     03/17/87 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This method gets the abstract geometry of the B-spline curve
and then calls a math routine to determine the relationship
of the curve to the input prism.

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "bserr.h"
#include "godef.h"
#include "gocmacros.h"
#include "grgsdef.h"
 
#define  OUTSIDE 0 			/* curve is outside prism 	*/
#define  INSIDE  1			/* curve is inside prism	*/
#define  OVERLAP 2			/* curve overlaps prism		*/

method GRprismrel(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
	IGRlong *prism_rel; IGRshort *type_prism; IGRchar *prism; 
	IGRlong *relationship)

{
    IGRchar	*ptr;			/* pointer to abstract geometry	*/


    IGRlong 	msg1;			/* return code			*/
    IGRlong	OMmsg;			

    struct IGRbsp_curve *curve;		/* bspline geometry		*/

    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;

					/* get the curve		*/
    GRgetabsg(&msg1,mx_type,matrix,&ptr,i);

    if (1 & msg1)			/* successful			*/
    {
        curve = (struct IGRbsp_curve *)ptr;

	if (*type_prism == 0)		/* prism is right prism		*/
	{
            BScv_in_fnc(prism,curve,relationship,&msg1);
	}
	else				/* prism is curve prism		*/
	{
            BScvincvfnc(prism,curve,relationship,&msg1);
	}
	if (msg1 != BSSUCC)
        {
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
 	}
    	else
	{
	    OMmsg = GRcheckrel(msg,prism_rel,relationship);
	}
    }
    else
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
    }

    return(OMmsg);
}
end implementation GRbspline;
