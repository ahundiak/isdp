/*
 *  OVERVIEW
 *
 *  The function in this file is API for Thin_wall 
 *
 *  NOTES
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
#include "ECmsg.h"
#include "msmacros.h"
#include "REshsolid.h"
#include "nddef.h"


#include "PWminimum.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/mx.h"
#include "PWapi/msgsend.h"


#include "emsdef.h"
#include "EMSmsgdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSfeadef.h"
#include "EMSasfeatdef.h"
#include "PWmodel.h"
#include "valinfo.h"
#include "PWapi/sfdntrav.h"
#include "PWapi/featquery.h"
#include "PWapi/thinwall.h"

#include "bsparameters.h"
#include "bserr.h"
#include "bsdotp.h"
#include "bscvtstclsd.h"
#include "bsnorvec.h"
static void get_parent_types();

struct dimension_info
{
  GRobjid    surf;
  IGRpoint   uv_point;
  OMuword    view_index;
};

struct func_args
{
 int num_sfs;
 PWobjid *sfs_ids;
};



extern OMuword OPP_EMSsolid_class_id;
extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSsurface_class_id;  
extern GRclassid OPP_EMSsfsolid_class_id;
extern GRclassid OPP_EMSprjcompsf_class_id;
extern GRclassid OPP_EMSrevol_class_id;
extern GRclassid OPP_EMSrevcompsf_class_id;
extern GRclassid OPP_EMSshslbool_class_id;

from GRgraphics import GRdisplay;
from GRgraphics import GRgetprops; 
from GRowner    import GRget_number_components;
from NDnode     import NDget_objects;
from EMSassoc   import EMget_parent_info,EMget_info;

PWresult pwThinWall
(
 PWobjid surface_entity,
 PWosnum os,
 struct PWvalueinfo *common_thickness,
 PWboolean is_offset_symmetric,
 PWboolean offset_inside,
 int       num_open_sfs,
 PWobjid   *opensfs,
 int       num_spel_sfs_groups,
 struct PWspecialsfs *special_sfs,
 PWobjid *mod_solid
)
{
  PWresult             result;
  PWboolean            is_solid = FALSE;
  IGRboolean           associative_flag = TRUE, special_solid = FALSE ;
  IGRlong              stat_OM,msg_loc,status;
  PWclassid            classid;
  GRclassid            locobj_classid;
  struct GRmd_env      md_env;
  struct EMSvalue_info common_tks;
  IGRint num_spec_tks = 0 ;  
  struct EMSvalue_info *spectks = NULL;
  IGRint *num_sfs_per_tk = NULL;
  GRobjid *spec_surf_ids = NULL;
  struct dimension_info *dim_info=NULL;
  int i,j,total_spec_sfs = 0;
  IGRlong sizbuf,nret;
  int index = 0;
  IGRboolean is_member=FALSE,found=NULL;
  IGRint list_size,sf_ind;
  GRobjid current_sf, *common_surfaces = NULL;
  GRspacenum thisos;
  PWobjid sf_id1;
  struct func_args sf_ids;
  PWosnum      save_os;
  PWboolean    stat=0,reset_os=FALSE;
  struct  GRid org_solid;
 
  PWresult count(PWobjid visited_id,PWosnum v_os, PWobjid *sf_id);
  PWboolean is_sfs_valid( PWobjid surface_entity,
                          PWosnum os,PWboolean *is_solid);
  //PWresult get_sfs( PWobjid v_id,PWosnum v_os,struct func_args *sf_id); 
 /*
   * Switch OS.
   */
  if((save_os = pwGetActiveOs()) != os)
  {
    stat = pwActivateOS(os);
    OnErrorState ( !(1&stat), result,
                   SetError( PW_K_Pathway, PW_K_InvalidArg), wrap_up);

    reset_os = TRUE;
  }

  org_solid.objid=surface_entity;
  org_solid.osnum=os;
  sf_ids.num_sfs = 0;
  sf_ids.sfs_ids = NULL;  
  pwTraverseSfSfs(surface_entity,os,(PWresult (*)())count,&sf_id1);
  /*pwTraverseSfSfs(surface_entity,os,(PWresult (*)())get_sfs,&sf_ids);
  for(i=0;i<sf_ids.num_sfs;i++)
  {
    if(i== sf_ids.num_sfs - 1) goto wrap_up;
  }
  */
  PutValueInfo(common_thickness,&common_tks);
  stat= pwGetActiveModuleEnv(&md_env);
  OnErrorState ( !(1&stat), result,
                SetError( PW_K_Pathway, PW_K_InvalidArg), wrap_up);
/*
  status = gr$get_module_env(msg = &msg_loc,
                          sizbuf = &sizbuf,
                          buffer = &md_env,
                          nret   = &nret);
  OnErrorState( !(status & 1),result,PW_K_Error,wrap_up);
*/

  /* Validate the object */
  /* status = om$is_objid_valid ( objid = surface_entity , osnum = os );

  OnErrorState( !status, result, PW_K_InvalidArg, wrap_up);

  classid = omClassidFromObjid ( surface_entity ,os);
  if(omIsAncestryValid (classid, OPP_EMSshslbool_class_id))
  {
     ex$message (msgnumb = EMS_F_ThOpAlPerf);
     goto wrap_up;
  }
  if ( omIsAncestryValid ( classid , OPP_EMSsolid_class_id ))
  {
     is_solid = TRUE;
  }
  else 
    if (( omIsAncestryValid ( classid , OPP_EMSsubbs_class_id )) ||
        ( omIsAncestryValid ( classid , OPP_EMSsurface_class_id )))
     {
        is_solid = FALSE;
        num_spel_sfs_groups = 0;
        num_open_sfs = 0;
     }
   else 
     OnErrorState( TRUE, result, PW_K_Error, wrap_up);
  */
   if(is_sfs_valid(surface_entity,os,&is_solid))
   {
     if(!is_solid)
     {
       num_spel_sfs_groups = 0;
       num_open_sfs = 0;
     } 
   }
   else
   {
     OnErrorState( TRUE, result, PW_K_InvalidArg, wrap_up); 
   }
  num_sfs_per_tk = (int *)malloc(num_spel_sfs_groups * (sizeof(int)));
  spectks = (struct EMSvalue_info *)malloc(num_spel_sfs_groups * 
                                           sizeof(struct EMSvalue_info));
  /* Check whether the input object is a pure solid of revolution or
     projection. If so, donot group tangent surfaces. 
  */

  stat_OM = om$get_classid(objid = surface_entity,
                           osnum = os,
                           p_classid = &locobj_classid);
  if (!(1&stat_OM)) goto wrap_up;

  /* Special solids are those which have the special offset
     algorithms. These should be tested for associativity. 
  */

  special_solid = FALSE;
  if(locobj_classid == OPP_EMSsfsolid_class_id)
  {
    IGRshort props;
    struct GRid tmpgrid;
    GRclassid   surf_classid;
    OM_S_CHANSELECT chan_to_comps;
    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);

    /*
     * Get the id of the object on channel index zero of
     * the 'sfsolid', and check its class. if it is an
     * associative surface of projection or revolution
     * it qualifies as a special solid.
     */
     stat_OM =  om$get_objid_at_index (objid = surface_entity,
                                       osnum = os,
                                       p_chanselect = &chan_to_comps,
                                       index = 0,
                                       objidaddr = &tmpgrid.objid,
                                       osnumaddr = &tmpgrid.osnum);
     /* EMerr_hndlr(EMSerror (stat_OM), *msg, EMS_E_Fail, wrap_up); */

     stat_OM = om$get_classid(objid = tmpgrid.objid,
                              osnum = tmpgrid.osnum,
                              p_classid = &surf_classid);
     /*    EMerr_hndlr(EMSerror (stat_OM), *msg, EMS_E_Fail, wrap_up); */

     if((surf_classid == OPP_EMSrevcompsf_class_id) ||
        (surf_classid == OPP_EMSprjcompsf_class_id))
     {
       stat_OM = om$send(msg = message GRgraphics.GRgetprops
                        (&msg_loc, &props),
                         senderid = NULL_OBJID,
                         targetid = surface_entity,
                         targetos = os);

     /* EMerr_hndlr(EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,wrap_up); */
      if(props & GRIS_ASSOCIATIVE)
      {
         special_solid = TRUE;
      }
    } /* if((surf_class... */
  }

  /* Store the open surface information */

      if((num_open_sfs > 0) && !special_solid)
      {
          GRspacenum    surface_osnum;
          GRobjid    *new_surface = NULL;
          IGRint    num_new_sfs = 0,added_sfs = 0;
          surface_osnum = os;
          for(i=0;i<num_open_sfs;i++)
          {
               EMget_tgt_surfaces(&msg_loc,opensfs[i],surface_osnum,
                                 &new_surface, &num_new_sfs,
                                 &md_env.md_env.matrix_type,
                                 md_env.md_env.matrix);
               if(num_new_sfs > 0)
               {
                        EMattach_surfaces(&opensfs,num_open_sfs,
                            new_surface,num_new_sfs,&added_sfs);
                            num_open_sfs += added_sfs;
                            om$dealloc(ptr = new_surface);
                }
           } /* end of for(i=0; i<num_sfs1....) */
       } /* end of if(!special_solid) */


 /* Check for Null_Solid due to open sfs */
  if(num_open_sfs > 0)
  {
    IGRint total_num_sfs;
    IGRboolean is_disjoint=0;
    /*
     * get  count of number of surfaces of this composite surface/solid
     */
    stat_OM= om$send( msg = message GRowner.GRget_number_components(
                                         &msg_loc, &total_num_sfs),
                      senderid = NULL_OBJID,
                      targetid = surface_entity,
                      targetos = os );
   /*   EMerr_hndlr(! (1 & stat_OM & msg_loc), *msg, EMS_E_Fail, wrap_up);*/
   /* If number of open surfaces greater than equal to 'total_num_sfs'
    * the resulting Thinwall will be a NULL SOLID
    */
   if(num_open_sfs >= total_num_sfs)
   {
    ex$message(msgnumb = EMS_F_NullSolidOpenSfs);
    goto wrap_up;
   }
   /*
    * Ckeck if the open sfs result in Dis joint solid
    */
           EMfind_disjointness(&msg_loc, &org_solid,
                            opensfs,&md_env,
                            num_open_sfs, 0, &is_disjoint);
           if(is_disjoint)
           {
              ex$message(msgnumb = EMS_F_WrnDsjSolid);
              goto wrap_up;
           }

  } 
       /**---Do same for the special_sfs----------**/

 index = 0;
 for(i = 0 ; i < num_spel_sfs_groups ; i++)
 {
   PutValueInfo(&special_sfs[i].thickness, &spectks[i]);
   num_sfs_per_tk[i] = special_sfs[i].num_sfs;
   if(num_sfs_per_tk[i] > 0)
   {
     GRspacenum    surface_osnum;
     GRobjid    *new_surface = NULL;
     IGRint    num_new_sfs = 0,added_sfs = 0;
     surface_osnum = os;
     for(j = 0; j<num_sfs_per_tk[i];j++)
     {
        EMget_tgt_surfaces(&msg_loc,special_sfs[i].objids[j],surface_osnum,
                                 &new_surface, &num_new_sfs,
                                 &md_env.md_env.matrix_type,
                                 md_env.md_env.matrix);
        if(num_new_sfs > 0)
        {
            EMattach_surfaces(&(special_sfs[i].objids),num_sfs_per_tk[i],
                             new_surface,num_new_sfs,&added_sfs);
            num_sfs_per_tk[i] += added_sfs;
            om$dealloc(ptr = new_surface);
         }
     } /* end of for(i=0; i<num_sfs1....) */
    }
   total_spec_sfs += num_sfs_per_tk[i];
   if(spec_surf_ids == NULL) 
      spec_surf_ids = (PWobjid *)malloc(num_sfs_per_tk[i] * sizeof(PWobjid));
   else 
      spec_surf_ids = (PWobjid *)realloc(spec_surf_ids,
                                         total_spec_sfs * sizeof(PWobjid));
    for(j = 0; j<num_sfs_per_tk[i];j++)
    {
      spec_surf_ids[index] = special_sfs[i].objids[j];
      index++;
    }
  }
  dim_info = (struct dimension_info *)om$malloc(
              size =(num_spel_sfs_groups +1)*sizeof(struct dimension_info));
  for(i=0; i<num_spel_sfs_groups +1;i++)
  {
    dim_info[i].uv_point[0]=0.5;
    dim_info[i].uv_point[1]=0.5;
    dim_info[i].uv_point[2]=0.5;
    dim_info[i].view_index = 1; 
    if(i != 0)
    {
      dim_info[i].surf = special_sfs[i-1].objids[0];
    }
  }
  common_surfaces = (GRobjid *) om$malloc (size = sizeof(GRobjid));
  common_surfaces[0] = sf_id1;
  found = FALSE;
  sf_ind = 0;
  list_size = 1;
  thisos = os;

  while (!found)
  {
    current_sf = common_surfaces[sf_ind];
    is_member = FALSE;
    is_member |= EFis_member(current_sf, num_open_sfs, opensfs);
    is_member |= EFis_member(current_sf,
                                 total_spec_sfs, spec_surf_ids);
    if(is_member)
    {
      if(sf_ind >= list_size-1)
      {
        stat_OM = EFget_surfaces_across_common_edges(&msg_loc, thisos,
                                           current_sf,
                                           &list_size,
                                           &common_surfaces);
     //  EMerr_hndlr(!(stat_OM&1), msg_loc, stat_OM, wrap_up);
    }
    sf_ind++;
  }
  else
  {
     found = TRUE;
  }
 }
 dim_info[0].surf= current_sf; 


  /* Call the driving function place_shell */
  stat_OM = EMplace_shell (&msg_loc,
                  !( associative_flag)? EMSasconst_notassociative :
                                                  NULL,
  
                   &md_env, NULL, surface_entity,
                   is_offset_symmetric,
                   offset_inside,
                   is_solid,
                   &common_tks,
                   num_spel_sfs_groups, 
                   spectks,
                   num_sfs_per_tk,
                   spec_surf_ids,
                   dim_info,
                   num_open_sfs, opensfs, mod_solid);

    /* Display the created solid, if it is a solid from a surface/
         Composite Surface.
    */
    if(!is_solid)
    {
      enum GRdpmode dpmode;
      dpmode = GRbd;
      stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                      &md_env.md_env.matrix_type, md_env.md_env.matrix, 
                      &dpmode, &md_env.md_id),
                     senderid = NULL_OBJID,
                     targetid = *mod_solid,
                     targetos = os);
    /*  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,wrap_up);    */
    } /* end of if(!is_solid)  */

wrap_up:
  /*
   * Switch back to original OS.
   */
  if(reset_os)
  {
    stat = pwActivateOS(save_os);
    if(!(1&stat))
      result = SetError( PW_K_Pathway, PW_K_Error);
  }

  if(spectks) free(spectks);
  if(spec_surf_ids) free(spec_surf_ids);
  PW_Wrapup (result, "pwThinWall");
  return( result );
}

PWresult count
(
  PWobjid visited_id,
  PWosnum v_os,
  PWobjid *sf_id
)
{
  static i=0;
  sf_id[0]=visited_id;
  return(1);
}

 PWboolean is_sfs_valid
(
  PWobjid   surface_entity,
  PWosnum   os,
  PWboolean *is_solid
)
{
  PWresult result;
  IGRlong  status;
  PWclassid classid;
  PWboolean is_valid = TRUE; 
  PWboolean is_feature=FALSE;
  PWboolean is_fea_active=FALSE;
    
  status = om$is_objid_valid ( objid = surface_entity , osnum = os );
  if(!status) goto wrap_up;

  is_feature=pwIsFeatureState(surface_entity,os,NULL);
  if(is_feature)
     is_fea_active = pwIsFeatureActive(surface_entity,os);
  classid = omClassidFromObjid ( surface_entity ,os);
  if(is_fea_active)
  {
    if(omIsAncestryValid (classid, OPP_EMSshslbool_class_id))
    {
     is_valid = FALSE;
     ex$message (msgnumb = EMS_F_ThOpAlPerf);
     goto wrap_up;
    }
  }
  else
  {
    if(is_feature)
    {
      is_valid = FALSE;
      goto wrap_up;
    }
  }

  if ( omIsAncestryValid ( classid , OPP_EMSsolid_class_id ))
  {
     *is_solid = TRUE;
     is_valid = TRUE;
  }
  else 
    if (( omIsAncestryValid ( classid , OPP_EMSsubbs_class_id )) ||
        ( omIsAncestryValid ( classid , OPP_EMSsurface_class_id )))
     {
        *is_solid = FALSE;
        is_valid = TRUE;
     }
   else 
     OnErrorState( TRUE, result, PW_K_Error, wrap_up);
wrap_up:
  PW_Wrapup (result, "pwThinWall");
  return( is_valid );
}

/* ----------- Just to test
PWresult get_sfs 
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
*/
PWresult pwQueryThinWall
(
  PWobjid feature_id,
  PWosnum os,
  struct PWvalueinfo *common_thickness,
  PWboolean *is_offset_symmetric,
  PWboolean *is_offset_inside,
  int *num_open_sfs,
  PWobjid **opensfs,
  int *num_spel_sfs_groups,
  struct PWspecialsfs **special_sfs,
  PWobjid *base_sf_entity
)
/*
void get_num_parents(
PWobjid objid,
PWosnum os
)
*/
{
  PWresult             result;
  struct GRid *p_parentobjs=NULL;
  int num_parents = 0,i,num_mult_tks=0,num_opensfs=0,j,index;
  IGRlong stat,msg_loc;
  unsigned int *p_parenttypes;
  union EMSparent_info *p_parents;
  struct EMSshell_solid recomp_info,*p_recomp_info = NULL;
  unsigned int info_size=0,type=0;
  PWclassid classid;

  classid = omClassidFromObjid ( feature_id ,os);
  if(! omIsAncestryValid (classid, OPP_EMSshslbool_class_id))
  {
    OnErrorState(TRUE, result, PW_K_Error, wrapup);
  }  
  /*
   * Get the recompute info for the feature.
   */
  stat = om$send (msg = message EMSassoc.EMget_info(&msg_loc,
                                                    NULL,
                                                    &type,
                                                    &info_size,
                                                    (char **)&p_recomp_info),
                  senderid = NULL_OBJID,
                  targetid = feature_id,
                  targetos = os );
 OnErrorState( !(1 & stat & msg_loc), result, PW_K_Error, wrapup); 
 if(p_recomp_info)
 { 
  is_offset_symmetric[0]=p_recomp_info->is_symmetric;
  is_offset_inside[0]=p_recomp_info->inward;
 }
  stat = om$send (msg = message NDnode.NDget_objects(ND_IN_BUF | ND_ROOT,
                                                       NULL, 0,
                                                       &p_parentobjs, 0,
                                                       MAXINT, &num_parents),
                    senderid = NULL_OBJID,
                    targetid = feature_id,
                    targetos = os );
  p_parenttypes=(unsigned int *)malloc(num_parents*sizeof(unsigned int)); 
  p_parents=(union EMSparent_info *)malloc(num_parents*
                                           sizeof(union EMSparent_info));
   get_parent_types(num_parents,p_recomp_info,p_parenttypes); 
/*   p_parenttypes[0] = EMSdistance;
  for(i = 1 ; i< num_parents ; i++)
     p_parenttypes[i] = EMSgrid;
 */


    stat = om$send (msg = message EMSassoc.EMget_parent_info(&msg_loc,
                                                           NULL,
                                                           num_parents,
                                                           NULL,
                                                           p_parenttypes,
                                                           p_parents ),
                  senderid = NULL_OBJID,
                  targetid = feature_id,
                  targetos = os );
   common_thickness[0].type = value_numeric;
   common_thickness[0].value=p_parents[0].value;
   base_sf_entity[0] = p_parents[num_parents - 1].grobj.grid.objid;
   num_mult_tks = p_recomp_info->num_mult_tks;
   num_spel_sfs_groups[0]=num_mult_tks;
   index = 1;
   special_sfs[0] = (struct PWspecialsfs *)malloc((num_mult_tks + 1) * 
                                                  sizeof(struct PWspecialsfs));
   if(num_mult_tks)
   {
    for(i=0;i<num_mult_tks;i++)
    {
     special_sfs[0][i].thickness.type  = value_numeric;
     special_sfs[0][i].thickness.value = p_parents[index].value;
     special_sfs[0][i].num_sfs=p_recomp_info->sfs_views[index].
                                               num_sfs_per_mult_tks;
     index++;
    }
    index++;
    for(i=0;i<num_mult_tks;i++)
    {
       special_sfs[0][i].objids = (PWobjid *)malloc(p_recomp_info->
                         sfs_views[i+1].num_sfs_per_mult_tks * sizeof(PWobjid));
       for(j=0;j<p_recomp_info->sfs_views[i+1].num_sfs_per_mult_tks;j++)  
       {
         special_sfs[0][i].objids[j]=p_parents[index].grobj.grid.objid;
         index++;
       }
     }
   }
   else
   index++;
  /* It stores a surface id to put the common thickness dimension in the 
   * parents list
   */
   num_opensfs = num_parents - 1 - index;
   num_open_sfs[0]=num_opensfs;
   opensfs[0]=(PWobjid *)malloc(num_opensfs * sizeof(PWobjid));   
   for(i=0; i<num_opensfs; i++)
   {
     opensfs[0][i] = p_parents[index].grobj.grid.objid;
     index++;
   }
wrapup:
  PW_Wrapup (result, "pwThinWall query");
  return(result);
}

static void get_parent_types(
int num_parents,
struct EMSshell_solid *shell_solid,
IGRuint *p_parent_types
)
{
  int index = 0,num_mult_tks;
  int i,j;

  num_mult_tks = shell_solid->num_mult_tks;

  /* Common thickness value + mult_thickness values are EMSdistance type  */
 for(i=0;i<=num_mult_tks;i++)
    p_parent_types[i]=EMSdistance;
  /* Rest of the parents are the GRid of the surfaces that represents
   * in mult_tks and open surfaces 
   */
 for(i=num_mult_tks+1;i<num_parents;i++)
    p_parent_types[i]=EMSgrid;

}

end implementation Root;
