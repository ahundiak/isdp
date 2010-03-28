#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/xhatch/COniplxhat.I */
extern IGRlong CO_ni_place_crosshatch __((IGRlong *msg, struct GRevent *events[], IGRshort *active_level, IGRchar *attributes, struct GRid *xhatch_gg, OM_S_OBJID cobid, GRspacenum cobos, OM_S_CHANSELECT *p_co_chanselect, struct GRmd_env *module_info[], struct GRid *objects_grid[], IGRshort xhatch_color, IGRdouble xhatch_spacing, IGRdouble xhatch_angle, struct GRxhatchpat *xhatch_pattern));
extern IGRint GRxh_load_pattern __((IGRlong pattern_type, IGRdouble xhatch_spacing, struct GRxhatchpat *pattern_def));

#if defined(__cplusplus)
}
#endif


#undef __
