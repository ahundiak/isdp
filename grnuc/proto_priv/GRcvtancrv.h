#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRcvtancrv.I */
extern int GRget_curve_tan_radcrv __((struct GRid GRid_in, IGRdouble uparm, IGRpoint outpoint, IGRvector tan, IGRdouble *radcrv));

#if defined(__cplusplus)
}
#endif


#undef __
