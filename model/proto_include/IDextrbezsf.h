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

/* IDextrbezsf.I */
extern IGRlong IDextrbezsf __((IGRlong *msg, IGRushort opts, 
	IGRshort *mattyp, IGRmatrix mat, IGRpoint modpole, 
	IGRushort pole_flag, struct IGRbsp_surface *insurf, 
	struct GRid *insurf_id, struct IGRbsp_surface **outsurf));

#if defined(__cplusplus)
}
#endif

