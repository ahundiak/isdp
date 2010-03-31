class implementation Root;

#include "EMS.h"
#define DEBUG 0
#if DEBUG
#include <stdio.h>
#endif
#include "EMSprop.h"
#include "EMSopt.h"
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
#include "bsparameters.h"
#include "bsdistptpt.h"
#include "bsprptonsf.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"          /* EMS error return codes */
#include "emsdattyp.h"
#include "emsmapdef.h"
#include "EMSbnddef.h"

from GRowner import GRget_components, GRget_number_components;
from EMSsurface import GRptproject;
from EMSsubbs import EMpartolbasis;
from EMSloopset import EMpt_location;

/*  
 * This function gets the surfaces that a curve gets mapped onto.
 * The number of surfaces that a curve can get mapped onto, is,
 * at the most, two.  The max number of surfaces will be two,
 * when a curve overlaps an edge of a surface having common
 * edge connection with another. 
 * NOTE : A single curve can not cross more than one component
 *        surface.	  
 *
 * History :
 *
 * M.R. Vadiraj : 07/04/94 : Creation.
 */

IGRlong EMgetsfsofcv(
  IGRlong       *msg,                   /* Error return code */
  IGRshort      *matrix_type,           /* My matrix type */
  IGRmatrix     matrix,                 /* My module matrix */
  struct GRid   *compsf,                /* The compsf */
  IGRpoint      point,                  /* The input point */
  IGRboolean    location_only,  
  struct        EMScvsfs *proj_parms)    /* The projected parms */

{
        IGRint          i, buf_size, nret,
                        comp_count= 0;
        IGRlong         status, msg_loc;
        IGRpoint        surf_pt;
        IGRdouble       proj_dist, test_dist = MAXDOUBLE,
                        uvpt[2];
        IGRboolean      in_world = TRUE, onsurf = FALSE;
        OM_S_CHANSELECT to_loopset;
        struct IGRbsp_surface *sfgeom = NULL;
        struct GRmd_env md_env;
        struct GRparms  tmp_parms, loc_parms;
        struct GRid     *comp_ids = NULL;
        struct EMSpartolbasis partol_basis;
        struct EMSptloc_info ptloc_info;

        extern IGRlong EMgetvggeom();

        *msg = MSSUCC;

        EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);
       
        gr$get_module_env(msg = &msg_loc,
                          sizbuf = &buf_size,
                          buffer = &md_env,
                          nret = &nret);

        if(!location_only) {
        status = om$send(msg = message GRowner.GRget_number_components(
                               &msg_loc, &comp_count),
                         targetid = compsf->objid,
                         targetos = compsf->osnum,
                         senderid = NULL_OBJID);
        EMerr_hndlr(!(1 & status & msg_loc), *msg, EMS_E_Fail, wrapup);

        comp_ids = (struct GRid *) om$malloc(size = (OMuint)comp_count *
                                             sizeof(struct GRid));

        status = om$send(msg = message GRowner.GRget_components(&msg_loc,
                                       &md_env, comp_ids, comp_count,
                                       &nret, NULL, OM_K_MAXINT),
                               targetid = compsf->objid,
                               targetos = compsf->osnum,
                               senderid = NULL_OBJID);
        EMerr_hndlr(!(1 & status & msg_loc), *msg, EMS_E_Fail, wrapup);

        /* Get all the components */

        for(i = 0; i < comp_count; i++)
        {
            status = om$send(msg = message EMSsurface.GRptproject(&msg_loc,
                                                  matrix_type, matrix,
                                                  point, surf_pt, &tmp_parms),
                             senderid = NULL_OBJID,
                             targetid = comp_ids[i].objid,
                             targetos = OM_Gw_current_OS);
            EMerr_hndlr(!(1 & status & msg_loc), *msg, EMS_E_Fail, wrapup);

            proj_dist = BSdistptpt(&msg_loc, point, surf_pt);
             
            if(proj_dist < test_dist)  
              {
               test_dist = proj_dist;
               OM_BLOCK_MOVE(&tmp_parms, &loc_parms,
                             sizeof(struct GRparms));
              }  
           }
        }

         if(location_only) {
         loc_parms.leaf_id.objid = proj_parms->surface.objid;
         loc_parms.leaf_id.osnum = proj_parms->surface.osnum;   
         }

         partol_basis.is_valid = TRUE;
         partol_basis.in_world = TRUE;
         partol_basis.mattyp = matrix_type;
         partol_basis.mat = matrix;

         if(!location_only) {
         uvpt[0] = loc_parms.u;
         uvpt[1] = loc_parms.v;
         }
         else {
         EMgetvggeom (&msg_loc, matrix_type, matrix,
                      &(proj_parms->surface),
                      &sfgeom, NULL);
         EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrapup);

         BSprptonsf(&msg_loc, sfgeom, point, &uvpt[0], &uvpt[1], &onsurf);

         if(sfgeom) {
         om$dealloc(ptr = sfgeom);
         sfgeom = NULL;
         }
      }

         ptloc_info.options = EMS_PTLOC_CLOSEST_EDGE | EMS_PTLOC_ACTLOOP |
                              EMS_PTLOC_LS_INFINITE | EMS_PTLOC_XYZ_ONEDGE;

         status = om$send(msg = message EMSsubbs.EMpartolbasis(&msg_loc,
                                matrix_type, matrix, &in_world,
                                FALSE, &(partol_basis.tol)),
                          targetid = loc_parms.leaf_id.objid,
                          targetos = loc_parms.leaf_id.osnum,
                          senderid = NULL_OBJID);
         EMerr_hndlr(!(1 & status & msg_loc), *msg, EMS_E_Fail, wrapup);

         status = om$send(msg = message EMSloopset.EMpt_location(&msg_loc,
                                        uvpt, &ptloc_info, &partol_basis),
                                p_chanselect = &to_loopset,
                                senderid = loc_parms.leaf_id.objid);
         EMerr_hndlr(!(1 & status & msg_loc), *msg, EMS_E_Fail, wrapup);

         if(!location_only) {
         proj_parms->surface.objid = loc_parms.leaf_id.objid;
         proj_parms->surface.osnum = loc_parms.leaf_id.osnum;
         proj_parms->location = ptloc_info.location;
         }
         else if(location_only && onsurf)
         proj_parms->location = ptloc_info.location;
         else if(location_only && !onsurf)
         proj_parms->location = EMS_L_OUTSIDE;

wrapup:

if(comp_ids && !location_only)
om$dealloc(ptr = comp_ids);
comp_ids = NULL;

if(1 & status & *msg)
return(OM_S_SUCCESS);
else
return(OM_E_ABORT);
}

end implementation Root;
