class implementation EMSsfaddraft;


/*

DESCRIPTION

    This method will deactivate me if I am an active state.  This is
    done by changing topology and/or geometry I have saved with what
    is currently active.

Algorithm
    Get the SSI table.
    Put in out_surfaces at composite_index.
    Set properties in the surfaces ON.
    Disconnect the new plane edges
    Connect the disconnected  old edges. 
    If option==EMS_UNDO_SAVE set my active bit OFF else delete
    myself.

Returned values
    EMS_S_SUCCESS if all is well.


HISTORY

    02/10/93  :  Nirmal  :  Creation

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
                    
extern OMuword OPP_EMSsfaddraftesf_class_id, OPP_EMSsolid_class_id;


method EMdeactivate (
    IGRlong *EMmsg;
    IGRshort *option;
    struct GRmd_env *env;
    GRobjid **display_ids; 
    IGRint *display_count
)
{
  IGRlong                       sts;
  IGRint                        i,j, *owner_index;
  GRobjid                       *sf_out;
  union EMSssi_table            *ssi;
  struct EMSaddraftssi_table         *my_info;
  struct GRid                   owner_GRid;
  OM_S_CHANSELECT               to_loopset,to_comps, to_common_edge;
  IGRboolean                    delete;
  IGRboolean                    display;
  IGRint                        num_comps, ii, num_edges;
  OMuint                        count;    
  GRobjid                       new_surface;
  GRobjid                       *new_surfaces;
  struct GRid                   my_GRid;
  GRspacenum                    dumosnum;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  ssi = NULL;
  new_surfaces = NULL;
  num_comps = 0;

  delete = (*option&EMS_UNDO_SAVE) ? FALSE : TRUE;

  display = *option & EMS_DO_DISPLAY;
  owner_GRid.objid = my_id;
  owner_GRid.osnum = OM_Gw_current_OS;

  sts = om$make_chanselect(channame="EMSsubbs.to_loopset",
                           p_chanselect=&to_loopset);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  sts = om$make_chanselect(chanaddr=&ME.GRcmpowner->to_components,
                           p_chanselect=&to_comps);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
  /* Send a message to myself to get the SSI table.-DLB */

  sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                targetid = my_id);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);  


  my_info = &ssi->addrft_info;

  if (*option & EMS_DO_DISPLAY)
  {
   IGRint      inx;          /*DECLARE*/
   enum GRdpmode display_mode = GRbehe;
   IGRboolean  got_it = FALSE;    

    sts = om$get_channel_count(object = me,
                                   p_chanselect = &to_comps,
                                   count = &count);
    EMerr_hndlr( !(1 & sts), *EMmsg, EMS_E_OMerror, wrapup);
   
   new_surfaces =(GRobjid *) om$malloc(size = count*sizeof(GRobjid));
   EMerr_hndlr (!(new_surfaces),*EMmsg, EMS_E_NoDynamicMemory,wrapup);

   num_comps = count-1;
   

for(ii=1;ii<count;ii++)
 {
  /* Get the added surfaces */
  sts = om$get_objid_at_index (objid = my_id,
                               p_chanselect = &to_comps,
                               index = ii,
                               objidaddr = &new_surface,
                               osnumaddr = &dumosnum);
  EMomerr_hndlr (sts, wrapup, "om$get_objid_at_index");  
  new_surfaces[ii-1] = new_surface;

   /* Has the added surface already been erased? */
   for (inx=0; inx<*display_count; inx++)
   {
     if ( (*display_ids)[inx] == new_surface)
     {
       got_it = TRUE;
       break;
     }
   }

   if (!got_it)
   {
     /**Erase the modified surface and store it**/

     sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
                         &env->md_env.matrix_type, 
                         env->md_env.matrix, &display_mode,
                         &env->md_id),
              targetid = new_surface);
     EMomerr_hndlr (sts, wrapup, "GRgraphics.GRdisplay"); 

     /**Store modified id**/
     EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                         DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
     if (!(1 & *EMmsg)) goto wrapup;

     (*display_ids)[*display_count] = new_surface;
     (*display_count)++;
   }
  }
}


  /*Put in the 'out_surfaces' and make them locatable and displayable.
   * NOTE:
   *       DUE TO THE FACT THAT THE SURFACES MUST BE CONNECTED AT THE 
   *       PROPER OWNERS INDEX, CARE MUST BE EXERCISED WHEN RECONNECTING
   *       THE SURFACES.  NAMELY, SINCE THE OWNERS CHANNEL IS A RELATIVELY
   *       ORDERED CHANNEL, THE SURFACES MUST BE CONNECTED IN THE REVERSE
   *       ORDER THAT THEY WERE REMOVED.  THIS REQUIRES THAT THE ARRAY OF
   *       SURFACE OUT IDS BE TRAVERSED FROM END TO BEGINNING. 
   */


  /* Find the total number of surfs removed */

  j = 0;

 for (i = 0; i < my_info->num_composites; i ++) 
    j += my_info->num_surfaces_out[i];

  sf_out = &my_info->surface_out_ids[j-1];
  owner_index = &my_info->composite_indices[j-1];

  for(i=my_info->num_composites-1; i>=0; i--)
   {
     owner_GRid.objid = my_info->composite_ids[i];     

     for(j=my_info->num_surfaces_out[i]-1; j>=0; j--)
      {
        /*Reconnect removed surfaces at proper owners index.*/

        sts = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                            &owner_GRid, (IGRlong *) owner_index),
                      targetid = *sf_out);
        EMerr_hndlr(!(1&sts&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

        EFsetsfstate(EMmsg, *sf_out, OM_Gw_current_OS, EMS_O_ON);
        EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

        sts = EFfix_parent_child_relationship(EMmsg, *sf_out, 
                                              owner_GRid.objid, 
                                              OM_Gw_current_OS, FALSE, NULL);
        if (!(1 & sts & *EMmsg)) goto wrapup;

        if (display)
        {
          /*Store the out ids in the array.*/
         
          EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                              BUFF_INCR, sizeof(GRobjid));
          if (!(1 & *EMmsg)) goto wrapup;

          (*display_ids)[*display_count] = *sf_out;
          (*display_count)++;
        }

        owner_index--;
        sf_out--;
      }
   }

 /* Disconnect all the old common edges */

 EMmake_chanselect( EMSedge_to_common_edge, &to_common_edge);

 num_edges = my_info->num_new_commedge_pairs;
 
 for (i=0; i<num_edges; i++)
  {
   if(my_info->new_commedge_pairs1[i] != NULL_OBJID)
   {
    sts = om$send ( msg = message Root.disconnect( to_common_edge,
                    my_info->new_commedge_pairs2[i],
                    OM_Gw_current_OS, 
                    to_common_edge),
             targetid = my_info->new_commedge_pairs1[i]);
    EMomerr_hndlr (sts, wrapup, "Root.disconnect");  
   }

  }       

 /* Stitch the new plane edges */

 num_edges = my_info->num_old_commedge_pairs;
  for (i=0; i<num_edges; i++)
  {
   if(my_info->old_commedge_pairs1[i] != NULL_OBJID)
    {
     struct EMSstitch_info stinfo;
     GRobjid srfid;

     stinfo.surf_geom0 = NULL;
     stinfo.edge_geom0 = NULL;
     stinfo.surf_geom1 = NULL;
     stinfo.edge_geom1 = NULL;
     stinfo.edge0 = my_info->old_commedge_pairs1[i];

     sts = om$send ( msg = message EMSedge.EMgetsurface_info
                 ( EMmsg, &srfid, NULL),
            targetid = my_info->old_commedge_pairs1[i]);
     EMomerr_hndlr (sts, wrapup, "EMSedge.EMgetsurface_info"); 

     stinfo.surf0 = srfid;
     stinfo.edge1 = my_info->old_commedge_pairs2[i];

     sts = om$send ( msg = message EMSedge.EMgetsurface_info
                 ( EMmsg, &srfid, NULL),
            targetid = my_info->old_commedge_pairs2[i]);
     EMomerr_hndlr (sts, wrapup, "EMSedge.EMgetsurface_info"); 

     stinfo.surf1 = srfid;

     stinfo.option = EMSstitch_NoMoveSurfs;

     sts = om$send(msg = message EMSedge.EMstitch(EMmsg,
                         &stinfo, env, NULL,
                         NULL, NULL, NULL, NULL),
            targetid = my_info->old_commedge_pairs1[i]);
     EMomerr_hndlr (sts, wrapup, "EMSedge.EMstitch"); 
   }
  }   
 

/*
 * if the option is EMS_UNDO_SAVE, make myself inactive and 
 * make the  new_plane  unlocatable and undisplayable.
 * Otherwise, delete myself and new_plane;
 */

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 if (delete)
  {
    /* check whether new_surfaces are obtained */
    if(new_surfaces)
     {
        for(ii=0; ii<num_comps; ii++)
          {

             sts = om$send (msg = message GRgraphics.GRdelete( EMmsg, 
                                          env), 
                            targetid = new_surfaces[ii]);
             EMomerr_hndlr (sts, wrapup, ""); 
          }
     }

  /*
   * disconnect my components from me before deleting.
   * This is done to turn off the necessary property bits
   * of the components.
   */

  if (*option & EMS_DELETE_DPR)
  {
   sts = om$send (msg = message GRconnector.GRdisconn (
                  EMmsg, &my_GRid),
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

  /*
   * change the properties (GRIS_DISPLAYBLE and
   * GRIS_LOCATABLE) of 
   * to FALSE
   */

  if(new_surfaces)
   {
      for(ii=0;ii<num_comps;ii++)
        {
           EFsetsfstate(EMmsg, new_surfaces[ii], OM_Gw_current_OS,
                        EMS_O_OFF);
           EMomerr_hndlr (sts, wrapup, "EFsetsfstate"); 
        }
   }

 } /* else for if (delete) */


wrapup:

 if (ssi) om$dealloc(ptr = ssi);
 if (new_surfaces) om$dealloc(ptr = new_surfaces);

 EMWRAPUP(*EMmsg,sts,"In EMSsfaddraft.EMdeactivate")

 return(sts);
}

end implementation EMSsfaddraft;
