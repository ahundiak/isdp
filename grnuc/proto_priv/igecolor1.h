#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/IGEcolor/igecolor.C */
extern void IGEbuild_log_table __((IGRshort num_colors, IGRshort num_shades, IGRint vlt_start_slot, IGRshort *log_table));

#if defined(__cplusplus)
}
#endif


#undef __
