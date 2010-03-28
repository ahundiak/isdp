#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nodein/NDmacro_over.I */
extern int ACtrans_symb __((struct GRid context_go, struct GRid my_go));
extern int ACtrans_text __((struct GRid context_go, struct GRid my_go));

#if defined(__cplusplus)
}
#endif


#undef __
