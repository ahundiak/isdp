#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUgetfontnum.I */
extern IGRboolean GUgetfontnum __((IGRchar *fontinfo_ptr, IGRshort *font_num, GRobjid *fontid, IGRchar *fractionbit, struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
