#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/fconv/FF_src/FFerror.c */
extern int FF_report_error __((int status));
extern int FS_report_error __((int status));

#if defined(__cplusplus)
}
#endif


#undef __
