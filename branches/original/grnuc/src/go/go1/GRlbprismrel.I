/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRlbsys
     METHOD NAME:	GRprismrel

     Abstract: 	This method determines the relationship of
		a local bounded system prism or a right 
		prism to a local bounded system.  The type 
		of prism is determined from the input variable,
		type_prism.  
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
     *type_prism  IGRshort	 type of prism 
				    	0 - right prism
					1 - curve prism
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
       *relationship IGRlong	 the relationship of the local 
				    bounded system to
				    the right prism 
					0 - local bounded system is 
					    outside prism 
					1 - local bounded system is 
					    inside prism
					2 - local bounded system 
					    overlaps prism
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
		BSlbs_infnc
		BSlbsincfnc	
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

This method gets the abstract geometry of the B-spline local bounded system
and then calls a math routine to determine the relationship
of the local bounded system to the input prism.

----*/
/*EH*/

class implementation GRlbsys;

#include "grimport.h"
#include "msdef.h"
#include "bserr.h"
#include "godef.h"
#include "gocmacros.h"
 

method GRprismrel(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
	IGRlong	*prism_rel; IGRshort *type_prism; IGRchar *prism; 
	IGRlong *relationship)

{
    IGRchar	*ptr;			/* pointer to abstract geometry	*/


    IGRlong	OMmsg;		
    IGRlong 	msg1;			/* return code			*/

    struct IGRlbsys *lbsys;		/* lbsys geometry		*/

    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;

					/* get the local bounded system	*/
    GRgetabsg(&msg1,mx_type,matrix,&ptr,i);

    if (1 & msg1)			/* successful			*/
    {
        lbsys = (struct IGRlbsys *)ptr;

	if (*type_prism == 0)		/* prism is right prism		*/
	{
            BSlbs_infnc(prism,lbsys,relationship,&msg1);
	}
	else				/* prism is curve prism		*/
	{
            BSlbsincfnc(prism,lbsys,relationship,&msg1);
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

    return(OMmsg);
}
end implementation GRlbsys;
