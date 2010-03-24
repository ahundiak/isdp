#define DEBUG_IMPORT
#undef DEBUG_IMPORT
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* dumpmessage.c - functions for messages, structs, enums, unions etc.	*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* October 1985								*/
/*									*/
/* Global Functions :							*/
/*	dump_messages - dumps message descriptions to output file.	*/
/*	dump_arg      - prints a declaration for a single variable.	*/
/*	verify_method - writes method header in output file.	 	*/
/*	dump_struct   - writes struct, union or enum declaration.	*/
/*	dump_instance - writes instance struct declaration.		*/
/*	end_struct_def- terminates definition of a struct.		*/
/*	insert_messages-inserts imported messages in symbol table	*/
/*	print_declaration_list -					*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#define NULL 0
#include <stdio.h>
#include <cppout.h>
#include "dumpmessage.h"
#include "odinsup.h"
#include "oppy.h"
#include "opp.h"
#include "dcltrs.h"
#include "relations.h"
#include "class.h"
#include "oppmalloc.h"
#include "basictab.h"
#include "typeinfo.h"
#include "char_st.h"
#include "fio.h"
#include "lexinput.h"
#include "kutil.h"

#ifdef DEBUG_TYPE
int OPP_debug_type = 0;
#endif

extern void exit();

static symtab_ptr processed_names = 0;
struct imported_message *imports_list = 0;

static void dump_required_types ();	 /* forward */
static int verify_struct();

int order_processed_name(char *name);

struct processed_name
{
 struct symbol s;
 int    flags;
#define F_PROCESSED_TAGNAME	0x1	/* set if "s" processed as a tag */
#define F_PROCESSED_SYMNAME	0x2	/* set if "s" processed as a symbol */
};

static int identifier_is_symbol_name(s)
 identifier_ptr s;
 {
  return !(s->s.tok == ENUM_NAME || s->s.tok == STRUCT_NAME || s->s.tok == UNION_NAME);
 }

int local_processed_name(s)
 identifier_ptr s;  /* check to see if s has already been processed */
 {
  struct processed_name *p; /* previously processed symbol with 
                               same name as "s" */

  if (!processed_names) return 0;
  if (!(p = (struct processed_name *)
            lookup_symbol (processed_names, s->s.s.name)))
   {
    struct processed_name *p2 = (struct processed_name *)malloc (sizeof (*p2));
    p2->s.name = s->s.s.name; /* share */
    if (!identifier_is_symbol_name(s))
     p2->flags = F_PROCESSED_TAGNAME;
    else
     if (s->type_info.std_class != extern_class)    /* EMS 12-02-92 */
       p2->flags = F_PROCESSED_SYMNAME;
    enter_symbol (processed_names, p2);
    return 0;
   }
  else if (identifier_is_symbol_name(s))
   {
     /* There are two cases in which it okay process "s" even though the
        same name has been processed before:
                      1.  "s" is a symbol name and "p" is a tag name.
                      2.  "s" is a tag name and "p" is a symbol name.
        This allows a tag name the same as a symbol name.
     */
     if (!(p->flags & F_PROCESSED_SYMNAME))
      {
       /* "s" is a symbol name "p" is a tag name */
       p->flags |= F_PROCESSED_SYMNAME;
       return 0;
      }
   }
  else if (!(p->flags & F_PROCESSED_TAGNAME))
   {
    /* "s" is a tag name "p" is a symbol name */
    p->flags |= F_PROCESSED_TAGNAME;
    return 0;
   }

  return 1;
 } /* local_processed_name */

/******************************************************************************/
/*
*	The following set of functions are used to keep track of all symbols
*	that written into the output ".c" file.  As the symbols are written to
*	the file, they are marked with the F_IDENTIFIER_WRITTEN bit.  These
*	routines maintain a list of all these symbols.  If you are opping more
*	than one file at time, all these bits must be cleared before another
*	".c" file is written out.
*/


static struct written
{
	identifier_ptr	*list;		/* array of written symbol pointers */
	int		size;		/* allocated size of array */
	int		current;	/* current number of used slots */
} written = { NULL, 0, 0 };

static void	add_to_written_symbols(identifier_ptr s)
{
	if (!written.list)
	{
		written.size = 500;
		if (!(written.list = malloc(written.size * sizeof(*written.list))))
		{
			fprintf(stderr, "opp: unable to alloc mem for written symbols\n");
			exit(1);
		}
	}
	else if (written.current >= written.size)
	{
		written.size += 200;
		if (!(written.list = realloc(written.list, written.size * sizeof(*written.list))))
		{
			fprintf(stderr, "opp: unable to realloc mem for written symbols\n");
			exit(1);
		}
	}
	written.list[written.current++] = s;
}

void	unmark_all_written_symbols(void)
{
	if (written.list)
	{
		int	i;

		for (i = 0; i < written.current; ++i)
		{
			written.list[i]->flags &= ~F_IDENTIFIER_WRITTEN;
			written.list[i] = NULL;
		}
		written.current = 0;
	}
}

void	mark_symbol_written(identifier_ptr s)
{
	s->flags |= F_IDENTIFIER_WRITTEN;
	add_to_written_symbols(s);
}

/******************************************************************************/

int dump_arg (fil, a) /* returns number of lines printed */
 FILE *fil;
 identifier_ptr a;
 {
  int count = print_type_info (fil, a->type_info);
  dump_dcltr (fil, a);
  return count;
 } /* dump_arg */

int print_declaration_list (fil, s, prefix) /* returns number of lines printed*/
 FILE *fil;	   /* output file */
 identifier_ptr s; /* list of declarations to be printed */
 char *prefix;	   /* a string of blanks for indentation */
 {
  /* This function prints the text of a list of variable or enum name
     declarations.  It is used to print the fields of structures and unions
     as well as enums.  It is also used to print the declaration of a list
     of local variables for use inside methods.
  */
  int index = 0;
  int line_count = 0;
  char *comma = "";

  for ( ; s ; s = s->link)
   {
    identifier_ptr typ;

    if (s->flags & F_IDENTIFIER_DUMMY) continue;
 

    if ((typ = s->type_info.type_link) && typ->s.tok == CHANNEL_NAME)
     {
      fputs (prefix, fil);
      fprintf (fil, "OM_p_CHANNEL_HDR    %s;\n", s->s.s.name);
     }
    else if (s->s.tok == ENUM_NAME)
     {
      if (s->index == index)
       fprintf (fil, "%s%s%s",comma,prefix,s->s.s.name);
      else
       fprintf (fil, "%s%s%s= %d",comma,prefix,s->s.s.name,s->index);
      index = s->index + 1;
      if (!*comma) comma = ",\n";
     }
    else
     {
      fputs (prefix, fil);
      mark_symbol_written(s);
      line_count += dump_arg (fil, s);
      fputs (";\n", fil);
     }
    ++line_count;
   }
  if (*comma) fputs ("\n", fil);
  return line_count;
 } /* print_declaration_list */

int print_struct (fil, s) /* returns count of lines printed */
 FILE *fil;
 identifier_ptr s;
 {
  register char *text = "", *name;
  int count;

  if (s->s.tok == CHANNEL_NAME || !s->field_link) return 0;

  switch (s->s.tok)
   {
    case STRUCT_NAME : text = "struct"; break;
    case UNION_NAME  : text = "union "; break;
    case ENUM_TAG    : text = "enum  "; break;
   }
  if (s->flags & F_IDENTIFIER_PHANTOM)
   name = "";
  else
   name = s->s.s.name;
  fprintf (fil, " %s %s\n  {\n", text, name);
  count = print_declaration_list (fil, s->field_link, "   ");
  fputs ("  } ", fil);

  return count + 2;
 } /* print_struct */

void define_macros()
 {
  /* This macro has been modified to generate as little code as possible. */
  /* Root must be special cased and cannot use this macro. */
  fputs ("#ifndef OPP_component_offset\n", oppout);

  fputs ("#define OPP_component_offset(CLS,PTR,TYPE) \
   {\
    register int cls=(CLS);\
    cls += (int)map;\
    cls = *(char *)cls;\
    cls *= sizeof(struct OM_sd_msgmap);\
    cls += mmap;\
    cls = (int)&((struct OM_sd_msgmap *)cls)->offset;\
    cls = *((int *)cls);\
    cls += (int) me;\
    (PTR) = (struct TYPE *) cls;\
   }\n", oppout);
  fputs ("#endif\n", oppout);

   /* This next define is for use with send to optimize send to self.  */
   /* It is equivalent to the OM define OM_W_UNKNOWN_MSG.  This avoids */
   /* having to include OMerrordef.h in every imp file.                */

   fputs("#ifndef OPP_W_UNKNOWN_MSG\n",oppout);
   fputs("#   define OPP_W_UNKNOWN_MSG (0x2508010)\n",oppout);
   fputs("#endif\n",oppout);

 } /* define_macros */

int we_rejected_it (m)
 identifier_ptr m;
 {
  register carrier_ptr cp = active_class->reject_list;

  for (; cp; cp=cp->next)
   if (m == cp->cargo) return 1;

  return 0;
 } /* we_rejected_it */

int we_overrode_it (m)
 identifier_ptr m;
 {
  register carrier_ptr cp = active_class->override_list;

  for (; cp; cp=cp->next)
   if (m == cp->cargo) return 1;

  return 0;
 } /* we_overrode_it */

void write_method_header (msg, methargs, inline_send)
 identifier_ptr msg;     /* Message being implemented by this method. */
 identifier_ptr methargs;/* List of formal arguments to method. */
 int inline_send;	 /* TRUE iff inline send was used in this method. */
 {
  char *msgname = msg->s.s.name;
  char *clsname = msg->classdef->name;

  /* Write function header with standard parameter list. */
  fprintf (oppout, "/* ARGSUSED */\n");
  fprintf (oppout, "int %s_%s_%s_method(", active_class->name, clsname,msgname);

  /* sender_os is unsigned because uword takes an extra instruction. */
  fprintf (oppout,
    "OPPmargs,sender_os,sender_id,my_id,p_spacemap,in_channel,p_ACLD)\n"
    " OM_p_CLASSDEF p_ACLD;\n"
    " OM_S_CHANNUM in_channel;\n"
    " unsigned sender_os;\n"
    " OM_S_OBJID sender_id, my_id;\n"
    " OM_p_SPAMAPENT p_spacemap;\n"
    " OM_S_MESSAGE *OPPmargs;\n"
    " {\n"
    "  %s\n"
    "  OM_p_OBJECTHDR me;\n",
    inline_send ?
     "register int OPPtndx; register int OPPdefclassid; "
     "register OM_p_MESSAGE OPPp_msg; OM_p_CLASSDEF OPPreq_ACLD;"
     :
     "");

  cur_out_line += 9;

  /* Declare local copies of parameters. */
  cur_out_line += print_declaration_list (oppout, methargs, "  ");

  /* Establish pointers to components of instance. */
  {
   register carrier_ptr cp;
   int doit = 0;

   for (cp = active_class->component_list; cp; cp=cp->next)
    if (cp->cargo->flags & F_IDENTIFIER_MARKED)
     {
      doit = 1;
      break;
     }

   if (!doit)
    {
     fputs("  me = p_spacemap->state.object;\n", oppout);
     cur_out_line += 1;
    }
   else
    {
     fputs ("  struct\n   {\n", oppout);
     cur_out_line += 2;
     for (cp = active_class->component_list; cp; cp=cp->next)
      {
       identifier_ptr cls = cp->cargo;
       if (cls->flags & F_IDENTIFIER_MARKED)
        {
	 char *name = cls->s.s.name;
         fprintf (oppout,  "    struct %s_instance *%s;\n", name, name);
         cur_out_line += 1;
        }
      }
     fputs ("   } ME;\n", oppout);
     cur_out_line += 1;
     fputs("  me = p_spacemap->state.object;\n", oppout);
     cur_out_line += 1;

     /* special case for Root class. */
     doit = 0;
     for (cp = active_class->component_list; cp; cp=cp->next)
      {
       identifier_ptr cls = cp->cargo;
       if (cls->flags & F_IDENTIFIER_MARKED)
        if (strcmp (cls->s.s.name, "Root"))
         doit = 1;
        else
         {
          fputs ("ME.Root = (struct Root_instance *)me;\n", oppout);
          cur_out_line += 1;
          cls->flags &= (~F_IDENTIFIER_MARKED);
         }
       }

     if (doit) /* others than Root */
      {
       /* Setup for OPP_component_offset calls */
       pp_fprintf (oppout,
        " {"
        "  register int mmap = (int)p_ACLD;"
        "  register char *map;"
        "  mmap += (int)offsetof(OM_S_CLASSDEF, w_baseclass);"
        "  { register int base = *(OMuword *)mmap;"
        "  mmap += (int)offsetof(OM_S_CLASSDEF, p_transmap) -"
        "  (int)offsetof(OM_S_CLASSDEF, w_baseclass);"
        "  map = *(char **)mmap;"
        "  map -= base;"
        "  }"
        "  mmap += (int)offsetof(OM_S_CLASSDEF, MsgMap) -"
        "	  (int)offsetof(OM_S_CLASSDEF, p_transmap);"
        "  mmap = *(int *)mmap;\n" );

       for (cp = active_class->component_list; cp; cp=cp->next)
        {
         identifier_ptr cls = cp->cargo;
         if (cls->flags & F_IDENTIFIER_MARKED)
          {
    	   char str[40];
           fputs ("    OPP_component_offset(", oppout);
	   sprintf (str, "OPP_%s_class_id end", cls->s.s.name);
	   pp_string (str); /* from kutil.c */
  	   fprintf (oppout, ",ME.%s, %s_instance);\n", cls->s.s.name, cls->s.s.name);
           cur_out_line += 1;
           cls->flags &= (~F_IDENTIFIER_MARKED);
          }
        }
       fputs (" }\n", oppout);
       cur_out_line += 3;
      }
    }
  }
  
 if (methargs)
  {
   /* Assign values to local copies of parameters. */
   register identifier_ptr m, m1;

#if 0
   fprintf(oppout,"{register struct %s_%s_Msg *opp_pargs=OPPmargs->p_arglist;\n",
              clsname, msgname);
   for (m1=msg->field_link,m = methargs; m && m1; m = m->link, m1=m1->link)
    {
     fprintf (oppout,"  %s = opp_pargs->%s;\n", m->s.s.name, m1->s.s.name);
     cur_out_line += 1;
    }
#else
   fputs ("{ register char *opp_pargs = OPPmargs->p_arglist;\n", oppout);
   for (m1=msg->field_link,m = methargs; m && m1; m = m->link, m1=m1->link)
    {
#if 0 // XXX Remove this older version for opp_the_type
     fprintf (oppout, "#define %s opp_the_type\n", m->s.s.name);
     fputs ("{ typedef ", oppout);
     dump_arg (oppout, m);
     fputs (";\n", oppout);
     fprintf (oppout, "#undef %s\n", m->s.s.name);
     fprintf (oppout, "  %s = *(opp_the_type *)opp_pargs;\n", m->s.s.name);
#else
     fprintf (oppout, "  %s = *(", m->s.s.name);
     print_type_info (oppout, m->type_info);
     if (m->type_info.dcltr_link != NULL && m->type_info.dcltr_link->type == dt_pointer)
      fputs (" **)opp_pargs; // formerly opp_the_type code\n", oppout);
     else
      fputs (" *)opp_pargs; // formerly opp_the_type code\n", oppout);
#endif
     if (m1->link)
      {
       pp_fprintf (oppout, " opp_pargs += (int)offsetof(struct %s_%s_Msg, %s) -\
(int)offsetof(struct %s_%s_Msg, %s);\n",
	clsname, msgname, m1->link->s.s.name, clsname, msgname, m1->s.s.name);
       cur_out_line +=1;
      }
#if 0 // XXX Remove this older version for opp_the_type
     fputs ("}\n", oppout);
     cur_out_line += 5;
#else
     cur_out_line += 2;
#endif
    }
#endif
   fputs ("}\n", oppout);
   cur_out_line += 2;
  }
 } /* write_method_header */

int equivalent_type (t1, t2)
 struct Type_Info t1, t2;
 {
  register identifier_ptr f1, f2;

  if (!(t1.std_type 	      == t2.std_type &&
        t1.std_class	      == t2.std_class &&
        t1.std_size  	      == t2.std_size &&
        t1.unsigned_attribute == t2.unsigned_attribute &&
        t1.signed_attribute   == t2.signed_attribute &&
        equal_dcltr (t1.dcltr_link, t2.dcltr_link))) return 0;

  f1 = t1.type_link;
  f2 = t2.type_link;
  if (f1 == f2) return 1;

  if (!f1 || !f2) return 0;

  if (f1->s.tok != f2->s.tok ||
      !(f1->flags & F_IDENTIFIER_PHANTOM) &&
      strcmp (f1->s.s.name, f2->s.s.name) ||
      (f1->flags & F_IDENTIFIER_MARKED) != 
      (f2->flags & F_IDENTIFIER_MARKED)) return 0;

  if (f1->s.tok == CHANNEL_NAME ||
      f1->flags & F_IDENTIFIER_MARKED) return 1;

  /* If this is a pointer and one field_link is zero and the other is not ... */
  if (!f1->field_link != !f2->field_link &&
      t1.dcltr_link && t1.dcltr_link->type == dt_pointer) return 1;

  f1->flags |= F_IDENTIFIER_MARKED;
  f2->flags |= F_IDENTIFIER_MARKED;

  for (f1 = f1->field_link, f2 = f2->field_link; f1 && f2;
       f1 = f1->link, f2 = f2->link)
   {
#   ifdef DEBUG_IMPORT
    fprintf (stderr, " equivalent_type - %s | %s\n",f1->s.s.name, f2->s.s.name);
#   endif
    if (strcmp (f1->s.s.name, f2->s.s.name) ||
        !equivalent_type (f1->type_info, f2->type_info)) return 0;
   }

  t1.type_link->flags &= ~F_IDENTIFIER_MARKED;
  t2.type_link->flags &= ~F_IDENTIFIER_MARKED;

  return (!f1 && !f2);
 } /* equivalent_type */

void verify_method (mess, methargs)
 identifier_ptr *mess, *methargs;
 /* The structure of (*mess)->field_link and *methargs must be the same.
    The names may be different. */
 {
  identifier_ptr msg = *mess;
  identifier_ptr m, m1;
  int arg_number;

  if (msg->s.tok != MESSAGE_NAME)
   {
    printerr (1);
    fprintf (stderr, " %s is not a message name.\n", msg->s.s.name);
    print_ident_type(msg);
    file_traceback ();
    return;
   }

  if (strcmp (msg->classdef->name, active_class->name) && !we_overrode_it (msg))
   { 
    printerr (1);
    fprintf (stderr, " method %s not in override list.\n", msg->s.s.name);
    file_traceback ();
   }

  /* Verify that method and message argument types coincide. */
# ifdef DEBUG
  fprintf (stderr, " verify_method - entering parameter loop \n");
# endif
  for (m=msg->field_link,m1= *methargs,arg_number=0;m&&m1;m=m->link,m1=m1->link)
   {
    arg_number++;
#if 0
    if (!equivalent_type (m->type_info, m1->type_info))
     {
      printerr (1);
      fprintf (stderr, " method/message argument type missmatch\n");
      fprintf (stderr, "- message argument %1d is \"", arg_number);
      dump_arg (stderr, m);
      fprintf (stderr, "\".\n-  method argument %1d is \"", arg_number);
      dump_arg (stderr, m1);
      fprintf (stderr, "\".\n");
      file_traceback ();
     }
#endif
   }

  if (m || m1) 
   {
    char *text;
    printerr (1);
    if (m)
     text = "few";
    else
     text = "many";
    fprintf (stderr, " method has too %s parameters for this message.\n", text);
    file_traceback ();
   }
 } /* verify_method */

static identifier_ptr import_field (list, msg)
 identifier_ptr list;
 identifier_ptr msg;
 {
  identifier_ptr p;
  identifier_ptr his_type;

  if (!list) return 0;

  p = new_identifier (list->s.s.name);
  *p = *list;

  /* handle type */
  if (his_type = p->type_info.type_link)
   {
    identifier_ptr t = (identifier_ptr)lookup_symbol (tag_table, his_type->s.s.name);

    if (t != his_type)
     {
      if (t)
       verify_struct (his_type, t, msg);
      else
       {
        t = new_identifier (his_type->s.s.name);
        *t = *his_type;
        t->flags &= ~F_IDENTIFIER_WRITTEN;
        enter_symbol (tag_table, t);
        t->field_link = import_field (t->field_link, msg);
       }
      p->type_info.type_link = t;
     }
   }

  p->link = import_field (list->link, msg);
  return p;
 } /* import_field */

static int verify_struct (s, s1, m)
 identifier_ptr s;  /* imported struct */
 identifier_ptr s1; /* our struct */
 identifier_ptr m;  /* message which requires this struct */
 {

   if (s1->s.tok == s->s.tok && (!s1->field_link || !s->field_link))
    {
     if (!s1->field_link) s1->field_link = s->field_link;
     return 1;
    }
   else
    {
     struct Type_Info t;
     struct Type_Info t1;

#ifdef DEBUG_IMPORT
  fprintf (stderr, "verify_struct - %s vs. %s\n", s->s.s.name, s1->s.s.name);
#endif 

     t = empty_type;
     t1 = empty_type;
     t.type_link = s;
     t1.type_link = s1;
     if (!equivalent_type (t, t1))
      {
       char *text;
       switch (s->s.tok)
	{
	 case STRUCT_NAME: text = "struct"; break;
	 case UNION_NAME:  text = "union";  break;
	 case ENUM_TAG:    text = "enum";   break;
	 default : 	  text = "Type";
	} /* switch */

       printerr (1);
       if (m)
	{
         fprintf (stderr, "%s \"%s\" required for imported message -\n",
			 text, s->s.s.name); 
         fprintf (stderr, "- %s in class %s\n", m->s.s.name,
			 m->classdef->name);
         fprintf (stderr, "- differs from previous declaration.\n");
	}
       else
        {
         fprintf (stderr, "%s \"%s\" inherited from ancestor class -\n",
			 text, s->s.s.name); 
         fprintf (stderr, "- differs from other inherited declaration.\n");
	}
       file_traceback ();
       return 0;
      }
     return 1;
    }
 } /* verify_struct */

static void print_msg_struct_and_index (m)
 identifier_ptr m;	/* Message symbol */
 {
  fprintf (oppout, "extern OMuword %s_OPP_%s_method_index;\n",
	   m->classdef->name, m->s.s.name);
  ++cur_out_line;
  if (m->field_link)
   {
    fprintf (oppout,  " struct %s_%s_Msg\n  {\n",
	     m->classdef->name, m->s.s.name);
    cur_out_line += 3 + print_declaration_list (oppout, m->field_link, "   ");
    fputs ("  };\n", oppout);
   }
 } /* print_msg_struct_and_index */

void free_imports_list ()
 {
  register struct imported_message *p = imports_list;

  while (p)
   {
    register struct imported_message *m = p->next;
    free (p);
    p = m;
   }

  imports_list = 0;
 } /* free_imports_list */

void verify_imported_message (m, class_from_which_imported)
 identifier_ptr m;
 identifier_ptr class_from_which_imported;
 {
  register char *msg_name;
  register char *msg_class_name;

  msg_name = m->s.s.name;

  if (m->s.tok != MESSAGE_NAME)
   {
    printerr (1);
    fprintf (stderr, " %s is not a message name.\n", msg_name);
    file_traceback ();
    return;
   }

  msg_class_name = m->classdef->name;

  { /* Seach all ancestors to see if message is inherited. */
  carrier_ptr cp;
  for (cp = active_class->component_list; cp; cp=cp->next)
   {
    identifier_ptr cl = cp->cargo;
    identifier_ptr s;

    if (strcmp (cl->s.s.name, msg_class_name)) continue;

    for (s = cl->classdef->messages; s; s=s->link)
     if (!(strcmp (msg_name, s->s.s.name)))
      {
       printerr (0);
       fprintf (stderr, " message %s.%s is inherited.\n",
	        msg_class_name, msg_name);
       fprintf (stderr, " - Import ignored.\n");
       file_traceback ();
       return;
      }
   }
  } /* search of ancestors */

  { /* Search list of messages which have already been imported */
  struct imported_message *p;
  for (p = imports_list; p; p=p->next)
   {
    identifier_ptr pm = p->m;
    if (!(strcmp(pm->s.s.name, msg_name)) &&
        !(strcmp(pm->classdef->name, msg_class_name)))
     {
      printerr (0);
      fprintf (stderr, " message %s.%s has already been imported from %s.\n",
  	     msg_class_name, msg_name, p->cl->s.s.name);
      fprintf (stderr, " - Import ignored.\n");
      file_traceback ();
      return;
     }
   }

  /* Add to imported message list */
  p = (struct imported_message *) malloc (sizeof (*p));
  p->m = m;
  p->cl = class_from_which_imported;
  p->next = imports_list;
  imports_list = p;
  } /* Search of imports */


  {
  identifier_ptr new_m = new_identifier (msg_name);
  *new_m = *m;
  
# ifdef DEBUG_IMPORT
  fprintf (stderr, "verify_imported_message %s\n",msg_name);
# endif

  new_m->field_link = import_field (m->field_link, m);

  dump_required_types (new_m->field_link);
  print_msg_struct_and_index (new_m);

#ifdef free_new_guys_now
  /* EMS 12/10/92  no longer free these guys since they are now added */
  /*               to the written symbol list for multi-opps          */

  /* ++++++++++ P.L.H. April 8, 1987 ++++++++++ */
  /* Free new_m and related fields.  Why they are being allocated? */

  while (new_m->field_link)
   {
    identifier_ptr p = new_m->field_link->link;
    free (new_m->field_link);
    new_m->field_link = p;
   }
  free (new_m);

  /* --------- April 8, 1987 ------------------ */
#endif
  }
 } /* verify_imported_message */

static void dump_msg_structs (s)
 identifier_ptr s;
 {
  identifier_ptr m;

#ifdef DEBUG
  fprintf (stderr, "dump_msg_structs - %s\n", s->s.s.name);
#endif
  for (m=s->classdef->messages; m; m=m->link)
   dump_required_types (m->field_link);
  for (m=s->classdef->messages; m; m=m->link)
   print_msg_struct_and_index (m);
#ifdef DEBUG
  fprintf (stderr, "/dump_msg_structs %s\n", s->s.s.name);
#endif
 } /* dump_msg_structs */

void dump_known_msg_structs (s)
 identifier_ptr s;
 {
  carrier_ptr cp;

#ifdef DEBUG
  fprintf (stderr, "dump_known_msg_structs %x\n",s);
#endif

  for (cp = s->classdef->component_list; cp; cp=cp->next)
   {
    identifier_ptr cl = cp->cargo;

#if 0
    cl = lookup_symbol (sym_table, cp->cargo->s.s.name);

    if (!(cl->flags & F_IDENTIFIER_WRITTEN))
#endif
     {
#ifdef DEBUG
      fprintf (stderr, " - %s\n", cp->cargo->s.s.name);
#endif

      dump_msg_structs (cl);
      cl->flags |= F_IDENTIFIER_WRITTEN;
     }
   }
#ifdef DEBUG
   fprintf (stderr, "/dump_known_msg_structs %s\n", s->s.s.name);
#endif
 } /* dump_known_msg_structs */

/* ARGSUSED */
void dump_messages (cl, parsing_specification)
 identifier_ptr cl;
 int parsing_specification; /* boolean */
 {
   dump_msg_structs (cl);
   harness_messages(cl);
 } /* dump_messages */

static void dump_required_types (s1)
 identifier_ptr s1;
 {
  identifier_ptr t, t2;
  carrier_ptr c;
  dcltr_ptr p;
  
  for (;s1; s1=s1->link)
   {
    if ((t = s1->type_info.type_link) &&
	!(t->flags & F_IDENTIFIER_WRITTEN) && t->field_link &&
        (t->s.tok == STRUCT_NAME ||
	 t->s.tok == UNION_NAME  ||
	 t->s.tok == ENUM_TAG))
     {
      dump_struct (t);
     }
    else for (c = s1->type_info.typedefName; c; c = c->next)
     if ((t = c->cargo) &&
	!(t->flags & F_IDENTIFIER_WRITTEN) && t->field_link &&
        (t->s.tok == STRUCT_NAME ||
	 t->s.tok == UNION_NAME  ||
	 t->s.tok == ENUM_TAG))
      {
        dump_struct (t);
      }

   for (c = s1->type_info.typedefName; c; c = c->next)
    if ((t = c->cargo) && !(t->flags & F_IDENTIFIER_WRITTEN))
     {
      mark_symbol_written(t);
      dump_required_types (t);
#ifdef DEBUG_TYPE
if (OPP_debug_type) printf("dump_required_types: 0x%.8x %s : %s\n", t,
t->s.s.name, t->classdef ? t->classdef->name : "<unknown>");
#endif
      if (order_processed_name(t->s.s.name) || local_processed_name(t)) continue;
      cur_out_line += dump_arg(oppout, t) + 1;
      fputs (";\n", oppout);
     }

     /************ EMS 4/2/93 Add new code to handle argument typedefs for  */
     /*                       prototype arguments                           */

     for (p = s1->type_info.dcltr_link; p; p=p->next)
        if (p->type != dt_bitfield)
           for (t2 = p->params; t2; t2=t2->link)
              for (c = t2->type_info.typedefName; c; c = c->next)
                 if ((t = c->cargo) && !(t->flags & F_IDENTIFIER_WRITTEN))
                 {
                    mark_symbol_written(t);
                    dump_required_types (t);
#ifdef DEBUG_TYPE
if (OPP_debug_type) printf("dump_required_types: 0x%.8x %s : %s\n", t,
t->s.s.name, t->classdef ? t->classdef->name : "<unknown>");
#endif
                    if (order_processed_name(t->s.s.name) || 
                        local_processed_name(t)) continue;
                    cur_out_line += dump_arg(oppout, t) + 1;
                    fputs (";\n", oppout);
                 }

   } /* for */
 } /* dump_required_types */

static void dump_prereq_types (s1)
 /* This is the same as dump required types except that forward references
    by pointers to structures are not dumped. */
 identifier_ptr s1;
 {
  identifier_ptr t, t2;
  dcltr_ptr p;
  carrier_ptr c;

  for (;s1; s1=s1->link)
   {
    if ((t = s1->type_info.type_link) &&
	!(t->flags & F_IDENTIFIER_WRITTEN) && t->field_link &&
        (t->s.tok == STRUCT_NAME ||
	 t->s.tok == UNION_NAME  ||
	 t->s.tok == ENUM_TAG) &&
	(!(p = s1->type_info.dcltr_link) || !last_dcltr_is_ptr (p)))
     {
      if (t->flags & F_IDENTIFIER_PHANTOM)
       dump_prereq_types (t->field_link);
      else
       dump_struct (t);
     }
   else for (c = s1->type_info.typedefName; c; c = c->next)
    if ((t = c->cargo) &&
	!(t->flags & F_IDENTIFIER_WRITTEN) && t->field_link &&
        (t->s.tok == STRUCT_NAME ||
	 t->s.tok == UNION_NAME  ||
	 t->s.tok == ENUM_TAG) &&
	(!(p = s1->type_info.dcltr_link) || !last_dcltr_is_ptr (p)))
     {
      if (t->flags & F_IDENTIFIER_PHANTOM)
       dump_prereq_types (t->field_link);
      else
       dump_struct (t);
     }

   for (c = s1->type_info.typedefName; c; c = c->next)
    if ((t = c->cargo) && !(t->flags & F_IDENTIFIER_WRITTEN))
     {
      mark_symbol_written(t);
      dump_prereq_types (t);
#ifdef DEBUG_TYPE
if (OPP_debug_type) printf("dump_prereq_types: 0x%.8x %s : %s\n", t,
t->s.s.name, t->classdef ? t->classdef->name : "<unknown>");
#endif
      if (order_processed_name(t->s.s.name) || local_processed_name(t)) continue;
      cur_out_line += dump_arg(oppout, t) + 1;
      fputs (";\n", oppout);
     }

     /************ EMS 4/2/93 Add new code to handle argument typedefs for  */
     /*                       prototype arguments                           */

     for (p = s1->type_info.dcltr_link; p; p=p->next)
        if (p->type != dt_bitfield)
           for (t2 = p->params; t2; t2=t2->link)
              for (c = t2->type_info.typedefName; c; c = c->next)
                 if ((t = c->cargo) && !(t->flags & F_IDENTIFIER_WRITTEN))
                 {
                    mark_symbol_written(t);
                    dump_prereq_types (t);
#ifdef DEBUG_TYPE
if (OPP_debug_type) printf("dump_prereq_types: 0x%.8x %s : %s\n", t,
t->s.s.name, t->classdef ? t->classdef->name : "<unknown>");
#endif
                    if (order_processed_name(t->s.s.name) || 
                        local_processed_name(t)) continue;
                    cur_out_line += dump_arg(oppout, t) + 1;
                    fputs (";\n", oppout);
                 }

   } /* for */
 } /* dump_prereq_types */

void dump_struct (s)
 identifier_ptr s;
 {
  identifier_ptr s2;

  s2 = (identifier_ptr)lookup_symbol (tag_table, s->s.s.name);
  if (s2 && s != s2 && s2->s.s.level == s->s.s.level)
   {
    struct Type_Info t1, t2;

    t1 = t2 = empty_type;
    t1.type_link = s;
    t2.type_link = s2;
    if (equivalent_type (t1, t2))
     s = s2;
    else
     {
      t2 = empty_type;
      t1 = s->type_info;
      if (equivalent_type(t1, t2)) /* if empty type s is a forward reference */
       s = s2;
      else
       {
        printerr (1);
        fprintf (stderr, "multiple declaration of type \"%s\"\n", s->s.s.name);
        fprintf (stderr, "class %s declares :\n", s->classdef->name);
        print_struct (stderr, s);
        fprintf (stderr, ";\n");
        fprintf (stderr, "class %s declares :\n", s2->classdef->name);
        print_struct (stderr, s2);
        fprintf (stderr, ";\n");
        file_traceback ();
      }
    }
   }

  if (!(s->flags & F_IDENTIFIER_WRITTEN) &&
      s->s.tok != CHANNEL_NAME && s->field_link)
   {
    mark_symbol_written(s);
#ifdef DEBUG_TYPE
if (OPP_debug_type) printf("dump_struct: 0x%.8x %s : %s\n", s, s->s.s.name,
s->classdef ? s->classdef->name : "<unknown>");
#endif
    if (order_processed_name(s->s.s.name) || local_processed_name(s)) return;
    if (s->s.tok != ENUM_TAG) dump_prereq_types (s->field_link);
    if (!(s->flags & F_IDENTIFIER_PHANTOM))
     {
      cur_out_line += 1 + print_struct (oppout, s);
      fprintf (oppout, ";\n");
     }
   }
 } /* dump_struct */

static void pre_req_types (s)
 identifier_ptr s;
 {
  if (s)
   {
    identifier_ptr *p;
#ifdef DEBUG
    printf (" pre_req_types -\n");
    printf ("  s            = %x\n", s);
    printf ("  class     = %x\n", s->classdef);
    printf ("  parent_count = %x\n", s->classdef->parent_count);
    printf ("  A_parents    = %x\n", s->classdef->A_parents);
#endif

    if (s->classdef->parent_count)
     for (p=(identifier_ptr *)(s->classdef->A_parents + s->classdef->parent_count);
         --p >= (identifier_ptr *)s->classdef->A_parents;)
      if (*p && *p != s) pre_req_types (*p);
    dump_required_types (s->field_link);
   }
 } /* pre_req_types */

void dump_instance (s)
 identifier_ptr s;
 {
  if (!s->classdef->instance_fields) return;
  pre_req_types (s);
  fprintf (oppout, " struct %s_instance \n  {\n", s->s.s.name);
  cur_out_line += 3 +
   print_declaration_list (oppout, s->classdef->instance_fields, "   ");
  fprintf (oppout, "  };\n");
 } /* dump_instance */

void end_struct_def (s)
 identifier_ptr s;
 {
  static int been_here = 0;
  char buf[20];

  if (s->s.tok == ENUM_TAG) /* enum names are in outer space */
  {
     /*  Big kludge for X11 (Xresource.h) problem where two enum types
     **  are typedefed on the same line
     */
 
     if (s->field_link) {
        if (!strcmp(s->field_link->s.s.name, "XrmBindTightly")) {
           if (been_here) {
              sprintf (buf, "Xrm%04dTightly", been_here);
              strcpy (s->field_link->s.s.name, buf);
              sprintf (buf, "Xrm%04dLoosely", been_here);
              strcpy (s->field_link->link->s.s.name, buf);
              ++been_here;
           }
           else {
             s->flags = 0;    /* clears the F_IDENTIFIER_PHANTOM flag */
             been_here = 1;
           }
        }
     }
  }
  else
   decrement_symbol_level (sym_table, NULL);
 } /* end_struct_def */

static void dump_function_parameter_required_types(s)
 identifier_ptr s;
 {
  if (s->type_info.dcltr_link)
   {
    identifier_ptr p = s->type_info.dcltr_link->params;
    
    for (; p; p = p->link) dump_prereq_types(p);
   } 
 }

static int i_declared_it;
static char *dumping_class;

static void dump_global_defs (s)
 identifier_ptr s;
 {
#ifdef DEBUG
  fprintf (stderr, " dump_global_defs %s\n", s->s.s.name);
#endif
  if ((s->s.tok == TYPEDEF_NAME || s->s.tok == VAR_NAME) &&
      !(s->flags & F_IDENTIFIER_WRITTEN) && 0 == s->s.s.level)
   {
    register int yes = s->s.tok == VAR_NAME &&
		       s->type_info.std_class == noclass &&
        	       (!i_declared_it ||
		        strcmp(dumping_class, s->classdef->name));

    if (yes) s->type_info.std_class = extern_class;
#ifdef DEBUG
    fprintf (stderr, " - dumping \n");
#endif
    mark_symbol_written(s);
    dump_prereq_types(s);
    dump_function_parameter_required_types(s);
#ifdef DEBUG_TYPE
if (OPP_debug_type) printf("dump_global_defs: 0x%.8x %s : %s\n", s,
s->s.s.name, s->classdef ? s->classdef->name : "<unknown>");
#endif
    if (order_processed_name(s->s.s.name) || local_processed_name(s)) return;
    cur_out_line += dump_arg (oppout, s) + 1;
    if (yes) s->type_info.std_class = noclass; /* restore */
    fprintf (oppout,  ";\n");
   }
 } /* dump_global_defs */

void dump_inherited_types (cl, extern_flag)
 struct opp_class_def *cl;
 int extern_flag;
 {
  symtab_ptr saved_tag_table = tag_table;
  symtab_ptr saved_sym_table = sym_table;

  extern int yydebug;

  if (processed_names)
   {
    /* In the case of a multi-opp delete the previous table. */
    delete_symbol_table (processed_names, free);
    processed_names = 0;
   }

  tag_table = cl->tag_tab;
  sym_table = cl->sym_tab;

  i_declared_it = extern_flag;
  dumping_class = cl->name;

  processed_names = new_basictab (251, yydebug ? stderr : 0);

  process_symbol_table (cl->tag_tab, dump_struct);
  process_symbol_table (cl->sym_tab, dump_global_defs);

  /* Leave the processed names table around so imported message
     types aren't duplicated in the output file. */

  sym_table = saved_sym_table;
  tag_table = saved_tag_table;
 } /* dump_inherited_types */

void verify_inherited_message (msg, cls)
 identifier_ptr msg;
 identifier_ptr cls;
 {
  register struct inherited_msg *im = (struct inherited_msg *) malloc (sizeof (*im));
  register struct inherited_msg **imp = (struct inherited_msg **) &active_class->inherited_methods;

  im->next = *imp;
  im->msg = msg;
  im->cls = cls;
  *imp = im;
 } /* verify_inherited_message */

void print_ident_type(id)
identifier_ptr id;
{
    char *type, *class;

    switch (id->s.tok)
     {
      case STRUCT_NAME  : type = "struct";	break;
      case UNION_NAME   : type = "union";	break;
      case MESSAGE_NAME : type = "message";	break;
      case ENUM_TAG     : type = "enum";	break;
      case ENUM_NAME    : type = "enum name";	break;
      case VAR_NAME	: type = "variable";	break;
      case TYPEDEF_NAME : type = "typedef";	break;
      case CLASS_NAME   : type = "class";	break;
      default :           type = "??";		break;
     }

    switch (id->type_info.std_class)
     {
      	case noclass:		class = "";		break;
	case auto_class:	class = "auto";		break;
	case static_class:	class = "static";	break;
	case typedef_class:	class = "typedef";	break;
	case register_class:	class = "register";	break;
	case variable_class:	class = "variable";	break;
	case extern_class:	class = "extern";	break;
	default :		class = "??";		break;
     }

    printf(" %s %s (%s)%s\n", class, type, id->classdef->name, id->s.s.name);
}

char *get_table_name(p)
 char **p;
 {
  /* to be used with process_ordertab_list(sym_tab, 0, 0, get_table_name) */
  return p ? *p : 0;
 }
