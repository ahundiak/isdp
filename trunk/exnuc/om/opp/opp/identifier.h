
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* identifier.h - declarations for identifier symbols 			*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* March 20, 1986							*/
/* Derived from symtab.h October 1985					*/
/* Aug. 5, 1986 - modified for use with seperate class def structure	*/
/*									*/
/* Also includes :							*/
/*  struct dcltr and related enums					*/
/*  struct typeinfo and related enums				  	*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef IDENTIFIER_INCLUDED
#define IDENTIFIER_INCLUDED

#include "tokensym.h"

#define SYMBOL_LENGTH 100

typedef struct identifier_symbol *identifier_ptr;

/* C declarator information */

 enum dcltr_type {dt_pointer, dt_array, dt_function, dt_varray, dt_bitfield,
			dt_const, dt_volatile};

 typedef struct dcltr
  {
   struct dcltr		*next; 	/* Rest of dcltr in postfix order. */
   identifier_ptr 	params;/* List of parameter names if function. */
   int			size;	/* Dimension of array if array. */
   short int		index;  /* in OPPdcltr_index array */
   enum dcltr_type      type;	/*  */
  } *dcltr_ptr;

/* end of C declarator stuff */

/* Declarations for typeinfo */

 struct terminal_type_info
  {
   struct terminal_type_info *next;
   int typ; /* from oppdecldef.h */
   int index;
   identifier_ptr sym;
  };

 enum std_classes {noclass=0, auto_class, extern_class, static_class,
	 	   typedef_class, register_class, variable_class};

 enum std_types   {notype=0, char_type, int_type, float_type, void_type};

 enum std_sizes   {nosize=0, long_size, short_size};

 struct Type_Info
  {
   struct identifier_symbol  *type_link;
   struct dcltr	             *dcltr_link; /* NULL if simple name. */
   struct terminal_type_info *term;
   struct carrier *typedefName;
   enum std_classes std_class;
   enum std_types   std_type;
   enum std_sizes   std_size;
   unsigned int     unsigned_attribute : 1;
   unsigned int     signed_attribute : 1;
   unsigned int	    private_attribute : 1;
   unsigned int	    nomod_attribute : 1;
   unsigned int	    const_attribute : 1;
   unsigned int	    volatile_attribute : 1;
  };

 extern struct Type_Info empty_type; /* defined in typeinfo.c */

/* end typeinfo stuff */

/* Begin identifier stuff */

struct identifier_symbol
 {
  struct token_symbol s;
  /* Field description stuff */
  unsigned int	   flags;
#define F_IDENTIFIER_WRITTEN 	1	/* written to output file */
#define F_IDENTIFIER_IMPORTED	2	/* for class_names */
#define F_IDENTIFIER_COMPONENT  8	/* for classes */
#define F_IDENTIFIER_USED	16	/* for messages, structs types etc. */
#define F_IDENTIFIER_MARKED	32	/* for traversal limitation */
#define F_IDENTIFIER_PHANTOM	64	/* symbol is phantom */
#define F_IDENTIFIER_DUMMY	128	/* field should not be dumped */
#define F_IDENTIFIER_KNOWN	256	/* already known to dictionary */
  identifier_ptr   link;	/* general purpose list link. */
				/* to next field or enum name. */
  identifier_ptr   field_link;  /* to fields in struct, union, message */
				/* to enum names in enum */
				/* to (struct hook_spec *) for channel types */
  struct opp_class_def *classdef;	/* for all identifiers */
  identifier_ptr   copy_of_me;
  struct Type_Info type_info;	/* all about type */
  int		   index;	/* useage depends on tok */
  short		   subtype;	/* unused */
 };

extern symtab_ptr sym_table, tag_table;

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

/* identifier.c */
identifier_ptr append_fields __((identifier_ptr new, identifier_ptr old));
void reverse_fields __((identifier_ptr *m));
void free_link __((identifier_ptr s));
identifier_ptr new_identifier __((char *name));
identifier_ptr new_phantom_identifier __((struct opp_class_def *cls));
void process_purged_identifier __((identifier_ptr s));

#if defined(__cplusplus)
}
#endif

#endif /* IDENTIFIER_INCLUDED */
/* End identifier.h */
