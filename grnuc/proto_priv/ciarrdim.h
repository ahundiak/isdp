#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciarrdim.c */
extern int DIMfind __((PCIlist *seq));
extern int mkDIM __((PCIlist *seq));
extern void DIMfree __((void));
extern int DIMall __((int id));

#if defined(__cplusplus)
}
#endif


#undef __
