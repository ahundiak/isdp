class implementation EMSsfrembnd;
/*
Description
    This method will deactivate me if I am an active state.  This is
    done by changing topology and/or geometry I have saved with what
    is currently active.

Algorithm
    Get the SSI table.
    Put in out_loops.
    Put in out_surfaces at composite_index.
    Set properties in the surfaces ON.
    Connect the disconnected common edges. 
    If option==EMS_UNDO_SAVE set my active bit OFF else delete
    myself.

Returned values
    EMS_S_SUCCESS if all is well.

History

 August 1991  :  AMD  :  Creation

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
from EMSedge import EMget_props, EMset_props, EMconnect_edges,
		    EMdisplay;
                    
extern OMuword OPP_EMSsfrembnd_class_id, OPP_EMSsolid_class_id;


method EMdeactivate (
    IGRlong *EMmsg;
    IGRshort *option;
    struct GRmd_env *env;
    GRobjid **display_ids; 
    IGRint *display_count
)
{
  IGRlong                       sts;
  IGRint                        i,j;
  IGRlong                       *owner_index;
  GRobjid                       *lp_out,lpset,*sf_out, *edges;
  union EMSssi_table            *ssi;
  struct EMSdbssi_table         *my_info;
  union EMSri_table             *ri;
  struct EMSnest_info           nesting;
  struct GRid                   owner_GRid;
  OM_S_CHANSELECT               to_loopset, to_common_edge;
  struct EMSpartolbasis         partolbasis;
  IGRboolean                    world, delete;
  IGRushort             ls_props, lp_props, ed_props, 
			        dumb_props=NULL;
  enum   GRdpmode               dpmode;
  IGRshort                      disp_flag;
  IGRboolean                    display;
  IGRint                        num_edges;    
  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  ssi = NULL;
  ri = NULL;

  delete = (*option&EMS_UNDO_SAVE) ? FALSE : TRUE;
  display = *option & EMS_DO_DISPLAY;
  owner_GRid.objid = my_id;
  owner_GRid.osnum = OM_Gw_current_OS;

  sts = om$make_chanselect(channame="EMSsubbs.to_loopset",
                           p_chanselect=&to_loopset);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  /*Send a message to myself to get the SSI table.-DLB*/
  sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                targetid = my_id);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);  


  /*Put in the 'out_loops' into the respective loopsets*/

  my_info = &ssi->db_info;
  lp_out = my_info->region_out_ids;
  ls_props = NULL | EMLS_NATURAL;
  lp_props = NULL;
  ed_props = NULL;

  for(i=0;i<my_info->num_surfaces;i++)
   {
     ls_props = NULL | EMLS_NATURAL;
     if(my_info->num_regions_out[i])
      {
        world = TRUE;
        sts = om$send(msg=message EMSsubbs.EMpartolbasis
                         (EMmsg,&env->md_env.matrix_type,env->md_env.matrix,
                          &world,FALSE,&partolbasis.tol),
                      targetid = my_info->surface_ids[i]);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);

        partolbasis.mattyp = &env->md_env.matrix_type;
        partolbasis.mat = env->md_env.matrix;
        partolbasis.in_world = TRUE;
        partolbasis.is_valid = TRUE;
        sts = om$send(msg=message EMSboundary.EMget_objid(EMmsg,&lpset),
                      senderid=my_info->surface_ids[i],
                      p_chanselect=&to_loopset);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
      }
     for(j=0;j<my_info->num_regions_out[i];j++)
      {
        {
           sts = om$send(msg = message EMSloop.EMactivate_loop(EMmsg),
                         targetid = *lp_out);
           if (! (1 & sts & *EMmsg)) goto wrapup;
        }

        sts = om$send(msg=message EMSloop.EMgivenestinfo(EMmsg,&nesting),
                      targetid= *lp_out);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);

        sts = om$send(msg=message EMSloopset.EMnesting
                          (EMmsg,&nesting,&partolbasis),
                      targetid=lpset);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);

        if(IF_EQ_OBJID(lpset,nesting.parent))
          sts = om$send(msg=message EMSloopset.EMtreemod
                            (EMmsg,&nesting,ADD_CHILD,&partolbasis),
                        targetid = lpset);
        else
          sts = om$send(msg=message EMSloop.EMtreemod
                            (EMmsg,&nesting,ADD_CHILD,&partolbasis),
                        targetid = nesting.parent);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);
        lp_out++;
      }

     /* After all the loops have been put back in the corresponding
      * loopset can become natural again. If so the bit needs to be set ON.
      */ 
     if(my_info->num_regions_out[i])
      {
        sts = om$send(msg = message EMSboundary.EMcheck_props
                            (EMmsg, &ls_props, &lp_props, &ed_props), 
                      targetid = lpset);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
      }
   }


  /*Put in the 'out_surfaces' and make them locatable and displayable.
   * NOTE:
   *       DUE TO THE FACT THAT THE SURFACES MUST BE CONNECTED AT THE 
   *       PROPER OWNERS INDEX, CARE MUST BE EXERCISED WHEN RECONNECTING
   *       THE SURFACES.  NAMELY, SINCE THE OWNERS CHANNEL IS A RELATIVELY
   *       ORDERED CHANNEL, THE SURFACES MUST BE CONNECTED IN THE REVERSE
   *       ORDER THAT THEY WERE REMOVED.  THIS REQuiRES THAT THE ARRAY OF
   *       SURFACE OUT IDS BE TRAVERSED FROM END TO BEGINNING. 
   */

  /*Find the total number of surfs removed.*/
  j = 0;
  for (i = 0; i < my_info->num_composites; i ++)
    j += my_info->num_surfaces_out[i];

  sf_out = &my_info->surface_out_ids[j-1];
  owner_index = (IGRlong *) &my_info->composite_indices[j-1];

  for(i=my_info->num_composites-1; i>=0; i--)
   {
     owner_GRid.objid = my_info->composite_ids[i];     

     for(j=my_info->num_surfaces_out[i]-1; j>=0; j--)
      {

        sts = om$send(msg = message EMSsubbs.EMpassloop(EMmsg, 
                      message EMSloopset.EMtoglpactive(EMmsg)),
                      targetid = *sf_out);
        EMerr_hndlr(!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);

        /*Reconnect removed surfaces at proper owners index.*/
        sts = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                            &owner_GRid, owner_index),
                      targetid = *sf_out);
        EMerr_hndlr(!(1&sts&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

        sts = EFfix_parent_child_relationship(EMmsg, *sf_out, 
                                              owner_GRid.objid, 
                                              OM_Gw_current_OS, FALSE, NULL);
        if (!(1 & sts & *EMmsg)) goto wrapup;

        EFsetsfstate(EMmsg, *sf_out, OM_Gw_current_OS, EMS_O_ON);
        EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

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
 
  /* Connect the disconnected edges */

  EMmake_chanselect( EMSedge_to_common_edge, &to_common_edge);

  edges = my_info->edges_disconnected;
  num_edges = my_info->num_edges_disconnected;
 
  for (i=0; i<num_edges; i+=2)
   {
    sts = om$send( msg = message EMSedge.EMget_props(EMmsg, &dumb_props),
             targetid = edges[i]);
    EMomerr_hndlr (sts, wrapup, "EMSedge.EMget_props");  

    if(edges[i+1] != NULL_OBJID)
    {
     sts = om$send (msg = message EMSedge.EMconnect_edges(EMmsg,
		         dumb_props, TRUE, edges[i+1], NULL_OBJID,
			 NULL_OBJID, &env->md_env),
             targetid = edges[i]); 
     EMomerr_hndlr (sts, wrapup, "EMSedge.EMconnect_edges");  
     }
    else
    {
     dumb_props &= ~EMED_SUBORDINATE;

     sts = om$send (msg = message EMSedge.EMset_props (EMmsg,
                          dumb_props, EMS_O_SET),
             targetid = edges[i]);
     EMomerr_hndlr (sts, wrapup, "EMset_props");  
    }
    
    /* Send a display message */

    dpmode = GRbd;
    disp_flag = EMS_WHL_EDGE;
    sts  = om$send (msg = message EMSedge.EMdisplay (EMmsg, 
			     NULL, &env->md_env.matrix_type, 
			     env->md_env.matrix, &dpmode, NULL,
                             disp_flag, NULL),
                 targetid = edges[i]);
    EMomerr_hndlr (sts, wrapup, "EMSedge.EMdisplay");

   }  
  wrapup:
    if (ssi) om$dealloc(ptr = ssi);
    if (ri) om$dealloc(ptr = ri);
    EMWRAPUP(*EMmsg,sts,"In EMSsfrembnd.EMdeactivate")
    return(sts);
}

end implementation EMSsfrembnd;
