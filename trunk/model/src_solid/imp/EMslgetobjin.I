/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsolid;

#include "EMS.h"
#include "godef.h"
#include "EMSerrordef.h"
# include "msdef.h"
#include "msmacros.h"
#include "emsclasses.h"
#include "ECmsg.h"

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
  IGRchar myclassname[OM_K_MAXCLASS_LEN], myinfo[30];
  IGRlong sts = OM_S_SUCCESS;

  *msg = MSSUCC;

  sts = om$get_classname(objid = my_id, classname = myclassname);
  if(!(1&sts)) goto wrapup;
  
  ex$message(msgname = myclassname, buff = myinfo)

  if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
   {
    ex$message(msgnumb = EMS_I_Associative, buff = info->type)
    strcat(info->type, " ");
   }
  else
    info->type[0] = '\0';

  strcat(info->type, myinfo);

wrapup:
    return(sts);
}

end implementation EMSsolid;


