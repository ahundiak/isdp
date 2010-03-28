#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/attrib/ACrg_coli.I */
extern int ACcol_set_type_val __((IGRchar *txt_att, struct ACrg_coll *attrib));

#if defined(__cplusplus)
}
#endif


#undef __
