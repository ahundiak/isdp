/* ###################   APOGEE COMPILED   ################## */
/* 
 DESCRIPTION
  
 This method returns the closest point on a composite surface to the input 
 point.  The parameters of the point on the surface are also returned.
  
 RETURN VALUES
 
 proj_pt                The closest point on the surface to the input point
  
 proj_parms             The surface parameters corresponding to the proj_pt.
  
 msg                    MSSUCC if success
                        MANOMEMORY if no memory
                        MSFAIL if problems 
  
 NOTES
  
 This routine gets surface components & calls the GRptproject method
 for each of these surfaces.

 HISTORY
	Tapadia  - ???
        M.R.Vadiraj  - 01-07-93 - Corrected all the compilation errors.
        Rust - 8/4/93 - the output "proj_pt" was not returned back. Also
                        commented EMptatpr as it was being called even
                        for composite surfaaces. It was not needed et all.
  
        Rust - 23/8/93 - Modified my earlier fix as the output was
                         not returned from the right "location".
 */

class implementation EMScompsurf;

#include "EMS.h"
#define DEBUG 0
#if DEBUG
#include <stdio.h>
#endif
# include "EMSprop.h"
# include "EMSopt.h"
#include "OMminimum.h"          /* for gocmacros.h  */
#include "igrtypedef.h"         /* for gocmacros.h  */
#include "igetypedef.h"
#include "gr.h"
#include "gocmacros.h"          /* GRgetabsg macro  */
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "msdef.h"              /* MS message codes */
#include "madef.h"              /* MA message codes */
#include "bserr.h"              /* BS message codes */
#include "EMSbnddef.h"          /* EMS loopset properties keywords */
#include "EMSbnd.h"             /* EMS information structures */
#include "EMSmsgdef.h"          /* EMS error return codes */

from EMSloopset import EMget_props, EMpt_location;

method GRptproject(
  IGRlong       *msg;                   /* Error return code */
  IGRshort      *matrix_type;           /* My matrix type */
  IGRmatrix     matrix;                 /* My module matrix */
  IGRpoint      point;                  /* The input point */
  IGRpoint      proj_pt;                /* The projected point */
  struct        GRparms *proj_parms)    /* The projected parms */

{
 	IGRint 		i;
 	IGRlong         status, msg_loc;
 	IGRint		comp_count= 0;
/* 	OM_S_CHANSELECT	to_comps; */
 	struct GRid    	*comp_ids = NULL;
/* 	OMuword 	dum_os; */
 	IGRdouble	proj_dist, test_dist = MAXDOUBLE,
                        temp_pt[3];
 	IGRpoint 	surf_pt;
 	extern IGRdouble BSdistptpt();
	struct 	GRparms tmp_parms;
        struct GRmd_env md_env;
        IGRint buf_size, nret;

 	*msg = MSSUCC;
        gr$get_module_env(msg = msg,
                    sizbuf = &buf_size,
                    buffer = &md_env,
                    nret = &nret);
/***************************************************************************
	status = EMmake_chanselect(GRcmpowner_to_components, &to_comps);

	status = om$get_channel_count(osnum = OM_Gw_current_OS,
			objid = my_id,
			p_chanselect = &to_comps,
			count = (OMuint *)&comp_count);
****************************************************************************/
        status = om$send(msg = message GRowner.GRget_number_components(
                            msg, &comp_count),
                   targetid = my_id);
        EMerr_hndlr(! (1 & status & *msg), *msg, EMS_E_Fail, wrapup);

        comp_ids = (struct GRid *) om$malloc(size =
                                        (OMuint)comp_count *
                                        sizeof(struct GRid));

        status = om$send(msg = message GRowner.GRget_components(msg,
                                       &md_env, comp_ids, comp_count,
                                       &nret, NULL, OM_K_MAXINT),
                                      targetid = my_id);
        EMerr_hndlr(! (1 & status & *msg), *msg, EMS_E_Fail, wrapup);
        
	/* Get all the components */
	for(i = 0; i < comp_count; i++) {
       /***************************************************************
		status = om$get_objid_at_index(objid = my_id,
				p_chanselect = &to_comps,
				index = i,
				objidaddr = &comp_id,
				osnumaddr = &dum_os);
       ***************************************************************/

	/* Get the projected point on each surface. May need to use 
	EMSsurface.GRptproject as some of these surfaces may still be 
	composite */

		status = om$send(msg = message EMSsurface.GRptproject(msg,
				matrix_type, matrix,
				point, surf_pt, &tmp_parms),
			senderid = NULL_OBJID,
			targetid = comp_ids[i].objid,
			targetos = OM_Gw_current_OS);
		
		EMerr_hndlr(!(1 & status & *msg), *msg, EMS_E_Fail, wrapup);
              
                temp_pt[0] = tmp_parms.u;
                temp_pt[1] = tmp_parms.v;
/******************
                status = om$send(msg = message EMSsurface.EMptatpr(msg, 
                                       matrix_type, matrix, temp_pt,
                                       2, surf_pt),
                                 senderid = NULL_OBJID,
                                 targetid = comp_ids[i].objid,
                                 targetos = OM_Gw_current_OS);
                EMerr_hndlr(!(1 & status & *msg), *msg, EMS_E_Fail, wrapup);
*********************/

		proj_dist = BSdistptpt(&msg_loc, point, surf_pt);

		if(proj_dist < test_dist) {
			test_dist = proj_dist;
			OM_BLOCK_MOVE(&tmp_parms, proj_parms, 
				sizeof(struct GRparms));
                OM_BLOCK_MOVE(surf_pt, proj_pt, sizeof(IGRpoint));
		}
	}
/*
     OM_BLOCK_MOVE(surf_pt, proj_pt, sizeof(IGRpoint));
*/
wrapup:

if(comp_ids)
om$dealloc(ptr = comp_ids);
comp_ids = NULL;

if(1 & status & *msg)
return(OM_S_SUCCESS);
else 
return(OM_E_ABORT);
}

end implementation EMScompsurf;
