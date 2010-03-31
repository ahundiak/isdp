/* ###################   APOGEE COMPILED   ################## */
/************************************************************************
Description
    This function will create a composite curve from a loop.  The composite
    curve must already be constructed.  Model-space counterparts will be
    obtained for each of the loop's edges which will be used in creating
    the composite curve.  A graphics construct message will also be sent
    to the composite curve.


Function Name
    EFcreate_composite_curve_from_loop(EMmsg, options, compcvos, compcvid,
                                       loopos, loopid, loop_props,
                                       mdenv, const_list)

Arguments

        Type                 Name       I/O            Description
    ------------------- --------------- --- -----------------------------------
    IGRlong               *EMmsg         O  function return code
    IGRushort      options       I  options to be used when creating
                                            the model-space counterparts
    OMuword                compcvos      I  composite curve's object space 
    GRobjid                compcvid      I  composite curve's object id
    OMuword                loopos        I  object space containing the loop
    GRobjid                loopid        I  object id of the loop
    IGRushort     *loop_props    I  the loop's properties (optional)
    struct GRmd_env       *mdenv         I  module environment of the edge
    struct GRvg_construct *const_list    I  construction information for
                                            the composite curve (a NULL pointer
                                            may be sent if the composite curve
                                            has already been set a graphics
                                            construct message

History

    ??/??/?? : ??? : Creation
    01/08/94 : WBC : Adding components to the composite curve using GRrigidconn
                     instead of calling EMmakecomp because EMmakecomp checks
                     to make sure the component endpoints are with a certain
                     tolerance, but since this compsite curve is being created
                     from a loop, we can assume the loop represents a valid
                     composite curve.
*************************************************************************/

class implementation GRcompcurve;

#include "nddef.h"
#include "ndmacros.h"
#include "asmacros.h"
#include "asbox.h"
#include "EMSobjmgrdef.h"
#include "EMSprop.h"
#include "madef.h"
#include "exmacros.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "EMSerrordef.h"
#include "emsdef.h"
#include "EMSlcdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include <alloca.h> 

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSloop import EMget_props;
from EMSboundary import EMgetxyzobj;


IGRlong EFcreate_composite_curve_from_loop(EMmsg, options, compcvos, compcvid,
                                           loopos, loopid, loop_props,
                                           mdenv, const_list)

IGRlong               *EMmsg;      /* function return code                */
IGRushort      options;    /* options to be used when creating    */
                                   /* the model-space counterparts        */
OMuword                compcvos;   /* composite curve's object space      */ 
GRobjid                compcvid;   /* composite curve's object id         */
OMuword                loopos;     /* object space containing the loop    */
GRobjid                loopid;     /* object id of the loop               */
IGRushort     *loop_props; /* the loop's properties (optional)    */
struct GRmd_env       *mdenv;      /* module environment of the loop      */
struct GRvg_construct *const_list; /* construction information for        */
                                   /* the composite curve (a NULL pointer */
                                   /* may be sent if the composite curve  */
                                   /* has already been set a graphics     */
                                   /* construct message                   */
{
    IGRlong              status,
                         sizebuffer,
                         nbytes_ret,
                         temp_msg;
    IGRint               edgecount,
                         cvinx,
                         relinx,
                         i,
                         j,
                         valid_edgecount;
    OM_S_CHANSELECT      chan_to_comps;
    GRobjid              new_objid;
    IGRushort            lp_props,
                         lpreverse;
    struct GRmd_env      construct_env;
    struct GRid          compcv_grid,
                        *msc_ids;
    struct GRpost_info   post_info;

    *EMmsg = EMS_I_NotFound;
    status = OM_S_SUCCESS;
    msc_ids = NULL;

    status = EMmake_chanselect(EMSbd_owner_to_comps, &chan_to_comps);
    EMomerr_exit(status, wrapup);

    status = om$get_channel_count(objid = loopid,
                                  osnum = loopos,
                                  p_chanselect = &chan_to_comps,
                                  count = (OMuint *)&edgecount);
    EMomerr_exit(status, wrapup);

    /* Obtain the model-space counterparts for each individual edge */

    if (edgecount)
    {
        msc_ids = (struct GRid *) alloca(edgecount * sizeof(struct GRid));
        EMerr_hndlr(!msc_ids, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
    }
    else  /* no edges connected to this loop */
    {
        *EMmsg = EMS_E_Fail;
        goto wrapup;
    }

    /* getting the module environment info for the construction
     * environment; by calling gr$get_module_env it is being assumed
     * that we are constructing in the "active" object space;
     * this would have to be changed if we have user writeable
     * reference files
     */

    sizebuffer = sizeof(construct_env);
    gr$get_module_env(msg = &temp_msg,
                      sizbuf = &sizebuffer,
                      buffer = &construct_env,
                      nret = &nbytes_ret);

    construct_env.md_id.osnum = compcvos;
    construct_env.md_id.objid = NULL_OBJID;  /* don't put in R-tree */

    if (loop_props)
    {
        lp_props = *loop_props;
    }
    else  /* get the loop's properties */
    {
        status = om$send(msg = message EMSloop.EMget_props(EMmsg, &lp_props),
                         senderid = NULL_OBJID,
                         targetid = loopid,
                         targetos = loopos);
        EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
    }

    cvinx = 0;
    valid_edgecount = 0;
    lpreverse = lp_props & EMLP_REVERSED;

    for (i = 0, j = edgecount - 1; i < edgecount; i++, j--)
    {
        relinx = lpreverse ? j : i;

        status = om$send(msg = message EMSboundary.EMgetxyzobj(&temp_msg,
                              options | EMSlcopt_nodgnedge | EMSlcopt_nocommon,
                              &mdenv->md_env, NULL, NULL, NULL, NULL,
                              compcvos, &msc_ids[cvinx].objid),
                         senderid = loopid,
                         targetos = loopos,
                         p_chanselect = &chan_to_comps,
                         from = relinx,
                         to = relinx);
        EMomerr_exit (status, wrapup);
        EMerr_hndlr (EMSerror (temp_msg), *EMmsg, EMS_E_EdgeError, wrapup);

        if (temp_msg != EMS_I_DegenerateEdge)
        {
            msc_ids[cvinx].osnum = compcvos;
            valid_edgecount++;
            cvinx++;
        }
    }

    if (const_list)
    {
        /* Initialize the composite curve's graphic info */

        status = om$send(msg = message GRgraphics.GRconstruct(const_list),
                         senderid = NULL_OBJID,
                         targetid = compcvid,
                         targetos = compcvos);
        EMomerr_exit(status, wrapup);
        EMerr_hndlr(! (1 & *(const_list->msg)), *EMmsg, EMS_E_Fail, wrapup);
    }

    /* connect the model-space counterparts generated above
     * to the composite curve
     */

    compcv_grid.objid = compcvid;
    compcv_grid.osnum = compcvos;

    for (i = 0; i < valid_edgecount; i++)
    {
        status = om$send(msg = message GRconnector.GRrigidconn(&temp_msg,
                                                               &compcv_grid,
                                                               (IGRlong *) &i),
                         senderid = NULL_OBJID,
                         targetid = msc_ids[i].objid,
                         targetos = msc_ids[i].osnum);

        EMomerr_exit (status, wrapup);
        EMerr_hndlr (EMSerror (temp_msg), *EMmsg, EMS_E_EdgeError, wrapup);
    }

    /* post the abstract geometry of the composite curve */

    post_info.construct_flag = TRUE;

    status = om$send(msg = message GRvg.GRpostabsg(&temp_msg, mdenv,
                                                   &post_info, NULL,
                                                   &new_objid),
                     senderid = NULL_OBJID,
                     targetid = compcvid,
                     targetos = compcvos);

    EMomerr_exit (status, wrapup);
    EMerr_hndlr (EMSerror (temp_msg), *EMmsg, EMS_E_EdgeError, wrapup);

wrapup:

    return (status);
}
end implementation GRcompcurve;
