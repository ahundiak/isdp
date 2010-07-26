
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* typeinfo.c - functions related to Type_Info structs			*/ 
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* October 1985								*/
/*									*/
/* The Type_Info struct is defined in symtab.h				*/
/*									*/
/* The global functions defined in this file are :			*/
/*	type_allignment - finds the allignment for a type		*/
/*	type_size	- finds the number of bytes for a type		*/
/*	print_type_info - prints the type for a C declaration		*/
/*	merge_type_info - merges the info in two Type_Info structs	*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#define NULL 0
#include "typeinfo.h"
#include <stdio.h>
#include "oppy.h"
#include "dcltrs.h"
#include "dumpmessage.h"
#include "relations.h"
#include "lexinput.h"
#include "char_st.h"
#include "fio.h"

struct Type_Info empty_type =
	{0, 0, 0, 0, noclass, notype, nosize, 0,0,0,0,0,0};

/*
  The following four functions :
  	print_class
	print_std_type
	print_size
	print_unsigned (macro)
  are used by print_type_info.
  Each takes a file pointer and a Type_Info struct as arguments.
*/

static void print_class (fil, t)
 FILE *fil;
 struct Type_Info t;
 {
  char *text;

  switch (t.std_class)
   {
    case auto_class:     text = "auto ";     break;
    case extern_class:	 text = "extern ";   break;
    case register_class: text = "register "; break;
    case static_class:	 text = "static ";   break;
    case typedef_class:  text = "typedef ";  break;
    default:		 text = "";
   }
  fprintf (fil, text);
 } /* print_class */

static void print_std_type (fil, t)
 FILE *fil;
 struct Type_Info t;
 {
  char *text;

  switch (t.std_type)
   {
    case int_type:	text = "int ";	break;
    case char_type:  	text = "char ";	break;
    case float_type:	if (t.std_size != long_size)
                         text = "float ";
                        else
                         text = "double ";
                        break;
    case void_type: 	text = "void ";	break;
    default:		text = "";
   } /* switch */
  fprintf (fil, text);
 } /* print_std_type */

static void print_size (fil, t)
 FILE *fil;
 struct Type_Info t;
 {
  char *text;

  switch (t.std_size)
   {
    case short_size:	text = "short ";break;
    case long_size:	if (t.std_type != float_type)
                         text = "long ";
                        else
                         text = "";
                        break;
    default:		text = "";
   } /* switch */

  fprintf (fil, text);
 } /* print_size */

#define print_unsigned(fil,t) \
  { if ((t).unsigned_attribute) fprintf ((fil), "unsigned "); }

#define print_signed(fil,t) \
  { if ((t).signed_attribute) fprintf ((fil), "signed "); }

#define print_type_qualifier(fil,t) \
  { if ((t).const_attribute) fprintf ((fil), "const "); \
    if ((t).volatile_attribute) fprintf ((fil), "volatile "); }

int print_type_info (fil, t) /* returns count of lines written */
 FILE *fil;
 struct Type_Info t;
 {
  int count = 0;

  if (t.dcltr_link && t.dcltr_link->type == dt_varray)
   {
    fprintf (fil, "OM_S_VARLENARR_DESCR ");
    return 0;
   }
  print_class (fil, t);
  print_type_qualifier (fil, t);
  print_unsigned (fil, t);
  print_signed (fil, t);
  print_size (fil, t);
  print_std_type (fil, t);
#ifdef DEBUG
  if (fil != stderr)
   {
    fprintf (stderr, "\nprint_type_info -\n");
    if (t.type_link->flags & F_IDENTIFIER_PHANTOM)
     fprintf (stderr, " phantom\n");
    fprintf (stderr, " type_link = %x\n", t.type_link);
    if (t.type_link) print_struct (stderr, t.type_link);
   }
#endif
  if (t.type_link)
   {
    if (t.type_link->flags & F_IDENTIFIER_PHANTOM)
     count = print_struct (fil, t.type_link);
    else
     {
      char *text   = "";
      char *format;
 
      switch (t.type_link->s.tok)
       {
        case STRUCT_NAME :
        case CLASS_NAME  : text = "struct"; break;
        case UNION_NAME  : text = "union "; break;
        case ENUM_TAG    : text = "enum  "; break;
       }
     
      if (t.type_link->s.tok == CLASS_NAME)
       format = "%s %s_total_instance ";
      else
       format = "%s %s ";
 
      fprintf (fil, format, text, t.type_link->s.s.name);
     }
   }
  else if (t.typedefName)
   {
    carrier_ptr p;

    for (p = t.typedefName; p; p = p->next)
     fprintf (fil, "%s ", p->cargo->s.s.name);
    return 0;
   }

  return count;
 } /* print_type_info */

static carrier_ptr copy_typedef_name_list(p)
 carrier_ptr p;
 {
  carrier_ptr dest = 0;
 
  if (p)
   {
    carrier_ptr prev;

    dest = prev = carrier_node(p->cargo);
    for (p = p->next; p; p = p->next)
     {
      prev->next = carrier_node(p->cargo);
      prev = prev->next;
     }
   }
  return dest;
 } /* copy_typedef_name_list */

static carrier_ptr append_typedef_name_list(p1, p2)
 carrier_ptr p1;
 carrier_ptr p2;
 {
  carrier_ptr p;

  if (!p1 || !p2)
   {
    return p1 ? p1 : p2;
   }

  for (p = p1; p; p = p->next)
   if (!p->next)
    {
     p->next = p2;
     break;
    }

  return p1;
 } /* append_typedef_name_list */

struct Type_Info merge_type_info(ta, tb, dcltr_merge)
 struct Type_Info ta; /* from the decl_specifier */
 struct Type_Info tb; /* from the dcltr */
 int dcltr_merge;     /* boolean - if true append tb dcltr list to ta. */
 {
  struct Type_Info tc;/* value to be returned */

#ifdef DEBUG
  fprintf (stderr, "ta.dcltr_link = %d\ntb.dcltr_link = %d\n",
	   ta.dcltr_link,tb.dcltr_link);
#endif
  
  tc = ta;

  if (ta.typedefName)
   tc.typedefName = copy_typedef_name_list(ta.typedefName);
  if (tb.typedefName)
   tc.typedefName = append_typedef_name_list(tc.typedefName, 
	copy_typedef_name_list(tb.typedefName));

  if (ta.dcltr_link && tb.dcltr_link)
   {
    /* The only valid case where two dcltr lists are to be merged is
       when one is from a typedef in the decl_specifier and the other
       is from the dcltr.  In this case, dcltr_merge will be true and
       the typedef's dcltr list will be appended to the other one.
    */
    if (dcltr_merge)
     tc.dcltr_link = append_dcltr (tb.dcltr_link, ta.dcltr_link);
    else
     {
      printerr (1);
      fprintf (stderr, " illegal type combination.\n");
      file_traceback ();
     }
   }
  else if (!ta.dcltr_link) tc.dcltr_link = tb.dcltr_link;

# ifdef DEBUG
  fprintf (stderr, "tc.dcltr_link = %d\n", tc.dcltr_link);
# endif

  if (ta.std_type && tb.std_type)
   {
    printerr (ta.std_type != tb.std_type);
    fprintf (stderr, "basic type ");
    print_std_type (stderr, ta);
    fprintf (stderr, " already declared ");
    print_std_type (stderr, tb);
    fprintf (stderr, " ignored.\n");
    file_traceback ();
   }
  else if (!ta.std_type) tc.std_type = tb.std_type;

  if (ta.std_class && tb.std_class)
   {
    printerr (ta.std_class != tb.std_class);
    fprintf (stderr, " storage class ");
    print_class (stderr, ta);
    fprintf (stderr, "already declared - ");
    print_class (stderr, tb);
    fprintf (stderr, "ignored.\n");
    file_traceback ();
   }
  else if (!ta.std_class) tc.std_class = tb.std_class;
  if (ta.std_size && tb.std_size)
   {
    // XXX - Allow "long double", where (I think) ta.size_type == long_size && tb.std_size == long_size && tb.std_type == char_type
    if (ta.std_size != ta.std_size)
     {
      printerr (ta.std_size != tb.std_size);
      fprintf (stderr, " size attribute ");
      print_size (stderr, ta);
      fprintf (stderr, "already declared - ");
      print_size (stderr, tb);
      fprintf (stderr, "ignored.\n");
      file_traceback ();
     }
   }
  else if (!ta.std_size) tc.std_size = tb.std_size;

  if (ta.unsigned_attribute && tb.unsigned_attribute)
   {
    printerr (0);
    fprintf (stderr, " unsigned attribute already declared.\n");
    file_traceback ();
   }
  else
   if (!ta.unsigned_attribute) tc.unsigned_attribute = tb.unsigned_attribute;

  if (ta.signed_attribute && tb.signed_attribute)
   {
    printerr (0);
    fprintf (stderr, " signed attribute already declared.\n");
    file_traceback ();
   }
  else
   if (!ta.signed_attribute) tc.signed_attribute = tb.signed_attribute;

  if (ta.const_attribute && tb.const_attribute)
   {
    printerr (0);
    fprintf (stderr, " const attribute already declared.\n");
    file_traceback ();
   }
  else
   if (!ta.const_attribute) tc.const_attribute = tb.const_attribute;

  if (ta.volatile_attribute && tb.volatile_attribute)
   {
    printerr (0);
    fprintf (stderr, " volatile attribute already declared.\n");
    file_traceback ();
   }
  else
   if (!ta.volatile_attribute) tc.volatile_attribute = tb.volatile_attribute;

  if (ta.private_attribute && tb.private_attribute)
   {
    printerr (0);
    fprintf (stderr, " private attribute already declared.\n");
    file_traceback ();
   }
  else
   if (!ta.private_attribute) tc.private_attribute = tb.private_attribute;

  if (ta.nomod_attribute && tb.nomod_attribute)
   {
    printerr (0);
    fprintf (stderr, " nomod attribute already declared.\n");
    file_traceback ();
   }
  else
   if (!ta.nomod_attribute) tc.nomod_attribute = tb.nomod_attribute;

  if (ta.type_link && tb.type_link)
   {
    printerr (1);
    fprintf (stderr, " multiple enum, struct or union types.\n");
    file_traceback ();
   }
  else if (!ta.type_link) tc.type_link = tb.type_link;
  
  /* verify merged type */

  switch (tc.std_type)
   {
    case int_type:
     break;

    case float_type:
     if (tc.std_size == short_size)
      {
       printerr (1);
       fprintf (stderr, " short attribute not compatible with float type.\n");
       file_traceback ();
       tc.std_size = nosize;
      }
     if (tc.unsigned_attribute)
      {
       printerr (1);
       fprintf (stderr, " unsigned attribute incompatible with float type.\n");
       file_traceback ();
       tc.unsigned_attribute = 0;
      }

     break;

    case char_type:
     if (tc.std_size)
      {
       printerr (1);
       fprintf (stderr, " size attribute incompatible with char type.\n");
       file_traceback ();
       tc.std_size = nosize;
      }
     break;

    case void_type:
     if (tc.std_size || tc.unsigned_attribute || tc.signed_attribute)
      {
       printerr (1);
       fprintf (stderr," void type cannot have size or unsigned/signed attributes.\n");
       file_traceback ();
       tc.std_size = nosize;
       tc.unsigned_attribute = 0;
       tc.signed_attribute = 0;
      }
     break;
   } /* switch std_type */

  if (tc.type_link)
   {
    if (tc.std_type)
     {
      printerr (1);
      fprintf (stderr, " standard type and struct or union type conflict.\n");
      file_traceback ();
      tc.type_link = NULL;
     }
 
    if (tc.std_size)
     {
      printerr (1);
      fprintf (stderr, " size specification ");
      print_size (stderr, tc);
      fprintf (stderr, "not allowed on struct or union. \n");
      file_traceback ();
     }

    if (tc.unsigned_attribute)
     {
      printerr (1);
      fprintf (stderr, " unsigned attribute not allowed on struct or union.\n");
      file_traceback ();
     }

    if (tc.signed_attribute)
     {
      printerr (1);
      fprintf (stderr, " signed attribute not allowed on struct or union.\n");
      file_traceback ();
     }
   }
  
  return tc;
 } /* merge_type_info */
