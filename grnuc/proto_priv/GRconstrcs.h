#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/detailco/GRconstrcs.I */
extern IGRint GRconstruct_cs __((IGRlong *msg, struct GRmd_env *mod_env, IGRshort level, struct IGRdisplay *display, IGRushort properties, IGRchar name[], IGRchar classname[], struct IGRlbsys *lb, struct GRid *cs_id));

#if defined(__cplusplus)
}
#endif


#undef __
