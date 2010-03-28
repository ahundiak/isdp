#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/cisymtab.c */
extern int STBhashc __((hkey *kfield, int tsize));
extern int STBcmp __((hkey *kf1, hkey *kf2));
extern int STBenter __((char *key, int number, int kind));
extern int STBfind __((char *key, int type));
extern void STBremove __((char *key, int type));
extern int STBcreate __((void));
extern void STBdestroy __((void));

#if defined(__cplusplus)
}
#endif


#undef __
