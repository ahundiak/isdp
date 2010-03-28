#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRclorthpg.c */
extern IGRboolean GRclorthpg __((IGRlong *msg, struct IGRpolyline *pg));
static IGRboolean GRfindfirst __((IGRlong *msg, struct IGRpolyline *pg, IGRlong *i, IGRlong *j));
static IGRboolean GRfindlast __((IGRlong *msg, struct IGRpolyline *pg, IGRlong *i, IGRlong *j));
static IGRboolean GRfindfperp __((IGRlong *msg, struct IGRpolyline *pg, IGRdouble *tol, IGRvector vc));
static IGRboolean GRfindlperp __((IGRlong *msg, struct IGRpolyline *pg, IGRdouble *tol, IGRvector vc));

#if defined(__cplusplus)
}
#endif


#undef __
