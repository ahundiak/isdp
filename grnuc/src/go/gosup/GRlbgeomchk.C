/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "lcdef.h"
#include "msdef.h"
#include "bserr.h"
#include "godef.h"
#include "igrdp.h"
#include "OMerrordef.h"
#include "griodef.h"

#include "igr.h"
#include "gr.h"
#include "dp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"

#include "lcmacros.h"
#include "OMprimitives.h"
#include "OMmacros.h"

extern    IGRboolean    MAptinlb();
extern    IGRboolean    MAlnlb2dis();

GRlbgeomchk(msg,cvl,lbsys,eligible_flag,path,path_position)

IGRlong 	*msg;		/* output - completion code	
				     MSSUCC - successful completion
				     MSFAIL - error			*/
struct GRlc_cvl *cvl;		/* input - structure from locate	*/
struct IGRlbsys	*lbsys;		/* input - lbsys geometry		*/
IGRint		*eligible_flag;	/* input - indicator of whether the
				    object is eligible			*/
struct GRlc_path *path; 	/* input/output - path structure, action 
				   in structure is updated		*/
IGRint 		*path_position; /* input - position in path array	*/

{
    IGRlong 	OMmsg,
		msg1;
    IGRboolean  on,
		status;
    IGRdouble dist_sq;
    IGRint   indicator;

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    switch (cvl->attributes.type)
    {
    case GR_pt_loc:
    {
       	/*
       	 *  Checks to see if point is inside of lbsys.
       	 *  value = FALSE - outside lbsys
       	 *          TRUE  - inside lbsys
       	 *  message = MSSUCC - successful completion.
       	 *            MSFAIL - failure of routine (error)
       	 */

	status = MAptinlb (&msg1, cvl->attributes.acc_point, lbsys, 
               	&cvl->attributes.acc_tolerance, &on);
   
	if ( status)
	{
	    if (*eligible_flag)
	    {
    	    	path[*path_position].action = add_all;
	    }
	    path[*path_position].result = GR_LC_HIT;
	}
	break;
    }
    case GR_bl_loc:
    {
      	status = MAlnlb2dis(&msg1,&cvl->attributes.acc_line, 
		lbsys, &dist_sq);

	if (status && ((cvl->attributes.acc_tolerance * 
            cvl->attributes.acc_tolerance) >= dist_sq))
       	{
	    if (*eligible_flag)
	    {
    	    	path[*path_position].action = add_all;
	    }
	    path[*path_position].result = GR_LC_HIT;
	}
	break;
    }
    case GR_rp_loc:
    {
   	BSlbs_infnc(&cvl->attributes.acc_rt_prism,lbsys,
	     &indicator,&msg1);		/* continue through next case	*/
    }	
    case GR_cv_loc:
    {
	if (cvl->attributes.type != GR_rp_loc)
	{
   	    BSlbsincfnc(&cvl->attributes.acc_cv_prism,lbsys,
	     &indicator,&msg1);
	}
       	if (msg1 == BSSUCC)
	{
       	    if (indicator == 1)
    	    {
	    	if (*eligible_flag)
	    	{
		    path[*path_position].action = add_inside;
		}
	    	path[*path_position].result = GR_LC_INSIDE;
    	    }
    	    else if (indicator == 2)
    	    {
	    	path[*path_position].result = GR_LC_OVERLAP;
		if (*eligible_flag)
		{
		    path[*path_position].action = add_overlap;
		}
    	    }
   	    else 
   	    {
	    	path[*path_position].result = GR_LC_OUTSIDE;
		if (*eligible_flag)
		{
		    path[*path_position].action = add_outside;
		}
    	    }
	}
	break;
    }
    case GR_nam_loc:
    case GR_crit_loc:
    {
	if (*eligible_flag)
	{
	    path[*path_position].action = add_all;
	}
	path[*path_position].result = GR_LC_HIT;

	break;
    }
    default:			/* invalid type			*/
    {
	*msg =  MSFAIL;
	OMmsg = OM_E_ABORT;
    }
    }

    return(OMmsg);
}
