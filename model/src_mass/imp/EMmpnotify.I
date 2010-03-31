/* ###################   APOGEE COMPILED   ################## */
class implementation EMSmassprop;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include <stdio.h>
#include "OMmacros.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsmass.h"
#include "grdpbdef.h"
#include "gr.h"
#include "grdpbmacros.h"
#include "ma.h"
#include "madef.h"
#define DEBUG 0
#define AREA_PROPERTIES 0
#define MASS_PROPERTIES 1

extern OMuword GRgraphics_OPP_GRdelete_method_index,
               GRgraphics_OPP_GRcopy_method_index,
               GRgraphics_OPP_GRxform_method_index;

from EMSsurface import EMmassprop ;
from EMSsurface import EMareaprop ;

extern OMuword OPP_GRgraphics_class_id;

/*
  HISTORY
           gupta     07/06/89     Creation Date
*/

method GRnotifylis(IGRlong *EMmsg;
                   IGRlong *stat_OM;
                   IGRlong *mask;
                   OM_S_MESSAGE *graphics_msg)

{
  *stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;


  /* for debugging purposes */

 /*   #ifdef DEBUG

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
   }

#endif   */


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
      case GR_GEOM_MODIFIED:
           me->mp_valid = FALSE;
           break;

      case GR_CHANGED:
          if( !ME.EMSmassprop->mp_valid)
          {
           IGRuchar style[1];
           OM_S_CHANSELECT   to_comps;
           IGRint size, nreturn;
           struct GRmd_env mod_env;
           enum GRdpmode display_mode ;

           size = sizeof(struct GRmd_env);
           *stat_OM =  gr$get_module_env( msg = EMmsg,
                           sizbuf = &size,
                           buffer = &mod_env,
                           nret = &nreturn);

     /***** old delete triad   
          *stat_OM = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_comps);
          EMerr_hndlr(!(1 & *stat_OM  & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);

          *stat_OM = om$send(msg = message GRgraphics.GRdelete(EMmsg,
                     &mod_env),
                    p_chanselect = &to_comps,
                    from = (option == AREA_PROPERTIES ? 4 : 7),
                    to = 0);
          EMerr_hndlr(!(1 & *stat_OM  & *EMmsg), *EMmsg, EMS_E_Fail,wrapup); 
          style[0] = 2;
          *stat_OM = om$send(msg = message GRvg.GRchgstyle(EMmsg,style),
                  targetid = my_id);
          EMerr_hndlr(!(1 & *stat_OM  & *EMmsg), *EMmsg, EMS_E_Fail,wrapup); 
     ******/

     /* erase triad  */
          display_mode = GRbe;
          *stat_OM = om$send(msg = message EMSmassprop.EMmpdisplay(EMmsg,
                     &mod_env,
                     &display_mode),
                  targetid = my_id);
          EMerr_hndlr(!(1 & *stat_OM  & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);

      /* delete massprop object (myself)    */
          *stat_OM = om$send(msg = message GRgraphics.GRdelete(EMmsg,
                             &mod_env),
                     targetid = my_id);
          EMerr_hndlr(!(1 & *stat_OM  & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);
         }

      case GR_DELETED:

       if (graphics_msg->select.FuncIndex ==
                                         GRgraphics_OPP_GRdelete_method_index)
        {
         struct GRgraphics_GRdelete_Msg   *parglist;

         parglist = (struct GRgraphics_GRdelete_Msg *) 
                                       graphics_msg->p_arglist;

         *stat_OM = om$send(msg = message GRgraphics.GRdelete (EMmsg,
                                  parglist->md_env),
                            targetid = my_id);
         EMerr_hndlr(!(1 & *stat_OM & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);
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

         *stat_OM = om$send (msg = message EMSmassprop.EMintxform (EMmsg,
                            parglist->md_env, parglist->matrix_type,
                            parglist->matrix, &newobjid),
                           targetid = my_id);
         EMerr_hndlr(!(1 & *stat_OM & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);
        }      
       break;

      case GR_COPIED:
       {
        struct EMSmassprop_EMintcopy_Msg      *parglist;
        GRobjid                               newobjid;
        if ((graphics_msg->select.FuncIndex ==
                                      GRgraphics_OPP_GRcopy_method_index) &&
            (graphics_msg->select.DefClassid != OPP_GRgraphics_class_id))
         {
          parglist = (struct EMSmassprop_EMintcopy_Msg *) 
                                                graphics_msg->p_arglist;

          *stat_OM = om$send (msg = message EMSmassprop.EMintcopy (EMmsg,
                                    parglist->obj_mdenv,
                                    parglist->new_mdenv,
                                    &newobjid, parglist->copy_info),
                              targetid = my_id); 
          EMerr_hndlr(! (1 & *stat_OM & *EMmsg),*EMmsg,EMS_E_Fail,wrapup);
         }
        } 
       break;

      case GR_RTREE_MANIPULATION:
      case GR_DISPLAYED:

         *stat_OM = om$send (msg = graphics_msg,
                             targetid = my_id);
         EMerr_hndlr (!(1 & *stat_OM), *EMmsg, EMS_E_Fail, wrapup);

         break; 
       
      default:              
           break;
    } /* switch (*mask) */


wrapup:
  EMWRAPUP (*stat_OM, *EMmsg, "In EMSmassprop.EMnotify");
  return (*stat_OM);
}
end implementation EMSmassprop;




