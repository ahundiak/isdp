class implementation NMnonmanitp;

#include "nddef.h"
#include "OMmacros.h"

extern OMuword OPP_NMnonmanitp_class_id;

IGRint NMcreate_nmtp(EMmsg, modelid, modelenv, nmtpid, created, options, construct)
IGRlong *EMmsg;
struct GRid *modelid;
struct GRmd_env *modelenv;
struct GRid *nmtpid;
IGRboolean *created;
IGRushort options;
struct GRvg_construct *construct;
{
 IGRlong 		sts = OM_S_SUCCESS;
 struct GRid		actid, *model_dep = NULL, locnmtpid;
 IGRint			num_modeldep = 0, i;
 IGRshort		action, grprops = NULL;
 IGRushort	initas_opt = EMS_no_const_assoc 
			| EMSinit_dont_store_recomp_info;
 struct EMSobject_info	nmtp_parent;
 struct GRid		nmtp_base;
 IGRboolean		nmtp_trans = TRUE;
  
 *EMmsg = EMS_S_Success;
 if(created) *created = FALSE;
 if(nmtpid) nmtpid->objid = NULL_OBJID;
 locnmtpid.objid = NULL_OBJID;

 /* Get the topmost model node.
 */
 sts = NMget_node(EMmsg, modelid, NULL, NULL, NULL, NULL, NULL, &actid, NULL);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Is there a NMnonmanitp object already dependent on the active id ?
    Following message being unknown, indicates absence of NMnonmanitp
    object.
 */
 sts = om$send(mode = OM_e_wrt_message, 
       msg = message NDnodein.NDget_objects(ND_CHILDREN | ND_IN_BUF, NULL, 
       NULL, &model_dep, 0, MAXINT, &num_modeldep), targetid = actid.objid, 
       targetos = actid.osnum, senderid = NULL_OBJID);
 if(sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
 if(!(1&sts)) goto wrapup;

 for(i=0; i<num_modeldep; i++)
  if(EFisAncestryValid(EMmsg, model_dep[i].objid, model_dep[i].osnum, 
     OPP_NMnonmanitp_class_id, TRUE))
   {
    if(nmtpid) *nmtpid = model_dep[i];
    if(created) *created = FALSE;
    goto wrapup;
   }

 /* If the call is just a query, exit at this point.
 */
 if(options & NMcrtnmtp_QueryOnly)
  {
   *EMmsg = EMS_I_Fail;
   goto wrapup;
  }

 /* No object exists. Create one and associate to the active model node.
 */
 sts = om$construct(osnum = construct->env_info->md_id.osnum, 
		    p_objid = &locnmtpid.objid, 
		    classid = OPP_NMnonmanitp_class_id);
 if(!(1&sts)) goto wrapup;
 locnmtpid.osnum = construct->env_info->md_id.osnum;

 grprops = GRNOT_IN_RTREE | GRIS_ASSOCIATIVE;
 action = 1;
 sts = om$send(msg = message GRgraphics.GRchgprops(EMmsg, &action, &grprops), 
       targetid = locnmtpid.objid, targetos = locnmtpid.osnum, 
       senderid = NULL_OBJID);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Associative the constructed object to the model.
 */
 nmtp_parent.grid = actid;
 nmtp_parent.env = *modelenv;
 nmtp_base = actid;
 nmtp_trans = TRUE;

 sts = om$send(msg = message NMassoctrans.NMinit_associative(EMmsg, 
       initas_opt, NMinitas_NoDuplicateParents, 1, &nmtp_parent, 1, 
       &nmtp_trans, &nmtp_base, NULL, NULL, NULL, construct), 
       targetid = locnmtpid.objid, targetos = locnmtpid.osnum, 
       senderid = NULL_OBJID);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(nmtpid) *nmtpid = locnmtpid;
 if(created) *created = TRUE;

wrapup:

if( (!(1&*EMmsg&sts)) && (!IF_NULL_OBJID(locnmtpid.objid)))
 {
  IGRlong locsts, locmsg;

  locsts = om$send(msg = message GRgraphics.GRdelete(&locmsg, construct->env_info),
	   targetid = locnmtpid.objid, targetos = locnmtpid.osnum, 
	   senderid = NULL_OBJID);
  if(nmtpid) nmtpid->objid = NULL_OBJID;
  if(created) *created = FALSE;
 }

EMWRAPUP(*EMmsg, sts, "NMcreate_nmtp");
return(sts);
}

end implementation NMnonmanitp;
