/*
 * Application Function:pwCreatSolidOfProj
 * ---------------------------------------
 *   
 *  API for creation of solid of projection given the profile, 
 *  direction of projection, and the distance. 
 *  
 * Input  
 * ------
 *  
 *   PWobjid          profile_id      |
 *                                    | The object id of the profile to 
 *                                    | be projected 
 * 
 *                                     
 *    PWosnum 	      profile_os      | 
 *                                    | The osnum of the profile
 *    
 *   PWpoint  	      startpt         | 
 *                                    | The point frmo where the solid of
 *                                    | projection starts.
 *   
 *   PWboolean	      project_normal  |
 *                                    | If TRUE, the projection is normal to
 *                                    | the plane contained by the profile.
 *
 *   PWvector	      dirvec          | 
 *                                    | The direction in which the projection
 *                                    | is done, and it is considered only when
 *                                    | the 'project_normal == FALSE ' 
 *
 *   struct PWvalueinfo  distance     | 
 *                                    | The distance of projection
 *
 *   PWboolean 	  is_symmetric        | If TRUE, the solid is projected by half
 *                                    | the distance on either sides of the 
 *                                    | plane contained by the profile and in
 *                                    | the direction normal to the plane of 
 *                                    | the profile.
 *  Output
 *  -----  
 * 
 *  GRobjid     	*solid        |  the pointer to the objid of the created
 *                                    |  solid
 *  NOTES
 *  ------
 *     
 *   It does not support the option of creation of solid of proj 'from  plane'
 *   to 'to plane'. This is handled by another API 
 *   'pwCreateSolidOfProjBtnPlanes' 
 *
 *  HISTORY
 * 
 *  Jagan  04/25/96   Creation
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
#include "EMSasopts.h"
#include "EMSmsgdef.h"
#include "EMSasnuc.h"
#include "REaddrmfea.h"
#include "EMSfeadef.h"
#include "EMSasfeatdef.h"
#include "emsdef.h"


#include "PWminimum.h"           
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWmodel.h"
#include "PWapi/mx.h"
#include "PWapi/msgsend.h"
#include "valinfo.h"
#include "PWapi/sfdntrav.h" 
#include "PWapi/solproj.h"


#include "bsparameters.h"
#include "bserr.h"
#include "bsdotp.h"
#include "bscvtstclsd.h"
#include "bsnorvec.h"

struct func_args
{
 int num_sfs;
 PWobjid *sfs_ids;
};

%safe 
static PWresult get_sfs
(
  PWobjid visited_id,
  PWosnum v_os,
  struct func_args *sf_id
);
static PWboolean isSolProj
(
  PWobjid solid_id,
  PWosnum solid_os
);
%endsafe

from GRvg import GRdetplane;
extern OMuword OPP_GRcurve_class_id,OPP_EMSprjcompsf_class_id;
extern OMuword OPP_SKmgr_class_id;
from GRgraphics import GRdisplay;
extern GRclassid OPP_EMSsfsolid_class_id, OPP_EMSproject_class_id;
extern GRclassid OPP_EMSgensolid_class_id;












PWresult pwCreatSolidOfProj
(
   PWobjid      profile_id,
   PWosnum 	profile_os,
   PWboolean 	project_normal,
   PWvector  	dirvec,
   struct PWvalueinfo  distance,
   PWboolean 	is_symmetric,
   PWobjid     	*solid 
)
{
  IGRlong                  msg_loc,status;
  PWboolean                assoc_placement;
  struct GRmd_env          md_env;
  IGRlong                  sizbuf, nret;
  struct GRvg_construct    cnstrlist ; 
  struct GRlc_info         curve;
  PWclassid                classid;
  struct IGRplane          prof_plane;
  PWvector                 prof_normal;
  PWpoint                  prof_point;
  enum GRdpmode            dpmode;
  PWboolean             reset_os=FALSE;
  PWosnum               save_os;
  PWboolean             stat=0;
  BSrc                  rc=BSSUCC;
 
  
  extern void EMinitvgcnstr ( );
  extern IGRboolean EMgetvgcnstr ( );
  extern IGRlong    EMplace_solid_of_projection();
  PWresult                 result;
  struct GRlc_info st_plane, end_plane;
  struct EMSpoint_info base, height;
  struct GRevent base_event,height_event;
  GRobjid *my_solid;
  struct GRprops  cvprops;

  struct IGRdisplay       display;
  IGRshort                level;
  IGRlong                 nbytes_in_buff,nbytes_trans; 
  IGRint sts;


  result = PW_K_Success;
    /*
   * Switch OS.
   */
  if((save_os = pwGetActiveOs()) != profile_os)
  {
    stat = pwActivateOS(profile_os);
    OnErrorState ( !(1&stat), result,
                   SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

    reset_os = TRUE;
  }
  BSnorvec(&rc,dirvec);


  my_solid = (GRobjid *)malloc(1*sizeof(GRobjid));
  sizbuf = sizeof(struct GRmd_env);
  status = gr$get_module_env(msg = &msg_loc,
                             sizbuf = &sizbuf,
                             buffer = &md_env,
                             nret   = &nret);

  OnErrorState( !(status & 1),result,PW_K_Error,wrapup);

  /* If the placement of solid of projection is symmetric, then
     the solid is placed normal to the plane of the profile
     with the thickness equal to half the distance on either sides
     if it is not symmetric, and it is normal it places the 
     solid normal to the plane of the profile.other wise
     it projects the profile in the dirction specified.
  */

  if(is_symmetric == TRUE)
  {
     if(distance.value < 0.0) distance.value *= -1;
     base_event.event.value = distance.value;
     base_event.located_object[0].located_obj.objid = NULL_OBJID;
     base_event.subtype = 1;
     base.ptevent = &base_event;
     base.type =  EMSdatainfo_numeric;

     height.type = EMSdatainfo_numeric; 
     height.ptevent = &height_event;

     st_plane.located_obj.objid = NULL_OBJID;
     end_plane.located_obj.objid = NULL_OBJID;

      prof_plane.point = prof_point;
      prof_plane.normal= prof_normal;
      status = om$send(msg = message GRvg.GRdetplane ( &msg_loc,
                                                     &md_env.md_env.matrix_type,
                                                     md_env.md_env.matrix,
                                                     &prof_plane),
                     senderid = NULL_OBJID,
                     targetid = profile_id,
                     targetos = profile_os );
      OnErrorState(!(1 & status & msg_loc),result,PW_K_Error, wrapup);
      memcpy( &dirvec[0], &prof_plane.normal[0], sizeof(PWvector));
  }
  else
  {
    if(!project_normal)
    {
      base.type =  EMSdatainfo_event; 
      base_event.event.button.x = 0;  //startpt[0];       
      base_event.event.button.y = 0;  //startpt[1]; 
      base_event.event.button.z = 0;  //startpt[2];
      base_event.located_object[0].located_obj.objid = NULL_OBJID;
      base.ptevent = &base_event; 

      height.type = EMSdatainfo_event;
      height_event.located_object[0].located_obj.objid = NULL_OBJID;
      height_event.event.button.x = dirvec[0] * distance.value; //+startpt[0];  
      height_event.event.button.y = dirvec[1] * distance.value; //+startpt[1];
      height_event.event.button.z = dirvec[2] * distance.value; //+startpt[2];
      height.ptevent = &height_event;

      st_plane.located_obj.objid = NULL_OBJID;
      end_plane.located_obj.objid = NULL_OBJID;

     }
     else
     {
      prof_plane.point = prof_point;
      prof_plane.normal= prof_normal;
      status = om$send(msg = message GRvg.GRdetplane ( &msg_loc,
                                                     &md_env.md_env.matrix_type,
                                                     md_env.md_env.matrix,
                                                     &prof_plane),
                     senderid = NULL_OBJID,
                     targetid = profile_id,
                     targetos = profile_os );
      OnErrorState(!(1 & status & msg_loc),result,PW_K_Error, wrapup);
      memcpy( &dirvec[0], &prof_plane.normal[0], sizeof(PWvector));
      base.type =  EMSdatainfo_event; 
      base_event.event.button.x = 0; //startpt[0];       
      base_event.event.button.y = 0; //startpt[1]; 
      base_event.event.button.z = 0; //startpt[2];
      base_event.located_object[0].located_obj.objid = NULL_OBJID;
      base.ptevent = &base_event; 

      height.type = EMSdatainfo_event;
      height_event.located_object[0].located_obj.objid = NULL_OBJID;
      height_event.event.button.x = dirvec[0] * distance.value; //+startpt[0];  
      height_event.event.button.y = dirvec[1] * distance.value; //+startpt[1];
      height_event.event.button.z = dirvec[2] * distance.value; //+startpt[2];
      height.ptevent = &height_event;

      st_plane.located_obj.objid = NULL_OBJID;
      end_plane.located_obj.objid = NULL_OBJID;
     }                  
    }
  
  /*  Validate the input data   
      1.  Is it valid obj ?
      2.  Is it profile obj ?
      3.  Is it closed profile ?
  */
  status = om$is_objid_valid ( objid = profile_id , osnum = profile_os );
  OnErrorState( !status, result, PW_K_InvalidArg, wrapup);

  classid = omClassidFromObjid ( profile_id ,profile_os);
    
  if ( ! omIsAncestryValid ( classid , OPP_GRcurve_class_id ))
  {
     OnErrorState( TRUE, result, PW_K_Error, wrapup);
  }

  result = GetObjectGeomProps(profile_id,profile_os,&md_env,&cvprops);
  if(!cvprops.phy_closed)
      OnErrorState( TRUE, result, PW_K_Error, wrapup);
  
  /* Get construction_list   */
  /* Get active display */

  nbytes_in_buff = sizeof(struct IGRdisplay);
  sts = gr$get_active_display (msg = &msg_loc,
                               sizbuf = &nbytes_in_buff,
                               buffer = &display,
                               nret = &nbytes_trans);
  OnErrorState( !(sts & 1),result,PW_K_Error,wrapup);

  /* Get active level */

  nbytes_in_buff = sizeof(IGRshort);
  sts = gr$get_active_level(msg = &msg_loc,
                            sizbuf = &nbytes_in_buff,
                            buffer = &level,
                            nret = &nbytes_trans);
  OnErrorState( !(sts & 1),result,PW_K_Error,wrapup);
 
  EMinitvgcnstr( &msg_loc, &md_env,&display, 0,&cnstrlist);
  OnErrorState( !(1&msg_loc), result, PW_K_Error, wrapup);

  status = EMgetvgcnstr ( NULL, NULL, &md_env, level,
                        &display, 0, 0, &cnstrlist);
  OnErrorState( !status, result, PW_K_Error, wrapup);

  cnstrlist.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;

  gr$get_associative_flag(buffer = &assoc_placement);

  curve.located_obj.objid = profile_id;
  curve.located_obj.osnum = profile_os;
  curve.module_info       = md_env ;
  
  /* Place solid of projection           */

  status = EMplace_solid_of_projection (&msg_loc,
                            assoc_placement ? NULL : EMSasconst_notassociative,
                            cnstrlist.env_info, cnstrlist.level,
                            cnstrlist.display, cnstrlist.class_attr,
                            cnstrlist.name, &curve, &base, &height,
                            &st_plane, &end_plane, my_solid);
            if(!(1 & status & msg_loc)) goto wrapup;

  /* Display the solid */
  dpmode = GRbd;
  status = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                      &md_env.md_env.matrix_type, md_env.md_env.matrix,
                      &dpmode, &md_env.md_id),
                     senderid = NULL_OBJID,
                     targetid = *my_solid,
                     targetos = profile_os);

  if (status)
  {
     solid[0] = *my_solid;
  }
wrapup :
  /*
   * Switch back to original OS.
   */
  if(reset_os)
  {
    stat = pwActivateOS(save_os);
    if(!(1&stat))
      result = SetError( PW_K_Pathway, PW_K_Error);
  }

 PW_Wrapup(result,"pwCreatSolidOfProj");
 return( result );

}

/* 
 * This API is for creating solid of projection between the given planes
 */

PWresult pwCreateSolidOfProjBtnPlanes
(
   PWobjid profile_id,
   PWosnum profile_os,
   PWboolean proj_normal,
   PWvector dir_vector, //if proj_normal==TRUE, approx dir_vec accepted,
                        // else dir_vec is absolute.
   PWobjid start_plane,  // if NULL, use prof plane.
   PWobjid end_plane,
   PWobjid *mod_solid
)
{
  IGRlong                  msg_loc,status;
  PWboolean                assoc_placement;
  struct GRmd_env          md_env;
  IGRlong                  sizbuf, nret;
  struct GRvg_construct    cnstrlist ; 
  struct GRlc_info         curve;
  PWclassid                classid;
  struct IGRplane          prof_plane;
  PWvector                 prof_normal;
  PWpoint                  prof_point;
  enum GRdpmode dpmode;
  
  extern void EMinitvgcnstr ( );
  extern IGRboolean EMgetvgcnstr ( );
  extern IGRlong    EMplace_solid_of_projection();
  PWresult                 result;
  struct GRlc_info st_plane, ed_plane;
  struct EMSpoint_info base, height;
  struct GRevent base_event,height_event;
  GRobjid *my_solid;
  struct GRprops  cvprops;

  struct IGRdisplay       display;
  IGRshort                level;
  IGRlong                 nbytes_in_buff,nbytes_trans; 
  IGRint sts;
   PWboolean             reset_os=FALSE;
   PWosnum               save_os;
 PWboolean             stat=0;


  result = PW_K_Success;
    /*
   * Switch OS.
   */
  if((save_os = pwGetActiveOs()) != profile_os)
  {
    stat = pwActivateOS(profile_os);
    OnErrorState ( !(1&stat), result,
                   SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

    reset_os = TRUE;
  }


  my_solid = (GRobjid *)malloc(1*sizeof(GRobjid));
  sizbuf = sizeof(struct GRmd_env);
  status = gr$get_module_env(msg = &msg_loc,
                             sizbuf = &sizbuf,
                             buffer = &md_env,
                             nret   = &nret);

  OnErrorState( !(status & 1),result,PW_K_Error,wrapup);
    base.type =  EMSdatainfo_name;
    base.ptevent = &base_event;
    height.type = EMSdatainfo_event;
    height.ptevent = &height_event;

    st_plane.located_obj.objid =  start_plane;
    st_plane.located_obj.osnum =  profile_os;
    ed_plane.located_obj.objid = end_plane;
    ed_plane.located_obj.osnum = profile_os;
  /*  Validate the input data   
      1.  Is it valid obj ?
      2.  Is it profile obj ?
      3.  Is it closed profile ?
  */
  status = om$is_objid_valid ( objid = profile_id , osnum = profile_os );
  OnErrorState( !status, result, PW_K_InvalidArg, wrapup);

  classid = omClassidFromObjid ( profile_id ,profile_os);
    
  if ( ! omIsAncestryValid ( classid , OPP_GRcurve_class_id ))
  {
     OnErrorState( TRUE, result, PW_K_Error, wrapup);
  }

  result = GetObjectGeomProps(profile_id,profile_os,&md_env,&cvprops);
  if(!cvprops.phy_closed)
      OnErrorState( TRUE, result, PW_K_Error, wrapup);
  
  /* Get construction_list   */
  /* Get active display */

  nbytes_in_buff = sizeof(struct IGRdisplay);
  sts = gr$get_active_display (msg = &msg_loc,
                               sizbuf = &nbytes_in_buff,
                               buffer = &display,
                               nret = &nbytes_trans);
  OnErrorState( !(sts & 1),result,PW_K_Error,wrapup);

  /* Get active level */

  nbytes_in_buff = sizeof(IGRshort);
  sts = gr$get_active_level(msg = &msg_loc,
                            sizbuf = &nbytes_in_buff,
                            buffer = &level,
                            nret = &nbytes_trans);
  OnErrorState( !(sts & 1),result,PW_K_Error,wrapup);
 
  EMinitvgcnstr( &msg_loc, &md_env,&display, 0,&cnstrlist);
  OnErrorState( !(1&msg_loc), result, PW_K_Error, wrapup);

  status = EMgetvgcnstr ( NULL, NULL, &md_env, level,
                        &display, 0, 0, &cnstrlist);
  OnErrorState( !status, result, PW_K_Error, wrapup);

  cnstrlist.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;

  gr$get_associative_flag(buffer = &assoc_placement);

  curve.located_obj.objid = profile_id;
  curve.located_obj.osnum = profile_os;
  curve.module_info       = md_env ;
  st_plane.module_info = md_env;
  ed_plane.module_info = md_env;

  status = EMplace_solid_of_projection (&msg_loc,
                            assoc_placement ? NULL : EMSasconst_notassociative,
                            cnstrlist.env_info, cnstrlist.level,
                            cnstrlist.display, cnstrlist.class_attr,
                            cnstrlist.name, &curve, &base, &height,
                            &st_plane, &ed_plane, my_solid);
            if(!(1 & status & msg_loc)) goto wrapup;

  dpmode = GRbd;
  status = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                      &md_env.md_env.matrix_type, md_env.md_env.matrix,
                      &dpmode, &md_env.md_id),
                     senderid = NULL_OBJID,
                     targetid = *my_solid,
                     targetos = profile_os);

  if (status)
  {
     mod_solid[0] = *my_solid;
  }
wrapup :
 PW_Wrapup(result,"pwCreatSolidOfProj");
  /*
   * Switch back to original OS.
   */
  if(reset_os)
  {
    stat = pwActivateOS(save_os);
    if(!(1&stat))
      result = SetError( PW_K_Pathway, PW_K_Error);
  }

 return( result );

}

/* 
 * This API is for getting the number of side surfaces in solid of projection
 */

int pwNumSideSfs
(
  PWobjid solid,
  PWosnum os
)
{
  int i;
  PWboolean is_solproj;
  struct func_args  f_args;

  f_args.num_sfs = 0;
  f_args.sfs_ids = NULL;

  /* check it is solproj or not */

  is_solproj = isSolProj(solid,os);
  if(!is_solproj) return(0);

  /* get its surfaces and num_sfs */
 
   pwTraverseSfSfs(solid,os,(PWresult (*)())get_sfs,&f_args);
   return((f_args.num_sfs) - 2); 
}

/*
 * This API is for getting the id of the end caps. It is_start_cap is TRUE
 * It returns the starting cap otherwise the objid of the ending cap
 */

 PWobjid pwCapsf
(
  PWobjid solid,
  PWosnum os,
  PWboolean is_start_cap
)
{
  struct func_args f_args; 
  PWboolean    is_solproj;
  f_args.num_sfs = 0;
  f_args.sfs_ids = NULL;
  is_solproj = isSolProj(solid,os);
  if(!is_solproj) return(0);
  pwTraverseSfSfs(solid,os,(PWresult (*)())get_sfs,&f_args);
  if(is_start_cap) return(f_args.sfs_ids[f_args.num_sfs - 1]);
  else return(f_args.sfs_ids[f_args.num_sfs - 2]);
}

/*
 * Given the index of the side_faces it returns the objid of that face
 */

PWobjid pwSideSf
(
  PWobjid solid,
  PWosnum os,
  int side_index  
)
{
 struct func_args f_args;
 PWboolean    is_solproj;
 f_args.num_sfs = 0;
 f_args.sfs_ids = NULL;
 is_solproj = isSolProj(solid,os);
 if(!is_solproj) return(0);

 pwTraverseSfSfs(solid,os,(PWresult (*)())get_sfs,&f_args);
 return(f_args.sfs_ids[side_index - 1]);
}


static PWresult get_sfs
(
  PWobjid visited_id,
  PWosnum v_os,
  struct func_args *sf_id
)
{
  if(sf_id->num_sfs == 0)
      sf_id->sfs_ids = (PWobjid *)malloc(sizeof(PWobjid));
  else
      sf_id ->sfs_ids = (PWobjid *)realloc(sf_id->sfs_ids,
                                        ((sf_id->num_sfs +1)*sizeof(PWobjid)));
  sf_id->sfs_ids[(sf_id->num_sfs)++]=visited_id;
  return(1);
}


static PWboolean isSolProj
(
  PWobjid solid_id,
  PWosnum solid_os
)
{
  PWclassid classid;
  IGRlong   status;
  PWresult  result;
  PWboolean is_solproj = FALSE;
  status = om$is_objid_valid ( objid = solid_id , osnum = solid_os );
  OnErrorState( !status, result, PW_K_InvalidArg, wrapup);

  classid = omClassidFromObjid ( solid_id ,solid_os);
  if( omIsAncestryValid ( classid , OPP_EMSsfsolid_class_id)
      || omIsAncestryValid ( classid , OPP_EMSgensolid_class_id))
  {
    is_solproj = TRUE;
    printf("It is EMSsfsolid \n");
  }
  wrapup:
  return(is_solproj);
}

end implementation Root;
