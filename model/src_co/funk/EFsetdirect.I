/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This function alters the input curve such that it starts at a
 particular point (if closed) and flows in a particular direction.

 Arguments

 curve
  The curve to be modified
 start_point
  If the curve is physically closed then the curve will be made
  to start at the position dictated by this information.  I do realize
  that this information is already implicity contained in the start_position
  BUT the split method asks for both and the caller probably already
  has this information.
 start_position
  If the curve is physically closed then the curve will be made
  to start at the position dictated by this information.
  If this argument is NULL then it is assumed that the current flow
  direction is acceptable.
 reverse_flow_direction
  Should the existing flow direction be altered?  This parameter
  applies equally to open and closed curves.
 my_stupid_id
  Callers object id.
 new_curve
  Since the input curves object id may change during this modification
  the parameter will return the new object id of the curve.  This curve
  will exist in the object space of the input curve.
 msg
  Error return code

 History

 07/20/88 : rlw : Creation date
 05/26/89 : rlw : Modified such that if a closed freeform curve is split into
                  2 pieces then the resulting curve is arclength parameterized
                  after the pieces are merged together.
 11-Oct-89: SM  : Pass NULL for curve buffers to EFmerge_curves.
 Sudha   06/02/93        modified to include for BSprototype headers
 */

class implementation GRcurve;

#include "EMS.h"
#include "msdef.h"
#include "maerr.h"
#include "godef.h"		/* construct list properties */
#include "bserr.h"		/* BSSUCC */
#include "bsfreecv.h"
#include "bsarclnparc.h"

extern OMuword OPP_GRsubbc_class_id;
extern OMuword OPP_GRcompcurve_class_id;

from GRcompcurve import EMmakecomp;

IGRlong EFset_curve_direction(
 curve,
 start_point,
 start_position,
 reverse_flow_direction,
 my_stupid_id,
 new_curve,
 msg)

struct		GRlc_info *curve;
IGRpoint	start_point;
struct		GRparms *start_position;
IGRboolean	reverse_flow_direction;
GRobjid		my_stupid_id;
GRobjid		*new_curve;
IGRlong		*msg;

{
 IGRlong	sts;
 GRobjid	curve_1, curve_2, composite_curve;
 struct		GRid *id;
 struct		GRmd_env *md_env;
 struct		GRmdenv_info *mdenv_info;
 struct		GRprops properties;
/*
 * Initialize
 */
 *msg = MSSUCC;
 id = &curve->located_obj;
 md_env = &curve->module_info;
 mdenv_info = &md_env->md_env;
 *new_curve = NULL_OBJID;
 curve_1 = NULL_OBJID;
 curve_2 = NULL_OBJID;
 composite_curve = NULL_OBJID;
/*
 * Let's determine if the curve is closed by 
 * getting it's geometric properties.
 */
 sts = om$send(
   msg = message GRvg.GRgeomprops(
    msg,
    &mdenv_info->matrix_type,
    mdenv_info->matrix,
    &properties),
   senderid = my_stupid_id,
   targetid = id->objid,
   targetos = id->osnum);
  if (! (1 & sts)) goto wrapup;
/*
 * If the curve is physically closed then
 * split it at the required place
 */
 if (properties.phy_closed)
  {
   if (start_position)		/* Is starting position specified? */
    {
     OMuword	the_classid;
     IGRshort	number_of_split_curves;
/*
 * Get the class id of the curve to be split
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
 * Split the sucker.  Note that I am assuming that the curves are
 * returned in such an order that when the curves are combined in
 * the order (curve_1, curve_2) that start_point will indeed be
 * the starting point.
 */
     sts = om$send(
       msg = message GRcurve.GRsplit(
        msg,
        md_env,
        start_point,
        start_position,
        &curve_1,
        &curve_2,
        &number_of_split_curves),
       senderid = my_stupid_id,
       targetid = id->objid,
       targetos = id->osnum);
      if (! (1 & sts)) goto wrapup;
     if ((*msg == MSINARG) ||
         (number_of_split_curves == 0))
      {
       *msg = MSSUCC;
       *new_curve = id->objid;
      }
     else if (number_of_split_curves == 1)
      {
       *new_curve = curve_1;
       curve_1 = NULL_OBJID;;
      }
/*
 * If the split produced two curves then we must
 * merge them together.  I need to put the curves together
 * such that I maintain the split point as the starting point.
 */
     else
      {
       struct		GRlc_info lc_info[2];

       lc_info[0] = *curve;
       lc_info[0].located_obj.objid = curve_2;
       lc_info[1] = *curve;
       lc_info[1].located_obj.objid = curve_1;
/*
 * First determine whether or not we are working with
 * a composite curve.
 */
       sts = om$is_ancestry_valid(
         subclassid = the_classid, 
         superclassid = OPP_GRcompcurve_class_id);
/*
 * If the curve is a composite then we must combine
 * the two pieces into a new composite.
 */
       if (sts == OM_S_SUCCESS)
        {
         IGRlong	rotten_one;
         struct		GRvg_construct construct_list;

         construct_list.msg        = msg; 
         construct_list.class_attr = NULL;   /* Not used */
         construct_list.level      = NULL;   /* Not used */
         construct_list.display    = NULL;   /* Not used */
         construct_list.env_info   = NULL;   /* Not used */
         construct_list.newflag    = NULL;   /* Not used */
         construct_list.name       = NULL;   /* No name */
         construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
         sts = om$construct(
           classid = OPP_GRcompcurve_class_id,
           msg = message GRgraphics.GRconstruct(
            &construct_list),
           p_objid = &composite_curve,
           osnum = id->osnum);
          if (! (1 & sts)) goto wrapup;
         sts = om$send(
           msg = message GRcompcurve.EMmakecomp(
            msg,
            md_env,
            2,			/* Composite 2 curves together */
            lc_info,
            &rotten_one),
           senderid = my_stupid_id,
           targetid = composite_curve,
           targetos = id->osnum);
          if (! (1 & sts)) goto wrapup;
         if (rotten_one != -1)	/* If both were not added */
          {
           *msg = MSFAIL;
           goto wrapup;
          }
         *new_curve = composite_curve;
         composite_curve = NULL_OBJID;
         curve_1 = NULL_OBJID;
         curve_2 = NULL_OBJID;
        } /* if (sts == OM_S_SUCCESS) */
/*
 * If the curve is not a composite then we must
 * merge the two pieces into a single curve of the
 * correct class.
 */
       else
        {
extern IGRboolean EFmerge_curves() ;
         extern		IGRboolean GRabsg_del_all();
         IGRboolean	status;
         IGRlong	loc_msg;
         struct		GRpost_info info;
         struct		IGRbsp_curve *merged_curve;

         merged_curve = NULL;
         status = EFmerge_curves(
           2,			/* 2 curves to be merged */
           lc_info,
	   NULL, 		/* no curve buffs */
           my_stupid_id,
           &merged_curve,
	   FALSE, 		/* do not try filling gaps */
           msg);
          if (! status) goto wrapup;
/*
 * If the curve is freeform then reparameterize it as requested
 * by Dieter Breden.
 */
         sts = om$is_ancestry_valid(
           subclassid = the_classid, 
           superclassid = OPP_GRsubbc_class_id);
         if (sts == OM_S_SUCCESS)
          {

           BSarclnparc(
             &loc_msg,
             merged_curve);
            if (loc_msg != BSSUCC)
             {
              *msg = MSFAIL;
              goto wrapup;
             }
          } /* if (sts == OM_S_SUCCESS) */
/*
 * Now post this merged curve into the first curve.  Note that I
 * am assuming that the class to be constructed is that of the
 * first curve.
 */
         info.construct_flag = FALSE;
         sts = om$send(
           msg = message GRvg.GRpostabsg(
            msg,
            md_env,
            &info,
            (IGRchar *) merged_curve,
            &curve_1),
           senderid = my_stupid_id,
           targetid = curve_1,
           targetos = id->osnum);
          if (! (1 & sts)) goto wrapup;
/*
 * Assign the results and clear the abstract buffer as it no
 * longer properly represents the constructed curve.
 */
         *new_curve = curve_1;
         curve_1 = NULL_OBJID;
         status = GRabsg_del_all();
/*
 * Free the merged curve
 */
         status = BSfreecv(
          &loc_msg, 
          merged_curve);
        } /* ELSE FOR if (sts == OM_S_SUCCESS) */
      } /* ELSE FOR else if (number_of_split_curves == 1) */
    } /* if (start_position) */
/*
 * Current starting point is OK
 */
   else
    *new_curve = id->objid;
  } /* if (properties.phy_closed) */
/*
 * If the curve is open then we will take it
 */
 else
  *new_curve = id->objid;
/*
 * Reverse the curve, if required
 */
 if (reverse_flow_direction)
  {
   sts = om$send(
     msg = message GRcurve.GRrevparm(
      msg,
      md_env),
     senderid = my_stupid_id,
     targetid = *new_curve,
     targetos = id->osnum);
    if (! (1 & sts)) goto wrapup;
  } /* if (reverse_flow_direction) */
/*
 * End of routine
 */
wrapup:
/*
 * If there is nothing in the new curve then an error
 * must have occured.  In this case, try to return something.
 */
 if (*new_curve == NULL_OBJID)
  {
   if (curve_1 != NULL_OBJID)
    *new_curve = curve_1;
   else
    *new_curve = id->objid;
  }
/*
 * Everything was probably OK.  Clean up any construction
 * curves that the function left lying around.
 */
 else
  {
   if (curve_1 != NULL_OBJID)
    {
     IGRlong	loc_msg;

     sts = om$send(
       msg = message GRgraphics.GRdelete(
        &loc_msg,
        md_env),
       senderid = my_stupid_id,
       targetid = curve_1,
       targetos = id->osnum);
    } /* if (curve_1 != NULL_OBJID) */
   if (curve_2 != NULL_OBJID)
    {
     IGRlong	loc_msg;

     sts = om$send(
       msg = message GRgraphics.GRdelete(
        &loc_msg,
        md_env),
       senderid = my_stupid_id,
       targetid = curve_2,
       targetos = id->osnum);
    } /* if (curve_2 != NULL_OBJID) */
  } /* ELSE FOR if (*new_curve == NULL_OBJID) */
/*
 * Since the components were removed in their own right, only
 * remove the composite element itself.  This is accomplished
 * by sending a Root.delete() as opposed to a GRgraphics.GRdelete()
 * message.
 */
 if (composite_curve != NULL_OBJID)
  {
   IGRlong	loc_msg;

   sts = om$send(
     msg = message Root.delete(1),
     senderid = my_stupid_id,
     targetid = composite_curve,
     targetos = id->osnum);
  } /* if (composite_curve != NULL_OBJID) */
/*
 * Finally, let's get out of here
 */
 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
}

end implementation GRcurve;
