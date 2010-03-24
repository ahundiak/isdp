/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* class.h - declarations for class.c					*/
/*									*/
/* August 7, 1986							*/
/* Paul L. Hammond							*/
/* Object PreProcessor							*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef CLASS_INCLUDED
#define CLASS_INCLUDED

#include "share.h"
#include "carriers.h"
#include "identifier.h"

struct inherited_msg
 {
  struct inherited_msg *next;
  identifier_ptr msg;
  identifier_ptr cls;
 };

struct opp_class_def
 {
  char 		   *name;
  identifier_ptr   instance_fields;	/* linked by "link" */
  identifier_ptr   messages;		/* linked by "link" */
  int		   message_count;	/* number of messages declared */
  symtab_ptr	   sym_tab;		/* all non-tag symbols known by class */
  symtab_ptr	   tag_tab;		/* all tag symbols known by class */
  symtab_ptr	   define_tab;		/* cpp macros */
  symtab_ptr	   omdef_tab;		/* omdef macros */
  symtab_ptr	   filename_tab;	/* included files */
  unsigned int	   flags;		/* ??? */
#define F_CLASS_MARKED		1	/* General purpose, clear before use */
#define F_CLASS_TAGGABLE	2	/* Taggable keyword found in specfile */
#define F_CLASS_NOT_TAGGABLE	4	/* not_taggable keyword found in specfile */
  int		   parent_count;	/* dimension of A_parents */
  struct opp_class_def **A_parents;	/* array of parent classes */
  short		   major_version; 
  short		   minor_version;
  int		   member_of_build;	/* true if writing output file */

  /* opp internal stuff - not in dictionary */

  carrier_ptr	override_list;		/* messages from ancestor classes */
  carrier_ptr	component_list;
  int		component_count;

  identifier_ptr indexed_enum_list;
  int next_enum_index;

  struct share_descr basic_sharing;
  struct share_descr struct_sharing;
  struct share_descr enum_sharing;

  struct sharing *share_list;
  int dcltr_count;
  int phantom_count;
  carrier_ptr reject_list;	 /* reject ... */
  struct inherited_msg *inherited_methods; /* from class inherit ... */
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

/* class.c */
struct opp_class_def *new_class __((char *name));
void attach_tables __((struct opp_class_def *cl1, struct opp_class_def *cl2));
void hook_up_parents __((struct opp_class_def *cl, carrier_ptr car));

#if defined(__cplusplus)
}
#endif

#endif /* ndef CLASS_INCLUDED */
