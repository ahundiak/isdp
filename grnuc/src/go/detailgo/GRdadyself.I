/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRdisyourself

Description
    This method sets up display for the components of a drawing view.

    *msg         IGRlong        completion code:
    *mx_type     IGRshort       type of matrix 
    matrix       IGRmatrix      environment transformation matrix
    *mode        GRdpmode       the display mode 
    *alt_symb    struct IGRaltdisplay 
    *sp_info     struct DP_information
    range_key    OM_p_KEY_DESC  range of the grahic object

Notes 
    It is necessary to respond to the GRhhdo, GRheo, and GRhdo modes
    even if the object is not displayable.

Return Values
    MSSUCC - successful completion
    MSFAIL - failure of routine
 
History
    Gray Winn   06/20/88    Creation Date
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
#include "godef.h"
#include "detail.h"

#define HIGHLIGHT       0x1
#define NOT_HIGHLIGHT   0x2

extern IGRint   GRget_to_comp_chansel();
extern IGRint   GRget_to_owner_info();

method GRdisyourself ( IGRlong *msg;
                       IGRshort *mx_type; 
                       IGRmatrix matrix;
                       enum GRdpmode *mode;
                       struct IGRaltdisplay *alt_symb; 
                       struct DP_information *sp_info;
                       OM_p_KEY_DESC range_key)
{
    IGRlong           om_msg;
    IGRint            flag=0; /* initialized to check out compiler warnings */
    IGRint            count;
    IGRint            found;
    IGRint            i;
    OM_S_CHANSELECT   chansel;
    OM_S_CHANSELECT   owner_chansel;
    enum GRdpmode     nh_mode;
    GRclassid         classid;
    GRclassid         dv_classid;
    GRobjid           objid;
    struct GRid       own_id;
    struct GRmd_env   mod_env;
    struct GRvg_construct         const_list;
    struct GRdrawview_class_attr  dv_class_attr;

    GRget_to_comp_chansel(&chansel);

    GRget_to_owner_info ( &owner_chansel,
                          OM_Gw_current_OS,
                          my_id,
                          &count );

    om$get_classid ( classname = "GRdrawview", 
                     p_classid = &dv_classid);

    found = FALSE;
    for (i=0; i < count; ++i) 
    {
        om$get_objid_at_index ( osnum = OM_Gw_current_OS, 
                                objid = my_id, 
                                p_chanselect = &owner_chansel,
                                index = i,
                                objidaddr = &own_id.objid,
                                osnumaddr = &own_id.osnum );

        om$get_classid ( osnum = own_id.osnum,
                         objid = own_id.objid,
                         p_classid = &classid );

        if (om$is_ancestry_valid(subclassid = classid,
                                 superclassid = dv_classid))
        {
            found = TRUE;
            break;
        }
    }

    if (!found) 
    {
        dv_class_attr.da_id.osnum = OM_Gw_current_OS;
        dv_class_attr.da_id.objid = my_id;
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
        const_list.class_attr = (IGRchar *)&dv_class_attr;
        const_list.name = NULL;
        om_msg = om$construct ( osnum = OM_Gw_current_OS, 
                                classname = "GRdrawview", 
                                p_objid = &objid,
                                msg = message GRgraphics.GRconstruct
                                                            (&const_list));
    }

    switch (*mode) 
    {
    case GRhd:
    case GRhe:
    case GRhhd:
    case GRhdo:
    case GRhhdo:
    case GRheo:
        flag = HIGHLIGHT;
        break;

    case GRbd:
    case GRbdhd:
    case GRbdhe:
    case GRbdheo:
        flag = HIGHLIGHT | NOT_HIGHLIGHT;
        nh_mode = GRbd;
        break;

    case GRbe:
    case GRbehe:
    case GRbehd:
    case GRbeheo:
        flag = HIGHLIGHT | NOT_HIGHLIGHT;
        nh_mode = GRbe;
        break;
    }

    if (flag & HIGHLIGHT) 
    {
        /* 
         *  Send the display message only to the reference file and to
         *  the coordinate system.  
         */
        om_msg = om$send ( msg = message GRdrawview.GRcomponent_pass 
                                                 ( msg,
                                                   OPPmargs, 
                                                   GR_DV_REFFILE | GR_DV_CS), 
                           targetid = my_id);
    }

    if (flag & NOT_HIGHLIGHT) 
    {
        om_msg = GRcomponent_pass_fun ( msg,
                                        message GRgraphics.GRdisyourself 
                                                ( msg, 
                                                  mx_type,
                                                  matrix,
                                                  &nh_mode,
                                                  alt_symb,
                                                  sp_info,
                                                  range_key),
                                        GR_DV_TEXTNAME | GR_DV_TEXTSCALE, 
                                        my_id, 
                                        OM_Gw_current_OS);
    }

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_DISPLAYED);

    if ( !(om_msg & 1) ) om_msg = OM_W_ABORT;

    return (om_msg);
}   
end implementation GRdvattach;
