#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/IGEcolor/DPcolors.C */
extern IGRint DPchek_clr_tbl __((IGRchar file_nme[]));
extern IGRint DPload_clr_tbl __((IGRchar file_nme[], IGRint *file_type));
extern IGRint DPsave_clr_tbl __((char file_nme[]));
extern IGRint DPret_clr_tbl __((IGRint *msg, IGRchar file_nme[], IGRint *file_type, IGRint *bg_color, IGRint *fg_color, IGRint *hl_color, IGRshort *num_colors, IGRint *colors, IGRshort *num_names, struct IGEcol_names *names));
extern void DPcnv_short __((char *s));
extern void DPcnv_int __((char *s));
extern int DPconv_read __((char *s, int n, int l, FILE *fp1));
extern int DPconv_write __((char *s, int n, int l, FILE *fp1));

#if defined(__cplusplus)
}
#endif


#undef __
