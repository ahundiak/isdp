#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/IGEcolor/IGElogclrtab.C */
extern IGRint IGEread_log_table __((IGRint screen_no, IGRshort *num_colors, IGRshort *log_table));
extern IGRint IGEwrite_log_table __((IGRint screen_no, IGRint num_colors, IGRint no_shades, IGRshort *log_table));
extern IGRint IGEget_abs_color __((int screen_no, IGRshort log_color, IGRshort *abs_color));
extern IGRint IGEget_num_act_colors __((IGRint screen_no, IGRshort *num_col_shd, IGRint type));

#if defined(__cplusplus)
}
#endif


#undef __
