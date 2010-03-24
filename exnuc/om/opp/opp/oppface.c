/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* oppface.c - opp interface routines for dictionary			*/
/*									*/
/* Object PreProcessor - opp (v 4.0)					*/ 
/* Paul L. Hammond							*/
/* September 2, 1986							*/
/*									*/
/* Global Functions :							*/
/*									*/
/* Global Variables :							*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#include <stdlib.h>
#include "opp.h"
#include <cppout.h>
#include <string.h>
#include "oppy.h"
#include "identifier.h"
#include "lex3.h"
#include "lexinput.h"
#include "cpp.h"
#include "class.h"
#include "dumpmessage.h"
#include "hiersymtab.h"
#include "dcltrs.h"
#include "ordertab.h"

ordertab_ptr new_ordertab(int hashlength, FILE *log, void *owner);

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
#define SEPARATOR_C	'/'
#elif defined(NT)
#define SEPARATOR_C	'\\'
#else
#error Unknown OS
#endif

static symtab_ptr known_classes;

void exit_opp ()
 {
  opp_error_count += cpp_error_count;
  if (include_report) report_dcltr();
  if (oppout)
   {
    fclose (oppout);
#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
    if (!keep_mode && opp_error_count)
    if (!fork())
     {
      execl ("/bin/rm", "rm", oppout_name, 0);
      _exit (1);
     }
#elif defined(NT)
	if (!keep_mode && opp_error_count)
	{
		char	cmd[4096];

		strcpy(cmd, "rm ");
		strcat(cmd, oppout_name);
		system(cmd);
	}
#else
#error Unknown OS
#endif
   }
  exit (opp_error_count);
 } /* exit_opp */

void init_opp (cpp_flags)
char *cpp_flags[];
 {
  int cpp_options = 0;

  known_classes = new_basictab (17, 0);

  init_reserved_table ();

  if (yydebug)        cpp_options |= CPP_DEBUG;
  if (include_report) cpp_options |= CPP_WARN_ON | CPP_INFO_ON;
  if (filter_duplicate_includes) cpp_options |= CPP_DUPE_INCL_FILTER;

  cpp_init (cpp_flags, cpp_options, 0);
  cpp_stream_close (); /* don't need initial stream */
  active_stream = 0;
 } /* init_opp */

static int opp_parse_class (class, p_class)
 char *class;
 struct opp_class_def **p_class;
 {
  char file_name[SYMBOL_LENGTH];
  char classname[SYMBOL_LENGTH], *p;
  struct cpp_stream *inactive_stream = active_stream;
  struct opp_class_def *saved_active_class = active_class;
  FILE *saved_oppout = oppout;
  identifier_ptr class_symbol;

#ifdef DEBUG
  printf ("opp_parse_class %s\n", class);
#endif
  strcpy (file_name, class);
  strcat (file_name, ".S");
 
  if (p = strrchr(class, SEPARATOR_C))
   strcpy (classname, p+1);
  else
   strcpy (classname, class);
    
  active_class = new_class (classname);

  if (active_stream) cpp_deactivate ();
  cpp_init_stream ((char *)active_class);
  cpp_open (file_name);

  active_class->member_of_build = 0;
  if (!opping_for_discos)
   active_class->sym_tab = sym_table = (symtab_ptr)
		 new_ordertab(117, yydebug ? stdout : NULL, active_class);
  else
   active_class->sym_tab = sym_table = (symtab_ptr)
		 new_hiersymtab(117, yydebug ? stdout : NULL, active_class);
  if (!opping_for_discos)
   active_class->tag_tab = tag_table = (symtab_ptr)
		 new_ordertab(117, yydebug ? stdout : NULL, active_class);
  else
   active_class->tag_tab = tag_table = (symtab_ptr)
		 new_hiersymtab(117, yydebug ? stdout : NULL, active_class);
  active_class->define_tab = active_stream->define_table;
  active_class->omdef_tab = active_stream->omdef_table;
  active_class->filename_tab = active_stream->file_table;

  class_symbol = new_identifier (classname);
  class_symbol->s.tok = CLASS_NAME;
  enter_symbol (sym_table, class_symbol);

  oppout = 0;
  if (yyparse())
   {
    printerr (1);
    fprintf (stderr, " exiting with syntax errors.\n");
    exit_opp ();
   }
  *p_class = active_class;
  

  /* protect symbol tables before closing stream */
  symtab_write_protect (active_stream->define_table);
  symtab_write_protect (active_stream->omdef_table);
  symtab_write_protect (active_stream->file_table);
  unmark_all_written_symbols(); /* resets all symbols that were dumped to .c file */
  cpp_stream_close ();
  active_stream = 0;

  /* restore context */
  if (active_class = saved_active_class)
   {
    sym_table = active_class->sym_tab;
    tag_table = active_class->tag_tab;
    active_stream = inactive_stream;
    oppout = saved_oppout;
    if (active_stream) cpp_activate ();
   }

  return 0; /* success */
 } /* opp_parse_class */

static void free_sym (s)
 identifier_ptr s;
 {
  register identifier_ptr p = s->field_link;

  if (s->s.tok == MESSAGE_NAME)
   while (p)
    {
     identifier_ptr f = p->link;
     free (p);
     p = f;
    }

  free (s);
 } /* free_sym */

static void free_tag (s)
 identifier_ptr s;
 {
  register identifier_ptr p = s->field_link;
/* +------- 1/93 saw  identifiers were being freed here within loop
                      then freed again in a consequent call as 's'
  if (s->s.tok != ENUM_TAG)
   while (p)
    {
     identifier_ptr f = p->link;
     free (p);
     p = f;
    }
   +-------
*/
  free (s);
 } /* free_tag */

opp_process_impl_file (file_name, pp_class)
 char *file_name; 
 struct opp_class_def **pp_class; /* output */
 {
  struct cpp_stream *inactive_stream = active_stream;
  struct opp_class_def *saved_active_class = active_class;
  FILE *saved_oppout = oppout;
  int saved_outlines = outlines;
  int saved_out_line = cur_out_line;
  struct imported_message *saved_imports_list = imports_list;
  char saved_oppout_name[256];
  
  strcpy (saved_oppout_name, oppout_name);

#ifdef SFAN
  strcpy (oppout_name, "/dev/null");
#else
  strcpy (oppout_name, file_name);
  strcpy (strrchr (oppout_name, '.'), ".c");
#endif

  cpp_init_stream (NULL);
  cpp_open (file_name);

  imports_list = 0;
  outlines = 0;
  cur_out_line = 1;
  oppout = fopen (oppout_name, "w");

  if (!oppout)
   {
    fprintf (stderr, " open failure on \"%s\".\n", oppout_name);
    return (1);
   }

  define_macros (); /* Writes macros in output file (dumpmessage.c). */

  if (!opping_for_discos)
   sym_table = (symtab_ptr)new_ordertab(117, yydebug ? stdout : NULL, active_class);
  else
   sym_table = (symtab_ptr)new_hiersymtab(117, yydebug ? stdout : NULL, active_class);
  if (!opping_for_discos)
   tag_table = (symtab_ptr)new_ordertab(117, yydebug ? stdout : NULL, active_class);
  else
   tag_table = (symtab_ptr)new_hiersymtab(117, yydebug ? stdout : NULL, active_class);
  active_class = NULL; /* force errors if referenced before established */

  ptree_init ();
  if (yyparse())
   {
    printerr (1);
    fprintf (stderr, " exiting with syntax errors.\n");
    exit_opp ();
   }
  *pp_class = active_class;
  ptree_end ();


  free_imports_list(); /* this has info discos might use for dependencies */
  delete_symbol_table (active_class->sym_tab, free_sym);
  delete_symbol_table (active_class->tag_tab, free_tag);
  delete_sharing (active_class->basic_sharing);
  delete_sharing (active_class->struct_sharing);
  delete_sharing (active_class->enum_sharing);
  delete_dcltr_sharing (active_class->share_list);
  active_class->sym_tab = 0;
  active_class->tag_tab = 0;
  active_class->omdef_tab = 0;
  active_class->define_tab = 0;
  free (active_class);

  unmark_all_written_symbols(); /* resets all symbols that were dumped to .c file */
  cpp_stream_close ();
  active_stream = 0;

  fclose (oppout);

  /* restore context */
  if (active_class = saved_active_class)
   {
    sym_table = active_class->sym_tab;
    tag_table = active_class->tag_tab;
    active_stream = inactive_stream;
    oppout = saved_oppout;
    outlines = saved_outlines;
    cur_out_line = saved_out_line;
    strcpy (oppout_name, saved_oppout_name);
    imports_list = saved_imports_list;
   }

  return 0; /* success */
 } /* opp_process_impl_file */

struct known_class
 {
  struct symbol s;
  struct opp_class_def *class;
 };

static struct known_class *new_known_class (p)
 struct opp_class_def *p;
 {
  struct known_class *kc;

  kc = (struct known_class *) malloc (sizeof (*kc) + strlen (p->name) +1);

  kc->s.name = strcpy ((char *)(kc+1), p->name);
  kc->class = p;

  return kc;
 } /* new_known_class */

int lookup_class (class, p_class)
 char *class;
 struct opp_class_def **p_class;
 {
  int stat = 0;
  struct known_class *p; 
 
  if (p = (struct known_class *)lookup_symbol (known_classes, class))
   *p_class = p->class;
  else
   {
    stat = discos_get_class (class, 0, p_class);
    if (!lookup_symbol (known_classes, class))
     enter_symbol (known_classes, new_known_class (*p_class));
   }
  if (!stat)
   {
    symtab_write_protect ((*p_class)->sym_tab);
    symtab_write_protect ((*p_class)->tag_tab);
    symtab_write_protect ((*p_class)->define_tab);
    symtab_write_protect ((*p_class)->omdef_tab);
   }
  return stat;
 } /* lookup_class */

int opp_get_class (class, outgen, p_class)
 char *class;
 int outgen; /* boolean */
 struct opp_class_def **p_class;
 {
  int stat = 0;
  struct known_class *p; 
  char classname[SYMBOL_LENGTH], *p_name;

  if (p_name = strrchr (class, SEPARATOR_C))
   strcpy (classname, p_name+1);
  else
   strcpy (classname, class);
 
  if (p = (struct known_class *)lookup_symbol (known_classes, classname))
   *p_class = p->class;
  else
   {
    stat = opp_parse_class (class, p_class);
    enter_symbol (known_classes, new_known_class (*p_class));
   }
  
  (*p_class)->member_of_build = outgen;

  if (outgen)
   {
    FILE *saved_oppout = oppout;
    int saved_outlines = outlines;
    int saved_out_line = cur_out_line;
    struct opp_class_def *saved_active_class = active_class;
    symtab_ptr saved_sym_table = sym_table;
    symtab_ptr saved_tag_table = tag_table;
    char *saved_lex_filename = lex_filename;
    char saved_oppout_name[256];

    strcpy (saved_oppout_name, oppout_name);

    lex_filename = class;
    strcpy (oppout_name, class);
    strcat (oppout_name, ".c");
    outlines = 0;
    cur_out_line = 1;
    oppout = fopen (oppout_name, "w");
    if (!oppout)
     {
      fprintf (stderr, " open failure on \"%s\".\n", oppout_name);
      return (1);
     }
    active_class = (*p_class);
    if (active_class)
     {
      sym_table = active_class->sym_tab;
      tag_table = active_class->tag_tab;
      generate_class_init (active_class);
     }
    else
     fprintf (stderr, " opp internal error - failed to lookup class symbol\n");
    fclose (oppout);

    if (active_class = saved_active_class)
     {
      tag_table = saved_tag_table;
      sym_table = saved_sym_table;
      lex_filename = saved_lex_filename;
      oppout = saved_oppout;
      cur_out_line = saved_out_line;
      outlines = saved_outlines;
      strcpy (oppout_name, saved_oppout_name);
     }
   }

  return stat; 
 } /* opp_get_class */

