#ifndef REplane_include
#define REplane_include

/*
 * Plane types that are associative.
 */
#define EMS_ASplane_encompassing_curves         14
#define EMS_ASplane_by_3pts                     15
#define EMS_ASparallelogram_by_3pts             16
#define EMS_ASplane_tangent_to_surface          35
#define EMS_ASplane_tangent_to_curve            36
#define EMS_ASplane_normal_to_curve             37
#define EMS_ASplane_converted_plane             38


struct EMSconverted_plane
{
 IGRuint orig_type;
 IGRchar *orig_info;
 IGRuint orig_info_size;
 IGRchar orig_classname[OM_K_MAXCLASS_LEN];
};

#endif
