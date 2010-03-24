
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* share.h - support for shared dcltrs.					*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* March 21, 1986							*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef SHARE_INCLUDED
#define SHARE_INCLUDED
#include "identifier.h"
#include "oppdecldef.h"

struct share_descr
 {
  struct terminal_type_info *list;
  int count;
 };

struct sharing
 {
  struct sharing *next;
  dcltr_ptr d;
  struct terminal_type_info *term;
 };

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

/* share.c */
void delete_sharing __((struct share_descr shares));
struct terminal_type_info *share_type __((int typ, identifier_ptr p, struct share_descr *p_shares));
void share_dcltrs __((dcltr_ptr *d, struct terminal_type_info *term));
void dump_dcltrs __((void));
void delete_dcltr_sharing __((struct sharing *share_list));

#if defined(__cplusplus)
}
#endif

#endif /* SHARE_INCLUDED */
/* End share.h */
