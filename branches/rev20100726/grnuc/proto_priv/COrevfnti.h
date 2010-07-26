#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/font/fontco/COrevfnti.I */
extern void GRfont_form_notify __((int form_label, int gadget_label, double value, Form form_ptr));
extern IGRint display_font __((Form form1, struct EXlstfnt *font_struct, IGRint row));

#if defined(__cplusplus)
}
#endif


#undef __
