class implementation NMnonmanist;

#include "NMmsg.h"
#include "msmacros.h"

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 IGRchar junk[54];

 *msg = EMS_S_Success;
 ex$message(msgnumb = NM_I_EdgeGlueState, buff = info->type)
 if(ME.NMnonmanigm->nmprops & NMgm_NullState)
  {
   ex$message(msgnumb = NM_I_NullState, buff = junk);
   strcat(info->type, junk);
  }

 return(OM_S_SUCCESS);
}

end implementation NMnonmanist;


