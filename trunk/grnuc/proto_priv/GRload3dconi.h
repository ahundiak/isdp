#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRload3dconi.c */
extern int GRload3dconic __((IGRlong *msg, struct IGRarc *new_arc, IGRdouble *origin, IGRmatrix rot_matrix, IGRdouble *start_angle, IGRdouble *sweep_angle, IGRdouble *prim_axis, IGRdouble *sec_axis, IGRshort *properties, struct GRpost_info *post_info));

#if defined(__cplusplus)
}
#endif


#undef __
