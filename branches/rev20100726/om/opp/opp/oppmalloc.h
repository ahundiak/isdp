
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* oppmalloc.h - opp malloc filter function 				*/
/*									*/
/* Paul L. Hammond							*/
/* November 20, 1986							*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef OPPMALLOC_INCLUDED
#define OPPMALLOC_INCLUDED

#if 0
/* The blank string is used for static storage */
#define malloc(A) opp_malloc ((A), "        ", __LINE__, __FILE__)
#define free opp_free

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

/* oppmalloc.c */
void opp_malloc_report __((void));
void bad_item __((struct memory_hunk *p));
void opp_free __((struct memory_hunk *p));
char *opp_malloc __((int byte_count, struct opp_malloc_ident *id, int line, char *file));
void opp_init_malloc_size __((int size));

#if defined(__cplusplus)
}
#endif

#else

#include <malloc.h>

#endif

#endif /* OPPMALLOC_INCLUDED */
