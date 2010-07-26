#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/ASlineparai.I */
extern int ASlinepara_get_parents __((IGRint num_p, struct GRid *list, IGRdouble *dist, struct ret_struct *line_def, IGRdouble *track_pt, IGRdouble *vnorm, IGRboolean *track, IGRboolean *plane, struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
