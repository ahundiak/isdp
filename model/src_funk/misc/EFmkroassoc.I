/*
Name

    EFmake_os_read_only_assoc

Abstract

        This function creates pointers (class EMSpointer) and model space
    counterparts (MSC) for elements in the current module's object space
    needed for it to support associativity if it is used later as a read
    only reference file.

Synopsis

         Type                    Name         I/O        Description
 ---------------------- --------------------- --- -------------------------
 IGRlong                *EMmsg                 O  The return code.
 IGRint                  options               I  Bitmask used to indicate
                                                  if pointers, model space
                                                  counterparts or both are
                                                  to be created.

Description

        This function creates pointers or MSCs or both, as indicated by the
    options argument, in the current module's object space.  A single object
    space pass is done to send the message GRfunction to the objects of the
    appropriate classes.  The GRfunction method will invoke a function that
    will create the MSCs and/or pointers based on the specified options and
    the class of the object.
        If the options argument indicates MSCs are to be created, the object
    space pass will send the message GRfunction to objects of class
    EMSsubbs and its subclasses.  An MSC will be created for each of the
    surface's non-subordinate edges (including graphic edges) that do not
    already have an MSC.
        If the options argument indicates pointers are to be created, the
    object space pass will send the message GRfunction to objects of class
    EMScompsurf, EMSagrp, ACconst and their subclasses.  Pointers are then
    created for the components of these objects.

Keywords

    function surface

History
         
    06/16/93 : WBC : Creation Date.

*/

class implementation EMSsurface;

#include "EMS.h"
#include "emsdef.h"
#include "OMminimum.h"
#include "igrtypedef.h"    /* needed for gocmacros.h */
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "gomacros.h"
#include "EMSopt.h"

#define  MAX_NUM_CLASSIDS  4

extern GRclassid OPP_EMSsurface_class_id;
extern GRclassid OPP_EMScompsurf_class_id;
extern GRclassid OPP_EMSagrp_class_id;
extern GRclassid OPP_ACconst_class_id;

from OMObjSpace import pass;


IGRint EFmake_os_read_only_assoc(EMmsg, options)

IGRlong     *EMmsg; 
IGRint       options;

{
    IGRint                      EFcreate_mscs_pointers();

    IGRlong                     OM_stat,
                                msg;
    IGRint                      classid_index = 0,
                                sts;
    struct GRmd_env             module_env;
    struct GRfunction_info      func_info;
    OM_S_CLASSLIST              classlist;
    OM_S_MESSAGE                mymessage;
    GRobjid                     osobj;
    GRspacenum                  cur_mod_osnum;
    OMuword                     classid_list[MAX_NUM_CLASSIDS];
    struct
    {
        IGRlong             *msg;
        IGRint              (*func_ptr)();
        IGRchar             *user_info;
    } arglist;

    OM_stat = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;

    sts = ex$get_cur_mod(osnum = &cur_mod_osnum);

    if (! (1 & sts))
    {
        *EMmsg = EMS_E_Fail;
        goto wrapup;
    }

    sts = om$osnum_to_oso_objid(osnum = cur_mod_osnum,
                                p_objid = &osobj);
    if (! (1 & sts))
    {
        *EMmsg = EMS_E_Fail;
        goto wrapup;
    }

    /* set up the list of class ids which specify to which objects the object
     * space pass will send its message
     */

    if (options & EMS_CREATE_MSCS)
        classid_list[classid_index++] = OPP_EMSsurface_class_id;

    if (options & EMS_CREATE_POINTERS)
    {
        classid_list[classid_index++] = OPP_EMScompsurf_class_id;
        classid_list[classid_index++] = OPP_EMSagrp_class_id;
        classid_list[classid_index++] = OPP_ACconst_class_id;
    }

    classlist.w_count = classid_index;
    classlist.w_flags = OM_CLST_subclass;
    classlist.p_classes = classid_list;

    sts = gr$get_module_env(buffer = &module_env);

    if (! (1 & sts))
    {
        *EMmsg = EMS_E_Fail;
        goto wrapup;
    }

    sts = go$build_user_function_buffer(buffer = &func_info,
                                        md_env = &module_env,
                                        pass_on = 0,
                                        your_info = &options);
    if (! (1 & sts))
    {
        *EMmsg = EMS_E_Fail;
        goto wrapup;
    }

    arglist.msg = &msg;
    arglist.func_ptr = EFcreate_mscs_pointers;
    arglist.user_info = (IGRchar *)&func_info;

    sts = om$make_message(classname = "GRgraphics",
                          methodname = "GRfunction",
                          size = sizeof(arglist),
                          p_arglist = &arglist,
                          p_msg = &mymessage);
    if (! (1 & sts))
    {
        *EMmsg = EMS_E_Fail;
        goto wrapup;
    }

    OM_stat = om$send(msg = message OMObjSpace.pass(&classlist,
                                                    OM_e_wrt_object,
                                                    &mymessage),
                      senderid = NULL_OBJID,
                      targetid = osobj,
                      targetos = cur_mod_osnum);

wrapup:

    return(OM_stat);
}

end implementation EMSsurface;
