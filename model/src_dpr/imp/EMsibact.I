/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfimpbnd;

#include "EMS.h"
/*
Description
    This method activates the corresponding state by removing and adding
    loops.

Algorithm
    Get the region table
    Take out out_loops
    Put in in_loops
    Take out out_surfaces.
    Set properties of the surfaces OFF.
    Set my active bit on

Return values
    EMS_S_Success if all is well.

History
    DLB 11/08/87  Modified for version 1.1.0
    SM  xx/xx/87  Creation.
*/

#include "emsdef.h"
#include "EMSopt.h"
#include "OMmacros.h"

from EMSsubbs import EMpartolbasis;
from EMSloop import EMtreemod,EMgivenestinfo, EMactivate_loop;
from EMSboundary import EMget_objid, EMcheck_props;
from EMSloopset import EMnesting,EMtreemod, EMset_props;
from EMSloop import EMset_props;

extern OMuword OPP_EMSpartedge_class_id;

method EMactivate(IGRlong *EMmsg;IGRshort *option;
                  struct GRmd_env *env;
                  GRobjid **display_ids;
                  IGRint *display_count)
{
 IGRlong  mthd_stat;
 IGRlong  OM_stat;
  IGRlong                   sts, rc;
  struct EMSnest_info       nesting;
  union EMSssi_table        *rgmod;
  struct EMSsfssi_table     *my_info;
  IGRint                    i,j, k, ll, edge_out_index, chan_count;
  OM_S_CHANSELECT           to_loopset;
  struct EMSpartolbasis     partolbasis;
  IGRboolean                world,on_off;
  GRobjid                   *lp_in,*lp_out,lpset,*sf_out, 
			    *edge_in, *edge_out, loop_id, ls_id;
			
  IGRushort         props, ls_props, lp_props, ed_props;
  IGRshort 		    action = 1;
  OM_S_CHANSELECT           ed_lp_chan, com_ed_chan, lp_ed_chan, 
							lp_ls_chan,
                            sf_ls_chan, sfcomp_chan, to_assoc;
  extern void 				EFrpl_old_new_eds();



  /*
   * Initialize
   */
  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  rgmod = NULL;

  sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  /*
   * Send a message to myself to get the region mod table. -DLB
   */
  sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &rgmod),
                targetid = my_id);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);  

  /*
   * Take out the 'out_loops' from the corresponding loopsets
   */
  my_info = &rgmod->sf_info;
  lp_out = my_info->region_out_ids;
  ls_props = NULL | EMLS_NATURAL;
  lp_props = NULL;
  ed_props = NULL;
  for(i=0;i<my_info->num_surfaces;i++)
   {
      /*Erase the surfaces that will be modified by the act -DLB*/
      if (*option & EMS_DO_DISPLAY)
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
                              DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
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


/* Put in the 'in_loops' into the respective loopsets
*/
   lp_in = my_info->region_in_ids;

   ls_props = NULL | EMLS_NATURAL;
   lp_props = NULL;
   ed_props = NULL;

   for(i=0;i<my_info->num_surfaces;i++)
    {
      ls_props = NULL | EMLS_NATURAL;
      if(my_info->num_regions_in[i])
       {
         world = TRUE;
         sts = om$send(msg=message EMSsubbs.EMpartolbasis
                  (EMmsg,&env->md_env.matrix_type,env->md_env.matrix,&world,
                         FALSE,&partolbasis.tol),
                        targetid = my_info->surface_ids[i]);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);
         partolbasis.mattyp = &env->md_env.matrix_type;
         partolbasis.mat = env->md_env.matrix;
         partolbasis.in_world = TRUE;
         partolbasis.is_valid = TRUE;
         sts = om$send(msg=message EMSboundary.EMget_objid(EMmsg,&lpset),
                 senderid=my_info->surface_ids[i],p_chanselect=&to_loopset);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
       }
      for(j=0;j<my_info->num_regions_in[i];j++)
       {
         {
           sts = om$send(msg = message EMSloop.EMactivate_loop(EMmsg), 
                        targetid = *lp_in);
           if (! (1 & sts & *EMmsg)) goto wrapup;
         }

         sts = om$send(msg=message EMSloop.EMgivenestinfo(EMmsg,&nesting),
                                targetid= *lp_in);
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
         lp_in++;
       }
/* After all the loops have been put back in the corresponding loopset
   can become natural again. If so the bit needs to be set ON.
*/
      if(my_info->num_regions_in[i])
       {
         sts = om$send(msg = message EMSboundary.EMcheck_props
                        (EMmsg, &ls_props, &lp_props, &ed_props), 
                                targetid = lpset);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
       }

    }


/*
 * take out the edges_out  and put back edges_in. Also, turn off
 * EMLP_NATURAL and EMLS_NATURAL bit of the loops and their
 * respective loopsets, these aedges are part of.
 */
 
  if (my_info->num_regions)
  {
    IGRboolean	one_by_many = TRUE, delete = FALSE;

    EFrpl_old_new_eds (&rc, my_info->cum_num_edges_out, 
                       my_info->edge_out_ids, my_info->num_edges_in, 
                       my_info->edge_in_ids, OM_Gw_current_OS, 
					   one_by_many, delete, TRUE);
    EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

  } /* if (my_info->num_regions) */


/* If some edges were copied, then replace the original
   edges by their copies.
*/
if (my_info->num_edges_copied)
{
  OMuword	edge_classid;

  sts = EMmake_chanselect (GRnotify_notification, &to_assoc);

  OM_stat = EMmake_chanselect (EMSedge_to_owner, &ed_lp_chan);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 for (i = 0; i < my_info->num_edges_copied; i++)
  {
    sts = om$get_classid(objid = my_info->ed_cp_ed_ids[2*i], 
			 p_classid = &edge_classid);
    OM_stat = om$send (msg = message Root.move_chan (ed_lp_chan, 
                         my_info->ed_cp_ed_ids[2*i], OM_Gw_current_OS,
                         ed_lp_chan),
                        targetid = my_info->ed_cp_ed_ids[2*i+1]);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    /* Move associations to the new edge
    */
    OM_stat = om$send (msg = message Root.move_chan (to_assoc, 
                         my_info->ed_cp_ed_ids[2*i], OM_Gw_current_OS,
                         to_assoc),
                        targetid = my_info->ed_cp_ed_ids[2*i+1]);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    sts = om$is_ancestry_valid(subclassid = edge_classid, 
			       superclassid = OPP_EMSpartedge_class_id);
    if(sts == OM_S_SUCCESS)
     {
       OM_stat = om$send (msg = message Root.move_chan (lp_ed_chan, 
                         my_info->ed_cp_ed_ids[2*i], OM_Gw_current_OS,
                         lp_ed_chan),
                        targetid = my_info->ed_cp_ed_ids[2*i+1]);
       EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
     }
    else
      sts = OM_S_SUCCESS;

  } /* for (i = 0; i < my_info->num_edges_copied; i++) */

} /* if (my_info->num_edges_copied) */

 wrapup:
        if(rgmod) om$dealloc(ptr = rgmod);
        EMWRAPUP(*EMmsg,sts,"In EMSsfimpbnd.EMactivate")
        return(sts);
}

end implementation EMSsfimpbnd;



/***********************************************************
This code was removed and replaced by the call to the function
EFrpl_old_new_eds.

    IGRboolean skip = FALSE;

    OM_stat = EMmake_chanselect (EMSloop_to_outter, &lp_ls_chan);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);


    OM_stat = EMmake_chanselect (EMSedge_to_owner, &ed_lp_chan);
    EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    edge_in = my_info->edge_in_ids;
    edge_out = my_info->edge_out_ids;

    ll = 0;
    for (i = 0; i < my_info->num_regions; i++)
    {
      loop_id = my_info->region_ids[i];
      props = EMLP_NATURAL;

      OM_stat = om$send (msg = message EMSloop.EMset_props ( &mthd_stat, 
                          props, EMS_O_OFF), targetid = loop_id);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

      props = EMLS_NATURAL;
      OM_stat = om$send (msg = message EMSloopset.EMset_props( &mthd_stat,
                         props, EMS_O_OFF), 
                        senderid = loop_id, p_chanselect = &lp_ls_chan);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

      for (j = 0; j < my_info->num_edges_out[i]; j++, ll++)
      {
	skip = FALSE;
        OM_stat = om$get_index ( osnum_c = OM_Gw_current_OS,
                                 objid_c = loop_id,
                                 p_chanselect = &lp_ed_chan,
                                 objid = *edge_out,
                                 indexaddr = &edge_out_index);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
				 
        for (k = 0; k < my_info->num_edges_in[i]; k++)
	{
	  if(IF_EQ_OBJID(*edge_in, *edge_out)) skip = TRUE;
	  OM_stat = om$send (msg = message Root.connect( lp_ed_chan,
                              OM_K_MAXINT, *edge_in, OM_Gw_current_OS,
                              ed_lp_chan, edge_out_index+k),
                             targetid = loop_id);
          EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
          edge_in++;
        }
        if(!skip)
        {
         OM_stat = om$send (msg = message Root.disconnect( lp_ed_chan,
                            *edge_out, OM_Gw_current_OS, ed_lp_chan),
                           targetid = loop_id);
         EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
        }
        edge_out++;

      } 

    } 
********************************************************/
