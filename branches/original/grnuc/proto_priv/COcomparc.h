#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/arc/COcomparc.I */
extern IGRlong COcomp_arc __((IGRlong *msg, struct GRevent *events, struct GRmd_env *module_info, struct GRid *module_grid, GRobjid my_id, OM_S_CHANSELECT *p_chanselect));

#if defined(__cplusplus)
}
#endif


#undef __
