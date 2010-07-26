#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRformlbsys.c */
extern int GRformlbsys __((IGRlong *msg, IGRmatrix window_rotation, IGRdouble *origin, struct IGRlbsys *lbsys));

#if defined(__cplusplus)
}
#endif


#undef __
