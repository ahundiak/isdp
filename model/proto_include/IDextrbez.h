#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* IDextrbez.I */
extern IGRlong IDget_crv_patch_affected_by_pole_deletion __((IGRlong *msg, 
	IGRushort opts, IGRshort *mattyp, IGRmatrix mat, 
    IGRpoint pole, struct IGRbsp_curve *incrv, struct GRid *incrv_id, 
    struct IGRbsp_curve **outcrv));

#if defined(__cplusplus)
}
#endif

