#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/so/DEcvdisel.C */
extern int DEcvdiselem __((int *msg, struct DPele_header *buffer, int *mode, struct DP_information *dp_info, struct DEcv_soo_info *soo_info, short *type, IGRmatrix matrix));
extern int DEshow_only_one_soo __((long *msg, struct GRid *grid, double u, struct GRid *window, struct GRmd_env *md_env));
extern int DEshow_only_soo __((void));
extern int DEshow_all __((void));

#if defined(__cplusplus)
}
#endif


#undef __
