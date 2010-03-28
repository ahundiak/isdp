/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "dpdef.h"
#include "dp.h"
#include "exdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "lcdef.h"


LCobj_project (event, display_flag, is_bore, check_for_set, mod)
struct GRevent  *event;
IGRint          display_flag;
IGRboolean      is_bore;
IGRboolean      check_for_set;
struct GRmd_env *mod;
{
    IGRint  ret_code = 1;
    OMuword classid_to_check;
    IGRint  sts;
    
    if (check_for_set) {
        sts = om$get_classid (
                    objid = event->located_object[0].located_obj.objid,
                    osnum = event->located_object[0].located_obj.osnum,
                    p_classid = &classid_to_check);
        if (! (1&sts)) {
            goto WRAPUP;
        }

        sts = om$is_ancestry_valid (subclassid = classid_to_check,
                                    superclassname = "GRgrset");
        if (sts == OM_S_SUCCESS) {

        /*
         *  The object is a subclass of GRgrset so it should not
         *  be sent a project message.
         *  These objects are usually the result of fence operations.
         */
            goto WRAPUP;
        }
    }
    if (! (display_flag & NO_PROJ_ACCEPT_POINT)) {
        if (! (display_flag & ELEM_HILIGHT) ) {
            ret_code = LCget_parms (event->event.button.x, event->event.button.y,
                         event->event.button.z, LC_APPARENT,
                         event->located_object[0].located_obj.objid,
                         event->located_object[0].located_obj.osnum,
                         event->event.button.objid,
                         event->event.button.osnum,
                         event->located_object[0].proj_pnt,
                         &event->located_object[0].geom_parms,
                         mod->md_env.matrix_type, mod->md_env.matrix);
        }
        else if (is_bore) {
            ret_code = LCget_parms (event->event.button.x, event->event.button.y,
                         event->event.button.z, LC_LNPROJECT,
                         event->located_object[0].located_obj.objid,
                         event->located_object[0].located_obj.osnum,
                         event->event.button.objid,
                         event->event.button.osnum,
                         event->located_object[0].proj_pnt,
                         &event->located_object[0].geom_parms,
                         mod->md_env.matrix_type, mod->md_env.matrix);
        }
        else {
            ret_code = LCget_parms (event->event.button.x, event->event.button.y,
                         event->event.button.z, LC_LNPROJECT,
                         event->located_object[0].located_obj.objid,
                         event->located_object[0].located_obj.osnum,
                         event->event.button.objid,
                         event->event.button.osnum,
                         event->located_object[0].proj_pnt,
                         &event->located_object[0].geom_parms,
                         mod->md_env.matrix_type, mod->md_env.matrix);
        }
    }
WRAPUP:
    return (ret_code);
}
