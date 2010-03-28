/* #######################    APOGEE COMPILED   ######################## */
class implementation GRdrawview;

#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "gocmacros.h"
#include "ref.h"
#include "refdef.h"
#include "OMmacros.h"
#include "grownmacros.h"

extern int GRget_to_comp_chansel();

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
    IGRlong  om_msg;
    IGRint   count;

    *msg = MSSUCC;

    count = 0;

    om_msg = om$send ( msg = message GRdrawview.GRget_alignment_count (msg,
                                                                       &count), 
                       targetid = my_id);

    ex$message ( msgnumb = (count == 1) ? GR_I_DrwVwUnAlgn : GR_I_DrwVw, 
                 buff = info->type);

    return(OM_S_SUCCESS);
}

method GRgenabsg ( IGRlong *msg; 
                   IGRshort *matrix_type; 
                   IGRmatrix matrix;
                   IGRchar **absgptr)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel ( &chansel ) ;

    return (om$send(msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRget_channel_type ( IGRlong *msg; IGRint *type; IGRint *conn_type )
{
    *msg = MSSUCC;
    *type = GR_FLEXIBLE;
    *conn_type = GR_NO_OVERRIDE;
    return (OM_S_SUCCESS);
}

method GRget_locate_properties (IGRlong *msg; IGRint *properties)
{
    *msg = MSSUCC;
    *properties = GR_LC_CMP_READ        |
                  GR_LC_CMP_WRITE       |
                  GR_LC_OWN_READ        |
                  GR_LC_OWN_WRITE       |
                  GR_LC_CMP_PRM_READ    |
                  GR_LC_CMP_PRM_WRITE   |
                  GR_LC_FLEXIBLE;
 
    return (OM_S_SUCCESS);
}

method GRadd_to_active_owner (IGRlong *msg; struct GRmd_env *mod_env)
{
    IGRlong        om_msg;
    IGRlong        ret_msg;
    GRclassid      classid;
    GRclassid      GRdrawview_class_id;
    struct GRid    act_own_id;

    *msg = MSSUCC;
 
    om_msg = gr$get_active_owner ( msg = &ret_msg, 
                                   mod_id = &mod_env->md_id,
                                   active_owner = &act_own_id);

    if (om_msg  & ret_msg & 1) 
    {
        om$get_classid (osnum = act_own_id.osnum, 
                        objid = act_own_id.objid, 
                        p_classid = &classid);
   
        om$get_classid (classname = "GRdrawview",
                        p_classid = &GRdrawview_class_id);

        if (classid != GRdrawview_class_id) 
        {
            /*
             *  Only add the drawing view if it not being added to a
             *  drawing view.
             */
             gr$add_to_active_owner (msg = &ret_msg, mod_env = mod_env);
        }
    }

    return(OM_S_SUCCESS);
}

method GRget_drawing_attachment_id (IGRlong *msg; struct GRid *da_id)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return (om$send(msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRcomponent_add ( IGRlong *msg; 
                         struct GRmd_env *mod_env;
                         struct GRid *comp_id; 
                         IGRint selector)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return (om$send(msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRcomponent_delete ( IGRlong *msg; 
                            struct GRmd_env *mod_env;
                            IGRint selector)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRcomponent_pass ( IGRlong *msg; 
                          OM_p_MESSAGE pass_msg;
                          IGRint selector)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRdisplay_drawing_views ( IGRlong *msg; 
                                 IGRshort *matrix_type;
                                 IGRmatrix matrix; 
                                 enum GRdpmode *dpmode;
                                 struct GRid *display_id;
                                 IGRint display_flag)
{
    IGRlong           om_msg;
    OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;

    GRget_to_comp_chansel(&chansel);

    if (display_flag) 
    {
        om_msg = om$send (msg = message GRgraphics.GRdisplay ( msg, 
                                                               matrix_type,
                                                               matrix,
                                                               dpmode, 
                                                               display_id),
                          targetid = my_id);
    }

    om_msg = om$send (msg = OPPmargs, p_chanselect = &chansel,from=0, to=0);

    return(om_msg);
}

method GRdrop_alignment (IGRlong *msg)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRscale_drawing_view ( IGRlong *msg;
                              struct GRmd_env *mod_env;
                              IGRint *flag; 
                              IGRchar *scale; 
                              IGRpoint point)
{
    IGRlong         om_msg;
    IGRshort        matrix_type;
    IGRdouble       old_scale[3];
    IGRdouble       new_scale[3];
    IGRdouble       scale_vc[4];
    IGRmatrix       matrix;
    IGRpoint        tpoint;
    IGRmatrix       rmatrix;
    GRobjid         objid;
    OM_S_CHANSELECT chansel;
    struct IGRlbsys lb;

    GRget_to_comp_chansel(&chansel);

    om_msg = om$send (msg = message GRdrawview.GRget_drawview_scale (msg,
                                                                     mod_env, 
                                                                     NULL, 
                                                                     old_scale),
                      p_chanselect = &chansel, 
                      from = 0, 
                      to = 0);

    if (om_msg & *msg & 1) 
    {
        om_msg = om$send ( msg = OPPmargs, p_chanselect = &chansel, from=0, to=0);

        if (om_msg & *msg & 1) 
        {
            om_msg = om$send ( msg = message GRdrawview.GRget_drawview_scale (msg, 
                                                                              mod_env, 
                                                                              NULL, 
                                                                              new_scale),
                               p_chanselect = &chansel, 
                               from = 0, 
                               to = 0);

            if (om_msg & *msg & 1) 
            {
                if (*flag) 
                {
                    tpoint[0] = point[0];
                    tpoint[1] = point[1];
                    tpoint[2] = point[2];
                }
                else 
                {
                    om_msg = om$send ( msg = message GRdrawview.GRget_model_geometry 
                                                                            ( msg,
                                                                              mod_env, 
                                                                              &lb),
                                       p_chanselect = &chansel, 
                                       from = 0, 
                                       to = 0);

                    tpoint[0] = lb.matrix[3];
                    tpoint[1] = lb.matrix[7];
                    tpoint[2] = lb.matrix[11];
                }

                scale_vc[0] = new_scale[0] / old_scale[0];
                scale_vc[1] = new_scale[1] / old_scale[1];
                scale_vc[2] = new_scale[2] / old_scale[2];
                scale_vc[3] = 1.0;

                MAidmx (msg, matrix);
                MAgscamx (msg, matrix, tpoint, scale_vc, rmatrix);
                MAtypemx (msg, rmatrix, &matrix_type);

                if (om_msg & *msg & 1) 
                {
                    om$send (msg = message GRgraphics.GRxform (msg,
                                                               mod_env, 
                                                               &matrix_type, 
                                                               rmatrix, 
                                                               &objid),
                             p_chanselect = &chansel, 
                             from = 1, 
                             to = OM_K_MAXINT);
                }
            }
        }
        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_GEOM_XFORMED);
    }

    return (om_msg);
}

method GRget_drawview_scale ( IGRlong *msg; 
                              struct GRmd_env *mod_env;
                              IGRchar *scale_string; 
                              IGRdouble *scale)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRget_drawview_description (IGRlong *msg; IGRchar *desc)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRput_drawview_description (IGRlong *msg; IGRchar *desc)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRget_drawview_label (IGRlong *msg; IGRchar *label)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRdetach_model (IGRlong *msg; struct GRmd_env *mod_env)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRattach_model ( IGRlong *msg; 
                        struct GRmd_env *mod_env; 
                        IGRchar *filename; 
                        IGRchar *saveview_name;
                        IGRint graphic_props; IGRint reference_props;
                        IGRshort level; struct IGRdisplay *display)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRget_model_matrix ( IGRlong *msg;   
                            struct GRmd_env *mod_env;
                            IGRint no_scale_flag; 
                            IGRmatrix matrix)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRget_model_geometry ( IGRlong *msg; 
                              struct GRmd_env *mod_env;
                              struct IGRlbsys *lb)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRget_alignment_count (IGRlong *msg; IGRint *count)
{
    OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;

    GRget_to_comp_chansel(&chansel);

    *count = *count + 1;

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRget_alignment_objects ( IGRlong *msg; 
                                 IGRint size;
                                 IGRint *count;
                                 struct GRid objects[])
{
    OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;

    GRget_to_comp_chansel(&chansel);

    if (*count < size) 
    {
        objects[*count].osnum = OM_Gw_current_OS;
        objects[*count].objid = my_id;
        *count = *count + 1;
    }

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRrealign_drawing_view ( IGRlong *msg; 
                                struct GRmd_env *mod_env;
                                IGRdouble *window_matrix; 
                                struct GRid *dv_id)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRrealign_compare ( IGRlong *msg; 
                           struct GRmd_env *mod_env;
                           IGRint *orientation; 
                           IGRchar *filename;
                           IGRchar *saveview;
                           IGRchar *scale)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}

method GRget_component_id ( IGRlong *msg; 
                            IGRint selector; 
                            IGRint count;
                            struct GRid ids[]; 
                            IGRint types[])
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send (msg = OPPmargs, p_chanselect = &chansel, from=0, to=0));
}
end implementation GRdrawview;
