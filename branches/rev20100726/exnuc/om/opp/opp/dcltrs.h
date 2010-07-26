
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* dcltrs.h - functions related to the processing of C declarators	*/ 
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* March 21, 1986							*/
/*									*/
/* The dcltr struct is defined in identifier.h				*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef DCLTRS_INCLUDED
#define DCLTRS_INCLUDED
#include <stdio.h>
#include "identifier.h"

/*
  A dcltr record represents either a pointer an array or a function.  Or it
  is a type qualifier const or volatile.
  Routines are provided to append any one of these to a list of dcltrs.
  These are:
   append_pointer_dcltr
   append_function_dcltr
   append_array_dcltr
   append_const_dcltr
   append_volatile_dcltr
  each of which calls append_dcltr.

  Each of these functions return a pointer to the resulting list.
*/

extern int total_dcltr_count;

#define new_dcltr() (dcltr_ptr)(total_dcltr_count++, malloc (sizeof (struct dcltr)))

#define freedcltr(d) (--total_dcltr_count, free (d))

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

/* dcltrs.c */
dcltr_ptr append_dcltr __((dcltr_ptr new, dcltr_ptr old));
 /* "new" list of dcltr structs linked by "next"
     is appended to the far end of the "old" list.
     Either list may be empty (NULL).
 */

dcltr_ptr append_dcltr_copy __((dcltr_ptr new, dcltr_ptr old));
 /* Same as append_dcltr (above) except the new list is copied first */

dcltr_ptr append_bitfield_dcltr __((dcltr_ptr old, int width));
 /* Bitfields are appended to the front of the list rather than the back */

dcltr_ptr append_pointer_dcltr __((dcltr_ptr old));
dcltr_ptr append_const_dcltr __((dcltr_ptr old));
dcltr_ptr append_volatile_dcltr __((dcltr_ptr old));
dcltr_ptr append_array_dcltr __((dcltr_ptr old, int size));
dcltr_ptr append_function_dcltr __((dcltr_ptr old, identifier_ptr params));
void dump_dcltr __((FILE *afile, identifier_ptr s));
int equal_dcltr __((dcltr_ptr d, dcltr_ptr d1));
identifier_ptr params_of_function_dcltr __((identifier_ptr f));

/* free_dcltr should be called with care. */
/* Parts of dcltr lists are shared when   */
/* typedefs are used which have dcltrs.   */
void free_dcltr __((dcltr_ptr d));

/*
   The "setlisttype" function sets the type of
   each member in a list of identifier records.
   This type consists of two parts, a Type_Info
   record and a tokentype value .
*/
void setlisttype __((identifier_ptr list, struct Type_Info type, int tok));

void messagefy_dcltrs __((identifier_ptr s));
void report_dcltr __((void));
int last_dcltr_is_ptr __((dcltr_ptr p));

#if defined(__cplusplus)
}
#endif

#endif /* DCLTRS_INCLUDED */
/* End dcltrs.h */
