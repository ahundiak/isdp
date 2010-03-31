class implementation NMnonmanigm;

#include "NMmsg.h"
#include "msmacros.h"

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 IGRchar junk[54];

 *msg = EMS_S_Success;
 if( (ME.NMnonmanigm->bool_type == NMbool_union) ||
     (ME.NMnonmanigm->bool_type == NMbool_intersect))
  ex$message(msgnumb = NM_I_TrimAndGlueState, buff = info->type)

 else if(ME.NMnonmanigm->bool_type == NMbool_split)
  ex$message(msgnumb = NM_I_InterAndGlueState, buff = info->type)

 else return(OM_E_ABORT);

 if(ME.NMnonmanigm->nmprops & NMgm_NullState)
  {
   ex$message(msgnumb = NM_I_NullState, buff = junk);
   strcat(info->type, junk);
  }

 return(OM_S_SUCCESS);
}

end implementation NMnonmanigm;


