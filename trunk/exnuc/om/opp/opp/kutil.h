#ifndef KUTIL_D_INCLUDED
#define KUTIL_D_INCLUDED 1

/*
 *   kutil.h contains the declarations of the declarations of the 
 *   pnode types.  Structures are declared which coorespond to the
 *   format of a parse tree node.  (note) parse_tree nodes contain
 *   an integer header to denote what type the node is.
 *   They also contain an integer trailing flag of -1.  In the
 *   interior of the node is an array of pointers.
 */

#include "ptoken.h" /* for struct pnode_token */

typedef struct
 {
  identifier_ptr id_ptr;
  identifier_ptr fld_ptr;
 } fs_retval;

struct iae_bag
 {
  int typ;
  fs_retval data;
 };

struct pnode_inst_access_exp
 {
  int typ;
  struct pnode_token *me_tok;
  struct pnode_token *pointer_tok;
  struct pnode_token *sqointer_tok;
  struct pnode_token *classname;
  struct pnode_token *dot_tok;
  struct pnode_token *fieldname;
  struct iae_bag *bag;
  int end_flag;
 };


struct pnode_local_data_declaration
 {
  int typ;
  struct pnode *specifier;
  struct pnode *dcltr;
  struct pnode_token *semi;
  int end_flag;
 };

struct pnode_typename_declaration
 {
  int typ;
  struct pnode *specifier;
  struct pnode *dcltr;
  int end_flag;
 };

struct pnode_formal_declaration
 {
  int typ;
  struct pnode *specifier;
  struct pnode *dcltr;
  int end_flag;
 };

struct message_bag
 {
  int typ;
  identifier_ptr bcn,bmn,bdc;
  int buf_i;
 };

struct pnode_message_buff
 {
  int typ;
  struct pnode_token *message;
  struct pnode_token *classname;
  struct pnode_token *dot;
  struct pnode_token *method;
  struct pnode_token *open_paren;
  struct pnode *list_express;
  struct pnode_token *close_paren;
  struct message_bag *bag;
  int end_flag;
 };


struct pnode_compound_stmt
 {
  int typ;
  struct pnode_token *open_squirly;
  struct pnode *declarations;
  struct pnode *stmts;
  struct pnode_token *close_squirly;
  int end_flag;
 };


struct pnode_struct_specifier
 {
  int typ;
  struct pnode_token *struct_tok;
  struct pnode_token *tag;
  struct pnode_token *open_squirly;
  struct pnode *field_list;
  struct pnode_token *close_squirly;
  int end_flag;
 };


struct pnode_opt_decl_list
 {
  int typ;
  struct pnode_opt_decl_list *podl;
  struct pnode_local_data_declaration *pldd;
  int end_flag;
 };


struct pnode_decl_specifier
 {
  int typ;
  struct pnode_decl_specifier *decl_spec;
  struct pnode *tc_spec;
  int end_flag;
 };


struct pnode_p1_dcltr
 {
  int typ;
  struct pnode_token *open_paren;
  struct pnode *dcl;
  struct pnode_token *close_paren;
  int end_flag;
 };


struct pnode_function_dcltr
 {
  int typ;
  struct pnode *dcl;
  struct pnode_token *open_paren;
  struct pnode *formals;
  struct pnode_token *close_paren;
  int end_flag;
 };


struct pnode_array_dcltr
 {
  int typ;
  struct pnode *dcl;
  struct pnode_token *open_bracket;
  struct pnode *expr;
  struct pnode_token *close_bracket;
  int end_flag;
 };


struct pnode_pointer_dcltr
 {
  int typ;
  struct pnode_token *star;
  struct pnode *dcl;
  int end_flag;
 };


struct pnode_list_struct_declaration
 {
  int typ;
  struct pnode_list_struct_declaration *plsd;
  struct pnode_struct_declaration *struct_decl;
  int end_flag;
 };


struct pnode_struct_declaration
 {
  int typ;
  struct pnode_decl_specifier *pds;
  struct pnode_list_struct_dcltr *plsdcltr;
  struct pnode_token *semi;
  int end_flag;
 };


struct pnode_list_struct_dcltr
 {
  int typ;
  struct pnode_list_struct_dcltr *plsd;
  struct pnode_token *comma;
  struct pnode_struct_dcltr *psd;
  int end_flag;
 };


struct pnode_struct_dcltr
 {
  int typ;
  struct pnode *pd;
  struct pnode_token *colen;
  struct pnode *expr;
  int end_flag;
 };


struct pnode_list_init_dcltr
 {
  int typ;
  struct pnode_list_init_dcltr *plid;
  struct pnode_token *comma;
  struct pnode_init_dcltr *pid;
  int end_flag;
 };


struct pnode_init_dcltr
 {
  int typ;
  struct pnode *dcl;
  struct pnode_token *comma;
  struct pnode *i_exp;
  int end_flag;
 };

struct pnode_sizeof_fun
 {
  int typ;
  struct pnode_token *size_of;
  struct pnode_token *open_paren;
  struct pnode *typename_decl;
  struct pnode_token *close_paren;
  int end_flag;
 };

struct pnode_paren_exp
 {
  int typ;
  struct pnode_token *open_paren;
  struct pnode *expr;
  struct pnode_token *close_paren;
  int end_flag;
 };

struct pnode_type_cast
 {
  int typ;
  struct pnode_token *open_paren;
  struct pnode *typename_decl;
  struct pnode_token *close_paren;
  struct pnode *expr;
  int end_flag;
 };

struct pnode_unary_exp
 {
  int typ;
  struct pnode_token *operator;
  struct pnode *expr;
  int end_flag;
 };

struct pnode_postfix_exp
 {
  int typ;
  struct pnode *expr;
  struct pnode_token *operator;
  int end_flag;
 };

struct pnode_bin_exp
 {
  int typ;
  struct pnode *expr1;
  struct pnode_token *operator;
  struct pnode *expr2;
  int end_flag;
 };

struct pnode_cond_exp
 {
  int typ;
  struct pnode *expr1;
  struct pnode_token *question;
  struct pnode *expr2;
  struct pnode_token *colen;
  struct pnode *expr3;
  int end_flag;
 };

/*
struct pnode_struct_pointer_access
 {
  int typ;
  struct pnode *expr1;
  struct pnode_token *pointer;
  struct pnode *expr2;
  int end_flag;
 };

struct pnode_struct_access
 {
  int typ;
  struct pnode *expr1;
  struct pnode_token *dot;
  struct pnode *expr2;
  int end_flag;
 };
*/

struct pnode_function_call
 {
  int typ;
  struct pnode *expr1;
  struct pnode_token *open_paren;
  struct pnode *expr2;
  struct pnode_token *close_paren;
  int end_flag;
 };

struct pnode_array_access
 {
  int typ;
  struct pnode *expr1;
  struct pnode_token *open_bracket;
  struct pnode *expr2;
  struct pnode_token *close_bracket;
  int end_flag;
 };


struct pnode_enum_dcltr
 {
  int typ;
  struct pnode_token *id;
  struct pnode_token *equal;
  struct pnode *expr;
  int end_flag;
 };


struct pnode_enum_dcltr_list
 {
  int typ;
  struct pnode_enum_dcltr_list *pedl;
  struct pnode_token *comma;
  struct pnode_enum_dcltr *ped;
  int end_flag;
 };

struct pnode_enum_dcltr_body
 {
  int typ;
  struct pnode_token *open_squirly;
  struct pnode_enum_dcltr_list *pedl;
  struct pnode_token *comma;
  struct pnode_token *close_squirly;
  int end_flag;
 };

struct pnode_enum_specifier
 {
  int typ;
  struct pnode_token *Enum;
  struct pnode_token *tag;
  struct pnode_enum_dcltr_body *bod;
  int end_flag;
 };

struct pnode_instance_specifier
 {
  int typ;
  struct pnode_token *Instance;
  struct pnode_token *tag;
  int end_flag;
 };

struct pnode_struct_access
 {
  int typ;
  struct pnode *p2;
  struct pnode_token *dot;
  struct pnode_token *field_name;
  int end_flag;
 };

struct pnode_struct_pointer_access
 {
  int typ;
  struct pnode *p2;
  struct pnode_token *pointer;
  struct pnode_token *field_name;
  int end_flag;
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

/* kutil.c */
#ifdef WIN32
extern int new_pnode (int typer, ...);
#else
int new_pnode __((int typer, ...));
#endif
struct pnode_token *pnode_token_malloc __((void));
void ptree_end __((void));
void ptree_init __((void));
void ptree_push __((void));
void ptree_pop __((void));
void ptree_work_typedef __((struct pnode *pn));
identifier_ptr field_search __((identifier_ptr class, struct pnode_token *field));
void pp_string __((char *string));
#ifdef WIN32
extern void pp_fprintf (FILE *oppout, char *format, ...);
#else
void pp_fprintf __((FILE *oppout, char *format, ...));
#endif
void output_node __((struct pnode *p));
void free_tree __((struct pnode *p));
int find_inline_send __((struct pnode_bin_exp *p));
void ptree_meth_body __((struct pnode *p, identifier_ptr *msg, identifier_ptr *methargs, int inline_send));

#if defined(__cplusplus)
}
#endif

#endif
