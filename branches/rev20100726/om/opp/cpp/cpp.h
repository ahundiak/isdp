#ifndef CPP_D_INCLUDED
#define CPP_D_INCLUDED	1

#include <stdio.h>
#include "tok.h"
#include "basictab.h"
#include "usagetab.h"
#include "char_st.h"
#include "omdef.h"


#define YYTEXT_SIZE 512


int cpp_options;
#define CPP_DEBUG		0x00000008
#define CPP_WARN_ON		0x00000004
#define CPP_INFO_ON		0x00000002
#define CPP_DUPE_INCL_FILTER	0x00000001

/*
	types:   The following is a collection of various types
		which may or may-not be of intrest to the user
		or users of this cpp package.
*/


struct ifstack_struct
 {
  int a;
  int elif;
  struct ifstack_struct *next;
 };


struct record_saver
 {
  int *rec;
  struct record_saver *next;
 };


struct filer
 {
  struct filer *next;
  struct char_stack *cs;
  struct record_saver *rs;
  int file_posit;
  FILE *ffile;
  char *filename;
  char *phantom_file;
  int linenum;
  int pol;
  int stdi;

  char *string_head; 	/* added to support inline string input */
  char *string_input;
  int is_string;
 };


/*
	The cpp_stream structure collects all the global variables
	of the cpp library so parallel streams can be open.
*/


struct cpp_stream
 {
  char *cur_filename;			/* fio */
  int cur_linenum;			/* fio */
  int cur_pol;				/* fio */
  struct char_stack *mcs;		/* fio: =0 */
  struct record_saver *mrs;		/* fio: =0 */
  struct filer *filer_stack;		/* fio: =0 */
  symtab_ptr assertion_table;
  symtab_ptr define_table;		/* prepro: =0 */
  symtab_ptr omdef_table;		/* prepro: =0 */
  symtab_ptr file_table;		/* prepro: =0 */
  struct ifstack_struct *ifstack;	/* prepro: =0 */
/* token in the stream */
  char yytext[YYTEXT_SIZE];		/* luther */
  int yylen;				/* luther */
  struct stripped_tok tok;		/* luther */
 };


extern struct cpp_stream *active_stream;
extern int cpp_error_count;


struct define_symbol
 {
  struct symbol symb;
  int no_of_pars;
  int parametric;
  struct cpp_token *parameters;
  struct cpp_token *define_tokens;
 };
#define DEFINE_SIZE sizeof(struct define_symbol)

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

/* char_st.c */
void push_char __((struct char_data c, struct char_stack **cs));
void push_string __((char *s, struct char_stack **cs, char *fname, int ln, int pl));
struct char_data pop_char __((struct char_stack **cs));
void char_stack_end __((void));
void close_char_stack __((struct char_stack **cs));
void dump_stack __((struct char_stack *cs));

/* cleanup.c */
void cpp_stream_close __((void));
void free_everything __((void));

/* cppdat.c */
void cpp_print_version __((void));

/* disco.c */
char *dump_macro __((struct define_symbol *mac));
char *dump_omdef __((struct om_macro *omac));

/* find_file.c */
char *string_malloc __((char *a));
void ff_free __((void));
void ff_add __((char *a));
char *find_file __((int mode, char *fn, char *cf));

/* loner.c */
void OMcpp_dump_it __((void));
void OMcpp_file __((char **argv));

/* parents.c */
char **parental_units __((char *filename));

/* prepro.c */
void call_free __((void *t));
void cpp_get_tok __((void));
void cpp_open __((char *a));
void cpp_unget_tok __((struct cpp_token *a));
void cpp_init_stream __((char *owner));
void cpp_init __((char **switches, long opts, char *owner));
void cpp_end __((void));

/* stream.c */
void cpp_deactivate __((void));
void cpp_activate __((void));

/* tok.c */
struct cpp_token *token_malloc __((void));
void token_unpack __((struct cpp_token *tt));
struct cpp_token *cpp_dupe_tok __((struct cpp_token *tt, struct cpp_token *tm));

#if defined(__cplusplus)
}
#endif

#endif
