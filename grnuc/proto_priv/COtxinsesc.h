#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/textco/COtxinsesc.I */
extern IGRboolean COinsert_escape __((IGRlong *msg, IGRuchar **text_string, IGRshort *text_length, IGRshort *text_buf_size, IGRshort *position, enum font_type *cur_font_type, struct GRdpb_text_symb *text_symb, struct IGRdisplay *disp_attr));

#if defined(__cplusplus)
}
#endif


#undef __
