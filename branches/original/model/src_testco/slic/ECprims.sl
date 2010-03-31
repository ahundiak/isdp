class           ECprims
product_name    "$MODEL"
super_class     COtools
super_class     CEO_LOCATE
start_state     terminate
spec_path       "$GRNUC/spec"
path            "."
options         "SItc"

specification

instance
{
    IGRint  mode;
    IGRint  num_events;
}

implementation

#include "DIdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasdef.h"
#include "EMSas.h"
#include "EMSdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSasopts.h"
#include "EMSopt.h"
#include "emsbool.h"
#include "primco.h"
#include <alloca.h>	/*Added by DLB 3/12/92*/

from GRowner    import GRget_number_components, GRget_components;
from GRvg       import GRdetplane;
from GRgraphics import GRdisplay;

extern OMuword OPP_SKmgr_class_id;

action arg_name_to_value
{
    *ret_type = _COB_UNKNOWN_ARG;
    *is_const = 0;

    if ( class_name[0] ) 
    {
        if ( !strcmp ( arg, "mode" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) (&me->mode);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
            else if ( addr_mode == _COB_regular ) 
            {
                data->i = (int)me->mode;
                *ret_type = _COB_arg_i;
            }
        }
        else if ( !strcmp ( arg, "num_events" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) (&me->num_events);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
            else if ( addr_mode == _COB_regular ) 
            {
                data->i = (int)me->num_events;
                *ret_type = _COB_arg_i;
            }
        }
    }

    if ( *ret_type == _COB_UNKNOWN_ARG ) 
    {
        om$send ( targetid = my_id,
                  mode = OM_e_wrt_message,
                  msg = message CEO_LOCATE.arg_name_to_value ( addr_mode,
                                                               class_name,
                                                               arg,
                                                               data,
                                                               ret_type,
                                                               is_const ) );
    }

    return OM_S_SUCCESS;
}

action dynamics
{
    IGRchar * info;

    switch (dynamics)
    {
    case EC_DY_EXTRUDE:
    case EC_DY_CENTERLINE:
    case EC_DY_START_ANGLE:
    case EC_DY_END_ANGLE:
        info = (char *)&me->mode;

        DYprojection ( sts,
                       dynamics,
                       info,
                       me->num_events,
                       &me->events[0] );
        break;
    }
}

action project (IGRlong * msg; IGRint type)
{
    IGRboolean              assoc_placement;
    struct EMSobject_info   curve;
    enum GRdpmode           mode = GRbd;
    IGRint                  i, j;
    GRobjid               * solids, * holes, * holes_solid;
    IGRint                  num_solids, num_holes;
    GRobjid               * curves = 0, * objects;
    IGRint                  num_curves, num_objects;

    *msg = MSSUCC;

    gr$get_associative_flag( buffer = &assoc_placement );

    curve.grid = me->events[EC_CURVE].located_object[0].located_obj;
    curve.env  = me->events[EC_CURVE].located_object[0].module_info;

    EFget_solids_and_holes ( msg,
                             &curve.grid,
                             &curve.env,
                             &curves, /* Free this one only */
                             &solids,   
                             &num_solids,
                             &holes,
                             &holes_solid,
                             &num_holes );

    num_curves = num_solids + num_holes;

    for (i=0; i<num_curves; ++i)
    {
        GRobjid                 original;

        curve.grid.objid = original = curves[i];

        if (type == EC_EXTRUDE) 
        {
            struct EMSpoint_info    base, height;

            base.type = height.type = EMSdatainfo_event;
            base.ptevent = &me->events[EC_FROM_POINT];
            height.ptevent = &me->events[EC_TO_POINT];

            EMplace_surf_of_projection 
                        ( msg,
                          assoc_placement ? 0 : EMSasconst_notassociative,
                          &me->ModuleInfo,
                          me->ActiveLevel,
                          &me->ActiveDisplay,
                          NULL,
                          NULL,
                          &curve,
                          &base,
                          &height,
                          TRUE,
                          &curves[i] );
        }
        else
        {
            struct EMSpoint_info    axis[2];
            struct EMSvalue_info    start, sweep;
            
            axis[0].type    = EMSdatainfo_event;
            axis[0].ptevent = &me->events[EC_AXIS_POINT1];

            axis[1].type    = EMSdatainfo_event;
            axis[1].ptevent = &me->events[EC_AXIS_POINT2];

            if (me->mode == EC_TURN_FULL)
            {
                sweep.type      = EMSdatainfo_numeric;
                sweep.val       = 360;

                start.type      = EMSdatainfo_numeric;
                start.val       = 0;
            }
            else if (me->mode == EC_TURN_END)
            {
                MAraddeg (msg, &me->events[EC_END_ANGLE].event.value, &sweep.val);
                sweep.type      = EMSdatainfo_numeric;

                start.type = EMSdatainfo_numeric;
                start.val  = 0;
            }
            else if (me->mode == EC_TURN_START_END)
            {
                MAraddeg (msg, &me->events[EC_END_ANGLE].event.value, &sweep.val);
                sweep.type      = EMSdatainfo_event;

                MAraddeg (msg, &me->events[EC_START_ANGLE].event.value, &start.val);
                start.type      = EMSdatainfo_event;
            }

            EMplace_surf_of_revolution
                                ( msg,
                                  assoc_placement ? 0 : EMSasconst_notassociative,
                                  &me->ModuleInfo, 
                                  me->ActiveLevel,
                                  &me->ActiveDisplay,
                                  NULL,
                                  NULL,
                                  &curve,
                                  axis,
                                  &start,
                                  &sweep,
                                  TRUE,
                                  &curves[i] );
        }

        if (!(*msg & 1)) curves[i] = NULL_OBJID;
        else
            for (j=0; j<num_holes; j++)
                if (holes_solid[j] == original)
                    holes_solid[j] = curves[i];
    }

    if (num_holes)
    {
        struct GRvg_construct construct_list;
        GRobjid * loc_opnds;
        IGRint    loc_num_opnds;

        construct_list.msg = msg;
        construct_list.env_info = &me->ModuleInfo;
        construct_list.newflag = FALSE;
        construct_list.level = me->ActiveLevel;
        construct_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
        construct_list.geometry = NULL;
        construct_list.display = &me->ActiveDisplay;
        construct_list.class_attr = NULL;
        construct_list.name = NULL;

        num_objects = 0;
        objects = (GRobjid *)alloca(num_curves * sizeof(GRobjid));
        loc_opnds = (GRobjid *)alloca((num_holes + 1) * sizeof(GRobjid));

        for (i=0; i<num_solids; ++i)
        {
            if (solids[i] != NULL_OBJID)
            {
                loc_opnds[0] = solids[i];
                loc_num_opnds = 1;

                for (j=0; j<num_holes; ++j)
                    if ((holes[j] != NULL_OBJID) && (holes_solid[j] == solids[i]))
                        loc_opnds[loc_num_opnds++] = holes[j];

                if (loc_num_opnds > 1)
                {
                    struct GRid res_id;
                
                    EFboolean ( msg, 
                                0,
                                loc_num_opnds,
                                loc_opnds,
                                EMSbool_difference,
                                &construct_list,
                                &res_id );

                    objects[num_objects++] = (*msg & 1) ? res_id.objid :solids[i];
                }
                else objects[num_objects++] = solids[i];
            }
        }
    }
    else
    {
        num_objects = num_curves;
        objects = curves;
    }

    for (i=0; i<num_objects; ++i)
    {
        if (objects[i] != NULL_OBJID)
        {
            om$send ( msg = message GRgraphics.GRdisplay 
                                        ( msg,
                                          &me->ModuleInfo.md_env.matrix_type,
                                          me->ModuleInfo.md_env.matrix,
                                          &mode,
                                          &me->ModuleInfo.md_id ),
                      targetid = objects[i],
                      targetos = me->ModuleInfo.md_id.osnum );
        }
    }

    if (curves)   free(curves);

    return (OM_S_SUCCESS);
}

action select_form
{
    return (OM_S_SUCCESS);
}

action form_notification
{
    return (OM_S_SUCCESS);
}

