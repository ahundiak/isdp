#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/cierrmess.c */
extern int ciwarning __((char *why, char *data));
extern int ERRovr __((char *why, char *data));
extern int ERRsynL __((char *why, char *data, int line));
extern int ERRsyn __((char *why, char *data));
extern int WNGsyn __((char *why, char *data));
extern int ERRsys __((char *msg));
extern int ERRmem __((char *msg));
extern int cibugchk __((char *procedure, char *msg));
extern void PCIcatch __((int sig));
extern int cibygones __((char *code, char *why, char *data));
extern int ERRusr __((char *code, char *why, char *data));
extern int WNGusr __((char *why, char *data));
extern int cinotimpl __((char *why));
extern int cihelp __((int err));

#if defined(__cplusplus)
}
#endif


#undef __
