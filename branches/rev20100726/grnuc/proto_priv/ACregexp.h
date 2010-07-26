#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/macro/ACregexp.C */
extern int AScheckRE __((char *in, char *out));
extern int ASmatchREGEXP __((char *pat, char *sub));
extern int ASmatchRE __((char *pat, char *sub));

#if defined(__cplusplus)
}
#endif


#undef __
