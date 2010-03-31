/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfimpbnd;

#include "EMS.h"
/*
Description
   This method makes its corresponding state active by adding and removing
   loops.

Algorithm
   Get the region table
   Take out in_loops if option==EMS_UNDO_SAVE else delete them.
   Put in out_loops
   Put in out_surfaces
   Set properties in the surfaces ON
   If option==EMS_UNDO_SAVE set my active bit OFF else delete myself

Return values
   EMS_S_SUCCESS if all is well

History
   WBC  12/19/93  While dealing with loops removed and added
		  skip any invalid oids encountered. Erroring out halfway
		  through is going to hose the model anyway, so skipping
		  invalid oids may actually help. (TR#119309313)
   DLB  11/08/87  Modified for version 1.1.0
   SM   xx/xx/87  Creation.
*/

#include "emsdef.h"
#include "EMSopt.h"
#include "OMmacros.h"

from EMSsubbs import EMpartolbasis;
from EMSloop import EMtreemod,EMgivenestinfo, EMactivate_loop;
from EMSboundary import EMget_objid, EMcheck_props, EMgetsurface_info;
from EMSloopset import EMnesting,EMtreemod;
from EMSloop import EMset_props;

extern OMuword OPP_EMSpartedge_class_id;
extern OMuword OPP_EMSedge_class_id;

method EMdeactivate(IGRlong *EMmsg; IGRshort *option;
                            struct GRmd_env *env;
                    GRobjid **display_ids; IGRint *display_count)
{
  IGRlong                       OM_stat;
  IGRlong                       sts,rc;
  struct EMSnest_info           nesting;
  union EMSssi_table            *ssi;
  struct EMSsfssi_table         *my_info;
  IGRint                        i,j;
  OM_S_CHANSELECT               to_loopset;
  struct EMSpartolbasis         partolbasis;
  IGRboolean                    world,delete;
  GRobjid                       *lp_in,*lp_out,lpset;
  IGRushort                     props, ls_props, lp_props, ed_props;
  OM_S_CHANSELECT       	ed_lp_chan, lp_ed_chan, 
			        to_assoc;
  extern void           	EFrpl_old_new_eds();


  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  ssi = NULL;
  delete = (*option&EMS_UNDO_SAVE) ? FALSE : TRUE;

  sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);


/* Send a message to myself to get the region mod table. -DLB
*/
  sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                targetid = my_id);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);  

/* Take out the 'in_loops' from the corresponding loopsets if the
   option is SAVE. Else delete them.
*/
  my_info = &ssi->sf_info;
  lp_in = my_info->region_in_ids;
  ls_props = NULL | EMLS_NATURAL;
  lp_props = NULL;
  ed_props = NULL;
  for(i=0;i<my_info->num_surfaces;i++)
   {
      if (!EFisAncestryValid(EMmsg, my_info->surface_ids[i], 
          OM_Gw_current_OS, OPP_EMSsurface_class_id, TRUE))
      {
        lp_in += my_info->num_regions_in[i];
        continue;
      }

      if (*option & EMS_DO_DISPLAY)
      {
        /*Erase the surfaces that will be modified by the deact -DLB*/

        IGRint inx;
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

        if (!got_it)
        {
          enum GRdpmode display_mode = GRbehe;   /*DECLARE*/

          sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                              &env->md_env.matrix_type, 
                              env->md_env.matrix, &display_mode,
                              &env->md_id),
                        targetid = my_info->surface_ids[i]);
          EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, *EMmsg, wrapup);

          EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                              DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
          if (!(1 & *EMmsg)) goto wrapup;

          (*display_ids)[*display_count] = my_info->surface_ids[i];
          (*display_count)++;
        }
      }
 
      ls_props = NULL | EMLS_NATURAL;
      if(my_info->num_regions_in[i])
       {
         sts = om$send(msg=message EMSboundary.EMget_objid(EMmsg,&lpset),
                 senderid=my_info->surface_ids[i],p_chanselect=&to_loopset);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
       }
      for(j=0;j<my_info->num_regions_in[i];j++)
       {
         /* make sure we have a valid loop before proceeeding */

         if (!EFisAncestryValid(EMmsg, *lp_in, OM_Gw_current_OS, 
             OPP_EMSloop_class_id, TRUE))
         {
	  lp_in++;
 	  continue;
         }

         sts = om$send(msg=message EMSloop.EMtreemod
                        (EMmsg,&nesting,(delete?DELETE:EXTRACT),NULL),
                                targetid = *lp_in);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);

        if (!delete)
        {
          IGRshort prop_option = EMS_O_OFF;
 
          props = EMLP_ACTIVE;
          sts = om$send(msg = message EMSloop.EMset_props(EMmsg, props,
                              prop_option),
                        targetid = *lp_in);
          if (! (1 & sts & *EMmsg)) goto wrapup;
        }
        lp_in++;
       }
/* After taking out the loops added by this state a loopset may become
   natural again. The bit of such loopsets need to be set ON again.
*/
      if(my_info->num_regions_in[i])
       {
         sts = om$send(msg = message EMSboundary.EMcheck_props
                        (EMmsg, &ls_props, &lp_props, &ed_props), 
                                targetid = lpset);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
       }

   }


/* Put in the 'out_loops' into the respective loopsets
*/
   lp_out = my_info->region_out_ids;

   ls_props = NULL | EMLS_NATURAL;
   lp_props = NULL;
   ed_props = NULL;
   for(i=0;i<my_info->num_surfaces;i++)
    {
      if (!EFisAncestryValid(EMmsg, my_info->surface_ids[i], 
          OM_Gw_current_OS, OPP_EMSsurface_class_id, TRUE))
      {
        lp_in += my_info->num_regions_out[i];
        continue;
      }

      ls_props = NULL | EMLS_NATURAL;
      if(my_info->num_regions_out[i])
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
      for(j=0;j<my_info->num_regions_out[i];j++)
       {
        /* make sure we have a valid loop before proceeeding */

        if (!EFisAncestryValid(EMmsg, *lp_out, OM_Gw_current_OS, 
            OPP_EMSloop_class_id, TRUE))
         {
	  lp_out++;
          continue;
         }

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

         /* if the loop's parent is returned as the loop itself, the loop
          * must already be attached to the loopset; in this case don't
          * need to do the treemod (TR#119309313)
          */

         if (nesting.parent != nesting.loopid)
         {
            if(IF_EQ_OBJID(lpset,nesting.parent))
              sts = om$send(msg=message EMSloopset.EMtreemod
                           (EMmsg,&nesting,ADD_CHILD,&partolbasis),
                           targetid = lpset);
            else
              sts = om$send(msg=message EMSloop.EMtreemod
                           (EMmsg,&nesting,ADD_CHILD,&partolbasis),
                           targetid = nesting.parent);
            EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);
         }
         lp_out++;
       }
/* After all the loops have been put back in the corresponding loopset
   can become natural again. If so the bit needs to be set ON.
*/
      if(my_info->num_regions_out[i])
       {
         sts = om$send(msg = message EMSboundary.EMcheck_props
                        (EMmsg, &ls_props, &lp_props, &ed_props), 
                                targetid = lpset);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
       }
    }


  /*
   * take out the edges_in. delete edges_in if the 
   * option is  not EMS_UNDO_SAVE and put back edges_out
   */
 
  if (my_info->num_regions)
  {
    IGRboolean one_by_many = FALSE;
    EFrpl_old_new_eds (&rc, my_info->cum_num_edges_out, 
                       my_info->edge_out_ids, my_info->num_edges_in, 
                       my_info->edge_in_ids, OM_Gw_current_OS, 
					   one_by_many, delete, TRUE);
    EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
  } /* if (my_info->num_regions) */


/* If some edges were copied, then replace the copies with the original
   edges. Delete the copies if the option is DELETE.
*/
if (my_info->num_edges_copied)
{
  OMuword	edge_classid;

  sts = EMmake_chanselect (GRnotify_notification, &to_assoc);

  OM_stat = EMmake_chanselect (EMSedge_to_owner, &ed_lp_chan);
   EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   for (i = 0; i < my_info->num_edges_copied; i++)
   {
     if ((!EFisAncestryValid(EMmsg, my_info->ed_cp_ed_ids[2*i],
                             OM_Gw_current_OS, OPP_EMSedge_class_id, TRUE)) ||
         (!EFisAncestryValid(EMmsg, my_info->ed_cp_ed_ids[2*i+1],
                             OM_Gw_current_OS, OPP_EMSedge_class_id, TRUE)))
      continue;

     OM_stat = om$send (msg = message Root.move_chan ( ed_lp_chan, 
                         my_info->ed_cp_ed_ids[2*i+1], OM_Gw_current_OS,
                         ed_lp_chan),
		        targetid = my_info->ed_cp_ed_ids[2*i]);
     EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    /* Move associations to the new edge
    */
    OM_stat = om$send (msg = message Root.move_chan (to_assoc, 
                         my_info->ed_cp_ed_ids[2*i+1], OM_Gw_current_OS,
                         to_assoc),
                        targetid = my_info->ed_cp_ed_ids[2*i]);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    sts = om$get_classid(objid = my_info->ed_cp_ed_ids[2*i], 
                         p_classid = &edge_classid);

    sts = om$is_ancestry_valid(subclassid = edge_classid, 
			       superclassid = OPP_EMSpartedge_class_id);
    if(sts == OM_S_SUCCESS)
     {
       OM_stat = om$send (msg = message Root.move_chan (lp_ed_chan, 
                         my_info->ed_cp_ed_ids[2*i+1], OM_Gw_current_OS,
                         lp_ed_chan),
                        targetid = my_info->ed_cp_ed_ids[2*i]);
       EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
     }
    else
      sts = OM_S_SUCCESS;

     if(delete) 
      {
        sts = om$send(msg = message Root.delete(TRUE), 
				targetid = my_info->ed_cp_ed_ids[2*i+1]);
	EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
      }

   } /* for (i = 0; i < my_info->num_edges_copied; i++) */

 } /* if (my_info->num_edges_copied) */


wrapup:
    if(ssi) om$dealloc(ptr=ssi);
        EMWRAPUP(*EMmsg,sts,"In EMSsfimpbnd.EMdeactivate")
        return(sts);
}
end implementation EMSsfimpbnd;
