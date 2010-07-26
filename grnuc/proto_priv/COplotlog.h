#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COplotlog.c */
extern void COplotlog_on __((void));
extern void COplotlog_off __((void));
extern void COplotlog __((char *string));

#if defined(__cplusplus)
}
#endif


#undef __
