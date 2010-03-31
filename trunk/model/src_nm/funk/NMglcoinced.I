/*
This function will try to glue the coincedent edges on a surface to each
other. The surfaces to be checked for this purpose are obtained through the
in_ssi structure, namely the surfaces on which some edges were created
as a result of a nm operation. The modifications made during gluing are also
appended to the in_ssi.
*/
class implementation NMnonmani;

#include "OMmacros.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "nm.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "emsmacros.h"
#include "godef.h"
#include "bserr.h"
#include "bsparameters.h"

extern OMuword OPP_NMnonmanist_class_id;

from NMnonmanist import NMperform_stitch;

#define StaticBuf 10

IGRint NMglue_coincedent_edges(EMmsg, in_ssi, construct, options, status_str)
IGRlong *EMmsg;
struct NMgmSSI *in_ssi;
struct GRvg_construct *construct;
IGRushort options;
IGRchar *status_str;
{
 IGRlong		sts = OM_S_SUCCESS;
 struct GRmd_env	*env;
 GRspacenum		constos;
 GRobjid		shell_stch = NULL_OBJID;
 IGRint			i, num_sfs = 0;
 struct GRid		*sfids = NULL, sfidsbuf[StaticBuf];
 IGRchar		locstr[200];

 *EMmsg = EMS_S_Success;
 env = construct->env_info;
 constos = env->md_id.osnum;

 if(in_ssi->num_sfs > StaticBuf)
  {
   sfids = (struct GRid *) om$malloc(size = in_ssi->num_sfs * 
	    sizeof(struct GRid));
   EMerr_hndlr(!sfids, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }
 else sfids = sfidsbuf;

 for(i=0; i<in_ssi->num_sfs; i++)
  if(in_ssi->nmentities[i].num_flps || in_ssi->nmentities[i].num_edges ||
     in_ssi->nmentities[i].numedgesout)
   sfids[num_sfs++] = in_ssi->nmentities[i].sfid;

 EMerr_hndlr(!num_sfs, *EMmsg, EMS_I_Useless, wrapup);

 /* If we created some new edges on this surface which were completely
    or partially coincedent with some other new edge or an existing
    edge on the surface, then such mates need to be glued together.
    I do that by creating a shell NMnonmanist object and giving it this
    surface as the only component to be glued. Pass in the same ssi to
    append anything that stitching does to the ssi used here.
 */
 sts = om$construct(classid = OPP_NMnonmanist_class_id, 
       osnum = constos, p_objid = &shell_stch);
 if(!(1&sts)) goto wrapup;

 for(i=0; i<num_sfs; i++)
  {
   if(status_str) strcpy(locstr, status_str);
   sts = om$send(msg = message NMnonmanist.NMperform_stitch(EMmsg, 1, 
         &sfids[i], env, NULL, 0, NULL, in_ssi, NULL,
	 NMstch_GlueEdgesOnly | NMstch_TempCreator, 
	 construct, status_str ? locstr : NULL), targetid = shell_stch, 
	 senderid = NULL_OBJID, targetos = constos);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

wrapup:
if(sfids && (sfids != sfidsbuf)) om$dealloc(ptr = sfids);
if(!IF_NULL_OBJID(shell_stch))
 {
  om$send(msg = message Root.delete(TRUE), targetid = shell_stch, 
  senderid = NULL_OBJID, targetos = constos);
 }
EMWRAPUP(*EMmsg, sts, "NMglue_coincedent_edges");
return(sts);
}

end implementation NMnonmani;
