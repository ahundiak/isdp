#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpchgfstfnt.C */
extern int DPchg_fst_fnt __((IGRlong *msg, struct DPfnt_os_tbl *fnt_os_tbl, GRspacenum fnt_os, IGRshort fst_char_fnt, IGRshort fst_frac_fnt, IGRshort fst_16bit_fnt));

#if defined(__cplusplus)
}
#endif


#undef __
