/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsection;

%safe
#include <math.h>
%endsafe


#include "EMS.h"
#include <stdio.h>
#include "OMmacros.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSxsection.h"

from EMSsurface import EMgetactiveid, EMintcopy;
from GRgraphics import GRdelete, GRxform;

extern OMuword GRgraphics_OPP_GRdelete_method_index,
               GRgraphics_OPP_GRxform_method_index;

/*
  HISTORY
           RC     11/05/88     Creation Date
           SM     06-Jul-89    Argument change in EMSsurface.EMintcopy
           RC     08/10/89     conditional inclusion of fprintf statements
*/

method GRnotifylis(IGRlong *EMmsg; IGRlong *OMmsg; IGRlong *mask;
                   OM_S_MESSAGE *graphics_msg)

{
  struct  GRid  act_st_GRid;
  IGRlong       mthd_stat;
  
   *OMmsg = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;

   /*
    * The following switch statement is for debugging only.
    */

#if DEBUG

   switch (*mask)
   {
     case GR_GEOM_MODIFIED:
     fprintf (stderr, "mask = GR_GEOM_MODIFIED \n");     
     break;

     case GR_GEOM_XFORMED:
     fprintf (stderr, "mask = GR_GEOM_XFORMED \n");     
     break;

     case GR_COPIED:
     fprintf (stderr, "mask = GR_COPIED \n");     
     break;

     case GR_ATTR_MODIFIED:
     fprintf (stderr, "mask = GR_ATTR_MODIFIED \n");     
     break;

     case GR_DISPLAYED:
     fprintf (stderr, "mask = GR_DISPLAYED \n");     
     break;

     case GR_CLIPPED:
     fprintf (stderr, "mask = GR_CLIPPED \n");     
     break;
  
     case GR_GEOM_POSTED:
     fprintf (stderr, "mask = GR_GEOM_POSTED \n");     
     break;

     case GR_DELETED:
     fprintf (stderr, "mask = GR_DELETED \n");     
     break;

     case GR_LOCATED:
     fprintf (stderr, "mask = GR_LOCATED \n");     
     break;

     case GR_CHANNEL_USED:
     fprintf (stderr, "mask = GR_CHANNEL_USED \n");     
     break;

     case GR_RTREE_MANIPULATION:
     fprintf (stderr, "mask = GR_RTREE_MANIPULATION \n");     
     break;

     case GR_CHANGED:
     fprintf (stderr, "mask = GR_CHANGED \n");     
     break;

     default:
     break;
   } /* switch (*mask) */

#endif

   /*
    * I need to execute the notification if I am the active state.
    */

   *OMmsg = om$send (msg = message EMSsurface.EMgetactiveid (&mthd_stat,
                       &act_st_GRid, NULL),
                      targetid = my_id);
   EMerr_hndlr (!(1&*OMmsg&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

   if (act_st_GRid.objid == my_id)
   {
    /*
     * Invoke the incoming message on myself if the mask is one of the
     * following
     *  o GR_GEOM_XFORMED
     *  o GR_COPIED
     *  o GR_DELETED
     *  
     * It is not certain about what other masks need some kind of
     * processing. Whenever the need arises, the appropriate code
     * will be added.
     * 
     * Since more than one method invoked in a given operation
     * may try to notify the listeners with the same mask, checking
     * just the mask is not sufficient e.g., GRowner_GRdelete invokes
     * GRdelete_owner method which notifies listeners with a mask of
     * GR_DELETED and GRdelete_owner as the message argument. Also,
     * at the end of GRdelete implementation of GRowner, listeners are
     * again notified  with the same mask of GR_DELETED.
     */

    switch (*mask)
    {
      case GR_DELETED:
       if (graphics_msg->select.FuncIndex ==
                         GRgraphics_OPP_GRdelete_method_index)
       {
         struct GRgraphics_GRdelete_Msg   *parglist;

         parglist = (struct GRgraphics_GRdelete_Msg *) 
                                       graphics_msg->p_arglist;

         *OMmsg = om$send(msg = message GRgraphics.GRdelete (EMmsg,
                           parglist->md_env),
                          targetid = my_id);
         EMerr_hndlr (!(1& *OMmsg & *EMmsg), *EMmsg, EMS_E_SurfaceError,wrapup);
       }
       break;

      case GR_GEOM_XFORMED:

       if (graphics_msg->select.FuncIndex ==
                         GRgraphics_OPP_GRxform_method_index)
       {
         struct GRgraphics_GRxform_Msg *parglist;
         GRobjid                       newobjid;

         parglist = (struct GRgraphics_GRxform_Msg *) 
                                          graphics_msg->p_arglist;

         *OMmsg = om$send (msg = message EMSxsection.EMxsec_int_xform (
                            EMmsg,
                            parglist->md_env, parglist->matrix_type,
                            parglist->matrix, NULL, &newobjid, TRUE),
                           targetid = my_id);
         EMerr_hndlr (!(1& *OMmsg & *EMmsg),*EMmsg,EMS_E_Fail,wrapup);
       }      
       break;

      case GR_COPIED:
        {
          struct EMSsurface_EMintcopy_Msg      *parglist;
          struct EMSfnmgr_info  my_fnmgr_info, cp_fnmgr_info;
          IGRlong               rc;
          GRobjid               newobjid, *act_eds = NULL, 
                                *inact_eds = NULL;
          IGRint                num_act_eds = 0, num_inact_eds = 0, i,
                                act_eds_arrsz = 0, inact_eds_arrsz = 0;
          IGRboolean            copy_exists;
          extern void           EFfnmgr_manipulation(), EMcpsearch();

          /* ********************************************************* */

          my_fnmgr_info.fans = cp_fnmgr_info.fans = NULL;
          my_fnmgr_info.tips = cp_fnmgr_info.tips = NULL;
          my_fnmgr_info.tips_p_fan = cp_fnmgr_info.tips_p_fan = NULL;
          my_fnmgr_info.num_fans = cp_fnmgr_info.num_fans = 0;
          my_fnmgr_info.num_tips = cp_fnmgr_info.num_tips = 0;
          my_fnmgr_info.fans_arrsz = cp_fnmgr_info.fans_arrsz = 0;
          my_fnmgr_info.tips_arrsz = cp_fnmgr_info.tips_arrsz = 0;
          my_fnmgr_info.tips_p_fan_arrsz = 0;
          cp_fnmgr_info.tips_p_fan_arrsz = 0;

          parglist = (struct EMSsurface_EMintcopy_Msg *) 
                             graphics_msg->p_arglist;

          *OMmsg = om$send (msg = message EMSsurface.EMintcopy (EMmsg,
                             parglist->obj_env, parglist->new_mdenv,
                             &newobjid, parglist->copy_info, 
			     parglist->bdry_options, parglist->sf_options),
                            targetid = my_id); 
          EMerr_hndlr (!(1& *OMmsg & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
          
          /*
           * Post my copy's edges/model association info.
           */

          *OMmsg = om$send (
                       msg = message EMSxsection.EMget_associated_edges (
                        &mthd_stat, &act_eds, &inact_eds, &num_act_eds,
                        &num_inact_eds, &act_eds_arrsz, &inact_eds_arrsz,
                        EMSXS_ACT_EDGES | EMSXS_INACT_EDGES, MAXINT),
                       targetid = my_id);
          EMerr_hndlr (!(1&*OMmsg&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

          my_fnmgr_info.tips = (GRobjid *) om$malloc (
                 size = sizeof(GRobjid) * (num_act_eds + num_inact_eds));
          EMerr_hndlr (!my_fnmgr_info.tips, *EMmsg, EMS_E_NoDynamicMemory,
                       wrapup);

          if (num_act_eds)
            OM_BLOCK_MOVE (act_eds, my_fnmgr_info.tips, sizeof(GRobjid) * 
                           num_act_eds);
          if (num_inact_eds)
            OM_BLOCK_MOVE (inact_eds, &my_fnmgr_info.tips[num_act_eds], 
                           sizeof(GRobjid) * num_inact_eds);

          my_fnmgr_info.num_tips = num_act_eds + num_inact_eds;

          EFfnmgr_manipulation (&rc, OM_Gw_current_OS, EMSlabel_xsection, 
                                EMSFM_MANIP_GET, EMSFM_KEY_TIP, 
                                &my_fnmgr_info, NULL);
          EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

          cp_fnmgr_info.tips = (GRobjid *) om$malloc (
                        size = sizeof(GRobjid) * my_fnmgr_info.num_tips);
          EMerr_hndlr (!cp_fnmgr_info.tips, *EMmsg, EMS_E_NoDynamicMemory,
                       wrapup);

          cp_fnmgr_info.fans = (GRobjid *) om$malloc (
                        size = sizeof(GRobjid) * my_fnmgr_info.num_tips);
          EMerr_hndlr (!cp_fnmgr_info.fans, *EMmsg, EMS_E_NoDynamicMemory,
                       wrapup);

          cp_fnmgr_info.tips_p_fan = (IGRint *) om$malloc (
                        size = sizeof(IGRint) * my_fnmgr_info.num_tips);
          EMerr_hndlr (!cp_fnmgr_info.tips_p_fan, *EMmsg, 
                       EMS_E_NoDynamicMemory, wrapup);

          cp_fnmgr_info.num_tips = cp_fnmgr_info.num_fans = 
                                                   my_fnmgr_info.num_tips;

          for (i = 0; i < my_fnmgr_info.num_tips; i++)
          {
            cp_fnmgr_info.tips_p_fan[i] = 1;

            EMcpsearch (&rc, my_fnmgr_info.tips[i],&cp_fnmgr_info.tips[i],
                        parglist->copy_info, 0, &copy_exists);
            EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
            EMerr_hndlr (!copy_exists, *EMmsg, EMS_E_InvalidArg,wrapup);

            EMcpsearch (&rc, my_fnmgr_info.fans[i],&cp_fnmgr_info.fans[i],
                        parglist->copy_info, 0, &copy_exists);
            EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
            EMerr_hndlr (!copy_exists, *EMmsg, EMS_E_InvalidArg,wrapup);

           } /* for (i = 0; i < num_eds; i++) */
    
           EFfnmgr_manipulation (&rc, parglist->new_mdenv->md_id.osnum, 
                                 EMSlabel_xsection, EMSFM_MANIP_PUT, 
                                 EMSFM_KEY_TIP, &cp_fnmgr_info, NULL);
           EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

           if (my_fnmgr_info.tips) om$dealloc (ptr = my_fnmgr_info.tips);
           if (my_fnmgr_info.fans) om$dealloc (ptr = my_fnmgr_info.fans);
           if (cp_fnmgr_info.tips) om$dealloc (ptr = cp_fnmgr_info.tips);
           if (cp_fnmgr_info.fans) om$dealloc (ptr = cp_fnmgr_info.fans);
           if (cp_fnmgr_info.tips_p_fan) 
                             om$dealloc (ptr = cp_fnmgr_info.tips_p_fan);

        }
        break;

     case GR_RTREE_MANIPULATION:
     case GR_DISPLAYED:

       *OMmsg = om$send (msg = graphics_msg,
                         targetid = my_id);
       EMerr_hndlr (!(1&*OMmsg), *EMmsg, EMS_E_Fail, wrapup);
       break; 
       
      default:              
       break;
    } /* switch (*mask) */

   } /* if (act_st_GRid.objid == my_id) */

wrapup:
  EMWRAPUP (*OMmsg, *EMmsg, "In EMSxsection.EMnotify");
  return (*OMmsg);
}
end implementation EMSxsection;
