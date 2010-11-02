/* 

   This routine determines the relative angle of state 
   vectors between a pair of incident constraints.

   The constraint pair incident on the part is passed in as
   arguments.
   
*/

class implementation EMconstr;

#include <errno.h>
#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "msdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSmsgdef.h"
#include <alloca.h>
#include "assemconstr.h"
#include <values.h>

#include "OMmacros.h"
#include "maptsxfor.h"

#include <math.h>
# include "bstypes.h"
# include "bserr.h"
# include "bsvalues.h"


from EMSsubbs import EMtangent_normal;
from EMSparamvc import EMgetgeom;

int EMgetrelang(part_grid, incident_constr_1, incident_constr_2, prel_angle) 
struct GRid part_grid;                  /* The part on which constraints act */
struct GRid incident_constr_1;		/* The incident constraints */
struct GRid incident_constr_2;		/* The incident constraints */
IGRdouble *prel_angle;
{
  IGRlong msg_loc, stat_OM;
  IGRboolean is_incident_1, is_incident_2;
  struct GRid other_part_grid, feature_grid_1, feature_grid_2;
    
  IGRdouble disp_fac;
  extern IGRdouble  BSdotp();
  extern IGRboolean BScrossp();
  IGRvector TN_1[4], TN_2[4];
  IGRvector state_vector_1, state_vector_2;
  IGRdouble parms[2];
  struct GRmd_env mod_env;  
  int i_vec;
  BSrc bs_rc;
  IGRdouble cos_rel_ang;
  unsigned int constype;  
  IGRushort opts = 0;
  IGRshort  mattyp; 
  struct EMSgeomdata vecdata;

  IGRpoint pt;
  IGRvector vects[2], normal;
  IGRpoint axis[2];
  int typ;
  
  msg_loc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  disp_fac = 1.0;
  parms[0] = 0.5;
  parms[1] = 0.5;  


  /*
   * Get the current module environment.
   */	
  gr$get_module_env( buffer = &mod_env );
  
  mattyp = mod_env.md_env.matrix_type; 
  
  is_incident_1 = TRUE;

  stat_OM = om$send (msg = message EMconstr.EMgetpart (&msg_loc, is_incident_1, 
                     &other_part_grid), 
                     senderid = NULL_OBJID,
                     targetid = incident_constr_1.objid,
                     targetos = incident_constr_1.osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), msg_loc, EMS_E_Fail, ret_end);

  if ((other_part_grid.objid != part_grid.objid) || 
      (other_part_grid.osnum != part_grid.osnum))
  {
    is_incident_1 = FALSE;
    stat_OM = om$send (msg = message EMconstr.EMgetpart (&msg_loc, is_incident_1, 
                     &other_part_grid), 
                     senderid = NULL_OBJID,
                     targetid =incident_constr_1.objid,
                     targetos = incident_constr_1.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), msg_loc, EMS_E_Fail, ret_end);

    if ((other_part_grid.objid != part_grid.objid) || 
        (other_part_grid.osnum != part_grid.osnum))
       EMerr_hndlr (TRUE, msg_loc, EMS_E_Fail, ret_end);    
  }
  
  stat_OM = om$send (msg = message EMconstr.EMget_feature (&msg_loc,
                             is_incident_1, &feature_grid_1),
                             senderid = NULL_OBJID,                             
                             targetid =incident_constr_1.objid,
                             targetos = incident_constr_1.osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), msg_loc, EMS_E_Fail, ret_end);
  
  is_incident_2 = TRUE;

  stat_OM = om$send (msg = message EMconstr.EMgetpart (&msg_loc, is_incident_2, 
                     &other_part_grid), 
                     senderid = NULL_OBJID,
                     targetid =incident_constr_2.objid,
                     targetos = incident_constr_2.osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), msg_loc, EMS_E_Fail, ret_end);

  if ((other_part_grid.objid != part_grid.objid) || 
      (other_part_grid.osnum != part_grid.osnum))
  {
    is_incident_2 = FALSE;
    stat_OM = om$send (msg = message EMconstr.EMgetpart (&msg_loc, is_incident_2, 
                     &other_part_grid), 
                     senderid = NULL_OBJID,
                     targetid =incident_constr_2.objid,
                     targetos = incident_constr_2.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), msg_loc, EMS_E_Fail, ret_end);


    if ((other_part_grid.objid != part_grid.objid) || 
        (other_part_grid.osnum != part_grid.osnum))
       EMerr_hndlr (TRUE, msg_loc, EMS_E_Fail, ret_end);    
  }
  
  stat_OM = om$send (msg = message EMconstr.EMget_feature (&msg_loc,
                             is_incident_2, &feature_grid_2),
                             senderid = NULL_OBJID,                             
                             targetid =incident_constr_2.objid,
                             targetos = incident_constr_2.osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), msg_loc, EMS_E_Fail, ret_end);
  
  EMgetconstrtype (incident_constr_1, &constype);
  
  if (constype == MATE)
  {
/*
    stat_OM = om$send(msg = message EMSsubbs.EMtangent_normal(&msg_loc,
                            &mod_env, parms, disp_fac, TN_1),
                            senderid = NULL_OBJID,                          
                            targetid =feature_grid_1.objid,
                            targetos =feature_grid_1.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), msg_loc, EMS_E_Fail, ret_end);
    for (i_vec = 0; i_vec < 3; i_vec++)
    {
      state_vector_1[i_vec] = -TN_1[2][i_vec];
    }

*/
    if( !EMgetsurf( &feature_grid_1, &mod_env, pt, vects, normal ))
        goto ret_end;

    for (i_vec = 0; i_vec < 3; i_vec++)
    {
      state_vector_1[i_vec] = normal[i_vec];
    }
  }
  else if (constype == ALIGN)
  {
/*
    stat_OM = om$send(msg = message EMSparamvc.EMgetgeom 
                           (&msg_loc, opts, &mattyp, mod_env.md_env.matrix,
                            &vecdata),
                            senderid = NULL_OBJID,                          
                            targetid =feature_grid_1.objid,
                            targetos =feature_grid_1.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), msg_loc, EMS_E_Fail, ret_end);

    OM_BLOCK_MOVE (vecdata.vector, state_vector_1, sizeof (IGRvector));        
*/

    if( !EMgetaxis( &feature_grid_1, &mod_env, axis, &typ ))
        goto ret_end;

    for (i_vec = 0; i_vec < 3; i_vec++)
    {
      state_vector_1[i_vec] = (axis[1][i_vec] - axis[0][i_vec]);
    }
  }

  
  EMgetconstrtype (incident_constr_2, &constype);
  
  if (constype == MATE)
  {
/*
    stat_OM = om$send(msg = message EMSsubbs.EMtangent_normal(&msg_loc,
                            &mod_env, parms, disp_fac, TN_2),
                            senderid = NULL_OBJID,                          
                            targetid =feature_grid_2.objid,
                            targetos =feature_grid_2.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), msg_loc, EMS_E_Fail, ret_end);
  
    for (i_vec = 0; i_vec < 3; i_vec++)
    {
      state_vector_2[i_vec] = -TN_2[2][i_vec];
    }
*/
    if( !EMgetsurf( &feature_grid_2, &mod_env, pt, vects, normal ))
        goto ret_end;

    for (i_vec = 0; i_vec < 3; i_vec++)
    {
      state_vector_2[i_vec] = normal[i_vec];
    }
  }
  else if (constype == ALIGN)
  {
/*
    stat_OM = om$send(msg = message EMSparamvc.EMgetgeom 
                           (&msg_loc, opts, &mattyp, mod_env.md_env.matrix,
                            &vecdata),
                            senderid = NULL_OBJID,                          
                            targetid =feature_grid_2.objid,
                            targetos =feature_grid_2.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), msg_loc, EMS_E_Fail, ret_end);
    OM_BLOCK_MOVE (vecdata.vector, state_vector_2, sizeof (IGRvector));        
*/
    if( !EMgetaxis( &feature_grid_2, &mod_env, axis, &typ ))
        goto ret_end;

    for (i_vec = 0; i_vec < 3; i_vec++)
    {
      state_vector_2[i_vec] = (axis[1][i_vec] - axis[0][i_vec]);
    }
  }

  if ((BSnorvec(&bs_rc, state_vector_1)) && (BSnorvec(&bs_rc, state_vector_2)))
    cos_rel_ang = BSdotp(&bs_rc, state_vector_1, state_vector_2);
  else
    EMerr_hndlr (TRUE, msg_loc, EMS_E_Fail, ret_end);

  *prel_angle = acos (cos_rel_ang);
  if( errno == EDOM ) 
    EMerr_hndlr (TRUE, msg_loc, EMS_E_Fail, ret_end);


ret_end:

  EMWRAPUP (msg_loc, stat_OM, "EMgetrelang");
  return (stat_OM);
}

end implementation EMconstr;
