

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* dumpmessage.h - functions for messages, structs, enums, unions etc.	*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* March 21, 1986							*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef DUMPMESSAGE_INCLUDED
#define DUMPMESSAGE_INCLUDED
#include <stdio.h>
#include "identifier.h"

struct imported_message
 {
  identifier_ptr m;
  identifier_ptr cl;
  struct imported_message *next;
 };

extern struct imported_message *imports_list;

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

/*
   Functions to Print Declarations :
   print_struct, print_declaration_list and dump_arg
   return the number of '\n' characters written to "fil".
 */

/* dumpmessage.c */
int local_processed_name __((identifier_ptr s));
int dump_arg __((FILE *fil, identifier_ptr a));
int print_declaration_list __((FILE *fil, identifier_ptr s, char *prefix));
int print_struct __((FILE *fil, identifier_ptr s));
void define_macros __((void));
int we_rejected_it __((identifier_ptr m));
int we_overrode_it __((identifier_ptr m));
void write_method_header __((identifier_ptr msg, identifier_ptr methargs, int inline_send));
int equivalent_type __((struct Type_Info t1, struct Type_Info t2));
void verify_method __((identifier_ptr *mess, identifier_ptr *methargs));
void free_imports_list __((void));
void verify_imported_message __((identifier_ptr m, identifier_ptr class_from_which_imported));
void dump_known_msg_structs __((identifier_ptr s));
void dump_messages __((identifier_ptr cl, int parsing_specification));
void dump_struct __((identifier_ptr s));
void dump_instance __((identifier_ptr s));
void end_struct_def __((identifier_ptr s));
void dump_inherited_types __((struct opp_class_def *cl, int extern_flag));
void verify_inherited_message __((identifier_ptr msg, identifier_ptr cls));
void print_ident_type __((identifier_ptr id));
char *get_table_name __((char **p));
void unmark_all_written_symbols __((void));
void mark_symbol_written __((identifier_ptr s));

#if defined(__cplusplus)
}
#endif

#endif /* DUMPMESSAGE_INCLUDED */
/* End dumpmessage.h */
