/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRcomponent_pass

Description
    This method is used to pass a message to a specific component of the
    drawing view.

Arguments
    *msg        IGRlong           return code
    pass_msg    OM_p_MESSAGE      message to be passed
    selector    IGRint            flag specifing type of component
                                     -  GR_DV_REFFILE
                                     -  GR_DV_TEXTNAME
                                     -  GR_DV_TEXTSCALE
                                     -  GR_DV_CS

Return Values
    MSSUCC   -  if success
    MSFAIL   -  if failure
\*/

class implementation GRdvattach;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "gocmacros.h"
#include "ref.h"
#include "refdef.h"
#include "OMmacros.h"
#include "OMminimum.h"

extern IGRint GRget_to_comp_chansel();

method GRcomponent_pass ( IGRlong *msg;
                          OM_p_MESSAGE pass_msg;
                          IGRint selector)
{
    IGRlong           om_msg;
    IGRint            i;
    IGRint            count;
    IGRint            tsel;
    OM_S_CHANSELECT   chansel;
    struct GRid       go_id;

    *msg = MSSUCC;

    GRget_to_comp_chansel(&chansel);

    om_msg = om$send ( msg = message GRowner.GRget_number_components 
                                            (msg, &count), 
                       targetid = my_id);

    for (i=count -1; i >= 0; --i) 
    {
        om_msg = om$get_objid_at_index ( osnum = OM_Gw_current_OS, 
                                         objid = my_id,
                                         p_chanselect = &chansel,
                                         index = i,
                                         objidaddr = &go_id.objid,
                                         osnumaddr = &go_id.osnum);
        if (om_msg & 1) 
        {
            GRdvget_comp_type (msg, &go_id, &tsel);

            if (*msg & 1) 
            {
                if (tsel & selector) 
                {
                    /*
                     *  If the object is in the selector mask then pass it the
                     *  message.
                     */         
                    om_msg = om$send ( msg = pass_msg,
                                       targetid = go_id.objid,
                                       targetos = go_id.osnum);
                }
            }
        }
    }

    return(om_msg);
}

/*
 *  Declare the classid of the components of the drawing view.
 */
IGRint GRdvget_comp_type (msg, go_id, selector)
    IGRlong        *msg;
    struct GRid    *go_id;
    IGRint         *selector;
{
    IGRlong           om_msg;
    GRclassid         classid;
    static OMuword    GRreffile_class_id = OM_K_CLASS_NOT_DEFINED;
    static OMuword    GRdvcs_class_id = OM_K_CLASS_NOT_DEFINED;
    static GRclassid  GRdvtext_class_id = OM_K_CLASS_NOT_DEFINED;
    static GRclassid  GR3dtext_class_id = OM_K_CLASS_NOT_DEFINED;

    *msg = MSSUCC;

    if (GRreffile_class_id == OM_K_CLASS_NOT_DEFINED) 
    {
        om$get_classid (classname = "GRreffile", 
                        p_classid = &GRreffile_class_id);
    }

    if (GRdvcs_class_id == OM_K_CLASS_NOT_DEFINED) 
    {
        om$get_classid (classname = "GRdvcs",
                        p_classid = &GRdvcs_class_id);
    }

    if (GR3dtext_class_id == OM_K_CLASS_NOT_DEFINED) 
    {
        om$get_classid (classname = "GR3dtext",
                        p_classid = &GR3dtext_class_id);
    }

    if (GRdvtext_class_id == OM_K_CLASS_NOT_DEFINED) 
    {
        om$get_classid (classname = "GRdvtext",
                        p_classid = &GRdvtext_class_id);
    }

    om_msg = om$get_classid ( osnum = go_id->osnum, 
                              objid = go_id->objid,
                              p_classid = &classid);

    if (om_msg & 1) 
    {
        if ( ! (*selector = (classid == GRreffile_class_id) ? GR_DV_REFFILE :
                            (classid == GRdvcs_class_id)   ?  GR_DV_CS :
                            (classid == GR3dtext_class_id) ?  GR_DV_TEXTNAME :
                            (classid == GRdvtext_class_id) ?  GR_DV_TEXTSCALE : 
                             0 ) )
        {
            *msg = MSFAIL;
        }
   }
   return(om_msg);
}

/*\
Name
    GRcomponent_pass_fun

Description
    This function is used to pass a message to a specific component of the
    drawing view.  The function is used to avoid formating a message
    structure.

Arguments
    *msg           IGRlong           return code
    pass_msg       OM_p_MESSAGE      message to be passed
    selector       IGRint            flag specifing type of component
                                        -  GR_DV_REFFILE
                                        -  GR_DV_TEXTNAME
                                        -  GR_DV_TEXTSCALE
                                        -  GR_DV_CS
    dv_objid       GRobjid           drawing view object id
    dv_osnum       GRspacenum        drawing view osnum

Return Values
    MSSUCC   -  if success
    MSFAIL   -  if failure
\*/
IGRint GRcomponent_pass_fun (msg, pass_msg, selector, dv_objid, dv_osnum)
    IGRlong           *msg;
    OM_p_MESSAGE      pass_msg;
    IGRint            selector;
    GRobjid           dv_objid;
    GRspacenum        dv_osnum;
{
    IGRlong           om_msg;

    *msg = MSSUCC;
    om_msg = om$send (msg = message GRdrawview.GRcomponent_pass ( msg,
                                                                  pass_msg, 
                                                                  selector),
                      senderid = NULL_OBJID, 
                      targetos = dv_osnum, 
                      targetid = dv_objid);

    return(om_msg);
}
end implementation GRdvattach;
