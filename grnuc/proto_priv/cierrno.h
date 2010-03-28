#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cierrno.C */
extern int CIreport_error __((long msg, int out, char *buf));
extern int CIprog_error __((long msg, char *text));

#if defined(__cplusplus)
}
#endif


#undef __
