#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRptalongcv.I */
extern int GRpoint_along_curve __((struct GRid GRid_in, IGRint endflag, IGRpoint dirpoint, IGRint num, IGRdouble *dist, IGRdouble *uparm, IGRdouble *out_point, struct GRid *cmp_id));

#if defined(__cplusplus)
}
#endif


#undef __
