#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/cob/strindex.C */
extern int bool_strindex __((char *s, char *t));

#if defined(__cplusplus)
}
#endif


#undef __
