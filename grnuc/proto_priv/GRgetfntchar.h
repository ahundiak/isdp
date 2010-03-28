#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/font/fontutil/GRgetfntchar.C */
extern IGRint GRgetfontchar __((int msg, struct vfont_entry *fontinfo, IGRuchar *charcode, IGRshort *font, IGRuchar *newcode));

#if defined(__cplusplus)
}
#endif


#undef __
