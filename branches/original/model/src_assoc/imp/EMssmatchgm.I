class implementation EMSsubbs;
/*
    History
        10-Jun-90       SM      Creation.
        19-Sep-90       DLB     Major rewrite to do topology match- instead of
                                moving right to left, tags, parents, & depends.
                                are moved left to right.
        10-Oct-90       SM      Untill error recovery,delete the
                                old dude.
        01/10/91        DLB     Return if rhs_val == my_id.
        01/29/91        DLB     Add the rhs surface to the rtree and reset
                                GRNOT_IN_RTREE bit.
        02/18/91        DLB     Handle rhs == NULL_OBJID - true if in mismatch
                                case.
        03/11/91        DLB     Change name for 2.0.1
        03/23/91        DLB     Match surface orientation.
        04/02/91        DLB     Don't match orient if in mismatch pass.
        05/01/91        DLB     If new_objid does not have a loopset, then 
                                add it.
        05/06/91        DLB     Send mk_nat_bdry only if my_id has topology.
                                Also env param to mk_nat_bdry is env_info
                                instead of env.
        06/22/91        DLB     Disabled the matching of topology.
        08/02/91        AIC     Added support for symbology,
                                ele-spec-attr, and horizon edges.
        08/07/91        DLB     Only match symbology/hor edges if not mismatch.
        08/28/91       Jack     Added call to EMget_graphics_edges to create
                                a cusp for the surface if it needs one. 
        09/08/91       pp       In some case the module_environment was
                                coming in as NULL which causes Jack's stuff
                                to break. (Eg: Lift face) Kludged the
                                code to handle the same.
        09/17/91       Jack     Reacted to parm change to EMget_graphics_edges.
                                Also, sent new option to only create the cusp.
        09/28/91       Jack     More parm changes to EMget_graphics_edges.                                  
        10/14/91        DLB     Added DONT_ORIENT check.
        01/16/92       Jack     Moved code to create a cusp for the surface
                                to EMssPostAb.I.
        01/30/92        AMD     Fix for TR 92n0329.
        02/06/92        DLB     Anand was using new_objid which will be
                                NULL_OBJID if in failure mode.
                                This is the real fix for 92n0329.
        04/08/92        DLB     Move hs symbology over to new object.
        06/24/92        DLB     Move locatable/displayable props.
        11/05/96      Anand     Made the change for the copies of objects to 
                                have their own properties of display and locate
                                if they need to have one TR#119222860
*/

#include "emsdef.h"
#include "EMSdpr.h"
#include "EMSopt.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hssymbmacros.h"
#include <alloca.h>

#define CLEAR FALSE

method EMmatch_geometry(IGRlong *EMmsg; IGRushort options;
                        struct GRmd_env *md_env; GRobjid new_objid)
{
 IGRlong         OM_stat=OM_S_SUCCESS, EFsend_store_on();
 OM_S_CHANSELECT to_loopset;
 struct GRmd_env buff_env, *ptr_env;

/*
 * If the module environment is not coming in, then assume an identity
 * module. Theoretically module environment should always be coming in.
 * pp 09/05/91
 */

 if (!md_env)
 {
   IGRint sizbuf, msg_loc, nret;

   sizbuf = sizeof(struct GRmd_env);

   gr$get_module_env ( msg = &msg_loc,
                         sizbuf = &sizbuf,
                         buffer = &buff_env,
                         nret = &nret );

   ptr_env = &buff_env;
 }
 else
  ptr_env = md_env;
 

 *EMmsg = EMS_S_Success;

 if (new_objid == my_id) return(OM_S_SUCCESS);

 /*DLB 2/6/92 - handle case of match being called for first time with old surf
  *             and new compsurf.  Call EFmatch_classes to set options.
  * Also removed Anands check for subbs class. Since the class check
  *  will handle this.
  *  This is the REAL fix for 92n0329.
  */

 if (!(options & EMstore_opt_HAS_COMPOSITE_OWNER))
 {
   if (!(options & EMstore_opt_MATCH_FAILED) && 
       !EFmatch_classes(EMmsg, my_id, new_objid, OM_Gw_current_OS, NULL)) 
   {
     options |= EMstore_opt_MATCH_FAILED;   
   }
 }

 /*Move tag (if match successful), name, channels*/
 OM_stat = EFmove_to_rhs(EMmsg, my_id, new_objid, sender_id, OM_Gw_current_OS,
                         options); 
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 if (!(options & EMstore_opt_MATCH_FAILED))

 {
   IGRint count;
   EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);
   OM_stat = om$get_channel_count(object = me,
                                  p_chanselect = &to_loopset,
                                  count = (OMuint *)&count);
   if (!(1 & OM_stat)) goto wrapup;                                     

   if (count)
   {
     /*I have topology so make sure new_objid also does.*/
     OM_stat = om$send(msg = message EMSsubbs.EMmk_nat_bdry(EMmsg,
                             &ptr_env->md_env, NULL), 
                       targetid = new_objid);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    
   }

   if (!(options & EMstore_opt_DONT_ORIENT) &&
       !(options & EMstore_opt_HAS_COMPOSITE_OWNER))
   {
     /*Ensure orientation of new surf is the same as me*/
     OM_stat = (IGRlong) EFmatch_orient(EMmsg, my_id, new_objid, new_objid,
                                        OM_Gw_current_OS, NULL);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;
   }

   {
     struct IGResbs  attr;

     OM_stat = om$send(msg = message GRvg.GRgetattr(EMmsg, (IGRchar *)&attr),
                       targetid = my_id);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;
     OM_stat = om$send(msg = message GRvg.GRputattr(EMmsg, (IGRchar *)&attr),
                       targetid = new_objid);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;
   }

   {
     struct GRsymbology  symb;

     OM_stat = om$send(msg = message GRvg.GRgetsymb(EMmsg, &symb),
                       targetid = my_id);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;
     OM_stat = om$send(msg = message GRvg.GRputsymb(EMmsg, &symb),
                       targetid = new_objid);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;
   }

   {
     IGRlong           loc_msg;
     IGRint            style, finish, size1, size2;
     IGRdouble         diff_refl, spec_refl, transparency;
     IGRuchar  tex_orient;
     IGRushort tex_index;
     IGRuchar  red, green, blue;
     unsigned char     *app_entry=NULL;

     /*The following is HS voodoo spoken by Shridar to get the app_entry info. 
      *  I don't have a clue about what to do here except what the Dr. has told
      *  me to do - DLB.
      */
     hs$get_app_entry_size(msg = &loc_msg,
                           size = &size1, active = 0,
                           mod_id = ptr_env->md_id.objid, 
                           mod_osnum = ptr_env->md_id.osnum);
     if (size1)
     {
       app_entry = (unsigned char *) alloca(size1 + 8);
       ((int *)app_entry)[0] = 0;
       ((int *)app_entry)[1] = 0;
     }

     hs$get_element_shading_symb(objid = my_id,
                                 osnum = OM_Gw_current_OS,
                                 style = &style,
                                 finish = &finish,
                                 diff_refl = &diff_refl,
                                 spec_refl = &spec_refl,
                                 transparency = &transparency,
                                 tex_orient = &tex_orient,
                                 tex_index = &tex_index,
                                 red = &red,
                                 green = &green,
                                 blue = &blue,
                                 app_entry = app_entry);

     if (size1)
     {
       size2 = ((int *)app_entry)[0];
       if (size1 != size2)
       {
         app_entry = NULL;
       }
     }

     hs$set_element_shading_symb(objid = new_objid,
                                 osnum = OM_Gw_current_OS,
                                 style = &style,
                                 finish = &finish,
                                 diff_refl = &diff_refl,
                                 spec_refl = &spec_refl,
                                 transparency = &transparency,
                                 tex_orient = &tex_orient,
                                 tex_index = &tex_index,
                                 red = &red,
                                 green = &green,
                                 blue = &blue,
                                 app_entry = app_entry);
   }


   /* TR#119222860
    */
   {
       IGRshort oldprops=NULL, newprops=NULL,  action=-1/*Replace*/;
       IGRshort props_mask=NULL;

       OM_stat = om$send(msg = message GRgraphics.GRgetprops(EMmsg,
                               &oldprops),
                         targetid = my_id);
       if (!(1 & OM_stat & *EMmsg)) goto wrapup;

       OM_stat = om$send(msg = message GRgraphics.GRgetprops(EMmsg,
                               &newprops),
                         targetid = new_objid);
       if (!(1 & OM_stat & *EMmsg)) goto wrapup;

       props_mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
       newprops = (~props_mask & newprops) | (oldprops & props_mask);

       OM_stat = om$send(msg = message GRgraphics.GRchgprops(EMmsg,
                               &action, &newprops),
                          targetid = new_objid);
       if (!(1 & OM_stat & *EMmsg)) goto wrapup;
   }
 }
 else
 {
   OM_stat = OM_S_SUCCESS;
 }

#if EVER_DECIDE_TO_PUT_TOPOLOGY_TAG_MATCHING_BACK_IN_PLACE_DLB_DLB_DLB
 OM_stat = EFsend_store_on(EMmsg, my_id, OM_Gw_current_OS, new_objid,
                           &to_loopset, options, ptr_env);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;                           
#endif

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EMSsubbs.EMmatch_geom")
  return(OM_stat);
}

end implementation EMSsubbs;
