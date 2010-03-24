#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* quefree.c */
void que_free __((identifier_ptr t));
void free_que __((void));

#if defined(__cplusplus)
}
#endif

