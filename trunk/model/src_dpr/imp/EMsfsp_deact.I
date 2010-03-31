/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include "emsdef.h"
#include "EMSdef.h"
#include "EMSbnddef.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "OMmacros.h"

#define INCR_SIZE 4

extern OMuword OPP_EMSpartedge_class_id;
extern OMuword OPP_EMSsubbs_class_id;

from EMSboundary import EMget_objid;
from EMSboundary import EMcheck_props;
from EMSloop import EMget_props;

method EMdeactivate(IGRlong *EMmsg;
                    IGRshort *option;
                    struct GRmd_env *my_env;
                    GRobjid **display_ids;
                    IGRint *display_count)
/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure

Assumption

Bugs

History
	
	  gupta 	05/04/87:	design date
                10/21/87:   major modification for new system
    DLB         07/26/88:   Added code to (re)set surface inactive bit.
Algorithm

      Get all the  edges on to_edge_assoc  channel. Take  one edge at a
      time and get its loop. If it has a loop, save the loop and delete
      or disconnect  the edge from its loop (depends on the option). If 
      it does not  have a loop then connect  the edge to the saved loop
      at appropriate index. That takes care of the edges.

                 Get the  objects  from  to_surf_assoc  channel.  There
      should be only two objects. First one should be the surface which
      had undergone split. Second object will be a primitive or a split
      dpr to  which the  surface  originally  belonged.  Get  the split 
      surfaces from the to_comps  channel and disconnect them  form the
      dpr. Then  put the  surface which was split  back to its rightful
      owner (the second object from to_surf_assoc channel).

                 Finally set the display and locatable bits ON or OFF
      for the surface which was split and the split surfaces.  
*/
                   
{
  IGRlong          stat_OM, msg, msg1;
  OMuword          edge_class_id;
  IGRint           dimension;
  IGRint           i, sav_ind, inx;
  OMuint           count, edge_index;
  IGRint           j;
  IGRint           num_looped_edge;
  IGRint           EMsend_loops();
  IGRint           num_surf_ids;
  IGRboolean       get_loop;
  IGRboolean       is_valid;
  unsigned short   act_loop_prop;
  unsigned short   ls_prop, lp_prop, ed_prop;
  struct GRid      *surf_ids;
  struct GRid      temp_id;
  GRobjid          *edge_save, *loop_save, loop_id;
  GRobjid          *spl_loops;
  OM_S_CHANSELECT  to_owner,to_edge_s, to_cpx;
  OM_S_CHANSELECT  to_comps;
  OM_S_CHANSELECT  to_loops, to_loopset;

  OM_S_OBJECT_LINKAGE ls_linkage, lp_linkage;
  
  void EFgetobjids();
/*------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  inx = num_looped_edge = sav_ind = 0;
  loop_save = NULL;
  edge_save = NULL;
  spl_loops = NULL;
  
  dimension = OM_DIMENSION_OF(ME.EMSdpr->ids);
  
  /* channel selectors */

  stat_OM = EMmake_chanselect (EMSloopset_to_loops, &to_loops);

  stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);

  stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edge_s);
  if (! (1 & stat_OM)) goto wrapup;

  stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
  if (! (1 & stat_OM)) goto wrapup;

  stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
  if (! (1 & stat_OM)) goto wrapup;

  stat_OM = EMmake_chanselect (GRconnector_to_owners, &to_cpx);
  if (! (1 & stat_OM)) goto wrapup;

  /* get the surfaces hanging off from to_comps */
  
  temp_id.objid = my_id;
  temp_id.osnum = OM_Gw_current_OS;

  EFgetobjids (&msg, &temp_id, &to_comps, &surf_ids, &num_surf_ids, 
               OPP_EMSsubbs_class_id, NULL, 0);
  EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);

  spl_loops = (GRobjid *) om$malloc (size = num_surf_ids * 
                                     sizeof (GRobjid));
  for (i=0; i<num_surf_ids; i++)
   {
    stat_OM = om$get_channel_objects (objid = surf_ids[i].objid,
                                      osnum = surf_ids[i].osnum,
                                      p_chanselect = &to_loopset,
                                      list = &ls_linkage,
                                      size = 1,
                                      count = &count);

    stat_OM = om$get_channel_objects (osnum = ls_linkage.osnum,
                                      objid = ls_linkage.S_objid,
                                      p_chanselect = &to_loops,
                                      list = &lp_linkage,
                                      size = 1,
                                      count = &count);
    spl_loops[i] = lp_linkage.S_objid;
   }

  if (*option & EMS_DO_DISPLAY)
   {
    /**Erase the new surfs.-DLB**/
    IGRint inx;
    enum GRdpmode display_mode = GRbehe;   /*DECLARE*/
    IGRboolean got_it = FALSE;


    for (i=0; i<num_surf_ids; i++)
     {
       /*Has the surface already been erased?*/
       got_it = FALSE;
       for (inx=0; inx<*display_count; inx++)
       {
          if ( (*display_ids)[inx] == surf_ids[i].objid )
          {
            got_it = TRUE;
            break;
          }
       }

       if (!got_it)
       {
         stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                &my_env->md_env.matrix_type, 
                                my_env->md_env.matrix, &display_mode,
                                &my_env->md_id),
                           targetid = surf_ids[i].objid,
                           targetos = surf_ids[i].osnum);
         EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, msg, wrapup);
  
         /**Store modified id**/
         EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                             DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
         if (!(1 & *EMmsg)) goto wrapup;

         (*display_ids)[*display_count] = surf_ids[i].objid;
         (*display_count)++;
       }
     }
   }

  /*********************DLB ADDITION**********************/
  if (dimension > 2)
  {
    edge_save = (GRobjid *) om$malloc(size = (dimension - 2) *
                                     (sizeof(GRobjid)));
  
    EMerr_hndlr (! edge_save, *EMmsg,EMS_E_NoDynamicMemory, wrapup);
  }
  /*******************************************************/

  get_loop = TRUE;

  for (i=2; i<dimension; i++)
   {
    if (get_loop)
     {
      stat_OM = EMsend_loops(&msg,
                         message EMSboundary.EMget_objid (&msg1,
                         &loop_id), ME.EMSdpr->ids[i], 0, OM_K_MAXINT,
                         EMLP_ACTIVE, NULL, NULL);
      EMerr_hndlr(EMis_error(msg1), *EMmsg, msg, wrapup);
      EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

      stat_OM = om$send(msg = message EMSloop.EMget_props(&msg,
                              &act_loop_prop),
                        targetid = loop_id);
      EMerr_hndlr(!(1&stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

      is_valid = FALSE;
      for (j=0; j<num_surf_ids; j++)
       {
        if (loop_id == spl_loops[j])
         is_valid = TRUE;
       }

      if (is_valid)
       {
        stat_OM = om$send(msg = message Root.move_chan(to_edge_s,
                                ME.EMSdpr->ids[i],
                                OM_Gw_current_OS, to_edge_s),
                          targetid = ME.EMSdpr->ids[i+1]);
        EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_deact.move_chan");
        get_loop = TRUE;
        num_looped_edge = 0;
        i++;
        continue;
       }

      if (! ((sav_ind) % INCR_SIZE))
        {
         if (! sav_ind)
          {
           loop_save = (GRobjid *) om$malloc (size = INCR_SIZE * 
                                   sizeof (GRobjid));
          }
         else
          {
           loop_save = (GRobjid *) om$realloc 
                       (ptr = (char *) loop_save, 
                        size = (sav_ind + INCR_SIZE) * sizeof (GRobjid));
          }
          EMerr_hndlr (! loop_save, *EMmsg,EMS_E_NoDynamicMemory, wrapup);
        }

        loop_save[sav_ind] = loop_id;
        sav_ind++;

      if (! (IF_NULL_OBJID(loop_id)))
       {
         /*
          * get the edge's index on to_edges channel
          */

         stat_OM = om$get_index(osnum_c = OM_Gw_current_OS,
                                objid_c = loop_id,
                                p_chanselect = &to_edge_s,
                                objid = ME.EMSdpr->ids[i],
                                indexaddr = &edge_index);
         EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_deact.get_index");

         stat_OM = om$send (msg = message Root.disconnect (to_owner,
                                  loop_id, OM_Gw_current_OS,
                                  to_edge_s),
                            senderid = loop_id,
                            targetid = ME.EMSdpr->ids[i]);
         EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_deact.disconnect");
         if (*option & EMS_UNDO_DELETE)
          {
           edge_save[inx] = ME.EMSdpr->ids[i];
           inx++;
          }
         get_loop = FALSE; 
         num_looped_edge++;
       }
     }
    else
     {
      stat_OM = om$is_objid_on_channel(objid_c = loop_id,
                                       p_chanselect = &to_edge_s,
                                       objid = ME.EMSdpr->ids[i]);
      if (stat_OM == OM_S_SUCCESS)
       {
        if (act_loop_prop & EMLP_REVERSED)
         {
          stat_OM = om$get_index(osnum_c = OM_Gw_current_OS,
                                 objid_c = loop_id,
                                 p_chanselect = &to_edge_s,
                                 objid = ME.EMSdpr->ids[i],
                                 indexaddr = &edge_index);
          EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_deact.get_index");
         }

        stat_OM = om$send (msg = message Root.disconnect (to_owner,
                                 loop_id, OM_Gw_current_OS,
                                 to_edge_s),
                           senderid = loop_id,
                           targetid = ME.EMSdpr->ids[i]);
        EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_deact.disconnect");
        if (*option & EMS_UNDO_DELETE)
         {
          edge_save[inx] = ME.EMSdpr->ids[i];
          inx++;
         }
         num_looped_edge++;
       }
      else if (stat_OM == OM_W_NOTONCHAN)
       {
        stat_OM = om$send (msg = message Root.connect (to_owner,
                                 edge_index, loop_id, OM_Gw_current_OS,
                                 to_edge_s, NULL),
                           targetid = ME.EMSdpr->ids[i]);
        EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_deact.connect");

        get_loop = TRUE;

        if (num_looped_edge == 1)
         {
          /* get class id of comm_edge id  and move the to_edge channel
           * only if it is a part edge
           */
          
          stat_OM = om$get_classid(objid = ME.EMSdpr->ids[i-1],
                                   p_classid = &edge_class_id);
          if (! (1 & stat_OM)) goto wrapup;

          stat_OM = om$is_ancestry_valid (subclassid = edge_class_id,
                            superclassid = OPP_EMSpartedge_class_id);
          if (stat_OM == OM_S_SUCCESS)
           {
            stat_OM = om$send(msg = message Root.move_chan(to_edge_s,
                                    ME.EMSdpr->ids[i-1],
                                    OM_Gw_current_OS, to_edge_s),
                              targetid = ME.EMSdpr->ids[i]);
            EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_deact.move_chan");
           }
          else if (stat_OM == OM_I_INVANCESTRY)
           {stat_OM = OM_S_SUCCESS;}
         }
        num_looped_edge = 0;
       }
     }
   }

  /* delete the appropriate edges if option is delete */
 
  if (*option & EMS_UNDO_DELETE)
   {
    for (i=0; i<inx; i++)
     {
      stat_OM = om$send (msg = message Root.delete(1),
                         targetid = edge_save[i]);
      EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_deact.delete");
     }
   }

  /* set the natural bits for the loops which were affected */

  for (i=0; i<sav_ind; i++)
   {
    ls_prop = NULL;
    lp_prop = EMLP_NATURAL;
    ed_prop = NULL; 

    stat_OM = om$send(msg = message EMSboundary.EMcheck_props(&msg,
                            &ls_prop, &lp_prop, &ed_prop),
                      targetid = loop_save[i]);
    EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_deact.EMcheck_props");
    EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);
   }

  /* work on the surfaces */

  temp_id.objid = ME.EMSdpr->ids[0];
  temp_id.osnum = OM_Gw_current_OS;

  /*******************DLB MODIFICATION***************************/
  stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg,
                           &temp_id, (IGRlong *) &ME.EMSsfsplit->owner_index), 
                     targetid = ME.EMSdpr->ids[1]);
  EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_deact.GRrigidconn");
  /**************************************************************/

  /* activate the surface (which was split) */
 
  EFsetsfstate(&msg, ME.EMSdpr->ids[1], OM_Gw_current_OS, EMS_O_ON);
  EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

  /**Store this surface for redisplay**/
  if (*option & EMS_DO_DISPLAY)
  {
    EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                        DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
    if (!(1 & *EMmsg)) goto wrapup;

    (*display_ids)[*display_count] = ME.EMSdpr->ids[1];
    (*display_count)++;
  }

  if (*option & EMS_UNDO_DELETE)
   {
    /* delete all the split surfaces hanging off from me */

    for (i=0; i<num_surf_ids; i++)
     {
      stat_OM = om$send(msg = message GRgraphics.GRdelete(&msg, my_env),
                        targetid = surf_ids[i].objid,
                        targetos = surf_ids[i].osnum);
      EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_deact.GRdelete");
     }
    /* delete myself */

	if (*option & EMS_DELETE_DPR)
	{
     stat_OM = om$send(mode = OM_e_wrt_message,
                       msg = message Root.delete(1),
                       targetid = my_id);
     EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_deact.delete");
    }
   }
  else
   {
    /* deactivate the surfaces (split faces) */

    for (i=0; i<num_surf_ids; i++)
     {
       EFsetsfstate(&msg, surf_ids[i].objid, surf_ids[i].osnum, EMS_O_OFF);
       EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);
     }
   }
  
wrapup:

   if (loop_save) om$dealloc(ptr = loop_save);
   if (edge_save) om$dealloc(ptr = edge_save);
   if (surf_ids) om$dealloc(ptr = surf_ids);
   if (spl_loops) om$dealloc(ptr = spl_loops);
   
   return(stat_OM);
}

end implementation EMSsfsplit;
