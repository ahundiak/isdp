#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/AScontentsi.I */
extern int asmake_contents __((struct GRid ref, struct GRid *contents));

#if defined(__cplusplus)
}
#endif


#undef __
