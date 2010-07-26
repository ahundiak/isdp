#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUrad50.C */
extern int GUascii_to_rad50 __((IGRint *num_chars, IGRchar *string, IGRushort rad_50[]));
extern int GUrad50_to_ascii __((IGRlong *num_words, IGRushort *rad_50, IGRchar *string));

#if defined(__cplusplus)
}
#endif


#undef __
