#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/AStext/text_util.I */
extern int ASfind_font_info __((IGRshort font, struct vfont_entry *font_info));

#if defined(__cplusplus)
}
#endif


#undef __
