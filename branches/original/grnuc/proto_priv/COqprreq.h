#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COqprreq.C */
extern int COqprreq __((PIplotdata *pd, char *result));

#if defined(__cplusplus)
}
#endif


#undef __
