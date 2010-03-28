/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRadd_components

Description
    This method is used to add a list of elements to an owner.
 
    *msg           IGRlong              completion code 
    *mod_env       struct GRmd_env      The current module environment
    *num_objects   IGRint               The number of objects
    objects[]      struct GRobj_env     The list of elements to be added.
    own_index[]    IGRint               An array of indexes for the owner's
                                        channel when connecting.
    go_index[]     IGRint               An array of indexes for the graphics
                                        object's channel when connecting. 

Notes
    The own_index and go_index arrays may be NULL.  If either is NULL
    then OM_K_MAXINT will be used.

    A component of a drawing view can not belong to another drawing
    view.  If the drawing view is asked to add a component it must
    first disconnect the component from all other drawing views.
 
Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.

History
    jhw   12/10/88 Disallow the addition of another drawing view.
    jhw   12/18/88 Allow addition of only one drawing view attachment.
\*/

class implementation GRdrawview;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "gocmacros.h"
#include "ref.h"
#include "refdef.h"
#include "OMmacros.h"

extern IGRint GRget_to_comp_info();
extern IGRint GRget_to_owner_chansel();

method GRadd_components ( IGRlong *msg; 
                          struct GRmd_env *mod_env;
                          IGRint *num_objects; 
                          struct GRobj_env objects[];
                          IGRint own_index[]; 
                          IGRint go_index[] )
{
    IGRlong           om_msg;
    IGRint            i,j,k;
    IGRint            count;
    GRclassid         classid;
    GRclassid         GRdrawview_class_id;
    GRclassid         GRdvattach_class_id;
    GRclassid         GRdrawsheet_class_id;
    GRclassid         GRdsborder_class_id;
    struct GRid       gr_id;
    OM_S_CHANSELECT   chansel;
    IGRboolean        dvattach_attached;

    om_msg = OM_S_SUCCESS;
    *msg = MSSUCC;

    GRget_to_comp_info( &chansel, OM_Gw_current_OS, my_id, &count );

    om$get_classid ( classname = "GRdrawview", 
                     p_classid = &GRdrawview_class_id);

    om$get_classid ( classname = "GRdvattach", 
                     p_classid = &GRdvattach_class_id);

    om$get_classid ( classname = "GRdrawsheet", 
                     p_classid = &GRdrawsheet_class_id);

    om$get_classid ( classname = "GRdsborder", 
                     p_classid = &GRdsborder_class_id);

    /*
     * Determine if a dvattach is already present.
     */
    dvattach_attached = FALSE;

    for (i=0; i<count; i++) 
    {
        om$get_objid_at_index ( object = me,
                                p_chanselect = &chansel,
                                index = i,
                                objidaddr = &gr_id.objid,
                                osnumaddr = &gr_id.osnum);
        if (om_msg & 1) {
            om$get_classid ( objid = gr_id.objid,
                             osnum = gr_id.osnum, 
                             p_classid = &classid );

            if ( classid == GRdvattach_class_id ) {
                dvattach_attached = TRUE;
                break;
            }
        }
    }

    GRget_to_owner_chansel( &chansel );

    for (i=0, k=0; i < *num_objects; ++i) {
        /*
         * Get the classid of the object.
         */
        om$get_classid ( osnum = objects[i].obj_id.osnum, 
                         objid = objects[i].obj_id.objid,
                         p_classid = &classid );
        /* 
         * If the object to be added is not a Drawing Sheet, Drawing Border or 
         * another drawing view, allow it on the objects list.
         */
        if ( (classid != GRdrawview_class_id)  &&
             (classid != GRdrawsheet_class_id) &&
             (classid != GRdsborder_class_id)  &&
             !((classid == GRdvattach_class_id) & dvattach_attached) ) 
        {
            if (k < i) objects[k] = objects[i];
            k++;

            om$get_channel_count ( objid = objects[k].obj_id.objid,
                                   osnum = objects[k].obj_id.osnum, 
                                   p_chanselect = &chansel,
                                   count = (OMuint *)&count);
            /*
             *  Loop for each owner of the component.
             */
            for (j=0; j < count; ++j) {
                om$get_objid_at_index ( objid = objects[k].obj_id.objid,
                                        osnum = objects[k].obj_id.osnum, 
                                        p_chanselect = &chansel,
                                        index = j, 
                                        objidaddr = &gr_id.objid, 
                                        osnumaddr = &gr_id.osnum );

                om$get_classid ( osnum = gr_id.osnum, 
                                 objid = gr_id.objid,
                                 p_classid = &classid );

                if ((classid == GRdrawview_class_id) ||
                    (classid == GRdrawsheet_class_id))
                {
                    if ((gr_id.objid != my_id) ||
                        (gr_id.osnum != OM_Gw_current_OS))
                    {
                        /*
                         *  Disconnect the component from the drawing view.
                         */
                        om_msg = om$send ( msg = message GRconnector.GRdisconn 
                                                            ( msg, &gr_id ), 
                                           targetid = objects[k].obj_id.objid,
                                           targetos = objects[k].obj_id.osnum);

                        break;   /* Object can only have one active owner. */
                    }
                }
            }
        }
    }

    if (k) {
        om_msg = om$send ( mode = OM_e_wrt_message, 
                           msg = message GRowner.GRadd_components ( msg, 
                                                                    mod_env,
                                                                    &k, 
                                                                    objects, 
                                                                    own_index, 
                                                                    go_index),
                           targetid = my_id);
    }

    return(om_msg);
}
end implementation GRdrawview;
