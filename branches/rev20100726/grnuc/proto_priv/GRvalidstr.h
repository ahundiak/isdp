#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRvalidstr.C */
extern IGRboolean GRvalid_string __((IGRlong *msg, IGRuchar *string, IGRshort *text_length, IGRshort prev_font, IGRshort current_font, struct vfont_entry *font_info));

#if defined(__cplusplus)
}
#endif


#undef __
