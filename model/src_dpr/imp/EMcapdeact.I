class implementation EMSsfcapsf;


/*

DESCRIPTION

    This method will deactivate me if I am an active state.  This is
    done by changing topology and/or geometry I have saved with what
    is currently active.

Returned values
    EMS_S_SUCCESS if all is well.


HISTORY

    11/10/92  :  AMD  :  Creation

*/


#include "EMS.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "EMSlmdef.h"

/* DPR_DISPLAY_BUFF_INCR */
#include "emsdef.h"

#define BUFF_INCR DPR_DISPLAY_BUFF_INCR

from EMSloop import EMtreemod,EMgivenestinfo,EMactivate_loop;
from EMSsubbs import EMpartolbasis, EMpassloop;
from EMSboundary import EMget_objid, EMcheck_props;
from EMSloopset import EMnesting,EMtreemod, EMtoglpactive;
from EMSloop import EMset_props;
from EMSedge import EMget_props, EMset_props, EMstitch,
		    EMgetsurface_info;
                    
extern OMuword OPP_EMSsfcapsf_class_id, OPP_EMSsolid_class_id;


method EMdeactivate (
    IGRlong *EMmsg;
    IGRshort *option;
    struct GRmd_env *env;
    GRobjid **display_ids; 
    IGRint *display_count
)
{
  IGRlong                       sts;
  IGRint                        i;
  union EMSssi_table            *ssi;
  struct EMScapssi_table         *my_info;
  struct GRid                   owner_GRid;
  OM_S_CHANSELECT               to_loopset,to_comps, to_common_edge;
  IGRboolean                    delete;
  IGRboolean                    display;
  IGRint                        num_edges;
  OMuint                        count;
  GRobjid                       cap;
  GRspacenum                    dumosnum;
  enum GRdpmode                 display_mode;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  ssi = NULL;

  delete = (*option & EMS_UNDO_SAVE) ? FALSE : TRUE;

  display = *option & EMS_DO_DISPLAY;

  owner_GRid.objid = my_id;
  owner_GRid.osnum = OM_Gw_current_OS;

  sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                targetid = my_id);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);  


  my_info = &ssi->cap_info;

  /* Disconnect the cap edges */

  EMmake_chanselect( EMSedge_to_common_edge, &to_common_edge);

  num_edges = my_info->num_edges;
 
  for (i=0; i<num_edges; i+=2)
  {
    sts = om$send ( msg = message Root.disconnect( to_common_edge,
                    my_info->edges_connected[i], OM_Gw_current_OS, 
                    to_common_edge),
             targetid = my_info->edges_connected[i+1]);
    EMomerr_hndlr (sts, wrapup, "Root.disconnect");  
  }       

  sts = om$make_chanselect(channame="EMSsubbs.to_loopset",
                           p_chanselect=&to_loopset);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  sts = om$make_chanselect(chanaddr=&ME.GRcmpowner->to_components,
                           p_chanselect=&to_comps);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  /* Get the caps */

  sts = om$get_channel_count ( objid = my_id,
                               p_chanselect = &to_comps,
                               count = &count);

  for ( i=(count-1); i>0; i--)
  {
   sts = om$get_objid_at_index (objid = my_id,
                                p_chanselect = &to_comps,
                                index = i,
                                objidaddr = &cap,
                                osnumaddr = &dumosnum);
   EMomerr_hndlr (sts, wrapup, "om$get_objid_at_index");  

   if (*option & EMS_DO_DISPLAY)
   {
    IGRint      inx;          /*DECLARE*/
    IGRboolean  got_it = FALSE;    


    /* Has the added surface already been erased? */
    for (inx=0; inx<*display_count; inx++)
    {
     if ( (*display_ids)[inx] == cap )
     {
       got_it = TRUE;
       break;
     }
    }

    if (!got_it)
    {
     /**Erase the modified surface and store it**/

     display_mode = GRbehe;
     sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
                         &env->md_env.matrix_type, 
                         env->md_env.matrix, &display_mode,
                         &env->md_id),
              targetid = cap);
     EMomerr_hndlr (sts, wrapup, "GRgraphics.GRdisplay"); 

     /**Store modified id**/
     EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                         DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
     if (!(1 & *EMmsg)) goto wrapup;

     (*display_ids)[*display_count] = cap;
     (*display_count)++;
    }
   }

  /* Refresh myself */

   display_mode = GRbd;
   sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
                       &env->md_env.matrix_type, 
                       env->md_env.matrix, &display_mode,
                       &env->md_id),
            targetid = my_id);
   EMomerr_hndlr (sts, wrapup, "GRgraphics.GRdisplay"); 

  /*
   * if the option is EMS_UNDO_SAVE, make myself inactive and 
   * make the  new_plane  unlocatable and undisplayable.
   * Otherwise, delete myself and new_plane;
   */

  if (delete)
  {
   sts = om$send (msg = message GRgraphics.GRdelete( EMmsg, 
                 env), targetid = cap);
   EMomerr_hndlr (sts, wrapup, "GRgraphics.GRdelete"); 
  }
  else
  {
   EFsetsfstate(EMmsg, cap, OM_Gw_current_OS, EMS_O_OFF);
   EMomerr_hndlr (sts, wrapup, "EFsetsfstate"); 
  }

 }

 /*
  * disconnect my components from me before deleting.
  * This is done to turn off the necessary property bits
  * of the components.
  */

  if(delete)
  {
   if (*option & EMS_DELETE_DPR)
   {
    sts = om$send (msg = message GRconnector.GRdisconn (
                   EMmsg, &owner_GRid),
             p_chanselect = &to_comps);
    EMomerr_hndlr (sts, wrapup, "GRconnector.GRdisconn"); 

    sts = om$send (mode = OM_e_wrt_message,
                   msg = message Root.delete(1),
             targetid = my_id);
    EMomerr_hndlr (sts, wrapup, "Root.delete"); 
   }
  } /* if (delete) */
  else
  {
  /*
   * set my properties ( GRIS_LOCATABLE and GRIS_DISPLAYABLE)
   * to false
   */

   ME.GRgraphics->properties &= ~GRIS_LOCATABLE;
   ME.GRgraphics->properties &= ~GRIS_DISPLAYABLE;

  } /* else for if (delete) */


wrapup:

 if (ssi) om$dealloc(ptr = ssi);

 EMWRAPUP(*EMmsg,sts,"In EMSsfcapsf.EMdeactivate")

 return(sts);
}

end implementation EMSsfcapsf;
