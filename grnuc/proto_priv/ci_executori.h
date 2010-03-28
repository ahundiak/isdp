#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/executor/ci_executori.I */
extern int ci_executor_put_q __((char *s, int resp));

#if defined(__cplusplus)
}
#endif


#undef __
