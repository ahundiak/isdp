/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRprismrel -  determines the relationship of
		clipping polygon to a right or curve 
		prism.  
		The type of prism is determined from the input 
		variable, type_prism.  

Synopsis
 	GRprismrel(msg,mx_type, matrix, prism_rel,type_prism, prism,
	    relationship)

	IGRlong *msg		Completion code
	IGRshort *mx_type	type of matrix
     	IGRmatrix matrix	environment matrix
        *prism_rel  IGRlong	 if NULL then return true relationship
				 of the object to the prism; else return
				 the relationship that is being checked
				 The flags for checking are defined in
				 grgsdef.h
				 GO_INSIDE
				 GO_OUTSIDE
				 GO_OVERLAP
				 GO_INSIDE | GO_OVERLAP
				 GO_OUTSIDE | GO_OVERLAP

     	IGRshort *type_prism 	type of prism 
				    	0 - right prism
					1 - curve prism

     	IGRshort *relationship	the relationship of the clipping
				 polygon to the prism
					0 - clipping polygon is 
					    outside prism 
					1 - clipping polygon is 
					    inside prism
					2 - clipping polygon 
					    overlaps prism

Description

	This method gets the abstract geometry of the clipping 
	polygon and then calls a math routine to determine the 
	relationship of the clipping polygon to the input prism.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	05/27/87	Design date.
\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "bserr.h"
#include "refpriv.h"
 
method GRprismrel(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
	IGRlong *prism_rel; IGRshort *type_prism; IGRchar *prism; 
	IGRlong *relationship)

{
    IGRchar	*ptr;			/* pointer to abstract geometry	*/

    IGRint	i;			/* loop index			*/

    IGRlong	OMmsg;		
    IGRlong 	msg1;			/* return code			*/

    struct IGRcv_prism *cv_prism;
    struct IGRpolyline py;
    struct IGRlbsys lbsys;

    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;

					/* get the clipping polygon	*/
    GRgetprism(&msg1,mx_type,matrix,&ptr,i);

    if (1 & msg1)			/* successful			*/
    {
        cv_prism = (struct IGRcv_prism *)ptr;
	if ( (cv_prism->curve.order == 2) && (!cv_prism->curve.rational))
	{
	     /* for now create a local bounded system from the
	      * curve prism.
	      */
	    
	    py.points = cv_prism->curve.poles;
	    py.num_points = cv_prism->curve.num_poles;

	    MApyextents(&msg1,&py,lbsys.diag_pt1,lbsys.diag_pt2);
	    lbsys.diag_pt2[2] = cv_prism->height;
	    for (i=0; i<16; ++i)
	    {
	  	lbsys.matrix[i] = cv_prism->matrix[i];
	    }	
	    if (*type_prism == 0)	/* prism is right prism		*/
	    {
            	BSlbs_infnc(prism,&lbsys,relationship,&msg1);
	    }
	    else			/* prism is curve prism		*/
	    {
            	BSlbsincfnc(prism,&lbsys,relationship,&msg1);
	    }

	    if (msg1 != BSSUCC)
            {
	    	*msg = MSFAIL;
	    	OMmsg = OM_E_ABORT;
	    }
 	}
	else
	{
    	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	}
    }
    else
    {
	OMmsg = OM_E_ABORT;
    }

    return(OMmsg);
}
end implementation GRclippoly;
