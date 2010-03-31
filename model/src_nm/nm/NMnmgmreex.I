/*
Assumption:
on the 'to_operands' channel, last object is the volume operand and the
remaining are non manifold operands.
*/
class implementation NMnonmanigm;

#include "emsmacros.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "NMmsg.h"
#include "msmacros.h"

#define StaticBuf 10

from NMinters import NMget_inters;

#ifndef DEBUG
#define DEBUG 0
#endif

method NMreexecute(IGRlong *EMmsg; struct GRvg_construct *construct;
		   unsigned short reex_options)
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 IGRint			numint = 0, i, j, num_parents = 0;
 struct EMSinters	*inters[4];
 IGRdouble		cht, tracetol;
 IGRshort		mattyp;
 IGRmatrix		mat;
 struct EMSsftracedata	tracedata[2];
 struct NMgmSSI		ssi;
 unsigned short	ssi_options;
 struct GRid		*nodes = NULL, my_GRid;
 IGRint			numnodes = 0, ndbufsize = 0;
 struct EMSobject_info  *inters_obj = NULL, *parents = NULL, 
			parentsbuf[StaticBuf], 
			intersbuf[StaticBuf];
 struct GRmd_env	locenv;
 IGRint			bytes_in, bytes_out;
 IGRboolean		issplit, nodes_obtained = FALSE;
 extern OM_S_OBJID	current_creator;
 IGRboolean		was_active = FALSE, null_state = TRUE;
 OM_S_CHANSELECT	to_children;
 IGRint			num_child, msgnumber;
 IGRchar		status_str[200], dot[2];

 *EMmsg = EMS_S_Success;
 NMinit_ssi(&ssi);
 for(i=0; i<4; i++) inters[i] = NULL;
 for(j=0; j<2; j++) NMinit_tracedata(&tracedata[j]);
 strcpy(dot, ".");

 was_active = (ME.NMnonmanigm->nmprops & NMgm_Active) ? TRUE : FALSE;

#if DEBUG
 fprintf(stderr, "** Recomputing NMnonmanigm node id %d\n", my_id);
#endif

 issplit = (ME.NMnonmanigm->bool_type == NMbool_split) ? TRUE : FALSE;


 if(issplit) msgnumber = NM_I_RecompInterAndGlue;
 else
  msgnumber = NM_I_RecompTrimAndGlue;

 ex$message(msgnumb = msgnumber, buff = status_str);
 strcat(status_str, dot);
 UI_status(status_str);

 if(IF_NULL_OBJID(construct->env_info->md_id.objid))
  {
   bytes_in = sizeof(struct GRmd_env);
   gr$get_module_env(msg = EMmsg, sizbuf = &bytes_in, buffer = &locenv, 
                     nret = &bytes_out);
   if(!(1&*EMmsg)) goto wrapup;
   construct->env_info = &locenv;
  }

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 /* Remove the feature loops created by the nodes above me, before
    recomputing myself. It is assumed that if this node is unevaluated, so
    is the entire tree.
 */
 if( (!(reex_options & NMreex_NoUneval)) && 
     (!(ME.NMnonmanigm->nmprops & NMgm_Unevaluated)))
  {
   sts = NMget_node(EMmsg, &my_GRid, NULL, NULL, &nodes, &numnodes, &ndbufsize,
	 NULL, NMgetnode_All);
   if(!(1&*EMmsg&sts)) goto wrapup;
   nodes_obtained = TRUE;

   for(i=numnodes-1; i>=0; i--)
    {
     ssi_options = NMssiact_EraseFlps | NMssiact_DeactTopology |
		     NMssiact_EraseVtx;
     sts = om$send(msg = message NMnonmanigm.NMSSI_action(EMmsg, ssi_options,
           construct->env_info, NULL), 
	   targetid = nodes[i].objid, targetos = nodes[i].osnum);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

  }


 /* Send a message to all pointers to translate and store the key, before
    deleting/recreating my topology.
 */
 sts = EMmake_chanselect(NDchildren_children, &to_children);
 if (!(1&sts)) goto wrapup;

 sts = om$get_channel_count(p_chanselect = &to_children,
                            object = me,
                            count = (OMuint *) &num_child);
 if (!(1&sts)) goto wrapup;
 for (i=0;i<num_child;i++)
  {
   sts = om$send (msg = message EMSpointerA.EMstore_key_from_id(EMmsg,
         NULL, NULL), p_chanselect = &to_children, from = i, to = i);
   if (sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
   if (!(1&sts&*EMmsg)) goto wrapup;
  }


 EMidmatrix(EMmsg, &mattyp, mat);

 parents = parentsbuf;
 sts = om$send(msg = message NMassoc.NMget_parent_info(EMmsg, &parents, 
       StaticBuf, &num_parents), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(num_parents > StaticBuf)
  inters_obj = (struct EMSobject_info *) om$malloc(size = num_parents * 
		sizeof(struct EMSobject_info));
 else inters_obj = intersbuf;
 EMerr_hndlr(!inters_obj, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 numint = 0;
 for(i=0; i<num_parents; i++)
  if(EFisAncestryValid(EMmsg, parents[i].grid.objid, parents[i].grid.osnum, 
     OPP_NMinters_class_id, FALSE))
   inters_obj[numint++] = parents[i];

 for(i=0; i<numint; i++)
  {
   strcat(status_str, dot);
   UI_status(status_str);

   sts = om$send(msg = message NMinters.NMget_inters(EMmsg, &inters[0], 
         &inters[1], NULL, NULL, NULL, &cht, NULL), 
         targetid = inters_obj[i].grid.objid, 
         targetos = inters_obj[i].grid.osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;

   /* Get the uptodate intersection edges on the nm operand (top edges if
      applicable), map them back on to the corresponding surface in the
      volume operand and generate a uptodate intersection list.
   */
   if(inters[0] && inters[1])
    {
     if(*EMmsg == EMS_I_Modified)
      {
       current_creator = my_id;
       sts = NMregenerate_inters(EMmsg, inters[0], inters[1], &inters[2], 
             &inters[3], cht, construct, &ssi);
       if(!(1&*EMmsg&sts)) goto wrapup;
      }
     else 
      {
       inters[3] = inters[1];
       inters[1] = NULL;
       inters[2] = inters[0];
       inters[0] = NULL;
      }
    }

   /* Trace the new intersections and create non manifold topology.
   */
   tracetol = 2*cht;
   if(inters[3])
    {
     EMsfinttrace (EMmsg, &mattyp, mat, inters[3], NULL, &tracetol,
                   &tracedata[0].num_grps, &tracedata[0].num_subgrps_grp, 
                   &tracedata[0].num_elems_subgrp, &tracedata[0].elems, 
                   &tracedata[0].subgrp_rev, &tracedata[0].elem_rev, 
                   &tracedata[0].grp_closed, &tracedata[0].subgrp_closed);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   
   if(issplit && inters[2])
    {
     EMsfinttrace (EMmsg, &mattyp, mat, inters[2], NULL, &tracetol,
                 &tracedata[1].num_grps, &tracedata[1].num_subgrps_grp, 
                 &tracedata[1].num_elems_subgrp, &tracedata[1].elems, 
                 &tracedata[1].subgrp_rev, &tracedata[1].elem_rev, 
                 &tracedata[1].grp_closed, &tracedata[1].subgrp_closed);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

   if(inters[3])
    {
     current_creator = my_id;
     sts = NMcreate_topology(EMmsg, inters[3], &tracedata[0], construct, 
           issplit ? NMcreatetp_NonOrientedInput : NULL, &ssi);
     if(!(1&*EMmsg&sts)) goto wrapup;
     null_state = FALSE;
    }

   if(issplit && inters[2])
    {
     current_creator = my_id;
     sts = NMcreate_topology(EMmsg, inters[2], &tracedata[1], construct, 
	   NMcreatetp_NmEdgesConnected | 
	   (issplit ? NMcreatetp_NonOrientedInput : NULL), &ssi);
     if(!(1&*EMmsg&sts)) goto wrapup;
     null_state = FALSE;
    }

   for(j=0; j<4; j++)
    if(inters[j])
     {
      (void) NMset_object_data_to_null(inters[j], TRUE, TRUE);
      EMinters_data_free(&rc, inters[j], MAXINT, NULL, NULL);
      EMinters_free(inters[j], MAXINT);
      inters[j] = NULL;
     }

   for(j=0; j<2; j++)
    {
     EMsfinttrace_free (&rc, tracedata[j].num_grps,
     tracedata[j].num_subgrps_grp, tracedata[j].num_elems_subgrp, 
     tracedata[j].elems, tracedata[j].subgrp_rev, tracedata[j].elem_rev, 
     tracedata[j].grp_closed, tracedata[j].subgrp_closed);
     NMinit_tracedata(&tracedata[j]);
    }

  } /* for(i=0; i<numint; i++) */

 ssi_options = NMssiact_RedrawAffectedSfs | NMssiact_DeleteTopology;
 sts = om$send(msg = message NMnonmanigm.NMSSI_action(EMmsg, ssi_options, 
       construct->env_info, NULL), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(!ssi.num_sfs)
  {
   ex$message(msgnumb = NM_I_NullState);
   sleep(3);
  }

 strcat(status_str, dot);
 UI_status(status_str);

 /* Check for edge coincedency on each affected surfaces.
 */
 current_creator = my_id;
 sts = NMglue_coincedent_edges(EMmsg, &ssi, construct, NULL, status_str);
 if(!(1&*EMmsg&sts)) goto wrapup;

 sts = om$send(msg = message NMnonmanigm.NMput_SSI(EMmsg, &ssi), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 ME.NMnonmanigm->nmprops &= ~NMgm_Unevaluated;

 if(null_state)
  ME.NMnonmanigm->nmprops |= NMgm_NullState;
 else
  ME.NMnonmanigm->nmprops &= (~NMgm_NullState);

 /* Send a message to all the pointers to translate and store the object
    id, after having posted the new topology.
 */
 for (i=0;i<num_child;i++)
  {
   sts = om$send (msg = message EMSpointerA.EMstore_id_from_key(EMmsg,
             NULL, NULL), p_chanselect = &to_children, from = i, to = i);
   if (sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
   if (!(1&sts&*EMmsg)) goto wrapup;
  }

 ssi_options = NMssiact_DrawFlps | NMssiact_DrawVtx;
 sts = om$send(msg = message NMnonmanigm.NMSSI_action(EMmsg, ssi_options, 
       construct->env_info, &ssi), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 


 /* Re-execute the nodes above me if so specified.
 */
 if(reex_options & NMreex_RecomputeAll)
  {
   unsigned short locoptions;
   
   locoptions = reex_options | NMreex_NoUneval;
   locoptions &= ~NMreex_RecomputeAll;
   if(!nodes_obtained)
    {
     sts = NMget_node(EMmsg, &my_GRid, NULL, NULL, &nodes, &numnodes, 
	  &ndbufsize, NULL, NMgetnode_All);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

   for(i=0; i<numnodes; i++)
    {
     if(IF_EQ_GRID(my_GRid, nodes[i])) continue;
     sts = om$send(msg = message NMnonmanigm.NMreexecute(EMmsg, construct, 
           locoptions), targetid = nodes[i].objid, 
           targetos = nodes[i].osnum);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
  }

wrapup:
current_creator = NULL_OBJID;
/* Set the active property to what it was in the begining.
*/
if(was_active) ME.NMnonmanigm->nmprops |= NMgm_Active;
else ME.NMnonmanigm->nmprops &= (~NMgm_Active);

if(nodes) om$dealloc(ptr = nodes);

if(inters_obj && (inters_obj != intersbuf)) om$dealloc(ptr = inters_obj);
if(parents && (parents != parentsbuf)) om$dealloc(ptr = parents);

 for(j=0; j<4; j++)
  if(inters[j])
   {
    (void) NMset_object_data_to_null(inters[j], TRUE, TRUE);
    EMinters_data_free(&rc, inters[j], MAXINT, NULL, NULL);
    EMinters_free(inters[j], MAXINT);
    inters[j] = NULL;
   }

 for(j=0; j<2; j++)
  {
   EMsfinttrace_free (&rc, tracedata[j].num_grps,
     tracedata[j].num_subgrps_grp, tracedata[j].num_elems_subgrp, 
     tracedata[j].elems, tracedata[j].subgrp_rev, tracedata[j].elem_rev, 
     tracedata[j].grp_closed, tracedata[j].subgrp_closed);
  }

 if(!(1&*EMmsg&sts))
  {
   IGRlong locsts, rc;

   ex$message(msgnumb = NM_I_RecompFailedNullNode)
   sleep(3);
   ssi_options = NMssiact_EraseFlps | NMssiact_DeactTopology |
	         NMssiact_EraseVtx;
   locsts = om$send(msg = message NMnonmanigm.NMSSI_action(&rc, ssi_options,
         construct->env_info, NULL), targetid = my_id);

   ssi_options = NMssiact_RedrawAffectedSfs | NMssiact_DeleteTopology;
   locsts = om$send(msg = message NMnonmanigm.NMSSI_action(&rc, ssi_options, 
         construct->env_info, NULL), targetid = my_id);
   ME.NMnonmanigm->nmprops &= ~NMgm_Unevaluated;
   ME.NMnonmanigm->nmprops |= NMgm_NullState;
  }

 NMfree_ssi(&ssi);

ex$message(msgnumb = NM_I_ClearStatusField)

EMWRAPUP(*EMmsg, sts, "NMnonmanigm.NMreexecute");
return(sts);
}

end implementation NMnonmanigm;
