/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRdisyourself

Description
    This method sets up display for the components of a drawing sheet.
    *msg         IGRlong        completion code:
    *mx_type     IGRshort       type of matrix 
    matrix       IGRmatrix      environment transformation matrix
    *mode        GRdpmode       the display mode 
    *alt_symb    struct IGRaltdisplay 
    *sp_info     struct DP_information
    range_key    OM_p_KEY_DESC  range of the grahic object

Return Values
    MSSUCC - successful completion
    MSFAIL - failure of routine
 
History
    Gray Winn   08/24/88    Creation Date
\*/

class implementation GRdsborder;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "gocmacros.h"
#include "ref.h"
#include "refdef.h"
#include "OMmacros.h"
#include "godef.h"
#include "detail.h"

extern IGRint GRget_to_owner_info();

method GRdisyourself ( IGRlong *msg; 
                       IGRshort *mx_type; 
                       IGRmatrix matrix; 
                       enum GRdpmode *mode;
                       struct IGRaltdisplay *alt_symb; 
                       struct DP_information *sp_info;
                       OM_p_KEY_DESC range_key )
{
    IGRlong           om_msg;
    IGRint            count;
    IGRint            found;
    IGRint            i;
    OM_S_CHANSELECT   chansel;
    GRclassid         classid;
    GRclassid         ds_classid;
    GRobjid           objid;
    struct GRid       own_id;
    struct GRmd_env   mod_env;
    struct GRvg_construct         const_list;
    struct GRdrawsheet_class_attr ds_class_attr;

    GRget_to_owner_info(&chansel, OM_Gw_current_OS, my_id, &count);

    om$get_classid ( classname = "GRdrawsheet", 
                     p_classid = &ds_classid );

    found = FALSE;

    for (i=0; i < count; ++i) 
    {
        om$get_objid_at_index ( osnum = OM_Gw_current_OS, 
                                objid = my_id, 
                                p_chanselect = &chansel, 
                                index = i,
                                objidaddr = &own_id.objid, 
                                osnumaddr = &own_id.osnum );

        om$get_classid ( osnum = own_id.osnum, 
                         objid = own_id.objid,
                         p_classid = &classid );

        if (classid == ds_classid) 
        {
            found = TRUE;
            break;
        }
    }

    if (!found) 
    {
        ds_class_attr.db_id.osnum = OM_Gw_current_OS;
        ds_class_attr.db_id.objid = my_id;
        mod_env.md_id.osnum = OM_Gw_current_OS;
        mod_env.md_id.objid = NULL_OBJID;
        MAidmx (msg, mod_env.md_env.matrix);
        mod_env.md_env.matrix_type = MAIDMX;
        const_list.msg = msg;
        const_list.newflag = FALSE;
        const_list.env_info = &mod_env;
        const_list.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
        const_list.geometry = NULL;
        const_list.display = NULL;
        const_list.level = NULL;
        const_list.class_attr = (IGRchar *)&ds_class_attr;
        const_list.name = NULL;
        om$construct ( osnum = OM_Gw_current_OS, 
                       classname = "GRdrawsheet", 
                       p_objid = &objid,
                       msg = message GRgraphics.GRconstruct( &const_list ) );
    }

    om_msg = om$send ( mode = OM_e_wrt_message,
                       msg = message GRowner.GRdisyourself ( msg, 
                                                             mx_type, 
                                                             matrix,
                                                             mode,  
                                                             alt_symb,
                                                             sp_info,
                                                             range_key ),
                       targetid = my_id);

    if ( !(om_msg & 1) ) om_msg = OM_W_ABORT;

    return (om_msg);
}   
end implementation GRdsborder;
