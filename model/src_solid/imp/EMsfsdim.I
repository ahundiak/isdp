/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  These are the autodimension methods for capped surfaces.
 *
 * HISTORY:
 *
 *  jhw    Creation         06/12/91
 */
class implementation EMSsfsolid;

#include "EMSconstruct.h"
#include "REsfsolid.h"
#include "REgencompsf.h"

method EMdim ( IGRlong             * msg;
               struct GRmd_env     * mod_env;
               IGRushort     options;
               IGRint                type;
               IGRchar             * info;
               IGRint                num_parents;
               struct GRid         * parents )
{
    IGRlong         om_msg = OM_S_SUCCESS;
    IGRint          surface_type;
    OM_S_CHANSELECT chansel;
    
    *msg = EMS_S_Success;

    if (type != EMS_ASsolid_by_capping_surface)
    {
        EMgetsfclass (type, NULL, &surface_type);

        EMmake_chanselect(GRcmpowner_to_components, &chansel);

        om_msg = om$send ( msg = message EMSdim.EMdim
                                                ( msg,
                                                  mod_env,
                                                  options,
                                                  surface_type,
                                                  info,
                                                  num_parents,
                                                  parents ),
                           p_chanselect = &chansel,
                           from = 0,
                           to = 0 );

        if (om_msg == OM_W_REJECTED_METHOD) om_msg = OM_S_SUCCESS;
                                                
        EMerr_hndlr (EMSerror (*msg & om_msg), *msg, EMS_E_Fail, ret_end);
    }
    else *msg = EMS_E_Fail;

ret_end:

  EMWRAPUP (*msg, om_msg, "EMSsfsolid.EMdim");

  return (om_msg);
}

method EMdimparam ( IGRlong            * msg; 
                    struct GRmd_env    * mod_env;
                    IGRushort    options;
                    IGRint               type;
                    IGRchar            * info;
                    IGRint               num_parents;
                    struct GRid        * parents;
                    IGRint               index; 
                    struct IGRplane    * dim_plane;
                    IGRdouble          * dim_plane_xaxis;
                    struct EMSgeomdata * dim_geom;
                    IGRint             * dim_type )
{
    IGRlong         om_msg = OM_S_SUCCESS;
    OM_S_CHANSELECT chansel;
    IGRint          surface_type;
    
    *msg = EMS_S_Success;

    if (type != EMS_ASsolid_by_capping_surface)
    {
        struct EMSdrafted_surface *r_c_info=NULL;

        if ( (type == EMS_ASsolid_drafted_surface ||
              type == EMS_ASsolid_drafted_surface1) && !dim_geom && index > 2)
        {
          /*The dim orientation is only needed so just extract it from my
           * instance data.
           */
          OMuword                   best_view_index;

          r_c_info = (struct EMSdrafted_surface *) ME.EMSassoc->info;

          if (r_c_info->num_sides)
            best_view_index = r_c_info->codes_views[index-3].view_index;
          else {*msg = EMS_E_InvalidCase; goto ret_end;}  /*NO_VIEW*/

          if (best_view_index == NO_VIEW)
          {*msg = EMS_E_InvalidCase; goto ret_end;}
  
          if (dim_plane) 
          {
            dim_plane->point[0] = dim_plane->point[1] = dim_plane->point[2]= 0;
            if (best_view_index == TOP_VIEW)
            {
              dim_plane->normal[0] = 0;
              dim_plane->normal[1] = 0;
              dim_plane->normal[2] = 1;
            }
            else if (best_view_index == FRONT_VIEW)
            {
              dim_plane->normal[0] = 0;
              dim_plane->normal[1] = -1;
              dim_plane->normal[2] = 0;
            }      
            else
            {
              dim_plane->normal[0] = 1;
              dim_plane->normal[1] = 0;
              dim_plane->normal[2] = 0;
            }      
          }
      
          if (dim_plane_xaxis) 
          {
            if (best_view_index == TOP_VIEW ||
                best_view_index == FRONT_VIEW)
            {
              dim_plane_xaxis[0] = 1.0;
              dim_plane_xaxis[1] = 0.0;
            }
            else
            {
              dim_plane_xaxis[0] = 0.0;
              dim_plane_xaxis[1] = 1.0;
            }
        
            dim_plane_xaxis[2] = 0.0;
          }

          goto ret_end;
        }

        EMgetsfclass (type, NULL, &surface_type);

        EMmake_chanselect(GRcmpowner_to_components, &chansel);

        om_msg = om$send ( msg = message EMSdim.EMdimparam 
                                                ( msg,
                                                  mod_env,
                                                  options,
                                                  surface_type,
                                                  info,
                                                  num_parents,
                                                  parents,
                                                  index,
                                                  dim_plane,
                                                  dim_plane_xaxis,
                                                  dim_geom,
                                                  dim_type ),
                           p_chanselect = &chansel,
                           from = 0,
                           to = 0 );
                                                
        EMerr_hndlr (EMSerror (*msg & om_msg), *msg, EMS_E_Fail, ret_end);

        if ( (type == EMS_ASsolid_drafted_surface ||
              type == EMS_ASsolid_drafted_surface1) && dim_geom && index > 2)
        {
          r_c_info = (struct EMSdrafted_surface *) ME.EMSassoc->info;

          if (dim_plane)
          {
            if (dim_plane->normal[2] == 1.0)
              r_c_info->codes_views[index-3].view_index = TOP_VIEW;
            else if (dim_plane->normal[1] == -1.0)
              r_c_info->codes_views[index-3].view_index = FRONT_VIEW;
            else
              r_c_info->codes_views[index-3].view_index = RIGHT_VIEW;
          }
        }
    }
    else *msg = EMS_E_Fail;

ret_end:

  EMWRAPUP (*msg, om_msg, "EMSsfsolid.EMdimparam");

  return (om_msg);
}
end implementation EMSsfsolid;
