/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include "EMSdef.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "OMmacros.h"

#include "bsparameters.h"
#include "bserr.h"
#include "gocmacros.h"
#include "OMmacros.h"



from EMSsubbs import EMpratmpt, EMpartolbasis;
from GRvg import EMptatpr;
from GRvg import GRgetsize, GRgetgeom;

method EMtwin_crv_parm(IGRlong             *EMmsg;
                       struct EMSedgebound *my_edge_info,
                                           *other_edge_info;
                       struct GRmd_env     *my_env;
                       IGRshort            other_edge_pos; 
                       GRobjid             *my_surf;
                       GRobjid             *other_surf) 
/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure
                - EMS_E_EdgeError error in edge method

   If the fact that the other_edge is natural or not, is unknown then
   send any negative number for the input argument other_edge_pos.

Assumption

Bugs

History
	
	  gupta 	05/04/87:	design date
      RC        05/07/88    Added argument my_surf such that the
                            caller can pass the my sf's id. If
                            unknown, *my_surf should be set to
                            NULL_OBJID and
                            this method will return *my_surf.
          Jaikish       12/1/97:
     Mod        12/1/97     Added a block to recheck par values if the original
			    fails.
Algorithm

      This method expects a parameter on an edge and it returns the
      corresponding parameter on the common edge. First get the uo,vo
      corresponding to the incoming parameter on my surface. Get the
      xyz, corresponding to this uo,vo. Get the un,vn on the common edge's
      surface corresponding to xyz. Finally decide the common edge
      parameter based on this un,vn.
Modified 
      The last method which is supposed to get the uv par of the other surface
      is cribbing and giving wrong results in some particular cases. So a
      new block has been added to recheck if the above is erroneous. The modi
      fication is nothing but calling a math function to get the proper
      UV parameters on the other surface.
*/

{
  IGRlong               stat_OM, msg,rc;
  IGRdouble             my_uv[2], other_uv[2], xyz[3],chtol;
  IGRdouble	            dist;
  IGRpoint	            base_point;
  GRobjid               other_edge;
  OM_S_CHANSELECT       to_common_edge;
  struct EMSproj_info   proj_info;
  struct EMSpartolbasis partolbasis;

/*------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  partolbasis.is_valid = FALSE;
  partolbasis.in_world = FALSE;
  partolbasis.mattyp = &my_env->md_env.matrix_type;
  partolbasis.mat = my_env->md_env.matrix;
  
  to_common_edge.type = OM_e_addr;
  to_common_edge.u_sel.addr = &ME.EMSedge->to_common_edge;

  if(*other_surf != NULL_OBJID)
   {
    IGRboolean world = TRUE;

    stat_OM = om$send(msg = message EMSsubbs.EMpartolbasis(&msg, 
	      partolbasis.mattyp, partolbasis.mat, &world, TRUE, 
	      &partolbasis.tol), targetid = *other_surf);
    EMomerr_hndlr(stat_OM, wrapup, "EMedtwinpar.EMgetsurf_info");
    EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);
    partolbasis.is_valid = TRUE;
   }
  else
   {
    stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
               (&msg, other_surf, 
               ME.EMSedge->ed_props & EMED_SEAM ? NULL:&partolbasis),
               p_chanselect = &to_common_edge);
    EMomerr_hndlr(stat_OM, wrapup, "EMedtwinpar.EMgetsurf_info");
    EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);
   }

  if (ME.EMSedge->ed_props & EMED_SEAM)
     {
      other_edge_info->span_inx = 0;
      other_edge_info->param = 1 - my_edge_info->param;
	  goto wrapup;    
     }

  /* get the partner's id */

  stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                          &other_edge),
                    p_chanselect = &to_common_edge);
  EMomerr_hndlr(stat_OM, wrapup, "EMedtwinpar.EMget_objid");
  EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

  /* get the uv corresponding to my crv_param */

  stat_OM = om$send(msg = message EMSedge.EMptatpr(&msg, 1,
                          my_edge_info, NULL, my_uv),
                    targetid = my_id);
  EMomerr_hndlr(stat_OM, wrapup, "EMedtwinpar.EMptatpr");
  EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
	
  /* if my_surf is not sent in 
     get my surface id as well as the other guys surface id */
    
  if (*my_surf == NULL_OBJID)
  {
    stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                          (&msg ,my_surf, NULL),
                    targetid = my_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMedtwinpar.EMgetsurf_info");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

  } /* if (*my_surf == NULL_OBJID) */

  /* get the xyz point on my surface */

  stat_OM = om$send(msg = message GRvg.EMptatpr(&msg,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix, my_uv, 2, xyz),
                    targetid = *my_surf);
  EMomerr_hndlr(stat_OM, wrapup, "EMedtwinpar.EMptatpr");
  EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

  /* the uv on the other surface */

  stat_OM = om$send(msg = message EMSsubbs.EMpratmpt(&msg,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix, 1,
                          xyz, other_uv, &dist, base_point),
                    targetid=*other_surf);
  EMomerr_hndlr(stat_OM, wrapup, "EMedtwinpar.EMpratmpt");
  EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);
/*
The above call fails for the testcase which was given in TR# 119701118. The
below added code is tested very severely before ckin. The test case can easily
be reproduced. the following code is executed only for those kind of cases
and at the same time if the above call fails.    --Jaikish.
*/ 

  BSxtractpar(&rc, BSTOLCHRDHT, &chtol);
  /**************************************************
  Modified to avoid BSproblem
  **************************************************/
  if(dist > chtol)
   {
   struct IGRbsp_surface  *other_sf1;
   IGRlong sf_size;
   IGRboolean on_surf;
   IGRdouble tmp_upar, tmp_vpar;
   IGRboolean sts;
   IGRlong stat_om1;
   IGRpoint xyz1;
   IGRlong  EMmsg1;

   xyz1[0] = xyz[0]; xyz1[1] = xyz[1];  xyz1[2] = xyz[2];

  stat_om1 = om$send(msg = message GRvg.GRgetsize (&EMmsg1,
                                         &my_env->md_env.matrix_type,
                                         my_env->md_env.matrix,&sf_size),
                              targetid = *other_surf,
                              targetos = OM_Gw_current_OS);
   EMomerr_hndlr(stat_om1, wrapup, "GRvg.GRgetsize");

   other_sf1 = (struct IGRbsp_surface *) om$malloc (size = sf_size);

   stat_om1 =  om$send (msg = message GRvg.GRgetgeom (&EMmsg1,
                                         &my_env->md_env.matrix_type,
                                         my_env->md_env.matrix,
                                        (IGRchar *) other_sf1),
                              targetid = *other_surf,
                              targetos = OM_Gw_current_OS);
   EMomerr_hndlr(stat_om1, wrapup, "GRvg.GRgetgeom");

    sts = BSprptonsf(&rc, other_sf1, xyz1, &tmp_upar, &tmp_vpar, &on_surf);

    if(other_sf1) om$dealloc(ptr = other_sf1);
     
     if((rc == BSSUCC) && (sts == 1))
     {
      other_uv[0] = tmp_upar;
      other_uv[1] = tmp_vpar;
     }
     else if(OM_Gf_verbose_warning)
         printf("failed to calculate bsprojptonsf::::exiting\n");
   }
  /* get the crv parameter on the other edges curve */

  other_edge_info->span_inx = 0;
  switch (other_edge_pos)
   {
    case 0:
           other_edge_info->param = other_uv[1];
           break;
    case 1:
           other_edge_info->param = other_uv[0];
           break;
    case 2:
           other_edge_info->param = 1 - other_uv[1];
           break;
    case 3:
           other_edge_info->param = 1 - other_uv[0];
           break;

    /* If not a natural edge then evaluate the parameter */

	default:
	      
  	       stat_OM = om$send(msg = message EMSedge.EMptproject (&msg,
                                   other_uv, 1, &proj_info,
                                   NULL, &partolbasis),
				             p_chanselect = &to_common_edge);
           EMomerr_hndlr(stat_OM, wrapup, "EMedtwinpar.EMptproject");
           EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

           other_edge_info->param = proj_info.param.param;
           other_edge_info->span_inx = proj_info.param.span_inx;
       }

wrapup:
  
   return(stat_OM);
}

end implementation EMSedge;
