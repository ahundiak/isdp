/*
History
	SM	03-Apr-91	Genesis.
*/
class implementation NMinters;

#include "nmchandef.h"
#include "nmdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emsmacros.h"
#include "msmacros.h"
#include "NMmsg.h"
#include "EMSssprops.h"

from EMSdpr import EMundo, EMredo;
from EMSsurface import EMgetactiveid;
from NMnonmanigm import NMSSI_action, NMprop;
from EMSsubbs import EMget_props, EMset_props;

#define StaticBuf 10

extern OMuint OM_Gf_verbose_warning;
/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;



method NMintersect(IGRlong *EMmsg; enum NMbooltype bool_type; 
		   IGRushort boolopt; struct EMSobject_info *op;
		   struct EMSinters **inters, **vol_inters;
		   struct EMSsftracedata *nm_tracedata, *vol_tracedata;
		   IGRushort intopt;
		   struct GRvg_construct *construct;
		   GRobjid *intobj, *auxobj; IGRchar *status_str)
{
 IGRlong 		sts = OM_S_SUCCESS, rc, locsts = OM_S_SUCCESS;
 struct EMSinters	*loc_inters = NULL, *loc_volinters = NULL;
 struct EMSdataselect	volop_data;
 struct EMSsftracedata	tracedata[2];
 struct EMSsfintloopsdata loopdata[2];
 struct EMSobject_info	locop[2];
 IGRint			i, num_inters = 0, num_all_nmnodes = 0, ndbufsize = 0, 
			numbase = 0;
 IGRushort 	inters_opt, outworld_opt, outparam_opt, trim_opt;
 extern void		EMinters_free(), EMinters_data_free();
 IGRdouble		cht;
 IGRboolean		double_chk = FALSE, handle_stop = FALSE, no_top, 
			nm_undone = FALSE, store = FALSE, recompute = FALSE;
 struct GRid		actid, *all_nmnodes = NULL;
 OM_S_OBJECT_LINKAGE	dprnode, *nmnode = NULL, nmnodebuf[StaticBuf];
 extern OM_S_OBJID      current_creator;
 IGRushort      tpval_opt = EMSsfbool_opt_OpenIntPossible |
				  EMSsfbool_opt_IncompleteInt;
 unsigned char	ssprops = NULL;
 struct GRid		base_st[2], *basestptr = NULL;
 IGRboolean		nrml_toggled = FALSE, null_state = FALSE;
 IGRchar		locstsstr[200];
 IGRboolean save_pathway_trim, save_pathway_orient;

begin:

 *EMmsg = EMS_S_Success;

 store = (intopt & NMintersect_NoStoreInters) ? FALSE : TRUE;
 recompute = (intopt & NMintersect_IsRecompute) ? TRUE : FALSE;

 if(recompute && !status_str)
  {
   IGRlong msgnumber;

   if(ME.NMinters->operation == NMbool_split) msgnumber = NM_I_RecompInters;
   else msgnumber = NM_I_RecompOrientInters;

   ex$message(msgnumb = msgnumber);
   ex$message(msgnumb = msgnumber, buff = locstsstr);
   status_str = locstsstr;
  }

 for(i=0; i<2; i++)
  {
   tracedata[i].num_grps = 0;
   tracedata[i].num_subgrps_grp = NULL;
   tracedata[i].num_elems_subgrp = NULL;
   tracedata[i].elems = NULL;
   tracedata[i].subgrp_rev = NULL;
   tracedata[i].elem_rev = NULL;
   tracedata[i].grp_closed = NULL;
   tracedata[i].subgrp_closed = NULL;

   loopdata[i].loop_sf = NULL;
   loopdata[i].endedges = NULL;
   loopdata[i].intedpars = NULL;
   loopdata[i].sfpartolb = NULL;
   loopdata[i].sfintloops_alloced = FALSE;
  }

 EMerr_hndlr((bool_type != NMbool_intersect) && (bool_type != NMbool_union) &&
 (bool_type != NMbool_split), *EMmsg, EMS_E_InvalidArg, wrapup);

 if(!op)
  {
   op = locop;
   sts = om$send(msg = message NMassoc.NMget_parent_info(EMmsg, &op, 
	 2, NULL), targetid = my_id);
   if(!(1&*EMmsg&sts))  goto wrapup;
   
   /* If I use the volume operand partially, treat the current state of the
      corresponding base state itself as the volume operand.
   */
   if(ME.NMinters->props & NMinters_PartialVolInt)
    {
     basestptr = base_st;
     sts = om$send(msg = message NMassoctrans.NMget_trans_info(EMmsg, NULL, 
	   &basestptr, &numbase), targetid = my_id);
     if(!(1&*EMmsg&sts))  goto wrapup;
     EMerr_hndlr(numbase!=2, *EMmsg, EMS_E_InvalidCase, wrapup);
     op[VolOpIdx].grid = base_st[VolOpIdx];
    }
  }

 /* Set up options for intersection
 */
 handle_stop = boolopt & EMSsfbool_opt_HandleStop;
 double_chk =  boolopt & EMSsfbool_opt_doublecheck;

 outworld_opt = EMSINT_OUTPUT_WORLD | EMSINT_WORLD_NOTYPEDCV;
 outparam_opt = EMSINT_OUTPUT_PARAM | 
                 EMSINT_PARAM_OBJECT |
                 (bool_type == NMbool_split ? NULL : EMSINT_ORIENT_OUTPUT) | 
                 (bool_type == NMbool_intersect ? EMSINT_ORIENT_RIGHT : NULL);
 trim_opt = EMSINT_TRIM_OUTPUT |
             EMSINT_TRIM_BDRYISAREA |
             EMSINT_TRIM_COPLANAR |
             (double_chk ? EMSINT_TRIM_MOREPRECISE | EMSINT_TRIM_PROCOVERLAP :
                           NULL);
 inters_opt = /*EMS_SFINT_MUSTINTERSECT | */
	      (bool_type == NMbool_split ? NULL : EMS_SFINT_MUSTORIENT) |
                EMS_SFINT_PUSHBADCOINC |
                (double_chk ? NULL : EMS_SFINT_MUSTNOAMBIGUOUS) |
                (double_chk ? EMS_SFINT_DOUBLECHECK : NULL) |
                (handle_stop ? EMS_SFINT_HANDLESTOP : NULL);

  num_inters = 0;
  volop_data.datatype = EMSdata_object;
  volop_data.data.object = &op[VolOpIdx].grid;
  
  /* For now all the players are assumed to be in the same object space.
  */

  no_top = (boolopt & EMSsfbool_opt_outinters) ||
           (boolopt & EMSsfbool_opt_outaux);

  /* If the nm op is not active, temporarily activate it.
  */
  actid.objid = NULL_OBJID;
  sts = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg, &actid, NULL),
        targetid = op[NmOpIdx].grid.objid, targetos = op[NmOpIdx].grid.osnum);
  if(!(1&*EMmsg&sts)) goto wrapup;

  if((!IF_NULL_OBJID(actid.objid)) && (!IF_EQ_GRID(actid, op[NmOpIdx].grid)))
   {
    IGRushort undo_opt = EMS_UNDO_SAVE;
    OM_S_CHANSELECT to_owners;
    OMuint count;

    EMmake_chanselect(GRconnector_to_owners, &to_owners);
    sts = om$get_channel_objects(objid = op[NmOpIdx].grid.objid, 
          osnum = op[NmOpIdx].grid.osnum, p_chanselect = &to_owners, 
          list = &dprnode, size = 1, count = &count);
    if(!(1&sts)) goto wrapup;

    sts = om$send(msg = message EMSdpr.EMundo(EMmsg, &undo_opt, 
          &op[NmOpIdx].env, NULL, NULL, NULL, NULL, NULL, NULL),
          targetid = dprnode.S_objid, targetos = dprnode.osnum);
    if(!(1&*EMmsg&sts)) goto wrapup;
    nm_undone = TRUE;
   }

  /* Check that the orientation of the volume operand is consistent, if this
     is a recompute. If initial intersection, get the orientation and
     store it.
  */
  if(recompute && !basestptr)
   {
    basestptr = base_st;
    sts = om$send(msg = message NMassoctrans.NMget_trans_info(EMmsg, NULL, 
          &basestptr, NULL), targetid = my_id);
    if(!(1&*EMmsg&sts)) goto wrapup;
   }
  else if(!basestptr) base_st[VolOpIdx] = op[VolOpIdx].grid;

  sts = om$send(msg = message EMSsubbs.EMget_props(EMmsg, &ssprops), 
        targetid = base_st[VolOpIdx].objid);
  if(sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS; /* could be composite */
  if(!(1&*EMmsg&sts)) goto wrapup;

  if(recompute)
   {
    IGRboolean rev1, rev2;

    rev1 = ME.NMinters->props & NMinters_VolOpRevOrnt ? TRUE : FALSE;
    rev2 = ssprops & EMSIS_NRML_REVERSED ? TRUE : FALSE;

    if(rev1 != rev2)
     {
      sts = om$send(msg = message EMSsubbs.EMset_props(EMmsg, 
            EMSIS_NRML_REVERSED, EMS_O_TOGGLE),
          targetid = op[VolOpIdx].grid.objid);
     if(sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS; /* could be composite */
     if(!(1&*EMmsg&sts)) goto wrapup;
     nrml_toggled = TRUE;
    }
   }
  else if(ssprops & EMSIS_NRML_REVERSED) 
     ME.NMinters->props |= NMinters_VolOpRevOrnt;

  current_creator = my_id;

  save_pathway_trim = _pathway_trim;
  save_pathway_orient = _pathway_orient;
  _pathway_trim = 0;
  _pathway_orient = 0;

  sts = EMintersect_surfaces(EMmsg, &op[NmOpIdx].grid, &op[NmOpIdx].env.md_env,
        1, &volop_data, &op[VolOpIdx].env.md_env, inters_opt, outworld_opt, 
        outparam_opt, trim_opt, construct, &num_inters, no_top ? NULL :&loc_inters,
        no_top ? NULL : &loc_volinters, no_top ? NULL : &tracedata[0],
        no_top ? NULL : &tracedata[1], intobj, auxobj, status_str);

  _pathway_trim = save_pathway_trim;
  _pathway_orient = save_pathway_orient;


  if(nrml_toggled)
   {
    sts = om$send(msg = message EMSsubbs.EMset_props(&rc, EMSIS_NRML_REVERSED,
	  EMS_O_TOGGLE), targetid = op[VolOpIdx].grid.objid);
    if(sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS; /* could be composite */
    if(!(1&rc&sts)) 
     {
      *EMmsg = EMS_E_Fail;
      goto wrapup;
     }
   }

  if(*EMmsg == EMS_I_Interrupt) goto wrapup;
  if( (*EMmsg == EMS_I_NotFound) && num_inters)
   {
    *EMmsg = EMS_E_IntersectOrient;
    goto wrapup;
   }

  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Intersect, wrapup);
  if(no_top) goto wrapup;
  if(!num_inters || !loc_inters)
   {
    if(double_chk)
     {
      ex$message(msgnumb = NM_I_NoIntersection)
      *EMmsg = EMS_I_NoIntersection;
     }
    else
      *EMmsg = EMS_E_NoIntersection;
    goto wrapup;
   }

  /* Validate the intersection topologically, and get some possible fixing
     done before storing it.
  */
  if(bool_type == NMbool_split)
   tpval_opt |=	EMSsfbool_opt_ValidateAllData;

  for(i=0; i<2; i++)
   {
    if(!(i ? loc_volinters : loc_inters)) continue;

    if(i) tpval_opt |=	EMSsfbool_opt_ValidateAllData;

    sts = EMsfint_topology_validate(EMmsg, 
            &op[NmOpIdx].env.md_env,	/* mdenvinfo */
            i ? loc_volinters : loc_inters,	/* sf1_inters */
            NULL,			/* sf2_inters */
            i ? &tracedata[1] : &tracedata[0],	/* sf1_tracedata */
            NULL,			/* sf2_tracedata */
            tpval_opt, 			/* bool options */
            i ? &loopdata[1] : &loopdata[0],	/* sf1_loopdata */
            NULL	/* sf2_loopdata */
            );
    /*
       If we have an operand which is to be trimmed, the intersection on
       it should be valid. Otherwise ignore the errors from the above
       function.
    */
    if(!i && (bool_type != NMbool_split) && (!(1&*EMmsg)))
     {
      null_state = TRUE;
      break;
     }

    *EMmsg = EMS_S_Success;
    sts = OM_S_SUCCESS;

    /* Undo the destructive effects of the above function on the intersection
       data (such as edge reversal property), before storing it.
    */
    (void) NMfixIntAfterTpVal (&rc, i ? loc_volinters : loc_inters, FALSE);

   } /* for(i=0; i<2; i++) */



wrapup:

  if(nm_undone && (!IF_NULL_OBJID(actid.objid)))
   {
    IGRushort redo_opt = NULL;

    locsts = om$send(msg = message EMSdpr.EMredo(&rc, &redo_opt, 
	  &op[NmOpIdx].env, NULL, NULL, NULL), 
          targetid = actid.objid, targetos = actid.osnum);
    nm_undone = FALSE;
   }

  /* In case of a problem, try the intersection again with more care.
  */
  if(!(1&*EMmsg&sts))
   {
    if(double_chk) null_state = TRUE;
    else
     {
      double_chk = TRUE;
      boolopt |= EMSsfbool_opt_doublecheck;

      /* Do housekeeping and restart.
      */
      if(loc_inters)
       {
        EMinters_data_free(&rc, loc_inters, MAXINT, NULL, NULL);
        EMinters_free(loc_inters, MAXINT);
        loc_inters = NULL;
       }

      if(loc_volinters)
       {
        EMinters_data_free(&rc, loc_volinters, MAXINT, NULL, NULL);
        EMinters_free(loc_volinters, MAXINT);
        loc_volinters = NULL;
       }

      for(i=0; i<2; i++)
       {
        if(loopdata[i].sfintloops_alloced)
         {
          EMsfintloops_data_free (tracedata[i].num_grps, 
                                  tracedata[i].num_subgrps_grp, 
				  loopdata[i].loop_sf, op[i].env.md_id.osnum);
          EMsfintloops_free(loopdata[i].loop_sf, loopdata[i].endedges, 
                            loopdata[i].intedpars, loopdata[i].sfpartolb);
          loopdata[i].sfintloops_alloced = FALSE;
         }
        EMsfinttrace_free (&rc, tracedata[i].num_grps, 
              	           tracedata[i].num_subgrps_grp,
   			   tracedata[i].num_elems_subgrp, tracedata[i].elems,
			   tracedata[i].subgrp_rev, tracedata[i].elem_rev, 
			   tracedata[i].grp_closed,tracedata[i].subgrp_closed);
       }

      if(nmnode && (nmnode != nmnodebuf)) om$dealloc(ptr = nmnode);
      if(all_nmnodes) om$dealloc(ptr = all_nmnodes);
      nmnode = NULL;
      all_nmnodes = NULL;
      goto begin;
     }
   }

  if(store || (recompute && null_state))
   {
    if(recompute)
     {
      IGRint		i, j;
      OMuint		count = 0;
      OM_S_CHANSELECT	to_children;
      struct GRid	nmGRid;
      IGRushort ssiopt = NMssiact_EraseFlps | NMssiact_DeactTopology |
		                 NMssiact_EraseVtx, nmprop;
      
      EMmake_chanselect(NDchildren_children, &to_children);

      /* Unevaluate each NM tree dependent upon me (if it has not been already
	 done). This needs to happen before my instance data is updated
 	 to the new intersection and the old data is lost.
      */
      locsts = om$get_channel_count(object = me, p_chanselect = &to_children, 
            count = &count);
      if(!(1&locsts)) goto finish;
      if(count > StaticBuf)
	nmnode = (OM_S_OBJECT_LINKAGE *) om$malloc(size = count *
			sizeof(OM_S_OBJECT_LINKAGE));
      else nmnode = nmnodebuf;
      EMerr_hndlr(!nmnode, rc, EMS_E_NoDynamicMemory, finish);
      locsts = om$get_channel_objects(object = me, p_chanselect = &to_children,
	    list = nmnode, size = count, count = &count);
      if(!(1&locsts)) goto finish;

      for(i=0; i<count; i++)
       {
	if(!EFisAncestryValid(&rc, nmnode[i].S_objid, nmnode[i].osnum, 
	    OPP_NMnonmanigm_class_id, FALSE)) continue;
	
	nmGRid.objid = nmnode[i].S_objid;
	nmGRid.osnum = nmnode[i].osnum;
	locsts = om$send(msg = message NMnonmanigm.NMprop(&rc, NMprop_Get, 
	      &nmprop), targetid = nmGRid.objid, targetos = nmGRid.osnum);
	if(!(1&locsts&rc)) goto finish;
	if(nmprop & NMgm_Unevaluated) continue;
	
	if(all_nmnodes) om$dealloc(ptr = all_nmnodes);
	all_nmnodes = NULL;
	num_all_nmnodes = 0;
	ndbufsize = 0;
	locsts = NMget_node(&rc, &nmGRid, NULL, NULL, &all_nmnodes, 
	      &num_all_nmnodes, &ndbufsize, NULL, NMgetnode_All);
	if(!(1&rc&locsts)) goto finish;
	
	for(j=num_all_nmnodes-1; j>=0; j--)
	 {
          locsts = om$send(msg = message NMnonmanigm.NMSSI_action(&rc, 
                ssiopt, construct->env_info, NULL), 
	        targetid = all_nmnodes[j].objid, 
		targetos = all_nmnodes[j].osnum);
         }

       } /* for(i=0; i<count; i++) */

      locsts = om$send(msg = message NMinters.NMdelete_inters(&rc,TRUE, FALSE),
            targetid = my_id);
      if(!(1&rc&locsts)) goto finish;

     } /* if(recompute) */

    if(null_state)
     {
      if(recompute)
       {
        ex$message(msgnumb = NM_I_RecompFailedNullNode)
        sleep(3);
        *EMmsg = EMS_I_NoIntersection;
        sts = OM_S_SUCCESS;
       }
     }
    else if(store)
     {
      BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);
      locsts = om$send(msg = message NMinters.NMput_inters(&rc, loc_inters, 
            loc_volinters, op, &bool_type, &cht, NMputint_StoreOther), 
            targetid = my_id);
      EMerr_hndlr(!(1&rc&locsts), rc, EMS_E_Fail, finish);
     }

   } /* if(store || (recompute && null_state)) */


  if(inters) {*inters = loc_inters; loc_inters = NULL;}
  if(vol_inters) {*vol_inters = loc_volinters; loc_volinters = NULL;}
  if(nm_tracedata) *nm_tracedata = tracedata[0];
  if(vol_tracedata) *vol_tracedata = tracedata[1];


finish:
current_creator = NULL_OBJID;
if( (1&*EMmsg&sts) && (!(1&rc&locsts)))
 {
  *EMmsg = rc;
  sts = locsts;
 }

if(nm_undone && (!IF_NULL_OBJID(actid.objid)))
 {
  IGRushort redo_opt = NULL;

  locsts = om$send(msg = message EMSdpr.EMredo(&rc,&redo_opt, &op[NmOpIdx].env,
          NULL, NULL, NULL), 
          targetid = actid.objid, targetos = actid.osnum);
 }

if(loc_inters)
 {
  if(store) (void) NMset_object_data_to_null(loc_inters, TRUE, TRUE);
  EMinters_data_free(&rc, loc_inters, MAXINT, NULL, NULL);
  EMinters_free(loc_inters, MAXINT);
 }

if(loc_volinters)
 {
  if(store) (void) NMset_object_data_to_null(loc_volinters, TRUE, TRUE);
  EMinters_data_free(&rc, loc_volinters, MAXINT, NULL, NULL);
  EMinters_free(loc_volinters, MAXINT);
 }

for(i=0; i<2; i++)
 {
  if(loopdata[i].sfintloops_alloced)
   {
    /* Prevent all the edges from getting deleted along with the loops
    */
    if(loopdata[i].loop_sf)
     {
      OM_S_CHANSELECT to_edges;
      int l, m, n = 0;
      EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);

      for(l=0; l<tracedata[i].num_grps; l++)      
       for(m=0, n=0; m<tracedata[i].num_subgrps_grp[l]; m++, n+=2)
         locsts = om$send(msg = message Root.wild_disconnect(to_edges), 
               targetid = loopdata[i].loop_sf[l][n], 
               targetos = op[i].env.md_id.osnum);
     }

    EMsfintloops_data_free (tracedata[i].num_grps, 
     tracedata[i].num_subgrps_grp, loopdata[i].loop_sf, op[i].env.md_id.osnum);
    EMsfintloops_free(loopdata[i].loop_sf, loopdata[i].endedges, 
     loopdata[i].intedpars, loopdata[i].sfpartolb);
   }

   if(!(i ? vol_tracedata : nm_tracedata))
   EMsfinttrace_free (&rc, tracedata[i].num_grps, tracedata[i].num_subgrps_grp,
   tracedata[i].num_elems_subgrp, tracedata[i].elems, tracedata[i].subgrp_rev, 
   tracedata[i].elem_rev, tracedata[i].grp_closed, tracedata[i].subgrp_closed);
  
 }

if(nmnode && (nmnode != nmnodebuf)) om$dealloc(ptr = nmnode);
if(all_nmnodes) om$dealloc(ptr = all_nmnodes);

if(status_str) ex$message(msgnumb = NM_I_ClearStatusField)

if(OM_Gf_verbose_warning)
 {
  EMWRAPUP(*EMmsg, sts, "NMinters.NMintersect");
 }
return(sts);

}

end implementation NMinters;
