#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRchrwhtsp.C */
extern IGRboolean GRchar_white_space __((IGRlong *msg, CharId character, struct vfont_entry *font_info, IGRdouble *left_space, IGRdouble *right_space));

#if defined(__cplusplus)
}
#endif


#undef __
