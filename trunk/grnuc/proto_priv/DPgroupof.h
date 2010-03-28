#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/DPgroupof.C */
extern IGRint DPproc_group_of __((IGRlong *msg, IGRlong *elig_mask, IGRlong *ly_mask, IGRchar *elig_string));
extern IGRchar *COstrp_blnks __((char *token));

#if defined(__cplusplus)
}
#endif


#undef __
