/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
class implementation EMScompsurf;

#include "emsdef.h"
#include "EMSopt.h"

extern OMuword OPP_EMSsubbs_class_id;

void EFgetcomponents(EMmsg, sender_id, target_id, target_os, comp_count,
                     comp_list) 
IGRlong     *EMmsg;
GRobjid     sender_id;
GRobjid     target_id;
OMuword     target_os;
IGRint      *comp_count;
struct GRid **comp_list;
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  IGRboolean      EFisAncestryValid(), single=FALSE;

  *EMmsg = EMS_S_Success;

  if (EFisAncestryValid(EMmsg, target_id, target_os,
                        OPP_EMSsubbs_class_id, FALSE))
  {
    /*Single surface.*/
    single = TRUE;
    *comp_count = 1;
  }                        
  else
  {
    OM_stat = om$send(msg = message GRowner.GRget_number_components(EMmsg,
                            comp_count),
                      senderid = sender_id,
                      targetid = target_id,
                      targetos = target_os);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
    if (! *comp_count) goto wrapup;
  }

  *comp_list = (struct GRid *) om$malloc
               (size = *comp_count * sizeof(struct GRid));
  if (! *comp_list) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

  if (single)
  {
    (*comp_list)[0].objid = target_id;
    (*comp_list)[0].osnum = target_os;
  }
  else
  {
    /*KLUDGE ALERT!!!!*/
    /*The environment is a parameter in the GRget_components message but, 
     * according to the author, it is not used and will never be used.
     * So, to avoid having to pass an unneeded parameter, I pass a NULL for
     * the display environment.  If the author of GRget_components is
     * incorrect and the environment is used, then it crash.
     */
    OM_stat = om$send(msg = message GRowner.GRget_components(EMmsg,
                            NULL, *comp_list, *comp_count, comp_count,
                            0, MAXINT),
                      senderid = sender_id,
                      targetid = target_id,
                      targetos = target_os);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EFgetcomponents")
    return;
}
end implementation EMScompsurf;
