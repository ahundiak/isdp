/*
 *  OVERVIEW
 *  
 *  The function in this file is API for placement of solid of revalution
 *
 *  NOTES
 *       
 *       If the sweep_angle is NULL, then it is sweept for 360 degrees,
 *       and if start_angle is NULL, then it is rotated from the plane
 *       of the profile.
 *       If the profile is open then, the sweep_angle, and the start_angle
 *       have to be equal to NULL and even if some value is sent, It is
 *       ignored.
 *  
 *  HISTORY
 *  Jagan  04/25/96  Creation
 */

class implementation Root;

#include "OMminimum.h"
#include "OMmacros.h"
#include "bsvalues.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "gr.h"
#include "dp.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSascmacros.h"
#include "EMSasopts.h"


#include "PWminimum.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWmodel.h"
#include "PWapi/mx.h"

#include "PWapi/msgsend.h"


#include "EMSmsgdef.h"
#include "EMSasnuc.h"
#include "REaddrmfea.h"
#include "EMSfeadef.h"
#include "EMSasfeatdef.h"
#include "valinfo.h"
#include "PWapi/solrev.h"

#include "bsparameters.h"
#include "bserr.h"
#include "bsdotp.h"
#include "bscvtstclsd.h"
#include "bsnorvec.h"

extern OMuword OPP_GRcurve_class_id;
from  GRgraphics import GRdisplay;

PWresult pwCreateSolidOfRev
(
   PWobjid profile_id,
   PWosnum profile_os,
   PWpoint axis_point,
   PWvector axis_vector,
   struct PWvalueinfo *start_angle, /* if NULL start at prof plane */
   struct PWvalueinfo *sweep_angle, /* if NULL, revolve 360.       */
   PWobjid *rev_solid
)
{ 
  int           i;
  PWresult       result;
  IGRboolean     assoc_placement;
  IGRlong        msg_loc,status;
  IGRlong        sizbuf, nret;
  struct GRmd_env         md_env;
  struct EMSobject_info   loc_curve;
  struct EMSpoint_info    loc_axis[2];
  struct EMSvalue_info    loc_start, loc_sweep;
  struct GRvg_construct    cnstrlist ;
  struct IGRdisplay       display;
  IGRlong                 nbytes_trans,nbytes_in_buff;
  IGRshort                level;
  IGRint                  sts;
  IGRpoint                start_pt,end_pt;
  PWclassid               classid;
  enum  GRdpmode          dpmode;
  struct GRprops          cvprops;
  struct PWvalueinfo     loc_sweep_angle,loc_start_angle;
  struct GRlc_info       curve_info;
  IGRpoint               axis[2];
  PWosnum      save_os;
  PWboolean    stat=0,reset_os=FALSE;

  rev_solid[0] = NULL_OBJID;
 /*
  * Switch OS.
  */
  if((save_os = pwGetActiveOs()) != profile_os)
  {
    stat = pwActivateOS(profile_os);
    OnErrorState ( !(1&stat), result,
                   SetError( PW_K_Pathway, PW_K_InvalidArg), wrap_up);

    reset_os = TRUE;
  }
  
        
  /* get constuction list    */

  status= pwGetActiveModuleEnv(&md_env);
  OnErrorState( !(status & 1),result,PW_K_Error,wrap_up);

  nbytes_in_buff = sizeof(struct IGRdisplay);
  sts = gr$get_active_display (msg = &msg_loc,
                               sizbuf = &nbytes_in_buff,
                               buffer = &display,
                               nret = &nbytes_trans);
  if(!(sts & msg_loc & 1))
  {
     goto wrap_up;
  }

  nbytes_in_buff = sizeof(IGRshort);
  sts = gr$get_active_level(msg = &msg_loc,
                            sizbuf = &nbytes_in_buff,
                            buffer = &level,
                            nret = &nbytes_trans);
  if(!(sts & msg_loc & 1))
   {
     goto wrap_up;
   }

  EMinitvgcnstr( &msg_loc, &md_env,&display, 0,&cnstrlist);
  OnErrorState( !(1&msg_loc), result, PW_K_Error, wrap_up);

  status = EMgetvgcnstr ( NULL, NULL, &md_env, level,
                          &display, 0, 0, &cnstrlist);
  OnErrorState( !status, result, PW_K_Error, wrap_up);


  loc_curve.grid.objid = profile_id; 
  loc_curve.grid.osnum = profile_os;
  
  /* Validate the input data.   */
     
  status = om$is_objid_valid ( objid = profile_id , osnum = profile_os );
  OnErrorState( !status, result, PW_K_InvalidArg, wrap_up);

  classid = omClassidFromObjid ( profile_id ,profile_os);

  if ( ! omIsAncestryValid ( classid , OPP_GRcurve_class_id ))
  {
     OnErrorState( TRUE, result, PW_K_Error, wrap_up);
  }
  loc_curve.env  = md_env;
  
  /*  Get the axis info */

  loc_axis[0].type = EMSdatainfo_numeric;
  for(i = 0; i<3;i++)
  {
    start_pt[i] = axis_point[i];
    loc_axis[0].pt[i] = start_pt[i];
  }

  loc_axis[1].type = EMSdatainfo_numeric;
  for(i = 0 ; i < 3 ; i++)
  {
     end_pt[i] = axis_point[i] + axis_vector[i];
     loc_axis[1].pt[i] = end_pt[i];
  }
  
  /* Find out if the profile is open. For open profiles the sweep
   * angle is always 360, and the start angle is always zero.
   */ 
  result = GetObjectGeomProps(profile_id,profile_os,&md_env,&cvprops);
  if(!cvprops.phy_closed)
  {
    start_angle=NULL;
    sweep_angle=NULL;
  }

  /* if sweep_angle == NULL, then it is always taken as 360
   * and if start_angle == NULL, then it is taken as 0
   */
  if(sweep_angle == NULL)
  {
       loc_sweep_angle.value = 360;
       loc_sweep_angle.type  = value_numeric;
  }
  else 
      loc_sweep_angle = *sweep_angle;
      
  if(start_angle==NULL)
  {
       loc_start_angle.value = 0.0;
       loc_start_angle.type  = value_numeric;
  } 
  else
      loc_start_angle = *start_angle;

  result = PutValueInfo(&loc_sweep_angle,&loc_sweep);
  result = PutValueInfo(&loc_start_angle,&loc_start);
       
  gr$get_associative_flag(buffer = &assoc_placement);
  curve_info.located_obj.objid = profile_id;
  curve_info.located_obj.osnum = profile_os; 
  curve_info.module_info = md_env;
  memcpy(&axis[0],&loc_axis[0].pt[0],sizeof(IGRpoint));
  memcpy(&axis[1],&loc_axis[1].pt[0],sizeof(IGRpoint));
  EFvalidate_surface_of_revolution(
  TRUE,                              //is_solid,
  &curve_info,              
  axis,
  NULL_OBJID,                
  &display,
  &md_env,
  &msg_loc);
  if(msg_loc == EMS_I_Intersect)
  {
    OnErrorState( TRUE, result, PW_K_Error, wrap_up);
  }
  
  /* Place solid of revalution */
  ems$pl_surf_of_revolution(msg = &msg_loc,
             options = assoc_placement ? NULL : EMSasconst_notassociative,
             construction_list = &cnstrlist, 
             curve = &loc_curve,
             axis = loc_axis,
             start_angle = &loc_start,
             sweep_angle = &loc_sweep,
             is_solid = TRUE,
             rev_obj = rev_solid );
  if(!(1 & msg_loc))
  {
   rev_solid[0] = NULL_OBJID;
   OnErrorState( TRUE, result, PW_K_Error, wrap_up);
  }

  /* Display the created solid  */
  dpmode = GRbd;
  status = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                      &md_env.md_env.matrix_type, md_env.md_env.matrix,
                      &dpmode, &md_env.md_id),
                     senderid = NULL_OBJID,
                     targetid = *rev_solid,
                     targetos = profile_os);
  
wrap_up :
  /*
   * Switch back to original OS.
   */
  if(reset_os)
  {
    stat = pwActivateOS(save_os); 
    if(!(1&stat))
      result = SetError( PW_K_Pathway, PW_K_Error);
  }

  PW_Wrapup(result,"pwCreateSolidOfRev ");
  return(result); 

}
end implementation Root;
