/* #######################    APOGEE COMPILED   ######################## */
class implementation COdetail;

from GRgraphics   import GRdisplay;
from GRdrawview   import GRput_drawview_description, GRget_drawview_scale,
                         GRget_drawview_label, GRdetach_model, 
                         GRdisplay_drawing_views, GRdrop_alignment,
                         GRget_projection_angle, GRrealign_drawing_view,
                         GRget_component_id;
from GRreffile    import GRlvdisplay;
/*
 * This method is to be used until COB allows a message to be sent 
 * from the state to an object other than the command object. This
 * should be finished by 2.0.0.
 */
method send_foreign ( IGRint mess )
{
    IGRint            status = OM_S_SUCCESS, msg = MSSUCC;
    struct GRmd_env   mod_env;
    IGRint            type, flag = 0;

    me->ret = MSSUCC;

    switch ( mess ) 
    {
    case CO_put_drawview_desc:
        status = gr$gspass ( msg = &msg,
                             pass_msg = message GRdrawview.GRput_drawview_description 
                                                    ( &me->ret,
                                                      me->event1.event.keyin ),
                             p_chanselect = &me->located_chansel );
         break;
    case CO_display_cs:
        status = om$send ( msg = message GRgraphics.GRdisplay 
                                                    ( &me->ret,
                                                      &me->ModuleInfo.md_env.matrix_type,
                                                      me->ModuleInfo.md_env.matrix, 
                                                      &me->DisplayMode,
                                                      &me->ModuleInfo.md_id ),
                           targetid = me->cs_id.objid,
                           targetos = me->cs_id.osnum );
        break;
    case CO_get_drawview_scale:
        status = gr$gspass ( msg = &msg,
                             pass_msg = message GRdrawview.GRget_drawview_scale 
                                                    ( &me->ret,
                                                      &mod_env, 
                                                      me->text_scale, 
                                                      NULL ),
                             path = &mod_env,
                             p_chanselect = &me->located_chansel );
        break;
    case CO_get_drawview_label:
        status = gr$gspass ( msg = &msg,
                             pass_msg = message GRdrawview.GRget_drawview_label 
                                                    ( &me->ret,
                                                      me->text_name ), 
                             p_chanselect = &me->located_chansel );
        break;
     case CO_display_drawview_layers:
        status = gr$gspass ( msg = &msg,
                             pass_msg = message GRreffile.GRlvdisplay
                                                    ( &me->ret,
                                                      &me->ModuleInfo.md_env.matrix_type,
                                                      me->ModuleInfo.md_env.matrix,
                                                      &me->DisplayMode, 
                                                      &me->ModuleInfo.md_id,
                                                      me->layer_mask_buffer ),
                             p_chanselect = &me->located_chansel );
        break;
    case CO_detach_model:
        status = gr$gspass ( msg = &msg,
                             pass_msg = message GRdrawview.GRdetach_model 
                                                    ( &me->ret, &mod_env ), 
                             path = &mod_env,
                             p_chanselect = &me->located_chansel);
        break;
    case CO_display_drawing_views:
        flag = 1;
    case CO_display_drawing_attachments:
        status = gr$gspass ( msg = &msg,
                             pass_msg = message GRdrawview.GRdisplay_drawing_views 
                                                    ( &me->ret,
                                                      &me->ModuleInfo.md_env.matrix_type, 
                                                      me->ModuleInfo.md_env.matrix,
                                                      &me->DisplayMode, 
                                                      &me->ModuleInfo.md_id, 
                                                      flag ),
                             path = &mod_env,
                             p_chanselect = &me->located_chansel );
        break;
    case CO_drop_alignment:
        status = gr$gspass ( msg = &msg,
                             pass_msg = message GRdrawview.GRdrop_alignment(&me->ret),
                             p_chanselect = &me->located_chansel );
        break;
    case CO_get_projection_angle:
        status = gr$gspass ( msg = &msg,
                             pass_msg = message GRdrawview.GRget_projection_angle 
                                                    ( &me->ret,
                                                      &me->projection_angle ),
                             p_chanselect = &me->located_chansel);
        break;
    case CO_realign_drawing_view:
        status = gr$gspass ( msg = &msg,
                             pass_msg = message GRdrawview.GRrealign_drawing_view 
                                                    ( &me->ret,
                                                      &mod_env, 
                                                      me->window_matrix, 
                                                      &me->dv_id1 ),
                             path = &mod_env,
                             p_chanselect = &me->located_chansel );
        break;
    case CO_get_cs_id:
        status = gr$gspass ( msg = &msg,
                             pass_msg = message GRdrawview.GRget_component_id 
                                                    ( &me->ret,
                                                      GR_DV_CS, 
                                                      1, 
                                                      &me->cs_id, 
                                                      &type ),
                             p_chanselect = &me->located_chansel);
        break;
    default:
        me->ret = MSFAIL;
        break;
    }
    
    return (OM_S_SUCCESS);
}

end implementation COdetail;

