#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/cache.I */
extern IGRint DMload_cache __((struct GRid list[2 ], IGRboolean convert_linestr, IGRboolean set_upar_limit, IGRdouble *upar, struct GRmd_env *md_env));
extern IGRint DMclear_cache __((void));
extern IGRint DMset_dyn_flag __((IGRboolean flag));
extern IGRint DMget_cache_data __((struct IGRbsp_curve **curve_actual, struct IGRbsp_curve **curve_projected, struct IGRbsp_curve **curve_converted, IGRboolean *dynamics_on, IGRdouble **point_on_curve, IGRdouble **curve_normal, IGRdouble **dim_normal, IGRboolean *planes_parallel, IGRboolean *const_radius, IGRdouble **center, IGRdouble *radius, IGRdouble *upar_low, IGRdouble *upar_high));

#if defined(__cplusplus)
}
#endif


#undef __
