#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRblocktext.C */
extern IGRint GRblock_text __((IGRlong *msg, IGRuchar **text_string, struct IGRestx *text_attr, struct IGRlbsys *lbsys, IGRdouble line_length, IGRint autowrap, IGRdouble word_space_factor));

#if defined(__cplusplus)
}
#endif


#undef __
