

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* odinsup.h - support for object debugger "odin".			*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* March 21, 1986							*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef ODINSUP_INCLUDED
#define ODINSUP_INCLUDED
#include "identifier.h"

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

/* odinsup.c */
int basic_type_of_type_info __((struct Type_Info t));
int print_indexed_struct_list __((void));
void share_terminal_dcltr __((identifier_ptr s));
void lookup_dcltr __((dcltr_ptr d, struct terminal_type_info *term));
void harness_messages __((identifier_ptr p_class));
void describe_instance __((identifier_ptr cl, char *instance_struct_name));

#if defined(__cplusplus)
}
#endif

#endif /* ODINSUP_INCLUDED */
/* End odinsup.h */
