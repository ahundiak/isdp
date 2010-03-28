#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GR2objangbis.C */
extern IGRboolean GR2objangbis __((IGRlong *msg, struct GRid *obj1, struct GRmdenv_info *env1, struct GRparms *parms1, IGRpoint pt1, struct GRid *obj2, struct GRmdenv_info *env2, struct GRparms *parms2, IGRpoint pt2, IGRshort *ext_flag, IGRdouble *dis, IGRpoint pt3, struct IGRbsp_curve *bc_ln));
static IGRboolean GRfindbis __((IGRlong *msg, struct IGRbsp_curve *bc1, struct IGRbsp_curve *bc2, IGRdouble *u1, IGRdouble *u2, IGRpoint pt1, IGRpoint pt2, IGRpoint ipoint, IGRshort *ext_flag, IGRdouble *dis, IGRpoint pt3, struct IGRbsp_curve *bc_ln));

#if defined(__cplusplus)
}
#endif


#undef __
