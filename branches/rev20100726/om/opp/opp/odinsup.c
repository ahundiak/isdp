
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* odinsup.c - support for object debugger "odin".			*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* October 1985								*/
/*									*/
/* Global Functions :							*/
/*	harness_messages     - writes symbol table stuff for odin.	*/
/*	describe_instance    - ???					*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#define NULL 0
#include <stdio.h>
#include "oppmalloc.h"
#include "odinsup.h"
#include "share.h"
#include "oppy.h"
#include "oppdecldef.h"
#include "opp.h"
#include "typeinfo.h"
#include "class.h"
#include "exsysdep.h"

int basic_type_of_type_info (t)
 struct Type_Info t;
 {
  switch (t.std_type)
   {
    default :
    case int_type:
     switch (t.std_size)
      {
       case short_size :
        if (t.unsigned_attribute) return OM_unsigned_short_int;
 	return OM_short_int;

       case long_size :
        if (t.unsigned_attribute) return OM_unsigned_long_int;
 	return OM_long_int;

       default :
        if (t.unsigned_attribute) return OM_unsigned_int;
 	return OM_int;
        
      } /* switch std_size */

    case float_type:
     if (t.std_size == long_size) return OM_double;
     return OM_float;

    case char_type:
     return OM_char;
   } /* switch std_type */
 } /* basic_type_of_type_info */

static void dump_enum_dcltr (s)
 identifier_ptr s;
 {
  if (s->type_info.type_link->index < 0)
   {
    s->type_info.type_link->index = active_class->next_enum_index++;
    s->type_info.type_link->link = active_class->indexed_enum_list;
    active_class->indexed_enum_list = s->type_info.type_link;
   }

  s->type_info.term = share_type (0, s->type_info.type_link,
		&active_class->enum_sharing);

 } /* dump_enum_dcltr */

#if 0
print_indexed_struct_list()
{
/* print the indexed struct list */
identifier_ptr head, p;
int	done = 0;
static int COUNT = 0;
static int DEBUG_ODINSUP = 0;

++COUNT;

if (DEBUG_ODINSUP)
{
	printf("\n[%d] class = %s\n", COUNT, active_class->name);
	p = head = active_class->indexed_struct_list;
	while (!done)
	{
	 printf("%d\t0x%.8x\t0x%.8x %s\n", p->index, p, p->link, p->s.s.name);
		p = p->link;
		if (p == head)
			done = 1;
	}
}
}
#endif

static void dump_composite_dcltr (s)
 identifier_ptr s;
 {
  register identifier_ptr p_type = s->type_info.type_link;

  int type_code = (p_type->s.tok == STRUCT_NAME) ? OM_struct : OM_union;

#if 0
  if (p_type->index < 0)
   {
    p_type->index = active_class->next_struct_index++;

    /* insert in circular list */
    if (active_class->indexed_struct_list)
     {
      p_type->link = active_class->indexed_struct_list->link;
      active_class->indexed_struct_list->link = p_type;
     }
    else
     p_type->link = p_type;

    active_class->indexed_struct_list = p_type;
#if 0
print_indexed_struct_list();
#endif
   }
#endif

  s->type_info.term = share_type (type_code, p_type,
   &active_class->struct_sharing);

 } /* dump_composite_dcltr */

void share_terminal_dcltr (s)
 identifier_ptr s;
 {
  if (!s->type_info.type_link)
   s->type_info.term = share_type (basic_type_of_type_info(s->type_info), 0,
			   &active_class->basic_sharing);
  else
   {
    if (s->type_info.type_link->s.tok == ENUM_TAG)
     dump_enum_dcltr (s);
    else if (s->type_info.type_link->s.tok != CHANNEL_NAME)
     dump_composite_dcltr (s);
/*  else ... */
   }
 } /* share_terminal_dcltr */

void lookup_dcltr (d, term)
 dcltr_ptr d;
 struct terminal_type_info *term;
 {
  if (d)
   fprintf (oppout, "(OM_p_DCLTR)&OPPdcltr_index[%d],", d->index);
  else
   {
    char *text;

    switch (term->typ)
     {
      default :      text = "basic_dcltr_index";  break;
      case OM_enum : text = "enum_dcltr_index";   break;
      case OM_struct:
      case OM_union: text = "struct_dcltr_index"; break;
     }

    fprintf (oppout, "(OM_p_DCLTR)&OPP%s[%d],", text, term->index);
   }
 } /* lookup_dcltr */

static int describe_struct_guts (m)
 identifier_ptr m; /* message, struct or class symbol */
 {
  identifier_ptr a;
  int arg_count = 0;

  for (a=m->field_link; a; a=a->link)
   {
    if (a->flags & F_IDENTIFIER_DUMMY) continue;

    if (a->type_info.std_class == variable_class)
     a->type_info.dcltr_link->type = dt_pointer; /* restore */

    arg_count++;
   }
  return arg_count;
 } /* describe_struct_guts */

void harness_messages (p_class)
 identifier_ptr p_class;
 {
  register identifier_ptr m;

  if (!p_class) return;

#ifdef DEBUG
  fprintf (stderr, " harness_messages for %s\n", p_class->s.s.name);
#endif

  fputs ("#include \"OMspecify.h\"\n", oppout);

  if (!p_class->link) return; /* no new messages */

  for (m = p_class->link; m; m=m->link)
   fprintf (oppout, "extern OMuword %s_OPP_%s_method_index;\n",
		p_class->s.s.name, m->s.s.name);

  fprintf (oppout, 
   "static OM_S_METHDEFN OPP%s_method_defs[] =\n{\n", p_class->s.s.name);

  /* Generate methdef for each new message in this class. */
  for (m = p_class->link; m; m=m->link)
   {
    int arg_count = describe_struct_guts (m);

    fprintf (oppout, "{\n");

    /* NOTE : This is an array.  The "next" field is used for storing
       a pointer to method_index variable.  This is used by som_create_class.
    */

    /* next, w_methidx */
    fprintf (oppout, " (struct OM_sd_methdefn *)&%s_OPP_%s_method_index,%d,\n",
		 p_class->s.s.name, m->s.s.name, m->index);

    /* w_sizeargs, b_numargs */
    if (arg_count)
     fprintf (oppout, " sizeof (struct %s_%s_Msg),%d,\n",
              p_class->s.s.name, m->s.s.name, arg_count);
    else
     fprintf (oppout, " 0,0,\n");

    /* s_name */
#if defined(SUNOS) || defined(IRIX) || defined(NT)
    fprintf (oppout, "   \"%s\",\n},\n",m->s.s.name);
#elif defined(CLIX)
    fprintf (oppout, "   {\"%s\"},\n},\n",m->s.s.name);
#else
#error Unknown OS
#endif
   } /* for */

  fputs ("};\n", oppout); /* close array initializer */
 } /* harness_messages */

/* ARGSUSED */
void describe_instance (cl, instance_struct_name)
 register identifier_ptr cl; 
 char *instance_struct_name;
 {
  if (cl->field_link) describe_struct_guts (cl);
 } /* describe_instance */

