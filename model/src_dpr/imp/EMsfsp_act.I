/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include "EMSdef.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "OMmacros.h"
#include "emsdef.h"
  
# define INCR_SIZE 6
# define ThisWasUsefulCode  0

extern OMuword OPP_EMSpartedge_class_id;
extern OMuword OPP_EMSsubbs_class_id;

from EMSboundary import EMget_objid;
from EMSboundary import EMcheck_props;

method EMactivate(IGRlong *EMmsg;
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
                10/21/87:   changes for new system
                06/06/88:   re-written               
    DLB         07/26/88:   Added code to (re)set surface inactive bit.   
    DLB         10/20/89:   Changed BUFF_INCR to DPR_DISPLAY_BUFF_INCR in
                            EFrealloc_if_needed call.
Algorithm

      Get all the edges from to_edge_assoc channel. Take one edge at a
      time and look for its loop. If it does not have a loop,then save
      this edge in a buffer and go for the next edge. Continue to do so
      until an edge is found with a loop. Disconnect the edge form the
      loop and connect the saved edges in this loop at appropriate 
      indices.
               Get the objects from to_surf_assoc channel. First object
      should be the surface which was split and second one should be
      the dpr or primitive to which it is connected to. Disconnect the 
      surface (0) from (1) and set the surface's display and locate
      bits OFF. Get the surfaces from to_comps channel and activate these
      surfaces by setting the display and locate bits ON.
*/
                   
{
  IGRlong          stat_OM, msg, msg1;
  OMuword          edge_class_id;
  IGRint           dimension;
  IGRint           sav_ind, lp_inx;
  OMuint           count, edge_index;
  IGRint           lp_count;
  IGRint           i, j;
  IGRint           num_surf_ids;
  IGRint           EMsend_loops();
  IGRboolean       is_valid;
  unsigned short   ls_prop, lp_prop, ed_prop;
  GRobjid          *edge_save, *loop_save;
  GRobjid          loop_id, *spl_loops;
  struct GRid      *surf_ids;
  struct GRid      temp_id;
/*
  OMuint           my_depth = 0;
*/
  OM_S_CHANSELECT  to_owner, to_edge_s, to_cpx;
  OM_S_CHANSELECT  to_comps, to_loops, to_loopset;
  OM_S_OBJECT_LINKAGE ls_linkage, lp_linkage;

  void EFgetobjids();

/*----------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  sav_ind = lp_inx = 0;
  num_surf_ids = 0;
 
  edge_save = NULL;
  loop_save = NULL;
  spl_loops = NULL;
  surf_ids = NULL;

  dimension = OM_DIMENSION_OF(ME.EMSdpr->ids);

  /* channel selectors */

  stat_OM = EMmake_chanselect (EMSloopset_to_loops, &to_loops);
  stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edge_s);
  stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
  stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
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
    /** Erase the old surface **/
 
    enum GRdpmode display_mode = GRbehe;   /*DECLARE*/

    stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &my_env->md_env.matrix_type, 
                            my_env->md_env.matrix, &display_mode,
                            &my_env->md_id),
                      targetid = ME.EMSdpr->ids[1]);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, msg, wrapup);
  }

  for (i=2; i<dimension; i++)
   {
    stat_OM = EMcount_loops(&msg, ME.EMSdpr->ids[i], &lp_count, NULL,
                            EMLP_ACTIVE, NULL, NULL);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

    if (lp_count)
      {
       stat_OM = EMsend_loops(&msg,
                          message EMSboundary.EMget_objid (&msg1,
                          &loop_id), ME.EMSdpr->ids[i], 0, OM_K_MAXINT,
                          EMLP_ACTIVE, NULL, NULL);
       EMerr_hndlr(!(1 & stat_OM & msg & msg1), *EMmsg, msg, wrapup);

       is_valid = FALSE;
       for (j=0; j<num_surf_ids; j++)
        {
         if (loop_id == spl_loops[j])
          {
           is_valid = TRUE;
           break;
          }
        }

       if (is_valid)
        {
         stat_OM = om$send(msg = message Root.move_chan(to_edge_s,
                                 ME.EMSdpr->ids[i+1],
                                 OM_Gw_current_OS, to_edge_s),
                           targetid = ME.EMSdpr->ids[i]);
         EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);
         i++;
         sav_ind = 0;
         continue;
        }

       if (! ((lp_inx) % INCR_SIZE))
        {
         if (! lp_inx)
          {
           loop_save = (GRobjid *) om$malloc (size = INCR_SIZE * 
                                   sizeof (GRobjid));
          }
         else
          {
           loop_save = (GRobjid *) om$realloc 
                       (ptr = (char *) loop_save, 
                        size = (lp_inx + INCR_SIZE) * sizeof (GRobjid));
          }
          EMerr_hndlr (! loop_save, *EMmsg,EMS_E_NoDynamicMemory, wrapup);
        }

        loop_save[lp_inx] = loop_id;
        lp_inx++;

       /* get the edge's index on to_edges channel */

       stat_OM = om$get_index(osnum_c = OM_Gw_current_OS,
                              objid_c = loop_id,
                              p_chanselect = &to_edge_s,
                              objid = ME.EMSdpr->ids[i],
                              indexaddr = &edge_index);
       EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

       stat_OM = om$send (msg = message Root.disconnect (to_owner,
                                 loop_id, OM_Gw_current_OS,
                                 to_edge_s),
                          senderid = loop_id,
                          targetid = ME.EMSdpr->ids[i]);
       EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

       for (j=0; j<sav_ind; j++)
        {
         stat_OM = om$send (msg = message Root.connect (to_owner,
                                  edge_index+j, loop_id,
                                  OM_Gw_current_OS, to_edge_s, NULL),
                             targetid = edge_save[j]);
         EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);
        }      

       if (sav_ind == 1)
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
                                    ME.EMSdpr->ids[i],
                                    OM_Gw_current_OS, to_edge_s),
                              targetid = ME.EMSdpr->ids[i-1]);
            EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);
           }
          else if (stat_OM == OM_I_INVANCESTRY)
           {stat_OM = OM_S_SUCCESS;}
        }

       sav_ind = 0;
       if (edge_save) om$dealloc(ptr = edge_save);
       edge_save = NULL;
      }
    else 
      {
       /*
        * save the edge id in edge_save. These edges will be connected
        * as soon as their loop is found.
        */

       if (! ((sav_ind) % INCR_SIZE))
        {
         if (! sav_ind)
          {
           edge_save = (GRobjid *) om$malloc (size = INCR_SIZE * 
                                       sizeof (GRobjid));
          }
         else
          {
           edge_save = (GRobjid *) om$realloc 
                       (ptr = (char *) edge_save, 
                        size = (sav_ind + INCR_SIZE) * sizeof (GRobjid));
          }
          EMerr_hndlr (! edge_save, *EMmsg,EMS_E_NoDynamicMemory, wrapup);
        }

       edge_save[sav_ind] = ME.EMSdpr->ids[i];
       sav_ind++;
      }
   }

  /* set the natural bits for the loops which were affected */

  for (i=0; i<lp_inx; i++)
   {
    ls_prop = NULL;
    lp_prop = EMLP_NATURAL;
    ed_prop = NULL; 

    stat_OM = om$send(msg = message EMSboundary.EMcheck_props(&msg,
                            &ls_prop, &lp_prop, &ed_prop),
                      targetid = loop_save[i]);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);
   }

  /* work on the surfaces */

  /* activate the split surfaces (split faces) */

    for (i=0; i<num_surf_ids; i++)
     {
      EFsetsfstate(&msg, surf_ids[i].objid, surf_ids[i].osnum, EMS_O_ON);
      EMerr_hndlr(!(1 & msg), *EMmsg, EMS_E_Fail, wrapup);
     }

  if (*option & EMS_DO_DISPLAY)
  {
    for (i=0; i<num_surf_ids; i++)
    {
      /*Store this surface that was erased (modified) -DLB*/
      EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                          DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
      if (!(1 & *EMmsg)) goto wrapup;
 
      (*display_ids)[*display_count] = surf_ids[i].objid;
      (*display_count)++;
    }
  }

# if ThisWasUsefulCode

  if (*option & EMS_UNDO_DELETE)
   {
    /* delete the surface which was split */

    stat_OM = om$send(msg = message GRgraphics.GRdelete(&msg, my_env),
                      targetid = ME.EMSdpr->ids[1]);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

    /* delete myself */

/*
    stat_OM = om$get_senddepth (p_depth = &my_depth);
    EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);
*/

    if (*option & EMS_DELETE_DPR)
    {
     stat_OM = om$send(mode = OM_e_wrt_message,
                       msg = message Root.delete(1),
                       targetid = my_id);
     EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);
    }
   }
  else

# endif

   {
    temp_id.objid = ME.EMSdpr->ids[0];
    temp_id.osnum = OM_Gw_current_OS;

    stat_OM = om$send (msg = message GRconnector.GRdisconn (&msg,
                             &temp_id),
                       senderid = temp_id.objid,
                       targetid = ME.EMSdpr->ids[1]);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

    /* deactivate the surface (which was split) */
 
    EFsetsfstate(&msg, ME.EMSdpr->ids[1], OM_Gw_current_OS, EMS_O_OFF);
    EMerr_hndlr(!(1 & msg), *EMmsg, EMS_E_Fail, wrapup);
   }
wrapup:

   if (edge_save) om$dealloc(ptr = edge_save);
   if (loop_save) om$dealloc(ptr = loop_save);
   if (spl_loops) om$dealloc(ptr = spl_loops);
   if (surf_ids) om$dealloc(ptr = surf_ids);
   
   return(stat_OM);
}

end implementation EMSsfsplit;
