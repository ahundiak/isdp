#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/font/fontmgr/GRisitfnt.C */
extern IGRboolean GRisitfnt __((IGRlong *msg, IGRuchar *font_file, IGRint *num_chars, IGRchar *typeface));

#if defined(__cplusplus)
}
#endif


#undef __
