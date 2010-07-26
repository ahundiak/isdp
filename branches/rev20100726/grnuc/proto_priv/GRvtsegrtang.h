#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRvtsegrtang.c */
extern IGRlong GRvtsegrtang __((IGRlong *msg, struct IGRbsp_curve *curve, IGRlong *pt_num, IGRdouble *dir, IGRlong *new_num, IGRboolean *found));

#if defined(__cplusplus)
}
#endif


#undef __
