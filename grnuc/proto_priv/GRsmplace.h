#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/symbco/GRsmplace.I */
extern IGRint GRsmplace __((IGRlong *msg, IGRint num_origins, IGRpoint origins[], IGRdouble *angle, IGRdouble scale[], IGRdouble rot_matrix[], IGRchar name[], unsigned int properties, struct IGRdisplay *display, IGRchar *class_attr, IGRshort level, struct GRmd_env *symbol_env, struct GRmd_env *target_env, IGRchar classname[], struct GRid *sdh_id, struct GRid sm_id[]));

#if defined(__cplusplus)
}
#endif


#undef __
