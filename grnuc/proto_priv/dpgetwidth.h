#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpgetwidth.C */
extern IGRint DPgetwidth __((IGRlong *msg, struct strk *strokes, struct f_facts *fun_facts, struct wids *widths, IGRushort *character, IGRboolean *first_char, IGRlong *abc_width, IGRdouble *width, IGRdouble *prev_width, IGRdouble *ideal_char_width, IGRchar **strk_ptr, IGRchar *undef_char_ptr, IGRshort *vec_resolution, IGRdouble *txt_x_scale, IGRboolean *is_char_defined));

#if defined(__cplusplus)
}
#endif


#undef __
