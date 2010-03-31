/* ###################   APOGEE COMPILED   ################## 

 Description

 This function promotes an object to be freeform.

 History

 12/28/87 : rlw : Creation date
 03/01/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
 10/18/89 : SS  : Take care of composite-curves
 01/16/90 : RC  : If a conic is promoted to a GRbcsubbc, update its
                  rtree reduced range by its pole range. 
 02/28/90 : SS  : A surface promoted to general surface needs to have
                  it's edge-curve-types promoted to general-curves.
 Sudha   06/02/93        modified to include for BSprototype headers
*/

class implementation GRvg;

#include "EMS.h"
#include "EMSopt.h"
#include "emsedgedef.h"
#include "emsdef.h"
#include "igrdef.h"
#include "msdef.h"
#include "bserr.h"
#include "bsbx2.h"

extern OMuword OPP_GRbcsubbc_class_id, OPP_GRconic_class_id;
extern OMuword OPP_GRcompcurve_class_id;
#ifndef IDRAW
extern OMuword OPP_EMSgenbs_class_id, OPP_EMSedge_class_id;
from EMSsubbs import EMpassloop;
from EMSboundary import EMtree_traverse;
from EMSedge import EMset_type;
#endif


IGRlong EMpromote_class(
 is_a_curve,
 md_env,
 id,
 msg)

IGRboolean	is_a_curve;
struct		GRmd_env *md_env;
struct		GRid *id;
IGRlong		*msg;

{
 IGRchar	*geometry, free_form_class_name[80];
 OMuword	the_classid, free_form_classid;
 IGRboolean is_a_conic_cv = FALSE;
 IGRlong	sts;
 GRrange    cn_old_range;
 struct		IGResbs element_specific;
 struct		GRsymbology symb;
 OM_S_CHANSELECT chan_to_comps;
 extern IGRint  EMgetvggeom();

/*
 * Initialize
 */
 *msg = MSSUCC;
 geometry = NULL;
/*
 * Get my class id
 */
 sts = om$get_classid(
   osnum = id->osnum,
   objid = id->objid,
   p_classid = &the_classid);
  if (! (1 & sts))
   {
    *msg = MSFAIL;
    goto wrapup;
   }
/*
 * Determine is class promotion is required
 */
 if (is_a_curve)
  {
   free_form_classid = OPP_GRbcsubbc_class_id;
   strcpy(free_form_class_name, "GRbcsubbc");
  }
 else
  {
#ifndef IDRAW
   free_form_classid = OPP_EMSgenbs_class_id;
   strcpy(free_form_class_name, "EMSgenbs");
#endif
  }
 sts = om$is_ancestry_valid(
   subclassid = the_classid,
   superclassid = free_form_classid);
 if (sts == OM_S_SUCCESS)
  goto wrapup;
 else if (sts != OM_I_INVANCESTRY)
  {
   *msg = MSFAIL;
   goto wrapup;
  }

/*
 * We must promote the class
 * 
 * 1) Get the geometry; if composite, then obtain in local buffer lest
 *    it be overwritten by component genabs (say, like in GRdelete).
 * 2) Get element specific attributes; if composite get the e.s.a. from
 *    1st component.
 * 3) Change the class; if composite, delete the components first.
 * 4) Post the element specific attributes
 * 3) Post the geometry
 */

 if (the_classid == OPP_GRcompcurve_class_id)
  {
   sts = EMgetvggeom(
     msg,
     &md_env->md_env.matrix_type,
     md_env->md_env.matrix,
     id,
     &geometry,
     NULL);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  }
 else
  {
   sts = om$send(		/* This better not point into instance data */
     msg = message GRvg.GRgenabsg(
      msg,
      &md_env->md_env.matrix_type,
      md_env->md_env.matrix,
      &geometry),
     senderid = id->objid,
     targetid = id->objid,
     targetos = id->osnum);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  }

 if (the_classid == OPP_GRcompcurve_class_id)
   {
    sts = EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    if (! (1 & sts))
     {
      *msg = MSFAIL;
      goto wrapup;
     }
    sts = om$send(
      msg = message GRvg.GRgetattr(
       msg,
       (IGRchar *) &element_specific),
      senderid = id->objid,
      targetos = id->osnum,
      from = 0, to = 0,
      p_chanselect = &chan_to_comps);
    if (! (1 & sts))
     {
      *msg = MSFAIL;
      goto wrapup;
     }
    sts = om$send(
      msg = message GRvg.GRgetsymb(
       msg,
       &symb),
      senderid = id->objid,
      targetos = id->osnum,
      from = 0, to = 0,
      p_chanselect = &chan_to_comps);
    if (! (1 & sts))
     {
      *msg = MSFAIL;
      goto wrapup;
     }
   }
 else
   {
    sts = om$send(			/* I assume IGResbs >= IGResbc */
      msg = message GRvg.GRgetattr(
      msg,
      (IGRchar *) &element_specific),
      senderid = id->objid,
      targetid = id->objid,
      targetos = id->osnum);
    if (! (1 & sts))
     {
      *msg = MSFAIL;
      goto wrapup;
     }
   }

 if (the_classid == OPP_GRcompcurve_class_id)
  {
   sts = om$send(
    msg = message GRgraphics.GRdelete(
     msg,
     md_env),
    senderid = id->objid,
    targetos = id->osnum,
    p_chanselect = &chan_to_comps);
  if (! (1 & sts))
   {
    *msg = MSFAIL;
    goto wrapup;
   }
  }

  if (is_a_curve)
  {
   IGRboolean world;

   sts = om$is_ancestry_valid ( subclassid = the_classid,
                                superclassid = OPP_GRconic_class_id);
   if (sts == OM_S_SUCCESS)
   {
    is_a_conic_cv = TRUE;    
    world = TRUE;
    sts = om$send (msg = message GRgraphics.GRgetrang (msg,
                    &md_env->md_env.matrix_type,
                    md_env->md_env.matrix, &world, cn_old_range),
                   senderid = id->objid,
                   targetid = id->objid, targetos = id->osnum);
    if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }

   } /* if (sts == OM_S_SUCCESS) */
   else if (sts != OM_I_INVANCESTRY)
   {
    *msg = MSFAIL;
    goto wrapup;
   }

  } /* if (is_a_curve) */

 sts = om$change_class(
   osnum = id->osnum,
   objid = id->objid,
   classname = free_form_class_name);
  if (! (1 & sts))
   {
    *msg = MSFAIL;
    goto wrapup;
   }

/*
 * Put the geometry back leaving the R-tree alone (if this is a non-composite
 * curve). Also put the element specific attributes into the object. If
 * this is a composite the curve has to be "constructed" as if new.
 */
 if (the_classid == OPP_GRcompcurve_class_id)
 {
  IGRlong msg_loc;
  struct GRvg_construct const_args;

  const_args.msg = &msg_loc;
  const_args.env_info = md_env;
  const_args.newflag = FALSE;
  const_args.level = symb.level;
  const_args.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  const_args.geometry = geometry;
  const_args.display = &symb.display_attr;
  const_args.class_attr = (IGRchar *)&element_specific;
  const_args.name = NULL;

  sts = om$send(
    msg = message GRgraphics.GRconstruct(
     &const_args),
    senderid = id->objid,
    targetid = id->objid,
    targetos = id->osnum);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
 }
 else
 {
  GRobjid	 newobjid;
  struct	 GRpost_info info;
  struct	 GRmd_env new_env;

  sts = om$send(
   msg = message GRvg.GRputattr(
    msg,
    (IGRchar *) &element_specific),
   senderid = id->objid,
   targetid = id->objid,
   targetos = id->osnum);
  if (! (1 & sts))
   {
    *msg = MSFAIL;
    goto wrapup;
   }

  info.construct_flag = TRUE;
  new_env = *md_env;
  new_env.md_id.objid = NULL_OBJID;

  sts = om$send(
    msg = message GRvg.GRpostabsg(
     msg,
     &new_env,
     &info,
     geometry,
     &newobjid),
    senderid = id->objid,
    targetid = id->objid,
    targetos = id->osnum);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     om$report_error(sts = sts);
     goto wrapup;
    }

#ifndef IDRAW
   if (!is_a_curve)
   {
    IGRlong msg_loc;

    om$send (msg = message EMSsubbs.EMpassloop (&msg_loc,
     message EMSboundary.EMtree_traverse (&msg_loc, message EMSedge.EMset_type
     (&msg_loc, 0), MAXINT, 1, &OPP_EMSedge_class_id, EMStreetrav_down, NULL,
     NULL, NULL)), targetid = id->objid, targetos = id->osnum,
     senderid = NULL_OBJID);
    }
#endif

   if (is_a_conic_cv)
   {
    IGRboolean          bs_sts;
    IGRshort            gr_props;
    IGRlong             rc;
    GRrange             cn_new_range;
    struct IGRbsp_curve *cv_geom;
    extern IGRlong      GRupdaterng();

    cv_geom = (struct IGRbsp_curve *) geometry;
    bs_sts = BSbx2 (&rc, &cv_geom->num_poles, (IGRpoint *)cv_geom->poles,
                    cv_geom->weights, &cn_new_range[0], &cn_new_range[3]);
    if (!bs_sts)
    {
      *msg = MSFAIL;
      goto wrapup;
    }

    sts = om$send (msg = message GRgraphics.GRgetprops (msg,
                    &gr_props),
                   senderid = id->objid,
                   targetid = id->objid, targetos = id->osnum);

    if (! (1 & sts))
    {
     *msg = MSFAIL;
     om$report_error(sts = sts);
     goto wrapup;
    }

    info.construct_flag = FALSE;
    sts = GRupdaterng (msg, md_env, &info, &id->objid, 
                       &gr_props, cn_old_range, cn_new_range);
    if (! (1 & sts))
    {
     *msg = MSFAIL;
     om$report_error(sts = sts);
     goto wrapup;
    }

   } /* if (is_a_conic_cv) */
 }
/*
 * eof
 */
wrapup:
 if (geometry && the_classid == OPP_GRcompcurve_class_id)
   om$dealloc (ptr = geometry);
 if (1 & *msg)
  return(TRUE);
 else
  return(FALSE);
}

end implementation GRvg;

