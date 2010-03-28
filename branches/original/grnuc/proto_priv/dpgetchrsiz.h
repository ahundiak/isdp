#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpgetchrsiz.C */
extern IGRint DPgetchrsiz __((IGRlong *msg, struct strk *strokes, struct f_facts *fun_facts, IGRchar *strk_ptr, IGRushort *character, IGRlong *char_size));

#if defined(__cplusplus)
}
#endif


#undef __
