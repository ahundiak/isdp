#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* IDrmplsi.I */
extern IGRboolean IDsurf_has_enough_rows_to_delete_one __((
	struct IGRbsp_surface *surf_ptr, 
	IGRboolean v_direction));

extern IGRboolean IDcrv_pole_can_be_deleted __((struct IGRbsp_curve *crv));

extern IGRboolean IDrow_is_surface_boundary __((
	struct IGRbsp_surface *surf_ptr, 
	IGRboolean v_direction, 
	IGRint pole_index));

#if defined(__cplusplus)
}
#endif

