class implementation EMSdatpln;

#include <alloca.h>
#include "bsparameters.h"
#include "bserr.h"

%safe
#include <math.h>
%endsafe

from EMSdatplnmgr import EMget_datums, EMmanage_datum_entry;

/*
 * This function returns a reference plane which matches the orientation
 * indicated by refpln_mx. By default, if there is no match then the
 * routine will construct a plane and return the same.  This plane is
 * going to be constructed in the same object space as the module object
 * that is passed through md_env field.
 * The following options are supported:
 * EMS_OPT_DO_NOT_CREATE : Do not create the reference plane if one does
                           not exist matching the given orientation.
 * History
 * PP : Creation : 09/20/91
 */

IGRlong EFreturn_reference_plane (EMmsg, options, md_env, refpln_mxtyp,
                                  refpln_mx,pln_GRid)
IGRlong *EMmsg;
IGRuint options;
struct GRmd_env *md_env;
IGRshort *refpln_mxtyp;
IGRmatrix refpln_mx;
struct GRid *pln_GRid;
{
 IGRboolean found;
 IGRlong status, i;
 IGRlong msg_loc;
 IGRint datum_count;
 OMuword constr_os;
 IGRvector zdir;
 struct GRid mgr_GRid;
 struct GRid *datums_GRid = NULL;
 IGRdouble dotp, *req_z, vectol;
 
 status = OM_S_SUCCESS;
 *EMmsg = MSSUCC;

 BSEXTRACTPAR(&msg_loc,BSTOLLENVEC,vectol);
 pln_GRid->objid = NULL_OBJID;

 constr_os =  md_env->md_id.osnum;
 req_z = &refpln_mx[8];

 status = ems$get_datum_plane_mgr (msg = &msg_loc, 
                                   osnum = &constr_os,
                                   mgrid = &mgr_GRid.objid,
                                   mgros = &mgr_GRid.osnum);
 if (!(1&status)) goto wrapup;

 status = om$send (msg = message EMSdatplnmgr.EMget_datums (&msg_loc,
                         EMS_OPT_HIDDEN_DATUMS |
                         EMS_OPT_BASE_DATUMS,
                         &datum_count, NULL),
                   senderid = NULL_OBJID,
                   targetid = mgr_GRid.objid,
                   targetos = mgr_GRid.osnum);
 if (!(1&status&msg_loc)) goto wrapup;

 found = FALSE;

 if (datum_count)
 {
  datums_GRid = (struct GRid *) alloca(sizeof (struct GRid) * datum_count);
  if (!datums_GRid) 
  {
    *EMmsg = MANOMEMORY;
    goto wrapup;
  }

  status = om$send (msg = message EMSdatplnmgr.EMget_datums (&msg_loc,
                         EMS_OPT_HIDDEN_DATUMS |
                         EMS_OPT_BASE_DATUMS,
                         &datum_count, datums_GRid),
                     senderid = NULL_OBJID,
                   targetid = mgr_GRid.objid,
                   targetos = mgr_GRid.osnum);
  if (!(1&status&msg_loc)) goto wrapup;

  for (i=0;i<datum_count;i++)
  {
   status = om$send (msg = message EMSdatpln.EMget_pln_info(&msg_loc,
                           NULL, md_env, NULL, NULL, zdir, NULL, NULL),
                     senderid = NULL_OBJID,
                     targetid = datums_GRid[i].objid,
                     targetos = datums_GRid[i].osnum);
   if (!(1&status&msg_loc)) goto wrapup;


   dotp = req_z[0]*zdir[0] + req_z[1]*zdir[1] + req_z[2]*zdir[2];

   if (fabs (1 - fabs(dotp)) < vectol)
   {
    *pln_GRid = datums_GRid[i];
    return (OM_S_SUCCESS);
   }
  }
 }
/*
 * If we have reached here, then this means no existing reference plane
 * was found which matched the required z orientation. Create a new one.
 * Do not create a graphic handle since this would be a waste.
 */
 if (!(options & EMS_OPT_DO_NOT_CREATE))
 {
  pln_GRid->osnum = constr_os;
  status = om$construct (classid = OPP_EMSdatpln_class_id,
                         osnum = constr_os,
                         p_objid = &pln_GRid->objid,
                         msg = message EMSdatpln.EMput_pln_info(&msg_loc,
                               NULL, md_env, &refpln_mx[0], &refpln_mx[4],
                               &refpln_mx[8], &refpln_mx[12],
                               EMS_HIDDEN_REFERENCE_PLANE));
  if (!(1&status&msg_loc)) goto wrapup;

  status = om$send (msg = message 
                       EMSdatplnmgr.EMmanage_datum_entry(&msg_loc,
                       EMS_OPT_ADD,
                       pln_GRid->objid),
                    senderid = NULL_OBJID,
                    targetid = mgr_GRid.objid,
                    targetos = mgr_GRid.osnum);
  if (!(1&status&msg_loc)) goto wrapup;
 }

wrapup:
 if (!(1&status&msg_loc)) *EMmsg = MSFAIL;
 return (status);
}
end implementation EMSdatpln;

