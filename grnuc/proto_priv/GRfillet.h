#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRfillet.I */
extern IGRboolean GRfillet __((IGRlong *msg, struct GRid *obj1, struct GRmd_env *env1, IGRpoint pt1, struct GRparms *parms1, struct GRid *obj2, struct GRmd_env *env2, IGRpoint pt2, struct GRparms *parms2, IGRdouble *radius, struct IGRline *center, IGRshort *trim_flag, IGRpoint tr_pnt1, IGRpoint tr_pnt2, struct IGRbsp_curve *arc, GRobjid *newid1, GRobjid *newid2));

#if defined(__cplusplus)
}
#endif


#undef __
