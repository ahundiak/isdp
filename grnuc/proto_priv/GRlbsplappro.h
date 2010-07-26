#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRlbsplappro.C */
extern IGRboolean GRlbsplapproj __((IGRlong *msg, struct IGRlbsys *lbsys, struct EX_button *button, IGRpoint proj_pnt, IGRdouble *tparam));

#if defined(__cplusplus)
}
#endif


#undef __
