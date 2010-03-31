class implementation EMSsfunitesf;

/*

DESCRIPTION

This method will activate me if I am an inactive state.  This is
done by changing topology and/or geometry I have saved with what
is currently active.

ALGORITHM

  Get the SSI table.
  Take out out_surfaces.
  Set properties of the surfaces OFF.
  Disconnect the common edges.
  Set my active bit on

RETURNED VALUES

EMS_S_Success is all is well.

HISTORY

  07/10/1992   : AMD  :   Creation
  07/07/1993   : Jack :   Replaced call to EMstitch with
                          EMconnect_edges.  The extra work that EMstitch
                          does to connect the pair of common edges is
                          unnecessary in this case.  Also, removed
                          several unused imports.
  22 Nov 93    : AIC  :   Test for reversibility during EMconnect_edges.
*/

#include "EMS.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "emsdef.h" /* DPR_DISPLAY_BUFF_INCR */
#include "EMSopt.h"
#include "EMSlmdef.h"

#define BUFF_INCR DPR_DISPLAY_BUFF_INCR


from EMSedge import EMgetsurface_info,
                    EMconnect_edges;


method EMactivate ( IGRlong *EMmsg;
                    IGRshort *option;
                    struct GRmd_env *env;
                    GRobjid **display_ids; 
                    IGRint *display_count)

{
  IGRlong                   sts;
  IGRint                    i,j, num_edges ;
  GRobjid                   *sf_out;
  union EMSssi_table        *ssi;
  struct EMSunssi_table     *my_info;
  struct GRid               temp_GRid;
  OM_S_CHANSELECT           to_loopset, to_common_edge, to_comps;
  IGRboolean                display;
  GRobjid                   new_plane;
  GRspacenum                dumosnum;

  /* Initialize */

  *EMmsg = EMS_S_Success;
  ssi = NULL;
  display = *option & EMS_DO_DISPLAY;

  sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                targetid = my_id);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);  

  my_info = &ssi->un_info;

/*
 *   Take out the 'out_surfaces' and make them non-locatable and
 *   non-displayable.
 */

  sf_out = my_info->surface_out_ids;
  temp_GRid.osnum = OM_Gw_current_OS;

  for(i=0;i<my_info->num_composites;i++)
   {
     for(j=0;j<my_info->num_surfaces_out[i];j++)
      {
        temp_GRid.objid = my_info->composite_ids[i];        

       /* Erase the surfaces that will be removed by the act -DLB */
       if (display)
        {
          IGRint       inx;                  /*DECL*/
          IGRboolean got_it = FALSE;

          /*Has this surface already been erased?*/
          for (inx=0; inx<*display_count; inx++)
          {
            if ( (*display_ids)[inx] == *sf_out )
            {
               got_it = TRUE;
               break;
            }
          }

          if (! got_it)
          {    
            enum GRdpmode display_mode = GRbehe;   /*DECLARE*/
 
            /*Have a surface not yet erased.*/          
            sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                                &env->md_env.matrix_type, 
                                env->md_env.matrix, &display_mode,
                                &env->md_id),
                          targetid = *sf_out);
            EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, *EMmsg, wrapup);
  
            /*Don't store surface removed.*/ 
          }    
        }

        sts = om$send(msg = message GRconnector.GRdisconn(EMmsg,&temp_GRid),
                      targetid = *sf_out);
        EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);   

        EFsetsfstate(EMmsg, *sf_out, OM_Gw_current_OS, EMS_O_OFF);
        EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

        sts = EFfix_parent_child_relationship(EMmsg, *sf_out, 
                                              temp_GRid.objid, 
                                              OM_Gw_current_OS, TRUE, NULL);
        if (!(1 & sts & *EMmsg)) goto wrapup;

       sf_out++;
      }
   }

 /* Turn on the displayable and locatable properties of the
    constructed surface. Since the constructed plane is connected
    to me at index=1 of component channel, I can get it in the 
    following manner  */
 
 EMmake_chanselect( GRcmpowner_to_components, &to_comps);

 sts = om$get_objid_at_index ( objid = my_id,
                               p_chanselect = &to_comps,
                               index = 1,
                               objidaddr = &new_plane,
                               osnumaddr = &dumosnum);
 EMomerr_hndlr (sts, wrapup, "om$get_objid_at_index");  

 if (*option & EMS_DO_DISPLAY)
 {
  /* Store added surface */

  EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                         DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
  if (!(1 & *EMmsg)) goto wrapup;

  (*display_ids)[*display_count] = new_plane;
  (*display_count)++;
 }

 EFsetsfstate ( EMmsg, new_plane, OM_Gw_current_OS, EMS_O_ON);

 /* Disconnect all the old common edges */

 EMmake_chanselect( EMSedge_to_common_edge, &to_common_edge);

 num_edges = my_info->num_edges;
 
 for (i=0; i<num_edges; i++)
  {
   if(my_info->edges_disconnected[i] != NULL_OBJID)
   {
    sts = om$send ( msg = message Root.disconnect( to_common_edge,
                    my_info->edges_removed[i], OM_Gw_current_OS, 
                    to_common_edge),
             targetid = my_info->edges_disconnected[i]);
    EMomerr_hndlr (sts, wrapup, "Root.disconnect");  
   }

  }       

 /* Stitch the new plane edges */

  for (i=0; i<num_edges; i++)
  {
   if (my_info->edges_disconnected[i] != NULL_OBJID)
    {
     GRobjid  srfid0,
              srfid1;


     sts = om$send ( msg = message EMSedge.EMgetsurface_info
                   ( EMmsg, &srfid0, NULL),
              targetid = my_info->edges_added[i]);
     EMomerr_hndlr (sts, wrapup, "EMSedge.EMgetsurface_info"); 


     sts = om$send ( msg = message EMSedge.EMgetsurface_info
                   ( EMmsg, &srfid1, NULL),
              targetid = my_info->edges_disconnected[i]);
     EMomerr_hndlr (sts, wrapup, "EMSedge.EMgetsurface_info"); 


     sts = om$send(msg = message EMSedge.EMconnect_edges(EMmsg,
                         0,
                         TRUE,
                         my_info->edges_disconnected[i],
                         srfid0,
                         srfid1,
                         &env->md_env),
              targetid = my_info->edges_added[i] );
     EMomerr_hndlr (sts, wrapup, "EMSedge.EM<connect_edges"); 

    }
  }   
 
 wrapup:
    if(ssi) om$dealloc(ptr = ssi);
    EMWRAPUP(*EMmsg,sts,"In EMSsfunitesf.EMactivate")
    return(sts);
}

end implementation EMSsfunitesf;
