/*
Name

    EFcreate_mscs_pointers

Abstract

        This function creates model space counterparts (MSC) and/or pointers
    for the specified object depending on the object's class and what
    options are specified.

Synopsis

         Type                    Name         I/O        Description
 ---------------------- --------------------- --- -------------------------
 IGRlong                *EMmsg                 O  The return code.
 struct GRid            *input_obj             I  The object id and osnum
                                                  of an object that for
                                                  which MSCs or pointers
                                                  should be created.
 struct GRfunction_info *user_info             I  User information; it
                                                  contains an options
                                                  bitmask indicating
                                                  whether MSCs or pointers
                                                  or both should be
                                                  created.
Description

        This function determines the class of the input object.  If the
    options bitmask indicates MSCs are to be created and the input object
    is subclassed from EMSsubbs, an MSC is created for each of the
    surface's edges (including graphics edges) which does not already have
    one.  If the options bitmask indicates pointers are to be created and
    the input object is subclassed from EMScompsurf, EMSagrp or ACconst,
    pointers will be created for each of the input object's components that
    are subclassed from EMSsubbs and, if any of the components are owner
    objects, it creates pointers for them on down to the lowest component.

Keywords

    function

History
         
    06/16/93 : WBC : Creation Date.
    08/30/93 : WBC : Allocated memory for the graphics edges before the call
                     to EMShelper.EMget_the_edges.
    06/16/94 : WBC : Always return TRUE so that a failure will not stop
                     an object space pass (TR119419323).
*/

class implementation EMSsurface;

#include "EMS.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "bserr.h"
#include "EMSprop.h"
#include "EMSxsection.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "igrtypedef.h"    /* needed for gocmacros.h */
#include "EMSopt.h"
#include "bs.h"
#include "EMSobjmgr.h"
#include "EMSobjmgrdef.h"
#include "madef.h"
#include "EMSlcdef.h"
#include "asbox.h"
#include "asmacros.h"
#include "EMptrmacros.h"
#include "EMSopt.h"

#define NUM_EDGE_TYPES  4

from EMSedge import EMget_props;
from EMSboundary import EMgetxyzobj;
from EMSsubbs import EMget_edges;
from EMShelper import EMget_the_edges;

extern GRclassid OPP_EMSsubbs_class_id;
extern GRclassid OPP_EMScompsurf_class_id;
extern GRclassid OPP_EMSagrp_class_id;
extern GRclassid OPP_ACconst_class_id;
extern GRclassid OPP_GRcmpowner_class_id;


IGRint EFcreate_mscs_pointers(EMmsg, input_obj, user_info)

IGRlong                *EMmsg; 
struct GRid            *input_obj;
struct GRfunction_info *user_info;

{
    IGRlong                     EFeligible_ems_pointers_owner();

    IGRdouble                   z_vector[3];
    OM_S_CHANSELECT	        to_helpers_chan,
                                common_edge_chan;
    IGRlong                     OM_stat;
    OMuint                      num_cmpnts;
    IGRint                      array_size,
                                array_num_edges[NUM_EDGE_TYPES],
                                index1,
                                index2,
                                options,
                                always_create_ptr,
                                make_ptrs;
    struct GRid                *edge_ptr_array[NUM_EDGE_TYPES],
                               *edges,
                               *graloop_edges,
                               *hrzloop_edges,
                               *cusploop_edges;
    GRobjid                     mscobj;
    OMuword                     classid;
    IGRboolean                  create_msc;
    IGRushort                   edprops;

    OM_stat = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;
    options = *(IGRint *)user_info->info;
    edges = graloop_edges = hrzloop_edges = cusploop_edges = NULL;

    OM_stat = om$get_classid(osnum = input_obj->osnum,
                             objid = input_obj->objid,
                             p_classid = &classid);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    if ((options & EMS_CREATE_MSCS) &&
        (om$is_ancestry_valid(subclassid = classid,
                                   superclassid = OPP_EMSsubbs_class_id) ==
                                                            OM_S_SUCCESS))
    {
        /* get all the edges of the surface, including the graphics
         * edges, and create MSCs for the edges that do not already
         * have them
         */

        array_size = array_num_edges[0] = 0;

        OM_stat = om$send(msg = message EMSsubbs.EMget_edges(EMmsg,
                                              MAXINT, EMS_OPT_ALL,
                                              user_info->md_env, &edges,
                                              &array_size,
                                              &array_num_edges[0]),
                          senderid = NULL_OBJID,
                          targetid = input_obj->objid,
                          targetos = input_obj->osnum);

        EMerr_hndlr (!(1 & OM_stat & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

        OM_stat = EMmake_chanselect(EMSrequester_to_helpers,
                                    &to_helpers_chan);
        EMerr_hndlr (!(1 & OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

        /* initialize z-vector even though it's not used */

        z_vector[0] = 1.0;
        z_vector[1] = z_vector[2] = 0.0;
        array_num_edges[1] = array_num_edges[2] = array_num_edges[3] = 0;

        /* need to allocate memory before calling EMShelper.EMget_the_edges
         * since memory for 32 entries is expected to already be allocated by
         * these methods
         */

        graloop_edges = (struct GRid *) om$malloc(size = (IGRuint)
                                                  (32 * sizeof(struct GRid)));
        EMerr_hndlr (! graloop_edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

        hrzloop_edges = (struct GRid *) om$malloc(size = (IGRuint)
                                                  (32 * sizeof(struct GRid)));
        EMerr_hndlr (! hrzloop_edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

        cusploop_edges = (struct GRid *) om$malloc(size = (IGRuint)
                                                   (32 * sizeof(struct GRid)));
        EMerr_hndlr (! cusploop_edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

        OM_stat = om$send(msg = message EMShelper.EMget_the_edges(
                                                   EMmsg,
                                                   EMS_OPT_ALL_HORIZON |
                                                   EMS_OPT_GRALOOP |
                                                   EMS_OPT_CUSP,
                                                   z_vector,
                                                   &user_info->md_env->md_env,
                                                   &array_num_edges[1],
                                                   &array_num_edges[2],
                                                   &array_num_edges[3],
                                                   &graloop_edges,
                                                   &hrzloop_edges,
                                                   &cusploop_edges),
                          senderid = input_obj->objid,
                          targetos = input_obj->osnum,
                          p_chanselect = &to_helpers_chan);

        EMerr_hndlr (!(1 & OM_stat & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

        edge_ptr_array[0] = edges;
        edge_ptr_array[1] = graloop_edges;
        edge_ptr_array[2] = hrzloop_edges;
        edge_ptr_array[3] = cusploop_edges;

        OM_stat = EMmake_chanselect(EMSedge_to_common_edge, &common_edge_chan);
        EMerr_hndlr (!(1 & OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

        /* create MSCs for any of the edges that don't already have them */

        for (index1 = 0; index1 < NUM_EDGE_TYPES; index1++)
        {
            for (index2 = 0; index2 < array_num_edges[index1]; index2++)
            {
                /* if the edge does not have a common edge or it is a
                 * dominant edge, create an MSC for the edge if it doesn't
                 * already have one
                 */

                OM_stat = om$get_channel_count(osnum = edge_ptr_array[index1][index2].osnum,
                                               objid = edge_ptr_array[index1][index2].objid,
                                               p_chanselect = &common_edge_chan,
                                               count = &num_cmpnts);
                EMerr_hndlr (!(1 & OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

                if (num_cmpnts)
                {
                    OM_stat = om$send(msg = message EMSedge.EMget_props(EMmsg,
                                                                    &edprops),
                                      senderid = NULL_OBJID,
                                      targetid = edge_ptr_array[index1][index2].objid,
                                      targetos = edge_ptr_array[index1][index2].osnum);

                    EMerr_hndlr (!(1 & OM_stat & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

                    if (edprops & EMED_SUBORDINATE)
                        create_msc = FALSE;
                    else
                        create_msc = TRUE;
                }
                else
                    create_msc = TRUE;

                if (create_msc)
                {
                    OM_stat = om$send(msg = message EMSboundary.EMgetxyzobj(
                                                 EMmsg, NULL,
                                                 &user_info->md_env->md_env,
                                                 NULL, NULL, NULL, NULL,
                                                 input_obj->osnum, &mscobj),
                                      senderid = NULL_OBJID,
                                      targetid = edge_ptr_array[index1][index2].objid,
                                      targetos = edge_ptr_array[index1][index2].osnum);

                    EMerr_hndlr (!(1 & OM_stat & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);
                }
            }
        }
    }

    if (options & EMS_CREATE_POINTERS)
    {
        OM_stat = EFeligible_ems_pointers_owner(EMmsg, input_obj, &classid,
                                                &make_ptrs, &always_create_ptr);
        EMerr_hndlr (!(1 & OM_stat & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

        /* call a function that will create a pointer for components that are
         * subclassed from EMSsubbs; if a component is an owner object this
         * function will be called recursively to process the components of
         * that owner
         */

        if (make_ptrs)
            EFmake_pointers(EMmsg, input_obj, always_create_ptr);
    }

wrapup:

    if (edges)
    {
        om$dealloc(ptr = edges);
        edges = NULL;
    }

    if (graloop_edges)
    {
        om$dealloc(ptr = graloop_edges);
        graloop_edges = NULL;
    }

    if (hrzloop_edges)
    {
        om$dealloc(ptr = hrzloop_edges);
        hrzloop_edges = NULL;
    }

    if (cusploop_edges)
    {
        om$dealloc(ptr = cusploop_edges);
        cusploop_edges = NULL;
    }

    *EMmsg = EMS_S_Success;

    return(OM_S_SUCCESS);
}


/*
Name

    EFeligible_ems_pointers_owner

Abstract

        This function determines whether an object of the specified class
    should have EMSpointers created for its components, and whether all
    components should have EMSpointers or only the ones subclassed from
    EMSsubbs.


Synopsis

         Type                    Name         I/O        Description
 ---------------------- --------------------- --- -------------------------
 IGRlong                *EMmsg                 O  The return code.
 struct GRid            *owner_grid            I  The owner objid and osnum.
 OMuword                *owner_classid         I  The classid of the owner
                                                  object, if known; otherwise
                                                  a NULL pointer may be sent in.
 IGRint                 *make_ptrs             O  Flag indicating whether the
                                                  owners of the specified class
                                                  should have EMSpointers for
                                                  their components subclassed
                                                  from EMSsubbs.
 IGRint                 *all_components        O  Flag indicating if owners of
                                                  the specified class should
                                                  have EMSpointers for all their
                                                  components; only applicable
                                                  if make_ptrs is returned as
                                                  TRUE
Description

    If the class of the input object is subclassed from EMScompsurf, EMSagrp
    or ACconst, pointers should be created for each of the input object's
    components that are subclassed from EMSsubbs and, if any of the components
    are owner objects, it creates pointers for them on down to the lowest
    component.

Keywords

    function

History
         
    06/16/94 : WBC : Creation Date.
*/

IGRlong EFeligible_ems_pointers_owner(EMmsg, owner_grid, owner_classid,
                                      make_ptrs, all_components)

IGRlong     *EMmsg;
struct GRid *owner_grid;
OMuword     *owner_classid;
IGRint      *make_ptrs;
IGRint      *all_components;

{
    IGRlong         sts;
    OMuint          num_owners;
    OMuword         classid;
    OM_S_CHANSELECT to_owners_chan;

    sts = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;
    *make_ptrs = TRUE;
    *all_components = FALSE;

    if (owner_classid)
    {
        classid = *owner_classid;
    }
    else
    {
        sts = om$get_classid(objid = owner_grid->objid,
                             osnum = owner_grid->osnum,
                             p_classid = &classid);
        EMerr_hndlr (!(1 & sts), *EMmsg, EMS_E_OMerror, wrapup);
    }

    sts = EMmake_chanselect(GRconnector_to_owners, &to_owners_chan);
    EMerr_hndlr (!(1 & sts), *EMmsg, EMS_E_OMerror, wrapup);

    /* if this owner object is subclassed from EMScompsurf or ACconst,
     * see if it is owned, that is, see if this owner it the "topmost"
     * owner; if it is, create pointers for all of its components
     */

    if ((om$is_ancestry_valid(subclassid = classid,
                              superclassid = OPP_EMScompsurf_class_id) ==
                                                          OM_S_SUCCESS) ||
        (om$is_ancestry_valid(subclassid = classid,
                              superclassid = OPP_ACconst_class_id) ==
                                                            OM_S_SUCCESS))
    {
        sts = om$get_channel_count(osnum = owner_grid->osnum,
                                   objid = owner_grid->objid,
                                   p_chanselect = &to_owners_chan,
                                   count = &num_owners);
        EMerr_hndlr (!(1 & sts), *EMmsg, EMS_E_OMerror, wrapup);

        if (num_owners > 0)
            *make_ptrs = FALSE;  /* this element is not a "topmost" owner */
        else
            *all_components = FALSE;
    }
    else if (classid == OPP_EMSagrp_class_id)
        *all_components = TRUE;  /* create pointers for all components */
    else
        *make_ptrs = FALSE;  /* the input object is not subclassed from
                              * EMScompsurf, ACconst or EMSagrp so pointers
                              * should not be created for it
                              */
wrapup:

    return(sts);
}

end implementation EMSsurface;
