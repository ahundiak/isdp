class implementation NMnonmanist;

#include "msdef.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msmacros.h"
#include "NMmsg.h"
#include "bserr.h"
#include "bsparameters.h"

#define StaticBuf 10

#ifndef DEBUG
#define DEBUG 0
#endif

method NMreexecute(IGRlong *EMmsg; struct GRvg_construct *construct;
		   unsigned short reex_options)
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 struct GRmd_env	locenv;
 IGRint			bytes_in, bytes_out, num_comps = 0, i;
 struct GRid		*nodes = NULL, my_GRid, *comps = NULL;
 extern OM_S_OBJID	current_creator;
 IGRint			numnodes = 0, ndbufsize = 0;
 IGRboolean		nodes_obtained = FALSE;
 unsigned short 	ssi_options = NULL; 
 IGRboolean		was_active = FALSE;
 OM_S_CHANSELECT	to_children;
 IGRint			num_child;
 IGRdouble		save_cht, save_lentol;
 IGRchar		status_str[200];

 *EMmsg = EMS_S_Success;
 was_active = (ME.NMnonmanigm->nmprops & NMgm_Active) ? TRUE : FALSE;
 BSEXTRACTPAR(&rc, BSTOLLENVEC, save_lentol);
 BSEXTRACTPAR(&rc, BSTOLCHRDHT, save_cht);

 BSchangepar(&rc, BSTOLLENVEC, ME.NMnonmanist->lentol);
 BSchangepar(&rc, BSTOLCHRDHT, ME.NMnonmanist->cht);

 ex$message(msgnumb = NM_I_RecompEdgeGlue);
 ex$message(msgnumb = NM_I_RecompEdgeGlue, buff = status_str);

#if DEBUG
 fprintf(stderr, "** Recomputing NMnonmanist node id %d\n", my_id);
#endif

 if(!construct->env_info)
  {
   construct->env_info = &locenv;
   construct->env_info->md_id.objid = NULL_OBJID;
  }

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
    deleting my topology.
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

 ssi_options = NMssiact_RedrawAffectedSfs | NMssiact_DeleteTopology;
 sts = om$send(msg = message NMnonmanigm.NMSSI_action(EMmsg, ssi_options, 
       construct->env_info, NULL), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 sts = om$send(msg = message NMassoctrans.NMget_trans_info(EMmsg, NULL, 
	&comps, &num_comps), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 current_creator = my_id;
 sts = om$send(msg = message NMnonmanist.NMperform_stitch(EMmsg, num_comps, 
	comps, construct->env_info, NULL, 0, NULL, NULL, NULL, NULL, construct, 
	status_str), 
	targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 ME.NMnonmanigm->nmprops &= ~NMgm_Unevaluated;

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
BSchangepar(&rc, BSTOLLENVEC, save_lentol);
BSchangepar(&rc, BSTOLCHRDHT, save_cht);

current_creator = NULL_OBJID;
/* Set the active property to what it was in the begining.
*/
if(was_active) ME.NMnonmanigm->nmprops |= NMgm_Active;
else ME.NMnonmanigm->nmprops &= (~NMgm_Active);

if(comps) om$dealloc(ptr = comps);
if(nodes) om$dealloc(ptr = nodes);

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

ex$message(msgnumb = NM_I_ClearStatusField)

EMWRAPUP(*EMmsg, sts, "NMnonmanigmst.NMreexecute");
return(sts);
}
end implementation NMnonmanist;
