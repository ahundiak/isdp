#ifndef OMDEF_D_INCLUDED
#define OMDEF_D_INCLUDED	1

struct om_macro
 {
  struct symbol symb;
  int parametric;
  struct para_symbol *para_link;
  symtab_ptr para_table;
  struct cpp_token *def_link;
 };

struct para_symbol
 {
  struct symbol symb;
  int has_default;
  struct cpp_token *defaults;
  int para_id;
  struct para_symbol *next;
  struct para_symbol *splink;
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

/* omdef.c */
void free_omdef __((struct om_macro *tt));
void process_omdef __((void));
void process_endomdef __((void));
void proc_omdef __((void));
void cpp_handle_omdef __((struct om_macro *ods));

#if defined(__cplusplus)
}
#endif

#endif
