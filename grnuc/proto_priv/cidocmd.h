#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/cidocmd.c */
extern int CMDbegin __((int cmd));
extern int CMDend __((void));
extern int KEYbegin __((int cmd));

#if defined(__cplusplus)
}
#endif


#undef __
