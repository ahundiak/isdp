#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/DPindlyof.C */
extern IGRint DPproc_mask_of __((IGRlong *msg, IGRlong *elig_mask, struct GRindlayer *ind_ly));

#if defined(__cplusplus)
}
#endif


#undef __
