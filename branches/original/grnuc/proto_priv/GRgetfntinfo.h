#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/font/fontmgr/GRgetfntinfo.I */
extern IGRint GRget_font_info __((IGRlong *msg, IGRshort *font_num, struct GRid *fontmgr, struct vfont_entry *font_info));

#if defined(__cplusplus)
}
#endif


#undef __
