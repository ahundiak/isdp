#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUtxtsubstr.c */
extern IGRboolean GUget_text_substring __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, struct vfont_entry *fontinfo, IGRboolean *convert, IGRint font_type, IGRint *flags, IGRshort *num_chars));

#if defined(__cplusplus)
}
#endif


#undef __
