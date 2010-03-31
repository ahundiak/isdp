/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method inserts a pole into a freeform curve.

 History

 lst : 09/25/86 : the beginning
 ss  : 10/20/86 : cvrt to 4.0
 rlw : 12/29/87 : Totally reworked.
 dhm : 04/05/88 : Added GR_NOTIFY_LISTNERS
 Sudha  06/16/93     Modified for BSprototype ansification
 dhm : 11/01/93 : Added the owner code.
 */

class implementation GRsubbc;

#include "EMS.h"
#include "bs.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "bsinspolcv2.h"
#include "bsfreecv.h"
#include "godef.h"
#include "nddef.h"
#include "ndmacros.h"

extern OMuword OPP_SKmgr_class_id;
extern OMuword OPP_SKcompcurve_class_id;
extern OMuword OPP_GRcompcurve_class_id;

from GRlistener import GRnotifylis;

method EMinsert_pole(
 struct		GRlc_info *lc_info;
 IGRpoint	point;
 IGRlong	*msg)
{
 IGRlong	sts, loc_msg;
 IGRshort       props, has_owner = FALSE;
 IGRint         num, last_pole;
 IGRdouble      par, other_par;
 struct		IGRbsp_curve *curve;
 struct GRid    owner_id;
 OMuword        owner_classid;
 OM_S_CHANSELECT to_owner;

/*
 * Initialize
 */
 *msg = MSSUCC;
 sts = OM_S_SUCCESS;
 curve = NULL;

/*
 * Get my geometry
 */
 sts = EMget_the_geometry(
   lc_info,
   TRUE,		/* It is a curve */
   FALSE,		/* It's not directed */
   TRUE,		/* Separate malloc's */
   my_id,
   &curve,
   msg);
  if (! (1 & sts)) goto wrapup;

/*
 * Check to see if I'm a component of a SKmgr, SKcompcurve, or GRcompcurve.
 * If I'm a component, then check the point to insert and see if it's an
 * interior pole - not between the 1st 2 or the last 2.  dhm 11/1/93
 */

 sts = om$send(msg = message GRgraphics.GRgetprops(&loc_msg, &props),
               targetid = my_id,
               targetos = lc_info->located_obj.osnum);
 if (! (1 & sts)) goto wrapup;

 if (props & GR_RIGID_RELATIONSHIP)
 {
     om$make_chanselect(channame = "GRconnector.to_owners",
                        p_chanselect = &to_owner);

     sts = om$get_objid_at_index(objid = my_id,
                                 p_chanselect = &to_owner,
                                 index = 0,
                                 objidaddr = &owner_id.objid,
                                 osnumaddr = &owner_id.osnum);
     if (! (1 & sts)) goto wrapup;

     sts = om$get_classid(osnum = owner_id.osnum,
                          objid = owner_id.objid,
                          p_classid = &owner_classid);
     if (! (1 & sts)) goto wrapup;

     sts = om$is_ancestry_valid(subclassid = owner_classid,
                                 superclassid = OPP_SKmgr_class_id);

     if (sts != OM_S_SUCCESS)
     {
         sts = om$is_ancestry_valid(subclassid = owner_classid,
                                    superclassid = OPP_SKcompcurve_class_id);
         if (sts != OM_S_SUCCESS)
         {
             sts = om$is_ancestry_valid(subclassid = owner_classid,
                                     superclassid = OPP_GRcompcurve_class_id);
             if (sts != OM_S_SUCCESS)
             {
                 sts = OM_I_INVANCESTRY;
                 goto wrapup;
             }
         }
     }

     has_owner = TRUE;

     sts = om$send(msg = message GRvg.EMpratpt(&loc_msg, 
                                     &lc_info->module_info.md_env.matrix_type,
                                     lc_info->module_info.md_env.matrix,
                                     point, &par, &num),
                   targetid = my_id);
     if (! (1 & sts)) goto wrapup;

     sts = om$send(msg = message GRvg.EMpratpt(&loc_msg,
                                     &lc_info->module_info.md_env.matrix_type,
                                     lc_info->module_info.md_env.matrix,
                                     &curve->poles[3], &other_par, &num),
                   targetid = my_id);
     if (! (1 & sts)) goto wrapup;

     if (par <= other_par)
     {
         *msg = MSINARG;
         goto wrapup;
     }

     last_pole = (curve->num_poles - 1) * 3;
     sts = om$send(msg = message GRvg.EMpratpt(&loc_msg,
                         &lc_info->module_info.md_env.matrix_type,
                         lc_info->module_info.md_env.matrix,
                         &curve->poles[last_pole-3], &other_par, &num),
                   targetid = my_id);
     if (! (1 & sts)) goto wrapup;

     if (par >= other_par)
     {
         *msg = MSINARG;
         goto wrapup;
     }

 } /* end if (props & GR_RIGIG_RELATIONSHIP) */

/*
 * Call the math function to insert
 * the pole.
 */
 {

  BSinspolcv2(
    point,
    curve,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Post the modified geometry into the database
 */
 {
  GRobjid	newobjid;
  struct	GRpost_info info;

  info.construct_flag = FALSE;
  sts = om$send(
    msg = message GRvg.GRpostabsg(
     msg,
     &lc_info->module_info,
     &info,
     (IGRchar *) curve,
     &newobjid),
    targetid = my_id);
   if (! (1 & sts)) goto wrapup;
 }
/*
 * eof
 */
wrapup:
 if (curve)
  {
 extern  IGRboolean  GRabsg_del_all();
   IGRboolean	status;

   status = BSfreecv(
    &loc_msg, 
    curve);
   status = GRabsg_del_all();
  }

 GR_NOTIFY_LISTENERS(msg, &sts, GR_GEOM_MODIFIED);

 if (has_owner)
 {
     if (owner_classid == OPP_GRcompcurve_class_id)
     {
         long mask = GR_GEOM_POSTED;
         OMuint count;
         OM_S_CHANSELECT chandef;

         om$make_chanselect(channame = "GRnotify.notification",
                            p_chanselect = &chandef);

         sts = om$get_channel_count(objid = owner_id.objid,
                                       osnum = owner_id.osnum,
                                       p_chanselect = &chandef,
                                       count = &count);
         if ((1 & sts) && (count))
         {
             /* send notification to the listeners   */

             sts = om$send(msg = message GRlistener.GRnotifylis
                                  (&loc_msg,&loc_msg,&mask,OPPmargs),
                           senderid = owner_id.objid,
                           targetos = owner_id.osnum,
                           p_chanselect = &chandef);
         }
     }
     else
     {
         nd$wait_batch(type = GR_GEOM_POSTED,
                       nb_obj = 1,
                       l_object = &owner_id);
     }

 }


 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  return(sts);
}
   
end implementation GRsubbc;
