/*

Name
  SKextend_profile

Abstract

Synopsis
   long		   *msg		return code  (OUT)
   struct GRevent  *event	event	     (IN)

Description
 This routine checks to see if the profile can be extended due to
 a tentative snap at the endpoint.  Basically does ref-plane checking
 and queries the user to make a decision in case the ref-planes do
 not match.

Return Value

Notes

Index

Keywords
  profile, extend

History
 07/11/92 : Rajiv Agrawal : Creation 
 08/14/92 : Rajiv Agrawal : Disallowed extending if an SKpoint was selected.
 			    Cannot extend from centerpoints of arcs.
 08/18/92 : Rajiv Agrawal : Made sure that the Tentative snap was to the
      			    endpoint of the profile.
 12/16/92 : Rajiv Agrawal : Ensured that the tentative snap is to the endpoint
 			    of an open composite curve.

 07/02/93 : Sudha         : Modified for BSprototypes ansification

*/

class implementation SKmgr;

#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "EMdtmacros.h"
#include "gr.h"
#include "griodef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bsdistptpt.h"

#define FIRST  0
#define SECOND 1

extern GRclassid OPP_SKgeometry_class_id, OPP_SKpoint_class_id, OPP_SKmgr_class_id;

from SKgeometry import SKgetmgr;
from SKvariable import SKgetmgr;
from GRcurve    import GRendpts;

IGRboolean SKextend_profile(long *msg, struct GRevent *event)
{
  IGRboolean		extend, valid_snap;
  OMuint		count;
  long			msg_loc, stat_OM;
  double		lentol;
  IGRpoint		endpts[2];
  GRobjid		skmgr_id;
  GRclassid  		objclass;
  struct GRid 		eleid, refplnid, datplnid, comp_curve;
  struct GRprops	properties;
  struct GRmd_env	*md_env;
  OM_S_CHANSELECT  	chan_to_parent, chan_to_owner;
      
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  extend = FALSE;
  valid_snap = FALSE;
  
  /*
   * Find if the located object is SKgeometry class but not of a SKpoint.
   */
  
  md_env = &event->located_object[0].module_info;
  eleid = event->located_object[0].located_obj;
  om$get_classid (objid = eleid.objid, osnum = eleid.osnum,
                  p_classid = &objclass);
  if (event->subtype == GRst_KEYPOINT &&
      (om$is_ancestry_valid (subclassid = objclass,
         superclassid = OPP_SKgeometry_class_id) == OM_S_SUCCESS) &&
      (om$is_ancestry_valid (subclassid = objclass,
         superclassid = OPP_SKpoint_class_id) != OM_S_SUCCESS))
  {
    /*
     * Get the SKmanager of the located element.
     */
    
    skmgr_id = NULL_OBJID;
    stat_OM = om$send (msg = message SKgeometry.SKgetmgr (&msg_loc, 
                             &skmgr_id),
                       targetid = eleid.objid,
                       targetos = eleid.osnum,
                       senderid = NULL_OBJID);
  
    EMerr_hndlr (EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
    if (IF_NULL_OBJID(skmgr_id))
      om$send (msg = message SKvariable.SKgetmgr (&msg_loc,
                     &skmgr_id),
               targetid = eleid.objid,
               targetos = eleid.osnum,
               senderid = NULL_OBJID);
  
    EMerr_hndlr (IF_NULL_OBJID (skmgr_id), *msg, EMS_E_InvalidArg, ret_end);
    
    /*
     * Make sure that the Tentative snap was made to the endpoint of
     * the existing profile.
     */

    EMmake_chanselect (GRconnector_to_owners, &chan_to_owner);
    om$get_channel_count (objid = eleid.objid, osnum = eleid.osnum,
                          p_chanselect = &chan_to_owner, count = &count);
    
    EMerr_hndlr ((count < 1), *msg, EMS_E_InvalidArg, ret_end);
    
    comp_curve.objid = NULL_OBJID;
    om$get_objid_at_index (objid = eleid.objid, osnum = eleid.osnum,
                           p_chanselect = &chan_to_owner, index = FIRST,
                           objidaddr = &comp_curve.objid,
                           osnumaddr = &comp_curve.osnum);
    EMerr_hndlr (IF_NULL_OBJID (comp_curve.objid), *msg, EMS_E_InvalidArg,
                 ret_end);
                 
    /*
     * If the owner is SKmgr directly then we have to be on an endpoint.
     * If the located element is part of a SKcompcurve, we need to check.
     */

    om$get_classid (objid = comp_curve.objid, osnum = comp_curve.osnum,
                    p_classid = &objclass);
    if (om$is_ancestry_valid (subclassid = objclass, 
          superclassid = OPP_SKmgr_class_id) == OM_S_SUCCESS)
      valid_snap = TRUE;
    else
    {
      /*
       * Check if the SKcompcurve is closed ... if it is then not a valid snap.
       */
      properties.phy_closed = FALSE;
      stat_OM = om$send( msg = message GRvg.GRgeomprops
                               (&msg_loc, &md_env->md_env.matrix_type, md_env->md_env.matrix, 
                                &properties),
                         targetid = comp_curve.objid,
                         targetos = comp_curve.osnum,
                         senderid = NULL_OBJID );
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
      
      if (!properties.phy_closed) 
      {
        om$send (msg = message GRcurve.GRendpts (&msg_loc, &md_env->md_env.matrix_type,
                       md_env->md_env.matrix, endpts[FIRST], endpts[SECOND]),
                 targetid = comp_curve.objid, 
                 targetos = comp_curve.osnum,
                 senderid = NULL_OBJID);
  
        BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
        if (BSdistptpt(&msg_loc, endpts[FIRST], &event->event.button.x) < lentol ||
            BSdistptpt(&msg_loc, endpts[SECOND], &event->event.button.x) < lentol)
          valid_snap = TRUE;
      }
    }
    
    /*
     * Get the reference plane of the sketch-manager.
     */
    
    EMmake_chanselect (NDfather_father, &chan_to_parent);
    refplnid.objid = NULL_OBJID;
    om$get_objid_at_index (objid = skmgr_id, 
                           osnum = eleid.osnum, 
                           p_chanselect = &chan_to_parent, index = FIRST,
                           objidaddr = &refplnid.objid, 
                           osnumaddr = &refplnid.osnum);
          
    EMerr_hndlr (IF_NULL_OBJID (refplnid.objid), *msg, EMS_E_InvalidArg,
                 ret_end);
    
    /*
     * Check if the profile ref plane is the same as the active one.
     * If not, prompt the user to take some action (TO BE DONE).
     */
    
    ems$get_active_datum_plane (msg = &msg_loc, datpln = &datplnid);
    if (refplnid.objid != datplnid.objid)
    {
      ex$message (msgnumb = EMS_S_ProfRefPlnDiffFromCurPln);
      ex$message (msgnumb = EMS_P_LinktoExistProfile);
      extend = FALSE;
    }
    else if (valid_snap)
      extend = TRUE;
  }

ret_end:
  if (EMSerror (stat_OM))
    *msg = EMS_E_Fail;
  return (extend);

}

end implementation SKmgr;
