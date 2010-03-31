/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;
/*
Abstract: 
    This method deletes the loopset and helpers of the surface, then
    deletes the surface object itself.

History:

    gupta  12/04/86 : Creation date.

    RC     2/12/87  : modification for topology class structure changes

    AIC    15-Jul-87: Return MSSUCC on success.

    10 February 88  AIC     Delete my helpers.
    dhm    04/05/88   add GR_NOTIFY_LISTENERS.
    SS     08/26/88   Modified notification for the new scheme
    DLB   04/19/91 Delete any EMSparameter object on parent channel.  This
                    abstract class wont have the parent channel and therefore
                    is a bit dirty but im going for a lean and mean impl.
                    rather than adding an override at EMAsubbs.
    jhw    08/06/91   Delete the parameters before the EMpostdelete is sent
                      since EMpostdelete send NDmove_to_root to dimension 
                      children. This causes the dimensions to fail to erase
                      when the associative object is deleted.
                      
    Jack   10/1/01    Rather than delete all of my helpers as done by
                      AIC on 2/10/88, only delete objects other than
                      EMShorizon.
    pp     07/22/92   Added the section to GRdelete for preprocessing
                      the delete of associative entities..
    NP	   08/25/92   Modified for ANSI compliance. Changed "count" and "cnt" to
		      IGRuint.
                      
*/

#define HSURF_BUNDLES   1

# define DEBUG 1

# include "msdef.h" /* MS message codes */
# include "emsdef.h"
# include "emsmacros.h"
# include "godef.h"
# include "gocmacros.h"
# include "EMSmsgdef.h"

#if HSURF_BUNDLES
#include "hssymbmacros.h"
#include "hsurf.h"
#endif

extern OMuword OPP_EMShorizon_class_id;

# define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSparameter import EMparam_delete;
from EMAsurface import EMpreprocess_delete;

method GRdelete(IGRlong *msg; struct GRmd_env *md_env)
{
  IGRboolean	    notify;
  IGRlong           msg_loc, stat_OM;    /* return status for method */
  OM_S_CHANSELECT   chan;
  IGRuint           count = 0, cnt;
  OM_S_OBJECT_LINKAGE *channel_objects = NULL;
  OMuword           my_classid;
 
  /*
   * initialize return variables
   */
  stat_OM = OM_S_SUCCESS;
  *msg = MSSUCC;
  
  if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
  {
    OM_S_CHANSELECT to_father;
    EMmake_chanselect(NDfather_father, &to_father);
    om$send(msg = message EMSparameter.EMparam_delete(&msg_loc, md_env),
            p_chanselect = &to_father);

    om$send(msg = message EMAsurface.EMpreprocess_delete(&msg_loc,
                  md_env),
            targetid = my_id);
  }

  if (notify = EMcheck_inhibit_postproc())
    {
    stat_OM = om$send (msg = message EMSsurface.EMpostdelete (&msg_loc, NULL,
               md_env, OPPmargs, NULL), targetid = my_id);
    EMomerr_exit (stat_OM, wrapup);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, wrapup);
    }

  /*
   * Delete loopset belonging to the surface
   */
  stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &chan);
  stat_OM = om$send(msg = message Root.delete(1), p_chanselect = &chan);
  EMomerr_hndlr(stat_OM, wrapup, "EMssdelete");

  /*
   * Delete all of the surface helpers except EMShorizon objects
   */
  stat_OM = EMmake_chanselect (EMSrequester_to_helpers, &chan);
# if DEBUG
  EMomerr_hndlr(stat_OM, wrapup, "EMssdelete - make_chanselect");
# endif
  
  stat_OM = om$get_channel_count(object = me,
                                 p_chanselect=&chan,
                                 count=&count);
  if(count)
   {
    channel_objects = (OM_S_OBJECT_LINKAGE *) alloca(sizeof(
                                             OM_S_OBJECT_LINKAGE) * count);

    stat_OM = om$get_channel_objects(object = me,
                                     p_chanselect = &chan,
                                     list = channel_objects,
                                     size = count,
                                     count = &count);
    for(cnt=0;cnt<count;cnt++)
     {
      stat_OM = om$get_classid( osnum = channel_objects[cnt].osnum,
                                objid = channel_objects[cnt].S_objid,
                                p_classid = &my_classid );
      EMomerr_hndlr(stat_OM, wrapup, "EMssdelete");
  
      if((stat_OM = om$is_ancestry_valid(subclassid = my_classid,
                      superclassid = OPP_EMShorizon_class_id)) !=
                                                          OM_S_SUCCESS)
       {
         stat_OM = om$send(msg = message Root.delete(1), 
                           targetos = channel_objects[cnt].osnum,
                           targetid = channel_objects[cnt].S_objid);
         EMomerr_hndlr(stat_OM, wrapup, "EMssdelete");
       }                                                                      
     } 
   } 




  /*
   * Delete myself
   */
  stat_OM = om$send(mode = OM_e_wrt_message,
                    msg = message GRgraphics.GRdelete(msg,md_env),
                    targetid = my_id);
  EMomerr_hndlr(stat_OM, wrapup, "EMssdelete");

#if HSURF_BUNDLES
  {
    IGRlong                         loc_msg;

    hs$delete_symb_entry(msg = &loc_msg, index = me->hidden_line);
  }
#endif


wrapup:
  if (notify)
    EMrestore_postproc();
  if(1 & *msg) *msg = MSSUCC;
  return(stat_OM);
}

end implementation EMSsubbs;
