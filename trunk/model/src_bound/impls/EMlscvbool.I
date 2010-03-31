/* ###################   APOGEE COMPILED   ################## */
/*
  BUGS

    Does not support save-state in any way. Only the intersection operation
    is well supported for disjoint areas or completely enclosing areas.
    Wrong results may be obtained in such cases for unions and differences.

  HISTORY

   Jack :  03-Jun-93 :  Added code to deallocate "myloops" to fix Purify memory
                        leak.
    NP  :  07-Aug-92 :	After my loops are split against input loops, each of
			my loops is currently checked for disjointness from the
			input loops ONLY if "double_check" is set. Now the
			disjoint check is done EITHER if "double_check" is 
			set OR if one of the loopset split options is 
			"EMImpBnd_BdryIsArea". See comments in code for more
			details.
    SM  :  13-Oct-89 :  Added argument lssplit_opt. Following options are
			now sent to EMSloopset.EMsplityourself - 
			lssplit_opt | EMImpBnd_CloseRegular | 
			EMImpBnd_NoInputDelete.
			Moved the following options to EMssBdryInt.I -
			(double_check ?
                        (EMImpBnd_DegenerateBdrys | EMImpBnd_BdryIsArea) : 
			NULL).
			Also removed the restriction that the loopset
			has to exist in XYZ.
			Added support for operand2 being a single loop.
			
    SS  :  06/26/89  :  Using the option in EMSloopset.EMsplityourself
                        to split at the ends of any overlap. This caused
                        some modifications in this code. This option
                        gets used only when double-checking asked for.
    SS  :  10/05/87  :  Creation
*/

class implementation EMSloopset;

#include "EMS.h"
#include "OMmacros.h"
#include "emsbool.h"
#include "emsdef.h"
#include "madef.h"
#include "emsimpdef.h"
#include "emstplydel.h"
#include "emssfintdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define ObjBuff	10

from EMSloop import EMpt_location, EMtplydelete, EMreverse;
from EMSloop import EMptinside, EMget_loops, EMget_props, EMset_props;

extern OMuword OPP_EMSloopset_class_id, OPP_EMSloop_class_id;

method EMcvboolean (IGRlong *msg; enum EMSbooltype operation;
                    GRobjid operand2; IGRushort options, 
		    lssplit_opt;
		    struct EMSownercomp **sfloops_unused1, **sfloops_unused2, 
		    **sfloops_used1, **sfloops_used2;
                    struct EMSpartolbasis *partolb)
{
  IGRboolean chkloop, deleteloop, inloop, delinloops, double_check;
  IGRushort *inprops, *myprops;
  IGRint num_inloops = 0, num_newloops = 0, num_myloops = 0;
  IGRint final_mycount;
  OMuint callinx;
  IGRint depth, buff_size, i, j, inloop_inx = 0;
  IGRdouble areapt[2], mindist, tempdist;
  IGRlong stat_OM, stat_tmp, msg_loc;
  GRobjid *inloops, *newloops, *myloops;
  struct EMSptloc_info ptloc_info;
  OM_S_CHANSELECT chan, to_assoc, to_edges;
  IGRboolean op2isls = FALSE, op2islp = FALSE;
  extern IGRboolean EFisAncestryValid();
  IGRint num_sfs1 = 0;
  struct EMSownercomp *locsfloops1 = NULL;
  IGRboolean list_ext = FALSE;
  extern void EMmkownlist(), EMownercomp_free();
  struct GRid	*trashptr = NULL, trashobj[ObjBuff];
  extern IGRlong EMgettrshobj();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  inloops = NULL;
  newloops = NULL;
  inprops = NULL;
  myprops = NULL;
  if(sfloops_unused1) *sfloops_unused1 = NULL;
  if(sfloops_unused2) *sfloops_unused2 = NULL;
  if(sfloops_used1) *sfloops_used1 = NULL;
  if(sfloops_used2) *sfloops_used2 = NULL;
  EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);

  delinloops = lssplit_opt & EMImpBnd_NoInputDelete ? FALSE : TRUE;
  double_check = options & EMS_SFINT_DOUBLECHECK;
  op2isls = EFisAncestryValid(&msg_loc, operand2, OM_Gw_current_OS, 
			OPP_EMSloopset_class_id, TRUE);
  if(!op2isls)
   op2islp = EFisAncestryValid(&msg_loc, operand2, OM_Gw_current_OS, 
			OPP_EMSloop_class_id, TRUE);
  EMerr_hndlr (!op2isls && !op2islp, *msg, EMS_E_InvalidArg, ret_end);
  EMerr_hndlr (!partolb->is_valid, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * Orient the loopset for the appropriate
   * operation that is to be performed.
   */

  if (operation == EMSbool_union || operation == EMSbool_difference)
    {
     if(op2isls)
      stat_OM = om$send (msg = message EMSloopset.EMreverse (&msg_loc),
               targetid = operand2);
     else
      stat_OM = om$send (msg = message EMSloop.EMreverse (&msg_loc),
               targetid = operand2);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopsetError, ret_end);

    if (operation == EMSbool_union)
      {
      stat_OM = om$send (msg = message EMSloopset.EMreverse (&msg_loc),
                 targetid = my_id);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopsetError, ret_end);
      }
    }
  else
    EMerr_hndlr (operation != EMSbool_intersect, *msg, EMS_E_InvalidArg,
     ret_end);

  /*
   * Get the loops from the second operand and pass them on
   * to the first operand for splitting and closing. Because of
   * the orientations of the loops, either a union, difference or
   * an intersection is performed.
   */

  depth = MAXINT;
  buff_size = 0;
  if(op2isls)
     stat_OM = om$send (msg = message EMSloopset.EMget_loops (&msg_loc, 
             EMS_OPT_ALL, &depth, &inloops, &inprops, &buff_size, 
             &num_inloops), targetid = operand2);
  else
     stat_OM = om$send (msg = message EMSloop.EMget_loops (&msg_loc, 
             EMS_OPT_ALL, &depth, &inloops, &inprops, &buff_size, 
             &num_inloops), targetid = operand2);

  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopsetError, ret_end);

  stat_OM = EMmake_chanselect (EMSloop_to_outter, &chan);
  EMomerr_exit (stat_OM, ret_end);
  stat_OM = EMmake_chanselect(GRnotify_notification, &to_assoc);
  EMomerr_exit (stat_OM, ret_end);

  if(sfloops_unused2 || sfloops_used2)
   {
    if(num_inloops > ObjBuff)
     trashptr = (struct GRid *) om$malloc(size = num_inloops * 
				sizeof(struct GRid));
    else trashptr = trashobj;
    EMerr_hndlr (!trashptr, *msg, EMS_E_NoDynamicMemory, ret_end);
    stat_OM = EMgettrshobj(&msg_loc, OPP_EMSloop_class_id, num_inloops, 
			   trashptr);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    for(i=0; i<num_inloops; i++)
     stat_tmp = om$send(msg = message Root.wild_disconnect(to_assoc), 
		targetid = trashptr[i].objid, targetos = trashptr[i].osnum);
   }

  for (i=0; i<num_inloops; i++)
    {
    stat_OM = om$send (msg = message Root.wild_disconnect (chan),
               targetid = inloops[i]);
    EMomerr_exit (stat_OM, ret_end);
    if(sfloops_unused2 || sfloops_used2)
     {
      /* Associate a trash loop to all the edges of the corresponding input 
	 loop. If the trash loop is associated 
	 to any of the edges of a  new loop after the operation is complete, 
	 it will indicate use of that particular input loop in the result. We 
	 need this info to output all the loops from operand2 that were not 
	 used (fully or partially) in the final result.
      */
      stat_OM = om$send(msg = message Root.connect(to_assoc, MAXINT, 
		trashptr[i].objid, trashptr[i].osnum, to_assoc, MAXINT),
		senderid = inloops[i], p_chanselect = &to_edges);
      EMomerr_exit (stat_OM, ret_end);
     }
    }
  /*delinloops = TRUE;*/

  num_newloops = 0;
  if(sfloops_unused2 || sfloops_used2) lssplit_opt |= EMImpBnd_MaintainAssoc;
  if(sfloops_unused1 || sfloops_used1) lssplit_opt |= EMImpBnd_MaintainSplit;

  stat_OM = om$send (msg = message EMSloopset.EMsplityourself (&msg_loc,
             inloops, num_inloops, NULL, NULL, NULL, 
             &newloops, &num_newloops,
             lssplit_opt | EMImpBnd_CloseRegular | EMImpBnd_NoInputDelete, 
             sfloops_unused1||sfloops_used1 ? &num_sfs1 : NULL, 
	     sfloops_unused1||sfloops_used1 ? &locsfloops1 : NULL,
             partolb, NULL), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopsetError, ret_end);

  /* Out of my loops removed, create a list of those which did not contribute
     towards the result. A loop removed but marked SPLIT indicates partial
     contribution towards the result.
  */
  if((sfloops_unused1 || sfloops_used1) && locsfloops1)
   {
    IGRushort	lpprops = NULL;
    for(i=0; i<locsfloops1->num_comps; i++)
     {
      stat_OM = om$send(msg = message EMSloop.EMget_props(&msg_loc, &lpprops), 
			targetid = locsfloops1->comps[i]);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopsetError, ret_end);
      if(lpprops & EMLP_SPLIT)
       {
	if(sfloops_used1)
	 {
          EMmkownlist(&msg_loc, sfloops_used1, NULL_OBJID, NULL, 
		    locsfloops1->comps[i], FALSE, &list_ext);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
          stat_OM = om$send(msg = message EMSloop.EMset_props
			(&msg_loc, EMLP_SPLIT, EMS_O_OFF), 
			targetid = locsfloops1->comps[i]);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopsetError, ret_end);
         }
        else
	 {
	  stat_OM = om$send(msg = message Root.delete(TRUE), 
			targetid = locsfloops1->comps[i]);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
         }
       }
      else if(sfloops_unused1)
       {
        EMmkownlist(&msg_loc, sfloops_unused1, NULL_OBJID, NULL, 
		    locsfloops1->comps[i], FALSE, &list_ext);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
       }
      else
       {
	stat_OM = om$send(msg = message Root.delete(TRUE), 
			targetid = locsfloops1->comps[i]);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
       }

     }
   }

  /*
   * Some post-processing might be necessary in some
   * cases.
   */

  if (operation == EMSbool_union)
    {
    stat_OM = om$send (msg = message EMSloopset.EMreverse (&msg_loc),
               targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopsetError, ret_end);
    }
  else if (operation == EMSbool_intersect)
    {
    /*
     * The loopset-split method does not differentiate between areas
     * of this loopset that might be completely enclosed by the inloops
     * and areas that may be completely disjoint from any of inloops.
     * Those areas of this loopset that are completely disjoint from 
     * operand2 (or inloops) are deleted.
     *
     * 8/7/92(NP): There is a problem in cases of loops that just "touch" along
     * an edge. This problem showed up after the "EMImpBnd_BdryIsArea" option 
     * was used to split loops so that overlapping regions would get split 
     * during intersections, and hence reduce chances of sliver formation.  
     * "EMImpBnd_BdryIsArea" is always set and not only during double check.
     *
     *    In cases of "touch"ing disjoint loops (touch along an edge or edges), 
     * "num_newloops" is NOT zero, although loops are disjoint. This is because
     * I am modified slightly due to overlap processing in "splityourself" due
     * to the  "EMImpBnd_BdryIsArea" option, and my modified loops are returned
     * in "newloops" array.  The fact remains however that some of my loops 
     * may still be disjoint (although touching along an edge) with the loops in
     * "inloops". Therefore, disjointness needs to be explicitly checked 
     * whenever  "EMImpBnd_BdryIsArea" option is set while splitting (i.e. 
     * "chkloop" needs to be set to TRUE) so that such disjoint loops may be 
     * deleted from the output loopset.
     *
     *    For loops touching along an edge but one lying within the other (non-
     * disjoint case), the disjoint check may be carried out, but no loops will
     * be deleted. Also, if the splitting is done WITHOUT using the 
     * "EMImpBnd_BdryIsArea" option, then each of my loops gets checked for
     * disjointness, below, ONLY if it is NOT in the "newloops" array (and it
     * will NOT be because touching along an edge in not considered an 
     * intersection, if boundary of "inloops" is in HOLE).
     *
     *	  Note that during double check, "EMImpBnd_BdryIsArea" is always set. So
     * it might be a good idea to remove "double_check" variable and keep only
     * "EMImpBnd_BdryIsArea" check. However, to keep perturbations to a minimum,
     * both are retained.
     */

    depth = MAXINT;
    buff_size = 0;
    stat_OM = om$send (msg = message EMSloopset.EMget_loops (&msg_loc, 
               EMS_OPT_PLOOP, &depth, &myloops, &myprops, &buff_size,
               &num_myloops), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopsetError, ret_end);

    final_mycount= num_myloops;
    for (i=0; i<num_myloops; i++)
      {
      chkloop = TRUE;

      if (!double_check && !(lssplit_opt&EMImpBnd_BdryIsArea) )
      {
        for (j=0; j<num_newloops; j++)
          {
          if (IF_EQ_OBJID (myloops[i], newloops[j]))
            {
            chkloop = FALSE;
            break;
            }
          }
      }

      if (chkloop)
        {
        /*
         * This loop has not been affected by the split-loopset
         * operation and has to undergo further scrutiny to see if
         * it should continue to belong in the output intersection-loopset.
         */

        callinx = 1;
        stat_OM = om$send (msg = message EMSloop.EMptinside (&msg_loc,
                   &callinx, partolb, 1, areapt, NULL), targetid = myloops[i]);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

        ptloc_info.options = NULL;
        mindist = MAXDOUBLE;
        inloop = FALSE;
        for (j=0; j<num_inloops; j++)
          {
          stat_OM = om$send (msg = message EMSloop.EMpt_location (&msg_loc,
                     areapt, &ptloc_info, partolb), targetid = inloops[j]);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, 
           ret_end);

          if (ptloc_info.location == EMS_L_INSIDE)
            {
            inloop = TRUE;
            tempdist = ptloc_info.edge[0].nst_pt.dist;
            if (tempdist < mindist)
              {
              mindist = tempdist;
              inloop_inx = j;
              }
            }
          }

        if (!inloop || !(inprops[inloop_inx] & EMLP_PLOOP))
          {
          stat_OM = om$send (msg = message EMSloop.EMtplydelete (&msg_loc,
              sfloops_unused1 ? &num_sfs1 : NULL, sfloops_unused1, NULL, NULL, 
 	      sfloops_unused1 ? NULL : EMtplydel_DeleteElems), 
                     targetid = myloops[i]);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
          final_mycount--;
          }
        }
      }
    if (!final_mycount)
      *msg = EMS_I_NoIntersection;
    }

ret_end:
  /*
   * Delete all the data that does not belong to the
   * result of this operation. Mainly the input loopset.
   */

  if (inloops && (delinloops || sfloops_unused2 || sfloops_used2))
    {
    for (i=0; i<num_inloops; i++)
      {
      deleteloop = TRUE;
      for (j=0; j<num_newloops; j++)
        {
        if (IF_EQ_OBJID (inloops[i], newloops[j]))
          {
          deleteloop = FALSE;
          if(sfloops_used2)
	   EMmkownlist(&msg_loc, sfloops_used2, NULL_OBJID, NULL, inloops[i], 
			FALSE, &list_ext);

          break;
          }
        }
      if(deleteloop && sfloops_unused2)
       {
	IGRboolean notused = TRUE;
        IGRint	n;
        OMuint numedges = 0;
	GRobjid	ed;
	
	/* Has this loop been partially used in the result ?
	   If so its trash loop would have been associated to one of the new 
	   loop's edges.
	   If it was totally inside area it will be part of the result
	   and would have been detected as one of the new loops.
	   If this loop is not part of the result totally or partialy, 
	   we have to return its id instead of deleting it.
	*/
        for (j=0; (j<num_newloops) && notused; j++)
         {
	  numedges = 0;
	  stat_tmp = om$get_channel_count(objid = newloops[j], 
			p_chanselect = &to_edges, count = &numedges);
	  for(n=0; (n<numedges) && notused; n++)		
	   {
	    stat_tmp = om$send(msg = message EMSboundary.EMget_objid
				(&msg_loc, &ed), senderid = newloops[j], 
			p_chanselect = &to_edges, from = n, to = n);
			
	    stat_tmp = om$is_objid_on_channel(objid_c = ed, 
			p_chanselect = &to_assoc,  
			objid = trashptr[i].objid, osnum2 = trashptr[i].osnum);
	  
	    if(stat_tmp == OM_S_SUCCESS)
	     {
	      notused = FALSE;
              if(sfloops_used2)
	       EMmkownlist(&msg_loc, sfloops_used2, NULL_OBJID, NULL, 
			   inloops[i], FALSE, &list_ext);
	     }
	   }
         }

	if(notused && sfloops_unused2)
	 {
	  EMmkownlist(&msg_loc, sfloops_unused2, NULL_OBJID, NULL, inloops[i], 
			FALSE, &list_ext);
	  deleteloop = FALSE;
         }
       }

      if (deleteloop && delinloops)
        {
        stat_tmp = om$send (msg = message Root.delete (TRUE), 
                    targetid = inloops[i]);
        }
      }
    stat_tmp = om$send (msg = message Root.delete (TRUE), 
                targetid = operand2);
    }

  if (myloops)
    om$dealloc (ptr = myloops);
  if (inloops)
    om$dealloc (ptr = inloops);
  if (newloops)
    om$dealloc (ptr = newloops);
  if (inprops)
    om$dealloc (ptr = inprops);
  if (myprops)
    om$dealloc (ptr = myprops);
  if(locsfloops1) EMownercomp_free(locsfloops1, NULL);
  if(trashptr)
   {
    for(i=0; i<num_inloops; i++)
     stat_tmp = om$send(msg = message Root.wild_disconnect(to_assoc), 
		targetid = trashptr[i].objid, targetos = trashptr[i].osnum);
    if(trashptr != trashobj) om$dealloc(ptr = trashptr);
   }

  EMWRAPUP (*msg, stat_OM, "EMSloopset.EMcvboolean");
  return (stat_OM);
}

end implementation EMSloopset;
