#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/xhatch/GRgenxhatch.I */
extern int GRxhpoint_compare __((IGRdouble *point1, IGRdouble *point2));
extern IGRint GRgenerate_crosshatch __((IGRlong *msg, struct GRid *elem_to_xhatch, IGRint num_boundaries, struct GRid *boundary_elems, struct GRid *window_grid, struct GRid *xh_gg, struct GRid xhatch_id, IGRshort xhatch_color, IGRdouble xhatch_spacing, IGRdouble xhatch_angle, struct GRxhatchpat *xhatch_pattern, IGRdouble *act_origin, struct GRmd_env *module_info, IGRboolean associative_flag));
extern IGRint GRxh_inc_pts_buffer __((IGRint *num_lines_alloc, IGRpoint **xarray_pts, IGRboolean *xarray_allocated));
extern IGRint GRxh_insert_pts_buffer __((IGRint *num_lines, IGRint cur_line_num, IGRint nint, IGRpoint *xint_pts, IGRpoint *xarray_pts));

#if defined(__cplusplus)
}
#endif


#undef __
