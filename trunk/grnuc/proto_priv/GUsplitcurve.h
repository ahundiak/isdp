#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUsplitcurve.C */
extern int GUsplit_curve __((IGRlong *msg, IGRint *file_des, IGRchar *dgn_buf, IGRchar *igds, IGRint *igds_size, IGRchar class_name[], struct IGRbsp_curve *geometry, GRrange range, struct GRsymbology *symbology, struct GRprops *geometric_props, IGRshort *properties, struct IGResbc *bsc_attr));

#if defined(__cplusplus)
}
#endif


#undef __
