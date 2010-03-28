#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRconsfunc.I */
extern IGRlong GRconsfunction __((struct GRvg_construct *arglist, GRobjid *objid, IGRshort *properties, IGRint *hidden_line, IGRshort *type));

#if defined(__cplusplus)
}
#endif


#undef __
