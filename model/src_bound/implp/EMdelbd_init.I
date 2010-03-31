class implementation EMSloop;

/* 
DESCRIPTION

  The actual processing for delete surface boundary command is done in
this method. The input loop supplied to this method is removed
together with the tree that it owns. The method recursively goes down
and also disconnects all the common edges. If after removal of this
loop tree, there are no more loops left on the surface, then the
surface itself is removed. A linked list of loops removed and surfaces
removed with their respective owners is returned.

HISTORY

  August, 1991  : AMD :  Creation

*/

#include "OMmacros.h"
#include "exmacros.h"
#include "emstplydel.h"
#include "emserr.h"
#include "EMSlmdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define INIT_OBJLIST_SIZE 3
#define INCR 10

extern GRclassid OPP_EMScomposite_class_id, OPP_EMSdpr_class_id;
extern GRclassid  OPP_EMSloopset_class_id;

from GRconnector import GRdisconn;
from EMSedge import EMget_props, EMset_props,
		    EMdisplay;
from EMSsubbs import EMget_ele_header;

method EMdelbnd_init(IGRlong *msg;
                     struct GRvg_construct construct_list;
                     IGRint *numsfs; 
                     struct EMSownercomp **sfloops; 
                     IGRint *numowners;
                     struct EMSownercomp **ownercomps;
                     IGRint *num_edges;
                     GRobjid **edges;
                     IGRushort options)
{
 
  IGRboolean list_extended;
  OMuint count, delloops_count, commed_count;
  IGRint stat_OM, i;
  IGRlong msg_loc, store_msg;
  GRobjid sfid, edid, compid;
  GRspacenum dumosnum;
  GRclassid compclassid;
  struct EMSnest_info nestinfo;
  OM_S_OBJECT_LINKAGE commed_objlist, *delloops_objlist;
  OM_S_OBJECT_LINKAGE objlist_mem[INIT_OBJLIST_SIZE];
  OM_S_CHANSELECT chan_to_edges, chan_to_commedge;
  OM_S_CHANSELECT chan_to_inner;
  OM_S_CHANSELECT chan_to_cpx, chan_to_comps, delete_channel;
  struct DPele_header     surface_ele_header;
  union IGRele_attr       ele_spec_att;  
  GRrange                 range;
  struct IGResqbs         bsqsurf;
  struct GRsymbology      symb;
  IGRshort                disp_flag;
  enum  GRdpmode          dpmode;

  void EMmkownlist(); 
  IGRint EMcount_loops(), EMsend_loops();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  delloops_objlist = NULL;

    chan_to_inner.type = OM_e_addr;
    chan_to_inner.u_sel.addr = &ME.EMSloop->to_inner;

    stat_OM = om$get_channel_count (objid = my_id, 
               p_chanselect = &chan_to_inner, count = &count);
    EMomerr_exit (stat_OM, ret_end);

    delete_channel = chan_to_inner;

  if (count)
    {
    if (count > INIT_OBJLIST_SIZE)
      {
      delloops_objlist = (OM_p_OBJECT_LINKAGE) om$malloc (size = 
                           count * sizeof (OM_S_OBJECT_LINKAGE));
      EMerr_hndlr (!delloops_objlist, *msg, EMS_E_NoDynamicMemory,
       ret_end);
      }
    else
      {
      count = INIT_OBJLIST_SIZE;
      delloops_objlist = objlist_mem;
      }

    stat_OM = om$get_channel_objects (objid = my_id, p_chanselect = 
               &delete_channel, list = delloops_objlist, size = count,
               count = &delloops_count);
    EMomerr_exit (stat_OM, ret_end);
    }
  else
    delloops_count = 0;

  stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
             &sfid, NULL), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

  /*
   * Remove myself from the loop-tree and append my objid onto
   * the argument list if so indicated by a non-NULL argument. Also set
   * my active-bit off.
   */
   
  stat_OM = om$send (msg = message EMSloop.EMtreemod (&store_msg, 
             &nestinfo, EXTRACT, NULL), 
             targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

  if (sfloops)
    {
    EMmkownlist (&msg_loc, sfloops, sfid, NULL, my_id, FALSE,
     &list_extended); 
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_DynamicMemoryAllocated,
     ret_end);

    if (list_extended && numsfs)
      (*numsfs)++;
    }    
 
  ME.EMSloop->lp_props &= ~EMLP_ACTIVE;

  if (store_msg == EMS_I_NoMoreLoops && !IF_NULL_OBJID (sfid))
   {
    if (!(options & EMS_REMBND_SURF)) goto ret_end;

    /* This being the outtermost loop, the removal of this loop 
       requires the surface should also be removed */    

    stat_OM = EMmake_chanselect (GRconnector_to_owners, &chan_to_cpx);    
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$get_channel_count (objid = sfid, 
               p_chanselect = &chan_to_cpx, count = &count);
    EMomerr_exit (stat_OM, ret_end);

    for (i=0; i<count; i++)
      {
      stat_OM = om$get_objid_at_index (objid = sfid, 
                 p_chanselect = &chan_to_cpx, index = i, objidaddr = &compid,
                 osnumaddr = &dumosnum);
      EMomerr_exit (stat_OM, ret_end);

      stat_OM = om$get_classid (objid = compid, p_classid = &compclassid);
      EMomerr_exit (stat_OM, ret_end);

      /*
       * Determine what kind of object owns this surface and get
       * this owners channel that connects to the surface.
       * This is a temporary kluge and should go away, when even the
       * EMSdpr class becomes a subclass of EMScomposite.
       */

      stat_OM = om$is_ancestry_valid (subclassid = compclassid,
                 superclassid = OPP_EMScomposite_class_id); 
      if (stat_OM == OM_S_SUCCESS)
        {
        stat_OM = EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);    
        EMomerr_exit (stat_OM, ret_end);
        }
      else if (stat_OM == OM_I_INVANCESTRY)
        {
        stat_OM = om$is_ancestry_valid (subclassid = compclassid,
                   superclassid = OPP_EMSdpr_class_id); 
        if (stat_OM == OM_S_SUCCESS)
          {
          stat_OM = EMmake_chanselect (GRcmpowner_to_components, 
                                       &chan_to_comps);    
          EMomerr_exit (stat_OM, ret_end);
          }
        }
      else
        EMomerr_exit (stat_OM, ret_end);

      /*
       * Disconect or delete this surface from it's owner if a valid
       * owner was found.
       */

      if (stat_OM != OM_I_INVANCESTRY)
        {
          OMuint ownerindex; 
          struct GRid owner_id;
        
          stat_OM = om$get_index(objid_c = compid,
                                 p_chanselect = &chan_to_comps,
                                 objid = sfid,
                                 indexaddr = &ownerindex);
          EMomerr_exit (stat_OM, ret_end);

          owner_id.objid = compid, 
          owner_id.osnum = OM_Gw_current_OS;

          stat_OM = om$send (msg = message GRconnector.GRdisconn
                    (&msg_loc, &owner_id), 
                     targetid = sfid, senderid = compid);
          EMomerr_exit (stat_OM, ret_end);

        if (ownercomps)
          {
          EMmkownlist (&msg_loc, ownercomps, compid, ownerindex, sfid, 
           FALSE, &list_extended);
          EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

          if (list_extended && numowners)
            (*numowners)++;
          }

        break;        
        }
      else
        EMomerr_exit (stat_OM, ret_end);
      }
    }

  
    chan_to_edges.type = OM_e_addr;
    chan_to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

    stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &chan_to_commedge);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$get_channel_count (objid = my_id, 
				    p_chanselect = &chan_to_edges,
             			    count = &count);
    EMomerr_exit (stat_OM, ret_end);

    for (i=0; i<count; i++)
     {
      IGRushort edprops=NULL;

      if (! ((*num_edges) % INCR))           
       {
        if (! *num_edges)
          *edges = (GRobjid *) om$malloc (size = INCR *
                               sizeof (GRobjid));
        else
          *edges = (GRobjid *) om$realloc (ptr = (char *)*edges, size = 
                       (*num_edges + INCR) * sizeof (GRobjid));
        EMerr_hndlr (! *edges , *msg, 
                    EMS_E_NoDynamicMemory, ret_end);
       }

      stat_OM = om$get_objid_at_index (objid = my_id, 
               p_chanselect = &chan_to_edges, index = i, objidaddr = &edid,
               osnumaddr = &dumosnum);
      EMomerr_exit (stat_OM, ret_end);

         stat_OM = om$get_channel_objects (objid = edid, 
                 p_chanselect = &chan_to_commedge, list = &commed_objlist, 
                 size = 1, count = &commed_count);
         EMomerr_exit (stat_OM, ret_end);
         if (commed_count)
         {
          IGRushort commedge_props=NULL; 
          IGRint ii;

          (*edges)[(*num_edges)] = edid;
          (*edges)[(*num_edges + 1)] = commed_objlist.S_objid;
          (*num_edges) += 2;

         stat_OM = om$send( msg = message Root.disconnect( chan_to_commedge,
                        edid, OM_Gw_current_OS, chan_to_commedge),
               targetid = commed_objlist.S_objid);
         EMomerr_hndlr (stat_OM, ret_end, "Root.disconnect");  

         for (ii=0; ii<2; ii++)
          {
           stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc,
                              ii ? &edprops : &commedge_props),
                 targetid = ii ? edid : commed_objlist.S_objid);
           EMomerr_hndlr (stat_OM, ret_end, "EMset_props");  
          } 
         EMomerr_hndlr (stat_OM, ret_end, "EMget_props");  

         if (commedge_props & EMED_SUBORDINATE)
          {
            edprops |= EMED_SUBORDINATE;
            commedge_props &= ~EMED_SUBORDINATE;
          }
          for (ii=0; ii<2; ii++)
          {
           stat_OM = om$send (msg = message EMSedge.EMset_props (&msg_loc,
                          ii ? edprops:commedge_props, EMS_O_SET),
                 targetid = ii ? edid : commed_objlist.S_objid);
           EMomerr_hndlr (stat_OM, ret_end, "EMset_props");  
          } 

         ele_spec_att.bsqsurf = &bsqsurf;
         stat_OM = om$send (msg = message EMSsubbs.EMget_ele_header(&msg_loc,
			   NULL,&construct_list.env_info->md_env, NULL, 
 			   &surface_ele_header, range, 
			   &symb.display_attr, ele_spec_att, NULL),
	       targetid = sfid);
          EMomerr_hndlr (stat_OM, ret_end, "EMsubbs.EMget_ele_header");  

          dpmode = GRbehe;
          disp_flag = EMS_WHL_EDGE;
          stat_OM = om$send ( msg = message EMSedge.EMdisplay (&msg_loc, 
			     &surface_ele_header, 
                             &construct_list.env_info->md_env.matrix_type, 
			     construct_list.env_info->md_env.matrix,
                             &dpmode, NULL,
                             disp_flag, NULL),
                      targetid = edid);
          EMomerr_hndlr (stat_OM, ret_end, "EMSedge.EMdisplay");

	  dpmode = GRbd;
          disp_flag = EMS_WHL_EDGE;
          stat_OM = om$send (msg = message EMSedge.EMdisplay (&msg_loc, 
			     NULL, 
                             &construct_list.env_info->md_env.matrix_type, 
			     construct_list.env_info->md_env.matrix,
                             &dpmode, NULL,
                             disp_flag, NULL),
                      targetid = commed_objlist.S_objid);
          EMomerr_hndlr (stat_OM, ret_end, "EMSedge.EMdisplay");

         } /* if commed_count */   
         else /* turn my display off */     
         {

          (*edges)[(*num_edges)] = edid;
          (*edges)[(*num_edges + 1)] = NULL_OBJID;
          (*num_edges) += 2;

          stat_OM = om$send (msg = message EMSedge.EMget_props (
                                   &msg_loc, &edprops ),
                      targetid = edid);
          EMomerr_hndlr (stat_OM, ret_end, "EMget_props");  

          edprops |= EMED_SUBORDINATE;

          stat_OM = om$send (msg = message EMSedge.EMset_props (&msg_loc,
                                   edprops, EMS_O_SET),
                       targetid = edid);
          EMomerr_hndlr (stat_OM, ret_end, "EMset_props");  

          ele_spec_att.bsqsurf = &bsqsurf;
          stat_OM = om$send (msg = message EMSsubbs.EMget_ele_header(&msg_loc,
			   NULL, 
			   &construct_list.env_info->md_env,
                           NULL,
 			   &surface_ele_header, range, 
			   &symb.display_attr, ele_spec_att, NULL),
	       targetid = sfid);
          EMomerr_hndlr (stat_OM, ret_end, "EMsubbs.EMget_ele_header");  

          dpmode = GRbehe;
          disp_flag = EMS_WHL_EDGE;
          stat_OM = om$send ( msg = message EMSedge.EMdisplay (&msg_loc, 
			     &surface_ele_header, 
			     &construct_list.env_info->md_env.matrix_type, 
			     construct_list.env_info->md_env.matrix,
                             &dpmode, NULL,
                             disp_flag, NULL),
                      targetid = edid);
          EMomerr_hndlr (stat_OM, ret_end, "EMSedge.EMdisplay");

         } 
      }


  if (delloops_count)
    {
    for (i=0; i<delloops_count; i++)
      {
      stat_OM = om$is_objid_valid (objid = delloops_objlist[i].S_objid);
      if (stat_OM == OM_S_SUCCESS)
        {
         stat_OM = om$send (msg = message EMSloop.EMdelbnd_init (&msg_loc,
                   construct_list, numsfs, sfloops, numowners, 
                   ownercomps, num_edges, edges, options),
                   targetid = delloops_objlist[i].S_objid);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
        }
      else
        stat_OM = OM_S_SUCCESS;
      }
    }

ret_end:
  if (delloops_objlist && delloops_count > INIT_OBJLIST_SIZE)
    om$dealloc (ptr = delloops_objlist);
  EMWRAPUP (*msg, stat_OM, "EMSloop.EMdelbnd_init");
  return (stat_OM);
}

end implementation EMSloop;

