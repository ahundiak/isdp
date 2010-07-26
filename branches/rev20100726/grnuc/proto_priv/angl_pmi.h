#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/angl_pmi.I */
extern IGRdouble point_angle __((IGRdouble *pt0, IGRdouble *pt1, IGRdouble *pt2, IGRdouble *vz));
extern IGRdouble line_angle __((struct ret_struct *line1, struct ret_struct *line2, IGRdouble *vz));

#if defined(__cplusplus)
}
#endif


#undef __
