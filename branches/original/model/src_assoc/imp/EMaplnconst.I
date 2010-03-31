/**********

NOTE, NOTE, NOTE:

DO NOT ACCESS ANY INSTANCE DATA DIRECTLY IN THIS METHOD!!!! THE CLASS OF
OBJECT CHANGES FOR EMS_ASplane_converted_plane type. THE ONLY WAY TO ACCESS
INSTANCE DATA IN SUCH A CASE IS TO SEND A MESSAGE. FOR e.g DO NOT USE
ME.GRgraphics->properties DIRECTLY. INSTEAD SEND GRchgprops MESSAGE.

	SM	04-Jun-92	
*************/
/*
 * METHOD:
 *
 *  EMconstruct_associative
 *
 * DESCRIPTION:
 *
 *  This is the method is used to construct and recompute a plane by 
 *  3 points,a parallelogram by 3 points, and a plane encompassing 
 *  planar elements.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  03/20/91
 */
class implementation EMAplane;

#include "OMmacros.h"
#include "REplane.h"
#include "mascalvc.h"

#define BASE        0
#define WIDTH       1
#define WIDTH_VEC   2
#define HEIGHT      3
#define HEIGHT_VEC  4

method EMconstruct_associative ( IGRlong               * msg; 
                                 IGRushort       opts;
                                 GRobjid                 old_objid;
                                 IGRint                  num_parents;
                                 IGRchar               * parent_info;
                                 IGRint                  type;
                                 IGRchar               * recomp_info;
                                 struct GRvg_construct * constr_list)
{
    IGRlong                   msg_loc, om_msg;
    IGRuint         * param_type;
    union EMSparent_info    * param;
    IGRint                    i,j,k,l;

    *msg = EMS_S_Success;
    om_msg = OM_S_SUCCESS;


    /* If this was a converted plane, change class to the original class, 
       put the original recompute info and send the message to new class.
    */
    if(type == EMS_ASplane_converted_plane)
     {
      struct EMSconverted_plane *my_info;

      EMerr_hndlr(!recomp_info, *msg, EMS_E_InvalidArg, ret_end);
      my_info = (struct EMSconverted_plane *) recomp_info;

      om_msg = om$change_class(objid = my_id,
            classname = my_info->orig_classname, 
            sd_override = OM_K_change_class_sd_override);
      if(!(1&om_msg)) goto ret_end;
      
      om_msg = om$send(msg = message EMSassoc.EMput_info(msg, NULL, 
               my_info->orig_type, my_info->orig_info_size, 
               my_info->orig_info), targetid = my_id);
      if(!(1&*msg&om_msg)) goto ret_end;
      om$send(msg = message EMSassoc.EMconstruct_associative(msg, opts, 
                    old_objid, num_parents, parent_info, my_info->orig_type, 
                    my_info->orig_info, constr_list), targetid = my_id);
      goto ret_end;
     }

    /*
     * Get space for the parameter information.
     */
    param_type = (IGRuint *)alloca(num_parents * sizeof(IGRint));
    param = (union EMSparent_info *)alloca(num_parents * sizeof (union EMSparent_info));

    /*
     * Fill in the appropriate parameter requests.
     */
    switch (type)
    {
    case EMS_ASplane_encompassing_curves:
        for (i=0; i<num_parents; ++i) param_type[i] = EMSgrid;
        break;

    case EMS_ASplane_by_3pts:
    case EMS_ASparallelogram_by_3pts:
        param_type[BASE]        = EMSpoint;
        param_type[WIDTH]       = EMSdistance;
        param_type[WIDTH_VEC]   = EMSvector;
        param_type[HEIGHT]      = EMSdistance;
        param_type[HEIGHT_VEC]  = EMSvector;
        break;

    case EMS_ASplane_tangent_to_surface:
    case EMS_ASplane_tangent_to_curve:
    case EMS_ASplane_normal_to_curve:
        param_type[0] = EMSdistance;
        param_type[1] = EMSdistance;
        param_type[2] = EMSlcinfo;
        param_type[3] = EMSpoint;
        break;

    default:
        goto ret_end;
    }        

    /*
     * Get the parameter information.
     */
    om_msg = om$send ( msg = message EMSassoc.EMget_parent_info
                                            ( &msg_loc,
                                              NULL,
                                              num_parents,
                                              parent_info,
                                              param_type,
                                              param ),
                        targetid = my_id);
    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * Construct the appropriate plane.
     */
    switch (type)
    {
    case EMS_ASplane_encompassing_curves:
        {
        struct GRlc_info   loc_curve;

        loc_curve.module_info = param[0].grobj.env;
        loc_curve.located_obj = param[0].grobj.grid;

        /*
         * Initialize the plane with the first curve.
         */
        om_msg = om$send ( msg = message EMSplane.EMplane_of_curve
                                ( msg,
                                  constr_list,
                                  &loc_curve,           /* Outtermost curve */
                                  NULL,                 /* No curve by buffer */
                                  NULL,                 /* No curve type */
                                  TRUE,                 /* Test degeneracy */
                                  (num_parents == 1),   /* Construct loopset */
                                  NULL,                 /* No orientation */
                                  NULL ),               /* Don't need edge */
                           targetid = my_id );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        /*
         * If there are other curves, impose them as boundaries.
         */
        if (num_parents > 1)
        {
            struct GRid        plane;
            struct GRlc_info * boundaries;

            plane.objid = my_id;
            plane.osnum = OM_Gw_current_OS;
            
            boundaries = (struct GRlc_info *)alloca(num_parents * sizeof(struct GRlc_info));

            for (i=0; i<num_parents; ++i)
            {
                boundaries[i].module_info = param[i].grobj.env;
                boundaries[i].located_obj = param[i].grobj.grid;
            }
            
            om_msg = EFimpose_boundaries_on_plane ( msg,
                                                    constr_list->env_info,
                                                    &plane,
                                                    boundaries,
                                                    num_parents,
                                                    FALSE ); /* No Status Msg */
        }
        }
        break;

    case EMS_ASplane_by_3pts:
    case EMS_ASparallelogram_by_3pts:
    {
        IGRvector vector;
        IGRpoint  points[3], tmp;

        memcpy(points[0], param[BASE].point, sizeof(IGRpoint));

        for (i=1,j=WIDTH,k=WIDTH_VEC; i<3; ++i, j+=2, k+=2)
        {
            MAscalvc (&msg_loc, &param[j].value, param[k].vector, vector);
            for (l=0; l<3; ++l)
                points[i][l] = points[0][l] + vector[l];
        }

        if (type == EMS_ASparallelogram_by_3pts)
        {
            memcpy (tmp, points[0], sizeof(IGRpoint));
            memcpy (points[0], points[1], sizeof(IGRpoint));
            memcpy (points[1], tmp, sizeof(IGRpoint));
        }
        om_msg = om$send ( msg = message EMSplane.EMplane 
                                    ( (IGRint *)msg,
                                      constr_list,
                                      points,
                                      (type == EMS_ASparallelogram_by_3pts) ),
                           targetid = my_id );
    }
        break;

    case EMS_ASplane_tangent_to_surface:
    case EMS_ASplane_tangent_to_curve:
    case EMS_ASplane_normal_to_curve:
    {
        struct GRevent event;

        event.subtype = GRst_REGULAR;
        event.event.button.objid = NULL_OBJID;
        memcpy(&event.event.button.x, param[3].point, sizeof(IGRpoint));
        om_msg = EFpoint_on_object (&param[2].lc_info, &event, NULL_OBJID, &msg_loc);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
        
        om_msg = om$send ( msg = message EMSplane.EMplane_normal_and_tangent_to
                            ( !(type == EMS_ASplane_normal_to_curve),
                              !(type == EMS_ASplane_tangent_to_surface),
                              TRUE,
                              &param[2].lc_info,
                              &event.located_object[0].geom_parms,
                              param[0].value,
                              param[1].value,
                              constr_list),
                           targetid = my_id ); 

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
        break;
    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMAplane.EMconstruct_associative");

    return (om_msg);
}

end implementation EMAplane;
