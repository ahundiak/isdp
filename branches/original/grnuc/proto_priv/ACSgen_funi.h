#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/symb_mac/ACSgen_funi.I */
extern short int ACSlocate_pattern __((char *Pattern, char *Source));
extern int get_dir __((IGRchar *tot_path, IGRint beg_ind, IGRint end_ind, IGRint *next_beg, IGRchar *dir));

#if defined(__cplusplus)
}
#endif


#undef __
