/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This function creates a solid by sweeping a surface which possibly has
 boundaries.  It is assumed that the resulting solid is valid, i.e. no
 checks are made to ensure that the solid does not intersect itself, etc..

 Bugs

 This function will not align the normals correctly in some cases where
 the input surface is not planar.

 History

 ??/??/87 : rc  : This was originally written as test command ECsolprj by
                  Chopra.
 01/15/88 : rlw : Reworked to place the construction logic into a single 
                  function that can be called by the command object.
 07/13/88 : rlw : Removed logic to handle a surface DPR object as input and
                  added topology compress and range reduction logic.
 10/23/88 : DLB : Removed range reduction logic. The only way to reduce the
                  range of a surface now is thru the compress tree command.
                  Even EMmake_primitive1 does not reduce the range.
 11/07/88 : RC  : Modified call EMlift_face.
 5/19/92 Tapadia  Support for symmetrically projecting the surface (hence added
		  an argument sym_dist_flag). Changed the name to
		  EMsweep_surface_via_lift_face_mod()
 Sudha   06/02/93        modified to include for BSprototype headers
 */

class implementation EMSsubbs;

#include "EMS.h"
#include "bs.h"                 /* BSSUCC, etc. */
#include "EMSconstruct.h"       /* Mask for aligning normals */
#include "EMSopt.h"             /* Topology copy options */
#include "godef.h"              /* Properties masks */
#include "msdef.h"              /* MSSUCC, MSFAIL */
#include "bssfarrevn.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"

from EMSsf_lift import EMlift_face;
from EMSsfdpr import EMadd;
from EMSdpr import EMmake_primitive1;
from EMSboundary import EMtpcopy, EMtree_traverse;
from EMSloopset import EMmakeFRT;
from EMSedge    import EMset_props;

extern OMuword OPP_EMSdpr_class_id;
extern OMuword OPP_EMSgensolid_class_id;

IGRlong EMsweep_surface_via_lift_face_mod(
 lc_info,
 from_point,
 to_point,
 construct_list,
 my_stupid_id,
 solid_id,
 sym_dist_flag,
 msg)

struct          GRlc_info *lc_info;
IGRpoint        from_point;
IGRpoint        to_point;
struct          GRvg_construct *construct_list;
OM_S_OBJID      my_stupid_id;
GRobjid         *solid_id;
IGRboolean	sym_dist_flag; 
IGRlong         *msg;

{
 OMuword                space_number;
 IGRlong                sts;
 GRobjid                sf_id, cp_sf_id, cp_ls_id;
 OM_S_CHANSELECT        sf_ls_chan, ls_sf_chan;
 struct                 GRmd_env *md_env;
 IGRdouble sym_dist;
 IGRint i;
 IGRmatrix matrix;
 IGRvector move_vec;
/*
 * Initialize
 */
 *msg = MSSUCC;
 sf_id = NULL_OBJID;
 cp_sf_id = NULL_OBJID;
 cp_ls_id = NULL_OBJID;
 *solid_id = NULL_OBJID;
 md_env = construct_list->env_info;
 space_number = md_env->md_id.osnum;
 for(i = 14; i > 0; i--) matrix[i] = 0.0;
 matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0;

/*
 * Make channel selectors
 */
 sts = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
  if (! (1 & sts))
   {
    *msg = MSFAIL;
    goto wrapup;
   }
 sts = EMmake_chanselect (EMSloopset_to_surface, &ls_sf_chan);
  if (! (1 & sts))
   {
    *msg = MSFAIL;
    goto wrapup;
   }

  /* If the symmetric distance option is true copy - transform the surface */
  if(sym_dist_flag) {
  	struct        GRid *id;
  	struct        GRmd_env *old_md_env;
  	IGRlong       loc_msg;
  	IGRboolean    status;

  	sym_dist = BSdistptpt(&loc_msg, from_point, to_point);

  	move_vec[0] = from_point[0] - to_point[0];
  	move_vec[1] = from_point[1] - to_point[1];
  	move_vec[2] = from_point[2] - to_point[2];
  	status = BSnorvec(&loc_msg, move_vec);
  	matrix[3] = (sym_dist/2.0) * move_vec[0]; 
  	matrix[7] = (sym_dist/2.0) * move_vec[1]; 
  	matrix[11] = (sym_dist/2.0) * move_vec[2]; 

  	id = &lc_info->located_obj;
  	old_md_env = &lc_info->module_info;
  	sts = om$send(
    	msg = message GRgraphics.GRcptform(
     			msg, old_md_env, matrix, old_md_env,
     			&sf_id),
    		senderid = my_stupid_id,
    		targetid = id->objid,
    		targetos = id->osnum);
        if (!(1 & sts)) goto wrapup;                   
   }
/*
 * Copy the original surface to the 
 * destination object space (possibly the same).
 */
 else 
 {
  struct        GRid *id;
  struct        GRmd_env *old_md_env;

  id = &lc_info->located_obj;
  old_md_env = &lc_info->module_info;
  sts = om$send(
    msg = message GRgraphics.GRcopy(
     msg,
     old_md_env,
     md_env,
     &sf_id),
    senderid = my_stupid_id,
    targetid = id->objid,
    targetos = id->osnum);
   if (!(1 & sts)) goto wrapup;                   
 }
/*
 * If the surface has topology then compress it and reduce the
 * surfaces range.  If it has no topology then create some.
 */
 {
  OMuint       channel_count;

  sts = om$get_channel_count(
    objid = sf_id,
    osnum = space_number,
    p_chanselect = &sf_ls_chan,
    count = &channel_count);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  if (channel_count)
   {
/*************************DLB 10/23/88****************************
    GRobjid     new_surface;
*****************************************************************/

    sts = om$send(
      msg = message EMSsubbs.EMcompress_top(
       msg,
       md_env),
      senderid = my_stupid_id,
      targetid = sf_id,
      targetos = space_number);
     if(!(1 & sts)) 
      {
       *msg = MSFAIL;
       goto wrapup;
      }
    {/*INTENTIONAL DLB*/
      extern OMuword OPP_EMSedge_class_id;      

      sts = om$send(msg = message EMSboundary.EMtree_traverse(msg, 
                          message EMSedge.EMset_props(msg, 
                                EMED_REVERSE_CONNECT, EMS_O_OFF),
                          MAXINT, 1, &OPP_EMSedge_class_id, EMStreetrav_down,
                          NULL, NULL, NULL),
                    p_chanselect = &sf_ls_chan,
                    senderid = sf_id,
                    targetos = space_number);
      if (!(1 & sts & *msg)) goto wrapup;                   
    }

/*************************DLB 10/23/88****************************
    sts = om$send(
      msg = message EMSsubbs.EMreduce_range(
       msg,
       md_env,
       &new_surface),
      senderid = my_stupid_id,
      targetid = sf_id,
      targetos = space_number);
     if (! (1 & sts))
      {
       *msg = MSFAIL;
       goto wrapup;
      }
    sf_id = new_surface;
*****************************************************************/
   } /* if (channel_count) */
  else
   {
    sts = om$send(
      msg = message EMSsurface.EMmk_nat_bdry(
       msg,
       &md_env->md_env,
       NULL),                           /* Don't want the edge id's */
      senderid = my_stupid_id,
      targetid = sf_id,
      targetos = space_number);
     if (! (1 & sts))
      {
       *msg = MSFAIL;
       goto wrapup;
      }
   } /* ELSE FOR if (channel_count) */
 }
/*
 * Change the symbology of the copied surface
 */
 {
  struct        GRsymbology symbology;
  struct        IGResbs *element_specific;

  symbology.level = construct_list->level;
  symbology.display_attr = *(construct_list->display);
  sts = om$send(
    msg = message GRvg.GRputsymb(
     msg,
     &symbology),
    senderid = my_stupid_id,
    targetid = sf_id,
    targetos = space_number);
   if (!(1 & sts)) goto wrapup;
  element_specific = (struct IGResbs *) construct_list->class_attr;
  sts = om$send(
    msg = message GRvg.GRputattr(
     msg,
     (IGRchar *) element_specific),
    senderid = my_stupid_id,
    targetid = sf_id,
    targetos = space_number);
   if (!(1 & sts)) goto wrapup;
  }
/*
 * Align the normal of the surface.  This logic works
 * well for planes but will not work in the general case.
 */
 {
  IGRboolean    status;
  IGRshort      pos_orient;
  IGRlong       i, loc_msg;
  IGRdouble     u, v, dot_p;
  IGRvector     lift_vec, sf_nrml;
  IGRpoint      sf_pt;
  struct        GRmdenv_info *mdenv_info;
  struct        IGRbsp_surface *surface;

  mdenv_info = &md_env->md_env;
  sts = om$send(
    msg = message GRvg.GRgenabsg(
     msg,
     &mdenv_info->matrix_type,
     mdenv_info->matrix,
     (IGRchar **) &surface),
    senderid = my_stupid_id,
    targetid = sf_id,
    targetos = space_number);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  u = 0.48;             /* Try and avoid a knot line */
  v = 0.37;             /* Try and avoid a knot line */
  BSsfarrevn(
    &loc_msg, 
    surface,
    1,
    &u, 
    1, 
    &v, 
    sf_pt,
    sf_nrml);
   if (loc_msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  for (i = 0; i < 3; i++)
   lift_vec[i] = to_point[i] - from_point[i];
  status = BSnorvec(
   &loc_msg,
   lift_vec);                  
  dot_p = BSdotp(
   &loc_msg,
   sf_nrml,
   lift_vec);
  if (dot_p >= 0.0)
   pos_orient = TRUE;
  else
   pos_orient = FALSE;
  sts = om$send(
    msg = message EMSsubbs.EMalgnnrml(
     msg,
     EMS_SET_POS_ORIENT,
     &pos_orient,
     NULL,                      /* No orientation point */
     NULL),                     /* No enviroment is necessary */
    senderid = my_stupid_id,
    targetid = sf_id,
    targetos = space_number);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Copy the surface again to form the other cap of the solid.
 * We don't want the topology, just the geometry but we must
 * be careful to ensure that the copy is in the R-tree.
 */
 sts = om$send(
   mode = OM_e_wrt_message,
   msg = message GRgraphics.GRcopy(
    msg,
    md_env,
    md_env,
    &cp_sf_id),
   senderid = my_stupid_id,
   targetid = sf_id,
   targetos = space_number);
  if (! (1 & sts)) goto wrapup;
/*
 * Align the normal of the copied surface to be the
 * opposite of the original surface
 */
 sts = om$send(
   msg = message EMSsubbs.EMrevorient(
    msg),
   senderid = my_stupid_id,
   targetid = cp_sf_id,
   targetos = space_number);
  if (! (1 & sts))
   {
    *msg = MSFAIL;
    goto wrapup;
   }
/*
 * Copy the topology of the surface with the option to connect 
 * its edges to the corresponding edges of the copied surface.
 */
 sts = om$send(
   msg = message EMSboundary.EMtpcopy(
    msg,
    NULL,                       /* No model space edges are required */
    space_number,               /* Old object space */
    space_number,               /* New object space */
    EMS_COPY_ONCOMMON,          /* Connect copied edges to existing edges */
    &cp_ls_id),                 /* The new loopset */
   senderid = sf_id,
   p_chanselect = &sf_ls_chan,
   targetos = space_number);
  if (! (1 & sts))
   {
    *msg = MSFAIL;
    goto wrapup;
   }
/*
 * Connect the newly created loopset to the copied surface
 */
 sts = om$send(
   msg = message Root.connect(
    sf_ls_chan,
    NULL,
    cp_ls_id,
    space_number,
    ls_sf_chan,
    NULL),
   senderid = my_stupid_id,
   targetid = cp_sf_id,
   targetos = space_number);
  if (! (1 & sts))
   {
    *msg = MSFAIL;
    goto wrapup;
   }
/*
 * Make sure the copied surface has it's FRT fixed
 */
 sts = om$send(
   msg = message EMSloopset.EMmakeFRT(
    msg,
    cp_sf_id),
   senderid = my_stupid_id,
   targetid = cp_ls_id,
   targetos = space_number);
  if (! (1 & sts))
   {
    *msg = MSFAIL;
    goto wrapup;
   }
/*
 * Construct the solid object and connect the
 * two surfaces to it.
 */
 {
  IGRshort      flag, props;
  IGRlong       owners_index;
  struct        GRid owners_id;

  flag = 1;
  props = construct_list->properties | GRIS_NEW;
  sts = om$construct(
    classid = OPP_EMSgensolid_class_id,
    msg = message GRgraphics.GRchgprops(
     msg,
     &flag,
     &props),
    p_objid = solid_id,
    osnum = space_number);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  owners_id.objid = *solid_id;
  owners_id.osnum = space_number;
  owners_index = 0;
  sts = om$send(
    msg = message GRconnector.GRrigidconn(
     msg,
     &owners_id,
     &owners_index),
    senderid = my_stupid_id,
    targetid = sf_id,
    targetos = space_number);
   if ((! (1 & sts)) || 
       (*msg != MSSUCC))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  sts = om$send(
    msg = message GRconnector.GRrigidconn(
     msg,
     &owners_id,
     &owners_index),
    senderid = my_stupid_id,
    targetid = cp_sf_id,
    targetos = space_number);
   if ((! (1 & sts)) || 
       (*msg != MSSUCC))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Perform the lift and compress the resulting
 * state tree.
 */
 {
  struct        GRid surface_to_lift, local_mod;
  struct        GRid solid, compressed_solid;

  surface_to_lift.objid = cp_sf_id;
  surface_to_lift.osnum = space_number;
  sts = om$send(
    msg = message EMSsurface.EM_lift(
     msg,
     message EMSsf_lift.EMlift_face(
      msg,
      md_env,
      construct_list,
      from_point,
      to_point,
      surface_to_lift,
      NULL,
      NULL,
      EMS_DO_DISPLAY, NULL, NULL),
     &local_mod),
    senderid = my_stupid_id,
    targetid = *solid_id,
    targetos = space_number);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  solid.objid = *solid_id;
  solid.osnum = space_number;
  sts = om$send(
    msg = message EMSsfdpr.EMadd(
     msg,
     &solid,
     NULL,
     md_env,
     NULL),
    senderid = my_stupid_id,
    targetid = local_mod.objid,
    targetos = space_number);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  sts = om$send(
    msg = message EMSdpr.EMmake_primitive1(
     msg,
     md_env,
     &compressed_solid),
    senderid = my_stupid_id,
    targetid = local_mod.objid,
    targetos = space_number);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  *solid_id = compressed_solid.objid;   /* I don't think this is necessary */
 }
/*
 * eof
 */
wrapup:
 if (! (1 & *msg))
  {
   IGRlong      loc_msg;
   if (sf_id != NULL_OBJID)
    {
     sts = om$send(
      msg = message GRgraphics.GRdelete(
       &loc_msg,
       md_env),
      senderid = my_stupid_id,
      targetid = sf_id,
      targetos = space_number);
    }
   if (cp_sf_id != NULL_OBJID)
    {
     sts = om$send(
      msg = message GRgraphics.GRdelete(
       &loc_msg,
       md_env),
      senderid = my_stupid_id,
      targetid = cp_sf_id,
      targetos = space_number);
    }
   if (*solid_id != NULL_OBJID)
    {
     sts = om$send(
      msg = message GRgraphics.GRdelete(
       &loc_msg,
       md_env),
      senderid = my_stupid_id,
      targetid = *solid_id,
      targetos = space_number);
    }
   return(FALSE);
  }
 else
  return(TRUE);
}

end implementation EMSsubbs;
