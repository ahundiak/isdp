#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/macro/ACsym_prt.I */
extern int cmp_symb __((struct GRsymbology *symb1, struct GRsymbology *symb2));
extern int change_symb __((int spos, int epos, struct GRsymbology *symb, FILE *stream, char *name));

#if defined(__cplusplus)
}
#endif


#undef __
