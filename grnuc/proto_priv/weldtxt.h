#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_annot/weldtxt.I */
extern int DMmake_arc __((IGRint *msg, IGRdouble start_pt[3 ], IGRdouble middle_pt[3 ], IGRdouble end_pt[3 ], struct GRid *arc_grid, struct GRmd_env *md_env));
extern int DMmake_weld_symbol __((IGRboolean above, IGRshort osnum, struct DMweld_param *par_weld, struct DMsenv_param *par_senv, IGRchar *text_string, IGRshort *text_length));
extern int DMadd_weld_symbol __((int osnum, int text_font, int weld_char, char *string, short *length));
extern int DMappend_space __((char *text_string, int type, short *len, double space));
extern int DMget_weld_symbol_char __((IGRint symbol, IGRint weld_type, IGRchar *weld_char));
extern IGRint DMextract_text __((IGRboolean above, IGRboolean mul_text, IGRchar *text_string, struct DMweld_param *par_weld, struct GRid text_grid));

#if defined(__cplusplus)
}
#endif


#undef __
