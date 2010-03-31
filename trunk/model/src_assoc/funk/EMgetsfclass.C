/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
/*
  DESCRIPTION

    This function is used to obtain the translation between the type
    stored in the instance data of a higher level class and the classid
    of the object that this type represents.

  HISTORY

    SS  :  03/18/91  :  Creation
    jhw :  04/04/91  :  Added several new classes.
    Tapadia 03/16/92 :  Support for solid of projection with plane(s)
    			(EMS_ASsolid_proj_by_trim_st_end_plane
    			EMS_ASsolid_proj_by_trim_end_plane)
    Tapadia 05/15/92 :  Suppport for symmetrically projecting in both 
 			directions normal to the profile.
    			(EMS_ASsolid_proj_by_sym_dist)

*/

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "EMSasdef.h"
#include "EMSasnucdef.h"
#include "REgenbs.h"
#include "REgensolid.h"
#include "REsfsolid.h"
#include "REswcompsf.h"
#include "REgencompsf.h"

extern GRclassid OPP_EMSgencompsf_class_id;
extern GRclassid OPP_EMSprjcompsf_class_id;
extern GRclassid OPP_EMSrevcompsf_class_id;
extern GRclassid OPP_EMSgenbs_class_id;
extern GRclassid OPP_EMAgenbs_class_id;
extern GRclassid OPP_EMAcylindr_class_id;
extern GRclassid OPP_EMAsphere_class_id;
extern GRclassid OPP_EMAcone_class_id;
extern GRclassid OPP_EMAtorus_class_id;
extern GRclassid OPP_EMAelpcyl_class_id;
extern GRclassid OPP_EMAelpcone_class_id;
extern GRclassid OPP_EMAelpsoid_class_id;

IGRlong EMgetsfclass (solid_type, surface_class, surface_type)
    IGRint      solid_type;
    GRclassid * surface_class;
    IGRint    * surface_type;
{
    GRclassid class;
    IGRint    type;

    switch (solid_type)
    {
    case EMS_ASsolid_surface_of_projection:
        class = OPP_EMSprjcompsf_class_id;
        type = EMS_ASsurface_of_projection;
        break;

    case EMS_ASsolid_surface_of_projection1:
        class = OPP_EMSprjcompsf_class_id;
        type = EMS_ASsurface_of_projection1;
        break;

    case EMS_ASsolid_surface_of_revolution:
        class = OPP_EMSrevcompsf_class_id;
        type = EMS_ASsurface_of_revolution;
        break;

    case EMS_ASsolid_surface_of_revolution1:
        class = OPP_EMSrevcompsf_class_id;
        type = EMS_ASsurface_of_revolution1;
        break;

    case EMS_ASsolid_proj_by_trim_st_end_plane:
        class = OPP_EMSprjcompsf_class_id;
        type = EMS_ASsurf_of_proj_trim_st_end_plane;
        break;

    case EMS_ASsolid_proj_by_trim_end_plane:
        class = OPP_EMSprjcompsf_class_id;
        type = EMS_ASsurf_of_proj_trim_end_plane;
        break;

    case EMS_ASsolid_proj_by_sym_dist:
        class = OPP_EMSprjcompsf_class_id;
        type = EMS_ASsurf_of_proj_by_sym_dist;
        break;

    case EMS_ASsolid_cylinder:
        class = OPP_EMAcylindr_class_id;
        type = EMS_AScylinder;
        break;

    case EMS_ASsolid_tube_by_linear_and_radii:
        class = OPP_EMAgenbs_class_id;
        type = EMS_AStube_by_linear_and_radii;
        break;

    case EMS_ASsolid_sphere_by_center_and_radius:
        class = OPP_EMAsphere_class_id;
        type = EMS_ASsphere_by_center_and_radius;
        break;

    case EMS_ASsolid_cone_by_axis_and_diameters:
        class = OPP_EMAcone_class_id;
        type = EMS_AScone_by_axis_and_diameters;
        break;

    case EMS_ASsolid_drafted_surface:
        class = OPP_EMSgencompsf_class_id;
        type = EMS_ASdrafted_surface;
        break;

    case EMS_ASsolid_drafted_surface1:
        class = OPP_EMSgencompsf_class_id;
        type = EMS_ASdrafted_surface1;
        break;

    case EMS_ASsolid_torus_by_axis_center_and_radius:
        class = OPP_EMAtorus_class_id;
        type = EMS_AStorus_by_axis_center_and_radius;
        break;

    case EMS_ASsolid_skinning_surface:
        class = OPP_EMAgenbs_class_id;
        type = EMS_ASskinning_surface;
        break;

    case EMS_ASsolid_right_elliptical_cylinder:
        class = OPP_EMAelpcyl_class_id;
        type = EMS_ASright_elliptical_cylinder;
        break;

    case EMS_ASsolid_right_elliptical_cone:
        class = OPP_EMAelpcone_class_id;
        type = EMS_ASright_elliptical_cone;
        break;

    case EMS_ASsolid_ellipsoid_by_foci_axis_len:
        class = OPP_EMAelpsoid_class_id;
        type = EMS_ASellipsoid_by_foci_axis_len;
        break;

    case EMS_ASsolid_ellipsoid_by_center_axis_radius:
        class = OPP_EMAelpsoid_class_id;
        type = EMS_ASellipsoid_by_center_axis_radius;
        break;

    default:
        return (0);
    }

    if (surface_class) *surface_class = class;
    if (surface_type)  *surface_type  = type;
 
    return (1);
}
