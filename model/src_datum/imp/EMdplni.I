/*
 * HISTORY
 * 
 * 07/02/92:Rajiv Agrawal:Message system compliance.
 * Jack : 4-Feb-93 : moved BSnorvec call for zdir to after
 *                   the BScrossp that calculates the zdir
 *                   vector. Fixes TR 119301001.
 * 02/18/93:Carlos:Added NDcompute_node.
 * 06/23/93 Sudha    modified for BSprototype ansification
 */

class implementation EMSdatpln;

#include "OMmacros.h"
#include "ndmacros.h" /* For nd$wait_batch */
#include "godef.h"
#include "parametric.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "madef.h"
#include "emsdef.h"
#include "nddef.h"
#include "SKdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "msdef.h"
#include "msmacros.h"
#include "exmacros.h"
#include "matypemx.h"
#include "maoptsxfo.h"
#include "mainvmx.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bscrossp.h"

from EMSdatplnmgr import EMmanage_datum_entry, EMactivate;
from EMSdatplnmgr import EMget_info;
from SKmgr import SKmgrprops;

method EMput_pln_info (IGRlong *EMmsg;
                       IGRuint options;
                       struct GRmd_env *md_env;
                       double xdir[3];
                       double ydir[3];
                       double zdir[3];
                       double origin[3];
                       IGRuint props)
/* ***************************************************************
Description
 This message stores the x,y and origin point of the datum plane.

Notes
 Upon exit the completion code will always be MSSUCC;
History
 Creation : PP : 07/04/91

****************************************************************** */

{
 BSrc rc;
 IGRboolean bsts;
 *EMmsg = MSSUCC;

 OM_BLOCK_MOVE(xdir,ME.EMSdatpln->x_dir,sizeof (IGRvector));
 OM_BLOCK_MOVE(ydir,ME.EMSdatpln->y_dir,sizeof (IGRvector));
 OM_BLOCK_MOVE(origin,ME.EMSdatpln->origin,sizeof (IGRvector));
 ME.EMSdatpln->props = props;

 if (md_env->md_env.matrix_type != MAIDMX)
 {
  IGRshort rot_mx_type,dim = 4,inverse_matrix_type;
  long one = 1;
  IGRmatrix inverse_matrix,rot_mx;

  MAinvmx(EMmsg,&dim,md_env->md_env.matrix,inverse_matrix);
  if (!(1&*EMmsg)) goto wrapup;
  OM_BLOCK_MOVE(inverse_matrix, rot_mx, sizeof (IGRmatrix));

  rot_mx[3] = 0.0;
  rot_mx[7] = 0.0;
  rot_mx[11] = 0.0;
  rot_mx[15] = 1.0;


  MAtypemx(EMmsg,inverse_matrix, &inverse_matrix_type);
  if (!(1&*EMmsg)) goto wrapup;

  MAtypemx(EMmsg,rot_mx, &rot_mx_type);
  if (!(1&*EMmsg)) goto wrapup;

  MAoptsxform(EMmsg,&one,&rot_mx_type,rot_mx,me->x_dir,
              me->x_dir);
  if (!(1&*EMmsg)) goto wrapup;

  MAoptsxform(EMmsg,&one,&rot_mx_type,rot_mx,me->y_dir,
              me->y_dir);
  if (!(1&*EMmsg)) goto wrapup;

  MAoptsxform(EMmsg,&one,&inverse_matrix_type,inverse_matrix,me->origin,
              me->origin);
  if (!(1&*EMmsg)) goto wrapup;
 }
 bsts = BSnorvec(&rc,me->x_dir);
 bsts = BSnorvec(&rc,me->y_dir);
 
 if (options & EMS_OPT_SET_EXTERNAL_CONSTRAINT)
   ME.GRgraphics->properties = GRHAS_EXTERNAL_CONSTRAINT | GRIS_ASSOCIATIVE;

wrapup:
 if (!(1&*EMmsg)) *EMmsg = MSFAIL;
 return (OM_S_SUCCESS);
}

method EMcreate_resize_handle (IGRlong *EMmsg;
                                IGRuint options;
                                struct GRmd_env *env;
                                struct GRvg_construct *construct_list;
                                IGRdouble x_size;
                                IGRdouble y_size;
                                GRobjid *handle_id)
{
 IGRlong status;
 OMuint comp_count;
 IGRlong i, save_weight, save_style,save_props;
 IGRdouble *xdir, *ydir, *origin;
 IGRdouble poly_pt[16],x_pt[12];
 IGRdouble cnst_pt[3],cnst_pt1[3], cnst_pt2[3];
 struct GRid my_grid;
 OM_S_OBJID loc_handle_id, loc_handle_id1;
 extern OMuword OPP_GR3dorthpoly_class_id;

 status = OM_S_SUCCESS;
 *EMmsg = MSSUCC;


 xdir = ME.EMSdatpln->x_dir;
 ydir = ME.EMSdatpln->y_dir;
 origin = ME.EMSdatpln->origin;

 status = om$get_channel_count(p_chanselect = &AS_to_comp,
                               objid = my_id,
                               count = &comp_count);
 if (!(1&status)) goto wrapup;

 for (i=0;i<3;i++)
 {
  cnst_pt1[i] = origin[i] - (xdir[i]* x_size)/2;
  cnst_pt2[i] = origin[i] + (xdir[i]* x_size)/2;
 }

 for (i=0;i<3;i++)
 {
  poly_pt[0+i] = cnst_pt1[i] - (ydir[i]*y_size)/2;
  poly_pt[3+i] = cnst_pt2[i] - (ydir[i]*y_size)/2;
  poly_pt[6+i] = cnst_pt2[i] + (ydir[i]*y_size)/2;
  poly_pt[9+i] = cnst_pt1[i] + (ydir[i]*y_size)/2;
  poly_pt[12+i] = poly_pt[i];
 }


 for (i=0;i<3;i++)
 {
  x_pt[0+i] = poly_pt[0+i] + ydir[i]*y_size*0.05;
  x_pt[3+i] = x_pt[0+i] + xdir[i]*x_size*0.1;
  x_pt[9+i] = x_pt[3+i] - ydir[i]*y_size*0.05;
  cnst_pt[i] = (x_pt[3+i] + x_pt[9+i])/2.0;
  x_pt[6+i] = cnst_pt[i] + xdir[i]*x_size*0.025;
 }

  
 if (comp_count)
 {
  *EMmsg = MSINARG;
  goto wrapup;
 }
 else
 {

  save_weight = construct_list->display->weight;
  save_style = construct_list->display->style;
  save_props = construct_list->properties;

  if (options & EMS_OPT_DISPLAY_HANDLE)
   construct_list->properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;
  else
   construct_list->properties = GRIS_NEW;
   
  construct_list->display->weight = INACTIVE_DATUM_WEIGHT;
  construct_list->display->style = DATUM_STYLE;

  EFplace_line_string(my_id,construct_list,5,poly_pt,&loc_handle_id,EMmsg);
  EFplace_line_string(my_id,construct_list,4,x_pt,&loc_handle_id1,EMmsg);


  construct_list->display->weight = save_weight;
  construct_list->display->style = save_style;
  construct_list->properties = save_props;
   

  if (!(1&status&*EMmsg)) goto wrapup;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  i = 0;
  status = om$send(msg = message GRconnector.GRrigidconn (EMmsg,
	         	         &my_grid, &i),
                   targetid = loc_handle_id);
  if (!(1&status&*EMmsg)) goto wrapup;

  i = 1;
  status = om$send(msg = message GRconnector.GRrigidconn (EMmsg,
	         	         &my_grid, &i),
                   targetid = loc_handle_id1);
  if (!(1&status&*EMmsg)) goto wrapup;
 
  if (handle_id) *handle_id = loc_handle_id;
  ME.GRgraphics->properties |=  GRIS_PLANAR | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
 }

wrapup:
 return (status);
}

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{

 *msg = MSSUCC;

 ex$message (msgnumb = EMS_S_ReferencePlane, buff = info->type);

 return(OM_S_SUCCESS);
}

method give_plane(
	IGRint *msg;
	IGRmatrix matrix;
	struct GRmd_env *md_env)
{
 IGRlong status;
 IGRint i;
 IGRmatrix my_matrix;

 *msg = MSSUCC;
 status = OM_S_SUCCESS;

 for (i=0;i<16;i++)
  my_matrix[i] = 0.0;
 my_matrix[15] = 1.0;
   
 status = om$send (msg = message EMSdatpln.EMget_pln_info((IGRlong *)msg,
                         NULL,
                         md_env,
                         my_matrix,
                         &my_matrix[4],
                         &my_matrix[8],
                         NULL,
                         NULL),
                   targetid = my_id);
 if (!(1&status&*msg)) goto wrapup;

 OM_BLOCK_MOVE(my_matrix,matrix,sizeof(IGRmatrix));

wrapup:
 return (status);
}

method GRxform(IGRlong *EMmsg; struct GRmd_env *obj_dsenv; 
               IGRshort *mx_type; IGRmatrix mx; GRobjid *newobjid)
{
 IGRboolean aflag;
 IGRlong num_pts,status,msg_loc;
 IGRdouble pt[15];
 IGRint i;
 extern IGRboolean ASbroadcast_in_progress;
 GRspacenum osn=NULL;

 status = OM_S_SUCCESS;
 *EMmsg = MSSUCC;

 aflag = pwIsActivationOn();
 if(aflag)
   osn = pwGetActiveOs();

 num_pts = 5;
 for (i=0;i<15;i++)
  pt[i] = 0.0;


 status = om$send (msg = message EMSdatpln.EMget_pln_info(EMmsg,
                         NULL,
                         obj_dsenv,
                         &pt[3],
                         &pt[6],
                         &pt[9],
                         &pt[12],
                         NULL),
                   targetid = my_id);
 if (!(1&status&*EMmsg)) goto wrapup;

 status = MAoptsxform(EMmsg, &num_pts, mx_type, mx,pt,pt);
 if (!(1&*EMmsg)) goto wrapup;
 
 for (i=0;i<3;i++)
 {
  pt[3+i] = pt[3+i] - pt[i];
  pt[6+i] = pt[6+i] - pt[i];
  pt[9+i] = pt[9+i] - pt[i];
 }

 status = om$send (msg = OPPmargs,
                   p_chanselect = &AS_to_comp);
 if (!(1&status)) goto wrapup;
 *newobjid = my_id;

 status = om$send (msg = message EMSdatpln.EMput_pln_info(EMmsg,
                         NULL,obj_dsenv,&pt[3], &pt[6],&pt[9],&pt[12],NULL),
                   targetid = my_id);
 if (!(1&status&*EMmsg)) goto wrapup;
/*
 * If I am being transformed and I am active then make sure that
 * construction plane follows with me.
 */

 if (!ASbroadcast_in_progress)
 {
  struct GRid my_GRid;
  OM_S_OBJID mgrid;
  OMuword mgros;
  OM_S_OBJID active_datum;

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  active_datum = NULL_OBJID;

  status = ems$get_datum_plane_mgr(msg = EMmsg,
                                   osnum = &osn,
                                    mgrid = &mgrid,
                                     mgros = &mgros);
  if (!(1&status&*EMmsg)) goto wrapup;

  status = om$send (msg = message EMSdatplnmgr.EMget_info(EMmsg,NULL,NULL,
                       NULL, &active_datum,NULL),
                 targetid = mgrid,
                 targetos = mgros);
  if (!(1&status&*EMmsg)) goto wrapup;

   if (active_datum == my_id)
   {
     status = om$send (msg = message EMSdatplnmgr.EMactivate(EMmsg,
                        NULL,&my_id,NULL),
                  targetid=  mgrid,
                  targetos = mgros);
     if (!(1&status&*EMmsg)) goto wrapup;
   }

  {
    OMuint children_count = 0;
    int i;
    int comp_type;
    struct GRid child_GRid;
    OM_S_CHANSELECT to_children;

    EMmake_chanselect(NDchildren_children, &to_children);
/*
 * I am determining the children count to avoid the problem of notifying
 * the batch when I am being copied and xformed. This will not be necessary
 * once GRNUC sets the bit to enable us to differentiate between the two.
 * When I am copied, there should not be any objects on the children channel.
 * pp 06/15/91
 */

    om$get_channel_count(p_chanselect = &to_children,
                         objid = my_id,
                         count = &children_count);

    comp_type = ND_COMP;

    for (i=0;i<children_count;i++)
    {
     om$get_objid_at_index(objid = my_id,
                           p_chanselect = &to_children,
                           index = i,
                           objidaddr = &child_GRid.objid,
                           osnumaddr = &child_GRid.osnum);

     nd$wait_batch(
                   type = GR_GEOM_POSTED,
                   l_object = &child_GRid,
                   l_obj_info = &comp_type,
                   nb_obj = 1);

    }
/*
 * DO this for intelligent recompute of profile.
 * pp 12/02/91
 */

     om$send (msg = message SKmgr.SKmgrprops(&msg_loc,SK_CHGPROPS_ON,
                              SK_MGR_PLN_OUTOFDATE,NULL),
                p_chanselect = &to_children);
  }
 }

wrapup:
 return (status);
}

method  EMtoggle_on_off(IGRlong *EMmsg;
                        IGRuint options)

/* ********************************************************************
Description
 This message turns the properties of the datum plane either to be
 displayed or not or just toggled based on the options coming in.

Arguments
 EMmsg: Completion code
 options : EMS_OPT_ON : Turns the datum on.
           EMS_OPT_OFF : Turns the datum off.

Related files:
 EMSdatumdef.h

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If successful.
 MSFAIL : If there is some form of failure.

History
 pp : 07/16/91 : Creation
************************************************************************ */
{
 IGRboolean aflag;
 IGRlong sts;
 IGRshort action, props;
 GRspacenum osn=NULL;

 *EMmsg = MSSUCC;
 sts = OM_S_SUCCESS;

 aflag = pwIsActivationOn();
 if(aflag)
   osn = pwGetActiveOs();

 if (options & EMS_OPT_ON)
  action = 1;
 else if (options & EMS_OPT_OFF)
  action = 0;

 if (options & EMS_OPT_OFF)
 {
  OM_S_OBJID mgrid;
  OMuword mgros;
  OM_S_OBJID active_datum;
  active_datum = NULL_OBJID;
/*
 * If I am being turned off, then I make myself inactive if I am the
 * active datum plane.
 */

 if(aflag)
 {
   sts = ems$get_datum_plane_mgr(msg = EMmsg,
                                 osnum = &osn,
                                 mgrid = &mgrid,
                                 mgros = &mgros);
 }
 else
 {
   sts = ems$get_datum_plane_mgr(msg = EMmsg,
                                 mgrid = &mgrid,
                                 mgros = &mgros);
 }
 if (!(1&sts&*EMmsg)) goto wrapup;

  sts = om$send (msg = message EMSdatplnmgr.EMget_info(EMmsg,NULL,NULL,
                       NULL, &active_datum,NULL),
                 targetid = mgrid,
                 targetos = mgros);
  if (!(1&sts&*EMmsg)) goto wrapup;

  if (active_datum == my_id)
  {
   sts = om$send (msg = message EMSdatplnmgr.EMactivate(EMmsg,
                        EMS_OPT_DEACTIVATE,NULL,NULL),
                  targetid=  mgrid,
                  targetos = mgros);
   if (!(1&sts&*EMmsg)) goto wrapup;
  }
 }

 props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

 sts = om$send (msg = message GRgraphics.GRchgprops(EMmsg,&action, &props),
                      targetid = my_id);
 if (!(1&sts&*EMmsg)) goto wrapup;

wrapup:
 return (sts);
}

method NDgive_structure (IGRlong *msg; struct ret_struct *str;
                         struct GRmd_env *md_env)
{
 IGRlong sts,i,j,msg_loc;
 IGRdouble *mat;
 IGRmatrix temp_mat;

 *msg = MSSUCC;
 sts = OM_S_SUCCESS;

 str->type = ref_generic;
 mat = str->var.ref_st.t;

 for (i=0;i<16;i++)
  temp_mat[i] = 0.0;

 temp_mat[15] = 1.0;

 sts = om$send (msg = message EMSdatpln.EMget_pln_info(&msg_loc,
                      NULL,md_env,
                      temp_mat, &temp_mat[4], &temp_mat[8],
                      &temp_mat[12], NULL),
                targetid = my_id);
 if (!(1&sts&msg_loc)) goto wrapup;

 for (i=0;i<4;i++)
  for (j=0;j<4;j++)
  mat[4*i+j] = temp_mat[4*j+i];

wrapup:
 if (!(1&msg_loc)) *msg = MSFAIL;
 return (sts);
}

method GRcopy(IGRlong *msg; struct GRmd_env *obj_mdenv; 
              struct GRmd_env *new_mdenv; GRobjid *newobjid)
{
 IGRuchar weight;
 IGRboolean base_reference_plane = FALSE;
 IGRshort action,props;
 IGRlong OM_stat,msg_loc;
 OM_S_OBJID mgrid;
 OMuword mgros;

 OM_stat = OM_S_SUCCESS;
 *msg = MSSUCC;

/*
 * send a message to myself to perform the copy process
 */

 if (ME.EMSdatpln->props & EMS_BASE_REFERENCE_PLANE)
 {
  ME.EMSdatpln->props &= ~EMS_BASE_REFERENCE_PLANE;
  base_reference_plane = TRUE;
 }

 OM_stat = om$send(mode = OM_e_wrt_parent,
                   msg = message EMSdatpln.GRcopy(&msg_loc, obj_mdenv,
                                                 new_mdenv, newobjid),
                   targetid = my_id);
 if (base_reference_plane)
 {
  ME.EMSdatpln->props |= EMS_BASE_REFERENCE_PLANE;
 }
 if (!(1&OM_stat&msg_loc)) goto wrapup;

 OM_stat = ems$get_datum_plane_mgr(msg = &msg_loc,
                                   osnum = &new_mdenv->md_id.osnum,
                                   mgrid = &mgrid,
                                   mgros = &mgros);
 if (!(1&OM_stat&msg_loc)) goto wrapup;

 OM_stat = om$send (msg = message EMSdatplnmgr.EMmanage_datum_entry(&msg_loc,
                          EMS_OPT_ADD,
                          *newobjid),
                    targetid = mgrid,
                    targetos = mgros);
 if (!(1&OM_stat&msg_loc)) goto wrapup;

 action = 0;
 props = GRIS_ASSOCIATIVE | GRHAS_EXTERNAL_CONSTRAINT;
 

 OM_stat = om$send(msg = message GRgraphics.GRchgprops(&msg_loc,
                                                       &action, &props),
                    targetid = *newobjid,
                    targetos = new_mdenv->md_id.osnum);
 if (!(1&OM_stat&msg_loc)) goto wrapup;

 weight = INACTIVE_DATUM_WEIGHT;
 OM_stat = om$send (msg = message GRvg.GRchgweight(&msg_loc,&weight),
                    targetid = *newobjid,
                    targetos = new_mdenv->md_id.osnum);
 if (!(1&OM_stat&msg_loc)) goto wrapup;

wrapup:
 if (!(1&msg_loc)) *msg = MSFAIL;
 return (OM_stat);
}

method GRdelete(IGRlong *msg; struct GRmd_env *md_env)
{
 IGRlong msg_loc;
 IGRlong OM_stat;
 OM_S_OBJID mgrid;
 OMuword mgros, current_os;
 OM_S_OBJID active_datum;
 struct GRid active_GRid;

 OM_stat = OM_S_SUCCESS;
 *msg = MSSUCC;

/*
 * Base reference plane cannot be deleted.
 */
 ems$get_active_datum_plane(msg = &msg_loc,
                            datpln = &active_GRid);
 if ((active_GRid.objid == my_id ) || 
     (ME.EMSdatpln->props & EMS_BASE_REFERENCE_PLANE))
  {
    IGRboolean display_message = FALSE;
    struct GRid owner_GRid;
    OMuint owner_count=0, comp_count = 0;
    OM_S_CHANSELECT to_owners, to_components;
/*
 * The following logic has been tailored to determine if only one entity
 * is getting deleted or multiple entities are getting deleted. (using
 * elements in view or fence operations).
 * If one entity is getting deleted then a message if appropriately
 * flashed so that the user knows what is happening.
 */
 
    EMmake_chanselect (GRconnector_to_owners, &to_owners);

    om$get_channel_count(p_chanselect = &to_owners,
                         objid = my_id,
                         count = &owner_count);

    if (owner_count == 1) 
    {
     owner_GRid.objid = NULL_OBJID;

     om$get_objid_at_index(objid = my_id,
                           p_chanselect = &to_owners,
                           objidaddr = &owner_GRid.objid,
                           osnumaddr = &owner_GRid.osnum,
                           index = 0);

     EMmake_chanselect (GRcmpowner_to_components, &to_components);

     om$get_channel_count(p_chanselect = &to_components,
                         objid = owner_GRid.objid,
                         osnum = owner_GRid.osnum,
                         count = &comp_count);
     

     if (comp_count == 1)
     {
       display_message = TRUE;
     }
    }
    else
     display_message = TRUE;

    if ((display_message)
    && (!(ex$is_invis(mod_osnum = OM_Gw_current_OS)))) 
    {
      if (active_GRid.objid == my_id)
      {
       ex$message(
                  msgnumb = EMS_S_ActRefNoDel);
      }
      else if (ME.EMSdatpln->props & EMS_BASE_REFERENCE_PLANE)
      {
       ex$message(
                  msgnumb = EMS_S_BasRefNoDel);
      }
      sleep(2);
    }

   if (!(ex$is_invis(mod_osnum = OM_Gw_current_OS))) 
   {
    IGRint bytes_in, bytes_out;
    struct GRid  mod_GRid;

    struct GRmd_env display_env;
    enum GRdpmode dpmode;
    
    ex$get_cur_mod(id = &mod_GRid.objid, osnum = &mod_GRid.osnum);

    bytes_in = sizeof(display_env);
    gr$get_display_env(
      msg = msg,
      sizbuf = &bytes_in,
      buffer = &display_env,
      nret = &bytes_out);

    dpmode = GRbd;
    om$send (msg = message GRgraphics.GRdisplay(msg, 
                &display_env.md_env.matrix_type,
                 display_env.md_env.matrix,
                 &dpmode,
                 &mod_GRid),
          targetid = my_id);
  }
  return (OM_S_SUCCESS);
 }

  {
   OM_S_CHANSELECT to_children;
   struct GRid src_grid;
   extern IGRboolean ASbroadcast_in_progress;

   EMmake_chanselect(NDchildren_children, &to_children);
/*
 * Send a NDmove_to_root message to my children.
 */
   if (!ASbroadcast_in_progress)
    om$send (msg = message NDnode.NDmove_to_root(&msg_loc, &src_grid,
                  md_env),
             p_chanselect = &to_children);
  }

 
 OM_stat = om$send(mode = OM_e_wrt_parent,
                   msg = message EMSdatpln.GRdelete(&msg_loc, md_env),
                   targetid = my_id);
 if (!(1&OM_stat&msg_loc)) goto wrapup;

 current_os = OM_Gw_current_OS;

 OM_stat = ems$get_datum_plane_mgr(msg = &msg_loc,
                                   osnum = &current_os,
                                   mgrid = &mgrid,
                                   mgros = &mgros);
 if (!(1&OM_stat&msg_loc)) goto wrapup;

 OM_stat = om$send (msg = message EMSdatplnmgr.EMget_info(&msg_loc,NULL,
                          NULL,NULL,&active_datum,NULL),
                    targetid = mgrid);
 if (!(1&OM_stat&msg_loc)) goto wrapup;
/*
 * Turn the reference plane lock off if I am active and the lock is on
 * to preserve integrity.
 * pp 11/2/91
 */

 if (active_datum == my_id)
 {
  IGRint mode;

  ems$ref_plane_lock(msg = &msg_loc,
                     options = EMS_REF_PLANE_LOCK_INQ,
                     mode = &mode);

  if (mode == EMS_REF_PLANE_LOCK_ON)
   {
    ems$ref_plane_lock(msg = &msg_loc,
                    options = EMS_REF_PLANE_LOCK_OFF | EMS_REF_PLANE_LOCK_SET);
   }
 }

 OM_stat = om$send (msg = message EMSdatplnmgr.EMmanage_datum_entry(&msg_loc,
                          EMS_OPT_DELETE,
                          my_id),
                    targetid = mgrid);
 if (!(1&OM_stat&msg_loc)) goto wrapup;

wrapup:
 if (!(1&msg_loc)) *msg = MSFAIL;
 return (OM_stat);
}

method ASreturn_go ( struct GRid * go;
                     IGRshort    * mat_type;
                     IGRdouble   * matrix )
{
    IGRlong         msg;
    struct GRmd_env mod_env;
    IGRint          sizbuf, nret;

    go->objid = my_id;
    go->osnum = OM_Gw_current_OS;


    if (matrix && mat_type)
    {
      sizbuf = sizeof(struct GRmd_env);

      gr$get_module_env ( msg = &msg,
                            sizbuf = &sizbuf,
                            buffer = &mod_env,
                            nret = &nret );

      *mat_type = mod_env.md_env.matrix_type;    

      memcpy (matrix, mod_env.md_env.matrix, sizeof(IGRmatrix));
    }

    return OM_S_SUCCESS;
}

method ACcopy_to_Groot(IGRlong *msg;IGRint cp_type;
			 struct GRmd_env *fr_env,*to_env;
  			 struct GRid *newobjid)
/* **********************************************************************
Description
 This method has been overriden to return the non-associative copy
 of the geometry.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MDFAIL : If there is some form of failure

History
 Creation : PP : 08/10/91
*********************************************************************** */
{
 IGRlong status, msg_loc;
 OM_S_OBJID temp_objid;

 status = OM_S_SUCCESS;
 *msg = MSSUCC;


 status = om$send (msg = message GRgraphics.GRcopy(&msg_loc,fr_env, to_env,
                          &temp_objid),
                   targetid = my_id);
 if (!(1&status&msg_loc)) goto wrapup;

 newobjid->objid = temp_objid;
 newobjid->osnum = to_env->md_id.osnum;


wrapup:
 if (!(1&status&msg_loc)) *msg = MSFAIL;
 return (status);
}

method NDmake_source(IGRlong *msg; struct GRid *located_obj,*context;
                     char *path; GRspacenum as_osnum; struct GRid *as)
{
IGRlong status;
struct GRid go;

*msg = MSFAIL;

if(context->objid == NULL_OBJID)
  {
   if(as_osnum != OM_Gw_current_OS) return (OM_W_ABORT);
   as->objid = located_obj->objid;
   as->osnum = located_obj->osnum;
   *msg = MSSUCC;
   status = OM_S_SUCCESS;
  }
else
  {
    status = om$send(msg = message NDnode.ASreturn_go(&go,NULL,NULL),
                      targetid = located_obj->objid,
                      targetos = located_obj->osnum);
    if(!(status&1)) go = *located_obj;

    status = ASmake_source_from_go(msg,&go,context,as_osnum,as);
  }
return(status);
}

method delete (int f_defer_flag)
/*
 * This method has been overriden to further safeguard the integrity of the
 * reference plane system.
 * pp 10/16/92
 */  
{
 IGRlong OM_stat, msg_loc;
 OMuword current_os, mgros;
 OM_S_OBJID mgrid;

 OM_stat = OM_S_SUCCESS;
 msg_loc = 1;

 current_os = OM_Gw_current_OS;

 OM_stat = ems$get_datum_plane_mgr(msg = &msg_loc,
                                   osnum = &current_os,
                                   mgrid = &mgrid,
                                   mgros = &mgros);
 if ((1&OM_stat&msg_loc))
 {
  OM_stat = om$send (msg = message EMSdatplnmgr.EMmanage_datum_entry(&msg_loc,
                          EMS_OPT_DELETE,
                          my_id),
                    targetid = mgrid);
 }

 if ((1&OM_stat&msg_loc))
 {
  return (om$send (msg = message EMSdatpln.delete(f_defer_flag),
                   mode = OM_e_wrt_parent,
                   targetid = my_id));
 }
 else
 {

  ME.EMSdatpln->props |= EMS_HIDDEN_REFERENCE_PLANE;
 }

 return (OM_S_SUCCESS);
}

/*

Name
  NDcompute_node

Justification
  (see TR119300092)

History
 02/18/93:Carlos:Creation.

 */
method NDcompute_node (IGRlong *msg; IGRint cn_type;
  		   IGRint count; struct GRid list []; 
                   struct GRmd_env *md_env)
{
 *msg = 0;  
 return (OM_S_SUCCESS);
}


end implementation EMSdatpln;

