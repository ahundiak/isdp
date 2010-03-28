#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GRfontusrlnk.C */
extern IGRboolean GRfont_user_linkage __((IGRlong *msg, struct EX_fonts *font_parameters, IGRdouble *slant_angle, IGRint filled_text, IGRchar *ele_buf));

#if defined(__cplusplus)
}
#endif


#undef __
