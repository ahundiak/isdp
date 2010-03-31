/* ###################   ANSI   COMPILED   ################## */
class implementation EMSassoc;

#include "OMmacros.h"
#include "parametric.h"
#include "matypemx.h"
#include "mamulmx.h"
#include "mainvmx.h"

IGRlong EFtransform_with_respect_to_cs(EMmsg, options, obj_GRid,
        recomp_info, md_env, parent_count, parent_list)
IGRlong *EMmsg;
IGRuint options;
struct GRid *obj_GRid;
IGRchar *recomp_info;
struct GRmd_env *md_env;
IGRint parent_count;
IGRchar *parent_list;
/*
 * This function transforms the entity obj_GRid based on the parents
 * that are passed through parent_list (expected to be a coordinate
 * system) and recomp_info.
 *
 * This is a support function for attachment of non-associative solids
 * to a coordinate system.
 * 
 * Creation : 01/11/91 : Prasad

	Sudha	06/01/93	modified to handle BSprototypes

 */
{
 IGRlong status;
 struct GRid *cs_GRid;
 IGRshort four = 4;
 IGRshort trans_mx_typ;
 struct ret_struct refdef;
 IGRdouble *mx;
 IGRmatrix inv_mx,trans_mx;
 OM_S_OBJID newobjid;

 status = OM_S_SUCCESS;

 *EMmsg = EMS_S_Success;
 cs_GRid = (struct GRid *)parent_list;

 status = om$send (msg = message NDnode.NDgive_structure(EMmsg,
                         &refdef, md_env),
                   senderid = NULL_OBJID,
                   targetid = cs_GRid->objid,
                   targetos = cs_GRid->osnum);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 mx = (IGRdouble *) recomp_info;

 MAinvmx(EMmsg,&four,mx, inv_mx);
 MAmulmx(EMmsg,&four,&four,&four,refdef.var.ref_st.t,inv_mx,trans_mx);
 MAtypemx(EMmsg, trans_mx,&trans_mx_typ);

 status = om$send (msg = message GRgraphics.GRxform(EMmsg, md_env,
                         (IGRshort *) &trans_mx_typ, trans_mx, &newobjid),
                   senderid = NULL_OBJID,
                   targetid = obj_GRid->objid,
                   targetos = obj_GRid->osnum);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 OM_BLOCK_MOVE(refdef.var.ref_st.t,mx,sizeof (IGRmatrix));

wrapup:
 EMWRAPUP(*EMmsg, status, "In EFtransform_with_respect_to_cserror");
 return (status);
}
end implementation EMSassoc;

