/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfrembnd;

/*
DESCRIPTION

This method will activate me if I am an inactive state.  This is
done by changing topology and/or geometry I have saved with what
is currently active.

ALGORITHM
  Get the SSI table.
  Take out out_loops.
  Take out out_surfaces.
  Set properties of the surfaces OFF.
  Disconnect the common edges.
  Set my active bit on

RETURNED VALUES

EMS_S_Success is all is well.

HISTORY

 August, 1991   : AMD :   Creation

*/

#include "EMS.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "emsdef.h" /* DPR_DISPLAY_BUFF_INCR */
#include "EMSopt.h"
#include "EMSlmdef.h"

#define BUFF_INCR DPR_DISPLAY_BUFF_INCR

from EMSloop import EMtreemod,EMgivenestinfo,EMactivate_loop;
from EMSsubbs import EMpartolbasis, EMpassloop;
from EMSboundary import EMget_objid, EMcheck_props;
from EMSloopset import EMnesting,EMtreemod,EMtoglpactive;
from EMSloop import EMset_props;
from EMSedge import EMget_props, EMset_props, EMdisplay;

method EMactivate (
    IGRlong *EMmsg;
    IGRshort *option;
    struct GRmd_env *env;
    GRobjid **display_ids; 
    IGRint *display_count
)
{
  IGRlong                   sts;
  IGRint                    i,j, num_edges ;
  GRobjid                   *lp_out,lpset,*sf_out, *edges;
  union EMSssi_table        *ssi;
  struct EMSdbssi_table   *my_info;
  struct GRid               temp_GRid;
  OM_S_CHANSELECT           to_loopset, to_common_edge;
  struct EMSnest_info       nesting;
  IGRushort         props, ls_props, lp_props, ed_props;
  IGRboolean                display;
  enum GRdpmode             dpmode;
  IGRshort                  disp_flag;

  /*Initialize.*/
  *EMmsg = EMS_S_Success;
  ssi = NULL;
  display = *option & EMS_DO_DISPLAY;

  sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                targetid = my_id);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);  

  my_info = &ssi->db_info;

  /* Take out the 'out_loops' from the corresponding loopsets.*/
  lp_out = my_info->region_out_ids;
  ls_props = NULL | EMLS_NATURAL;
  lp_props = NULL;
  ed_props = NULL;

  for(i=0;i<my_info->num_surfaces;i++)
   {
      if (display)
      {
        IGRint       inx;                  /*DECL*/
        IGRboolean got_it = FALSE;

        /*Has this surface already been erased?*/
        for (inx=0; inx<*display_count; inx++)
        {
          if ( (*display_ids)[inx] == my_info->surface_ids[i] )
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
                        targetid = my_info->surface_ids[i]);
          EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, *EMmsg, wrapup);
  
          /*Store this surface that was erased (modified) -DLB*/
          EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                              BUFF_INCR, sizeof(GRobjid));
          if (!(1 & *EMmsg)) goto wrapup;
 
          (*display_ids)[*display_count] = my_info->surface_ids[i];
          (*display_count)++;
        }    
      }

      ls_props = NULL | EMLS_NATURAL;
      if(my_info->num_regions_out[i])
       {
         sts = om$send(msg=message EMSboundary.EMget_objid(EMmsg,&lpset),
                 senderid=my_info->surface_ids[i],p_chanselect=&to_loopset);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
       }
      for(j=0;j<my_info->num_regions_out[i];j++)
       {
         sts = om$send(msg=message EMSloop.EMtreemod
                           (EMmsg,&nesting,EXTRACT,NULL),
                                targetid = *lp_out);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);

         {
           IGRshort option = EMS_O_OFF;
        
           props = EMLP_ACTIVE;
           sts = om$send(msg = message EMSloop.EMset_props(EMmsg, props,
                               option),
                         targetid = *lp_out);
           if (! (1 & sts & *EMmsg)) goto wrapup;
         }
         lp_out++;
       }

/* After taking out the loops removed by this state a loopset may become
   natural again. The bit of such loopsets need to be set ON again.
*/
      if(my_info->num_regions_out[i])
       {
         sts = om$send(msg = message EMSboundary.EMcheck_props
                        (EMmsg, &ls_props, &lp_props, &ed_props), 
                                targetid = lpset);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
       }
   }

/* Take out the 'out_surfaces' and make them non-locatable and
   non-displayable.
*/
  sf_out = my_info->surface_out_ids;
  temp_GRid.osnum = OM_Gw_current_OS;

  for(i=0;i<my_info->num_composites;i++)
   {
     for(j=0;j<my_info->num_surfaces_out[i];j++)
      {
        temp_GRid.objid = my_info->composite_ids[i];        

        /*Erase the surfaces that will be modified by the act -DLB*/
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

        sts = EFfix_parent_child_relationship(EMmsg, *sf_out, 
                                              temp_GRid.objid, 
                                              OM_Gw_current_OS, TRUE, NULL);
        if (!(1 & sts & *EMmsg)) goto wrapup;

        EFsetsfstate(EMmsg, *sf_out, OM_Gw_current_OS, EMS_O_OFF);
        EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

        sts = om$send( msg = message EMSsubbs.EMpassloop ( EMmsg,
                      message EMSloopset.EMtoglpactive (EMmsg) ),
                targetid = *sf_out );
        if (! (1 & sts & *EMmsg)) goto wrapup;

       sf_out++;
      }
   }

 /* Disconnect all the common edges */

 EMmake_chanselect( EMSedge_to_common_edge, &to_common_edge);

 edges = my_info->edges_disconnected;
 num_edges = my_info->num_edges_disconnected;
 
 for (i=0; i<num_edges; i+=2)
  {
   IGRushort dumb_props;

   /* turn my display off */
   dpmode = GRbe;
   disp_flag = EMS_WHL_EDGE;
   sts  = om$send (msg = message EMSedge.EMdisplay (EMmsg, 
			     NULL, &env->md_env.matrix_type, 
			     env->md_env.matrix, &dpmode, NULL,
                             disp_flag, NULL),
                 targetid = edges[i]);
   EMomerr_hndlr (sts, wrapup, "EMSedge.EMdisplay");

   if(edges[i+1] != NULL_OBJID)
   {
    sts = om$send ( msg = message Root.disconnect( to_common_edge,
                    edges[i + 1], OM_Gw_current_OS, to_common_edge),
             targetid = edges[i] );
    EMomerr_hndlr (sts, wrapup, "Root.disconnect");  

    sts = om$send( msg = message EMSedge.EMget_props(EMmsg, &dumb_props),
             targetid = edges[i+1]);
    EMomerr_hndlr (sts, wrapup, "EMSedge.EMget_props");  

    dumb_props &= ~EMED_SUBORDINATE;

    sts = om$send (msg = message EMSedge.EMset_props (EMmsg,
                         dumb_props, EMS_O_SET),
            targetid = edges[i+1]);
    EMomerr_hndlr (sts, wrapup, "EMset_props");  

    dpmode = GRbd;
    disp_flag = EMS_WHL_EDGE;
    sts  = om$send (msg = message EMSedge.EMdisplay (EMmsg, 
			     NULL, &env->md_env.matrix_type, 
			     env->md_env.matrix, &dpmode, NULL,
                             disp_flag, NULL),
                 targetid = edges[i+1]);
    EMomerr_hndlr (sts, wrapup, "EMSedge.EMdisplay");
   }

  }       

  wrapup:
    if(ssi) om$dealloc(ptr = ssi);
    EMWRAPUP(*EMmsg,sts,"In EMSsfrembnd.EMactivate")
    return(sts);
}

end implementation EMSsfrembnd;
