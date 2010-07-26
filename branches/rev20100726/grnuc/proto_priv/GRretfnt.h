#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/font/fontmgr/GRretfnt.I */
extern IGRint GRretrieve_font __((IGRlong *msg, IGRuchar *fontfile, IGRuchar *local_font_name, IGRshort font_flags, struct GRid *fontmgr, IGRshort *position));

#if defined(__cplusplus)
}
#endif


#undef __
