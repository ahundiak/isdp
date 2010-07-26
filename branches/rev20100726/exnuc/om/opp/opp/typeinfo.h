

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* typeinfo.h - functions related to Type_Info structs			*/ 
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* March 21, 1986							*/
/*									*/
/* The Type_Info struct is defined in identifier.h			*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef TYPEINFO_INCLUDED
#define TYPEINFO_INCLUDED
#include "identifier.h" /* symbol table declarations     */

extern struct Type_Info empty_type;

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

/* typeinfo.c */
/* print_type_info returns the number of '\n's written to "fil". */
int print_type_info __((FILE *fil, struct Type_Info t));

struct Type_Info merge_type_info __((struct Type_Info ta, struct Type_Info tb, int dcltr_merge));
 /* struct Type_Info ta; from the decl_specifier */
 /* struct Type_Info tb; from the dcltr */
 /* int dcltr_merge;     boolean - if true append tb dcltr list to ta. */

#if defined(__cplusplus)
}
#endif

#endif /* TYPEINFO_INCLUDED */
/* End typeinfo.h */
