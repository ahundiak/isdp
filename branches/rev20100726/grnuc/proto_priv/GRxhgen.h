#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/xhatch/GRxhgen.I */
extern IGRint GRxh_generate_crosshatch __((IGRlong *msg, struct GRid *window_grid, struct GRid *xh_gg, struct GRid xhatch_id, IGRshort xhatch_color, IGRdouble xhatch_spacing, IGRdouble xhatch_angle, struct GRxhatchpat *xhatch_pattern, IGRdouble *act_origin, struct GRmd_env *module_info, IGRboolean associative_flag));

#if defined(__cplusplus)
}
#endif


#undef __
