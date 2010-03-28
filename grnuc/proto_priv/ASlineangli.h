#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/ASlineangli.I */
extern int ASlineangl_vor __((struct ret_struct *pointdef, struct ret_struct *linedef, struct GRid line_grid, struct GRmd_env *md_env));
extern int ASlineangl_get_parents __((IGRint num_p, struct GRid *list, IGRdouble *angle, struct ret_struct *linedef, struct ret_struct *pointdef, IGRdouble *track_pt, IGRdouble *vnorm, IGRboolean *track, IGRboolean *plane, struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
