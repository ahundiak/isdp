#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/gde/gdedriver/chkerror.c */
extern int chkerror __((int sts, char *string));

#if defined(__cplusplus)
}
#endif


#undef __
