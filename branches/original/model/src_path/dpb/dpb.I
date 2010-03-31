/*
 * FOR Project PATHWAY
 *     Shrirang : Creation
 */

/*
 * OVERVIEW
 *     This file consists of OMuse functions related to Surface
 *     data access. 
 *
 * NOTES
 *     The function in this file access the EMSsubbs instance data, it
 *     primarily tells whether the surface is ACTIVE or not.
 */

class implementation Root;

/* Includes */

#include <math.h>

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"

/* BS include */
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"

#include "EMSmsgdef.h"

#include "PWminimum.h"
#include "PWerror.h"

#include "EMSssprops.h"

#include "EMSdpb.h"
#include "grdpbdef.h"

/* BS prototypes */

#include "bschangepar.h"
#include "bschgdeppar.h"

/* PW prototypes */

#include "PWmodel.h"
#include "PWapi/dpb.h"

#include "PWapi/objaccess.h"

/* Imports */

from EMSdpb 	import EMget_dpbinfo;
from GRdpb	import GRget;

extern PWclassid OPP_EMSdpb_class_id;
extern PWclassid OPP_GRdpb_class_id;

PWresult pwGetDpbInfo
(
  struct PWdpbdata        *dpbdata,
  PWosnum                 os
)
{
    struct EMdpbinfo emsinfo;
    PWobjid id = 0;

    int   OMsts = OM_S_SUCCESS;
    long OMmsg = EMS_S_Success;

    id = omObjOfClass(OPP_EMSdpb_class_id, os);
    if(0 == id)
      return (SetError(0,PW_K_InvalidArg));

    OMsts = om$send(msg = message  EMSdpb.EMget_dpbinfo((IGRlong *)&OMmsg, 
							&emsinfo),
		  targetid = id,
		  targetos = os,
		  senderid = id); 
    if(!(1&OMsts&OMmsg))
      return (SetError(0,PW_K_InvalidArg));

    dpbdata->u_order = emsinfo.u_order; 	
    dpbdata->v_order = emsinfo.v_order; 	
    dpbdata->u_rules = emsinfo.u_rules; 	
    dpbdata->v_rules = emsinfo.v_rules; 	

    dpbdata->polygon_display = (emsinfo.props & EMDPB_POLYGON_DISPLAY_ON) ?
			      TRUE : FALSE; 	
    dpbdata->consider_boundaries = 
      (emsinfo.props & EMDPB_IGNORE_BOUNDARIES) ? FALSE : TRUE; 	
    dpbdata->u_periodic = emsinfo.props & EMDPB_U_PERIODIC; 	
    dpbdata->v_periodic = emsinfo.props & EMDPB_V_PERIODIC; 	

    id = 0;
    id = omObjOfClass(OPP_GRdpb_class_id, os);  
    if(0 == id)
      return (SetError(0,PW_K_InvalidArg));

    OMsts = om$send(msg = message  GRdpb.GRget((IGRint *)&OMmsg, 
                            grdpb_basis_tolerance,
			    (IGRchar *)&dpbdata->basis_tol),
		  targetid = id,
		  targetos = os,
		  senderid = id); 
    if(!(1&OMsts&OMmsg))
      return (SetError(0,PW_K_InvalidArg));

    OMsts = om$send(msg = message GRdpb.GRget((IGRint *)&OMmsg, 
                            grdpb_arclength_tolerance,
			    (IGRchar *)&dpbdata->arclen_tol),
		  targetid = id,
		  targetos = os,
		  senderid = id); 
    if(!(1&OMsts&OMmsg))
      return (SetError(0,PW_K_InvalidArg));

    OMsts = om$send(msg = message GRdpb.GRget((IGRint *)&OMmsg, 
                            grdpb_offset_tolerance,
			    (IGRchar *)&dpbdata->offset_tol),
		  targetid = id,
		  targetos = os,
		  senderid = id); 
    if(!(1&OMsts&OMmsg))
      return (SetError(0,PW_K_InvalidArg));
	
    OMsts = om$send(msg = message GRdpb.GRget((IGRint *)&OMmsg, 
			     grdpb_chord_height_tolerance,
			     (IGRchar *)&dpbdata->cht_tol),
		    targetid = id,
		    targetos = os,
		    senderid = id); 
    if(!(1&OMsts&OMmsg))
      return (SetError(0,PW_K_InvalidArg));

    OMsts = om$send(msg = message GRdpb.GRget((IGRint *)&OMmsg, 
                             grdpb_maximum_step_size,
			     (IGRchar *)&dpbdata->max_step_size),
		    targetid = id,
		    targetos = os,
		    senderid = id); 

    if(!(1&OMsts&OMmsg))
      return (SetError(0,PW_K_InvalidArg));
	
    return PW_K_Success;
}


PWresult pwSetBSFromDpbInfo
(
  struct PWdpbdata        *dpbdata
)
{
    IGRlong msg;
    BSchangepar(&msg, BSTOLCHRDHT, dpbdata->cht_tol);
    if(BSSUCC != msg)
      return (SetError (PW_K_Pathway, PW_K_Internal));

    BSchangepar(&msg, BSTOLOFFSET, dpbdata->offset_tol);
    if(BSSUCC != msg)
      return (SetError (PW_K_Pathway, PW_K_Internal));

    BSchangepar(&msg, BSTOLARCLEN, dpbdata->arclen_tol);
    if(BSSUCC != msg)
      return (SetError (PW_K_Pathway, PW_K_Internal));

    BSchangepar(&msg, BSTOLMAXSTEP, dpbdata->max_step_size);
    if(BSSUCC != msg)
      return (SetError (PW_K_Pathway, PW_K_Internal));

    BSchgdeppar(dpbdata->basis_tol, &msg);
    if(BSSUCC != msg)
      return (SetError (PW_K_Pathway, PW_K_Internal));
    return PW_K_Success;
}

end implementation Root;
