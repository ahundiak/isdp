#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_annot/dyn_txbln.I */
extern IGRint DMget_bln_txt_width __((IGRboolean flag, IGRshort *txt_length, struct DMsenv_param *par_senv, struct GRid text_grid, struct GRmd_env *md_env));
extern int DMisinput_kanji __((char *string, int length, IGRboolean *inp_type));
extern int DMget_exact_str __((char *string, int length, char *test_str, short *test_len));

#if defined(__cplusplus)
}
#endif


#undef __
