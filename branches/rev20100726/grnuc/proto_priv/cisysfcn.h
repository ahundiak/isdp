#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/cisysfcn.c */
extern int SYSargcheck __((syscheck *f, PCIlist *call));
extern int cisymb __((PCIlist *func));
extern void SYSinit __((void));
extern syscheck *SYSfind __((PCIident fn));
extern int mkSYS __((char *funcname));
extern int SYScall __((PCIlist *call));

#if defined(__cplusplus)
}
#endif


#undef __
