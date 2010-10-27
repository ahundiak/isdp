extern int atomic_line_position;

#define debug 1

struct dtree_node
{
   char *fname;
   struct dtree_node *next,*dep;

	/* flags */

   unsigned int	DN_macro:1;	/* fname is a MACRO 	*/
   unsigned int  DN_nodep:1;	/* don't search for dep's */
};

struct source_group_node
{
   char  *sgrp_name;
   struct dtree_node	*spec_list, 
			*imp_list, 
			*C_list, 
			*c_list, 
			*assm_list,
			*lex_list,
			*yacc_list,
			*unk_list;
   struct source_group_node   *next;
   struct dtree_node *execname;
   struct dtree_node *libname;
   struct dtree_node *linklib;
   struct dtree_node *archive;
   struct dtree_node *deplib;
};

struct source_present
{
 unsigned int   c:1;
 unsigned int   C:1;
 unsigned int   assm:1;
 unsigned int   lex:1;
 unsigned int   yacc:1;
 unsigned int   spec:1;
 unsigned int   imp:1;
 unsigned int   unk:1;
} src_flags;
 
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

/* exfilnam.c */
void convert_to_native_filename __((char *path, int is_executable_name));
int expand_macro __((char *in, char *out));
int is_absolute_path __((char *path));
int expand_filename __((char *in, char *out, int size));

/* fget_atom.c */
int fget_atom __((char *atom, FILE *infile));

/* fget_str.c */
int fget_str __((char *str, FILE *infile));

/* fread_input.c */
int fread_infile __((char *str, FILE *infile));

/* ignore.c */
struct dtree_node *get_ignore_list __((char *name));

/* is_file.c */
int is_file __((char *f));
char *find_in_path __((char *filename, char *path));

/* make_rules.c */
void write_opp_inference_rule __((char *transition, char *filter));
void write_rules __((void));

/* red_fname.c */
char *red_fname __((char *in_name));

/* reduce_pth.c */
void reduce_pth __((char *p));

/* str_malloc.c */
char *string_malloc __((char *a));

/* version.c */
int find_decimals __((char *str, int no));
int convert_version __((char *str));

#if defined(__cplusplus)
}
#endif

