/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* initgen.c - functions to generate class_init function		*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* October 1985								*/
/*									*/
/* Global functions :							*/
/*	generate_class_init - generates class init function		*/
/*	find_components	    - finds all the components of a class	*/
/*	declare_component_ids- prints extern declarations		*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#define NULL 0
#include <stdio.h>
#include <cppout.h>
#include "oppmalloc.h"
#include "identifier.h"
#include "oppy.h"
#include "opp.h"
#include "odinsup.h"
#include "dumpmessage.h"
#include "lexinput.h"
#include "carriers.h"
#include "relations.h"
#include "class.h"
#include "exsysdep.h"
#include "kutil.h"

int class_overridden(carrier_ptr override_list, char *classname);

static void dump_dispatch_table (cl)
 identifier_ptr cl; /* Class symbol. */
 {
  register identifier_ptr msgs;
  /* If the class has any messages, this function generates code to initialize
     the method dispatch table for the messages declared by that class.  
  */
  msgs = cl->classdef->messages;
  if (msgs)
   {
    register identifier_ptr m;
    register char *classname;

    classname = cl->s.s.name;
    for (m = msgs; m; m = m->link)
     if (!we_rejected_it (m))
      fprintf (oppout, "extern int %s_%s_%s_method();\n",
	       classname, classname, m->s.s.name);

    fputs ("static int (*OPPmethod_list[])()=\n {\n", oppout);
    cur_out_line += 3;

    for (m = msgs; m; m = m->link)
     {
      if (we_rejected_it (m))
       fputs ("  0,\n", oppout);
      else
       fprintf (oppout, "  %s_%s_%s_method,\n",
	        classname, classname, m->s.s.name);
      ++cur_out_line;
     }
    fputs (" };\n", oppout);
    ++cur_out_line;
   }
 } /* dump_dispatch_table */

static int find_channels_and_dump_types (cl, p_chans)
 identifier_ptr cl;
 carrier_ptr *p_chans;
 {
  identifier_ptr ch, typ;
  carrier_ptr cplist = 0, cplistend = 0;
  int count = 0;

  for (ch = cl->field_link; ch; ch = ch->link)
   if ((typ = ch->type_info.type_link) && typ->s.tok == CHANNEL_NAME)
   {
    carrier_ptr cp = (carrier_ptr) malloc (sizeof (*cp));
    ++count;
    cp->cargo = ch;
    cp->next = 0;
    if (cplist)
     cplistend->next = cp;
    else
     cplist = cp;
    cplistend = cp;
    ch->index = 0;
    if (!(typ->flags & F_IDENTIFIER_WRITTEN))
     {
      struct hook_definition *h = (struct hook_definition *) typ->field_link;
#ifdef DEBUG
      fprintf (stderr, "dumping channel type %s\n",typ->s.s.name);
      fprintf (stderr, " h = %x, class_count = %d, class_list = %x\n",
		h, h->class_count, h->class_list);
#endif
      mark_symbol_written(typ);
      if (!(h->attributes & CHAN_ATT_RES) && h->class_count)
      {
       char **p;
       for (p = h->class_list + h->class_count; --p >= h->class_list;)
        fprintf (oppout, "extern OMuword OPP_%s_class_id;\n", *p);
       fprintf(oppout,"static OMuword *OPP%d[]=\n",h->class_list);
       fprintf (oppout, " {\n");
       cur_out_line += 2;
       for (p = h->class_list + h->class_count; --p >= h->class_list;)
        {
         fprintf (oppout, "  &OPP_%s_class_id,\n",*p);
	 ++cur_out_line;
        }
       fprintf (oppout, " };\n");
       ++cur_out_line;
      }

      fprintf (oppout, "static OM_S_CHANNEL_TYPE_DEFN OPP%d=\n {\n  0", typ);
      if (h->attributes & CHAN_ATT_OO) fprintf (oppout, "|CD_1_1");
      if (h->attributes & CHAN_ATT_OM) fprintf (oppout, "|CD_1_m");
      if (h->attributes & CHAN_ATT_MO) fprintf (oppout, "|CD_m_1");
      if (h->attributes & CHAN_ATT_MM) fprintf (oppout, "|CD_m_m");
      if (h->attributes & CHAN_ATT_REL) fprintf (oppout, "|CD_relordered");
      if (h->attributes & CHAN_ATT_ABS) fprintf (oppout, "|CD_absordered");
      if (h->attributes & CHAN_ATT_RES) fprintf (oppout, "|CD_restricted");
      fprintf (oppout, ",\n  \"%s\",\n  %d,%d,%d,", typ->s.s.name,
	h->initial_count, h->incremental_count, h->class_count);
      if (h->attributes & CHAN_ATT_RES)
       fprintf (oppout, "(OMuword **)\"%s\"\n", *h->class_list);
      else if (h->class_count)
       fprintf (oppout, "OPP%d\n", h->class_list);
      else
       fputs ("0\n", oppout);
      fputs (" };\n", oppout);
      cur_out_line += 6;
     }
   }
  *p_chans = cplist;
  return count;
 } /* find_channels_and_dump_types */

static void dump_channels (cl, ch)
 identifier_ptr cl;
 carrier_ptr ch;
 {


  fputs ("static OM_S_CHANNEL_DEFN OPPchannel_index[] =\n {\n", oppout);
  cur_out_line += 2;
  for (;ch;ch=ch->next)
   {
    char *name = ch->cargo->s.s.name;
    pp_fprintf (oppout, "\
  {\n\
   &OPP%d,\n\
   (OMuint) offsetof(struct %s_instance, %s),\n\
   \"%s\",\n\
  },\n", ch->cargo->type_info.type_link, cl->s.s.name, name, name);
    cur_out_line += 5;
   }
  fputs (" };\n", oppout);
  ++cur_out_line;
 } /* dump_channels */

static int find_class_components (cl, p_list)
 identifier_ptr cl;
 carrier_ptr *p_list;
 {
  /* Note : If symbol records were unique, we could simply set and check
	    the F_IDENTIFIER_COMPONENT flag in each class symbol instead
	    of doing the following search with strcmp.

     Since all classes have unique names (but not unique symbol records),
     we must search the existing component list to see if this class is
     already in it.  If it is, assume all ancestors are also and return 0.
  */

  {
   carrier_ptr cp;
   char *classname = cl->s.s.name;
   for (cp = *p_list; cp; cp=cp->next)
    if (!strcmp (cp->cargo->s.s.name, classname)) return 0;
  }

  /* If this class is not in list, its ancestors may not be either.
     First recurse on all parents then add this class to list. */

  {
  int count = 0;

  {
  int pcount;
  if (pcount = cl->classdef->parent_count)
   {
    identifier_ptr *p;
    identifier_ptr *parents = (identifier_ptr *)cl->classdef->A_parents;
    for (p = (identifier_ptr *)parents + pcount; --p >= parents;)
     if (*p && *p != cl) count += find_class_components (*p, p_list);
   }
  }

  {
   carrier_ptr cp = carrier_node (cl);
   cp->next = *p_list;
   *p_list = cp;
  }

  return count + 1;
  }
 } /* find_class_components */

int find_components (cl, p_list)
 identifier_ptr cl;	/* pointer to a class symbol */
 carrier_ptr *p_list;	/* pointer to list to which components are to be added*/
 {
  int count;

#ifdef DEBUG
  printf ("find_components of %s\n", cl->s.s.name);
#endif

  *p_list = 0;
  count = find_class_components (cl, p_list);
  *p_list = reverse_carrier_list (*p_list);
  return count;
 } /* find_components */

void Ideclare_component_ids (cl)
 identifier_ptr cl;	/* pointer to a class symbol */
 {
  register carrier_ptr p;

  for (p=cl->classdef->component_list; p; p = p->next)
   {
    char str[40];
    fputs ("extern unsigned short ", oppout);
    sprintf (str, "OPP_%s_class_id end", p->cargo->s.s.name);
    pp_string (str);
    fputs (";\n", oppout);
    ++cur_out_line;
   }
 } /* declare_component_ids */

void declare_component_ids (cl)
 identifier_ptr cl;	/* pointer to a class symbol */
 {
  register carrier_ptr p;

  for (p=cl->classdef->component_list; p; p = p->next)
   {
    fprintf (oppout, "extern unsigned short OPP_%s_class_id;\n",
	     p->cargo->s.s.name);
    ++cur_out_line;
   }
 } /* declare_component_ids */

void dump_total_instance (cl)
 identifier_ptr cl;	/* pointer to class symbol */
 {
  carrier_ptr cp; /* for traversal of component_list */
  carrier_ptr comp = cl->classdef->component_list;
  carrier_ptr over = cl->classdef->override_list;

  for (cp = comp; cp; cp=cp->next)
     if (! class_overridden(over, cp->cargo->s.s.name))
        dump_instance (cp->cargo);
  
  fprintf (oppout, "struct %s_total_instance\n {\n",cl->s.s.name);
  cur_out_line += 2;

  for (cp = comp; cp; cp=cp->next) if (cp->cargo->field_link)
   {
    register char *name = cp->cargo->s.s.name;
    if (! class_overridden(over, name))
    {
       fprintf (oppout, "  struct %s_instance %s;\n",name, name);
       ++cur_out_line;
    }
   }

  fputs (" };\n", oppout);
  ++cur_out_line;
 } /* dump_total_instance */

int class_overridden(override_list, classname)
carrier_ptr override_list;
char *classname;
{
   register carrier_ptr cur = override_list;
   for (; cur; cur=cur->next)
      if (! strcmp(cur->cargo->s.s.name, classname))
         return 1;

   return 0;
} /* class_not_overridden */

/* dump_and_count_varrays generates declarations which initialize an
   an array of definitions for all the variable length arrays used in
   the total instance of the given class. */
/* static */ int dump_and_count_varrays (cl)
 identifier_ptr cl;     /* pointer to class symbol */
 {
  int count = 0;
  carrier_ptr cp;

  /* Loop for each instance field in each component class.
     Process ordinary variable length arrays and ?_to_many channels. */

  for (cp = cl->classdef->component_list; cp; cp=cp->next)
   {
    identifier_ptr s;

    /*--------------------------------------------------------------------*/
    /*  Check to see if the instance data for this class was overridden.  */
    /*  If it is, don't dump any vararray stuff.                          */
    /*--------------------------------------------------------------------*/

    if (class_overridden(cl->classdef->override_list,cp->cargo->s.s.name)) 
       continue;
    
    for (s=cp->cargo->classdef->instance_fields; s; s=s->link)
     {
      identifier_ptr typ;
      dcltr_ptr dlink = s->type_info.dcltr_link;
      int is_varray = dlink && dlink->type == dt_varray;
      struct hook_definition *h;
      
      if (is_varray ||
	  ((typ = s->type_info.type_link) && typ->s.tok == CHANNEL_NAME &&
	    !(((h = (struct hook_definition *)typ->field_link)->attributes & CHAN_ATT_RES) && (h->attributes & (CHAN_ATT_OO | CHAN_ATT_MO)) ) ) )
       {
        if (!count)
         fputs ("static OM_S_VARLENARR_DEFN OPPvarrays[]=\n {\n", oppout);
   
        fputs ("  {\n", oppout);
   
        if (is_varray)
         {
          /* write offset to descriptor - w_offset*/
          /*       initial dimension - w_count*/
          pp_fprintf (oppout,
          "   (OMuint)offsetof(struct %s_total_instance, %s.%s_descr),\n   %d,\n",
           cl->s.s.name, cp->cargo->s.s.name, s->s.s.name, dlink->size);
     
          /* write w_per_elt_size */
          {
           struct identifier_symbol tid;
   
           fputs ("   sizeof (", oppout);
           tid = *s;
           tid.type_info.std_class = noclass;
           tid.type_info.dcltr_link = tid.type_info.dcltr_link->next;
           tid.s.s.name = "";
           dump_arg (oppout, &tid);
           fputs ("), 0,\n", oppout);
          }
         }
        else /* channel w/vla */
         {
          pp_fprintf (oppout,
           "   (OMuint) offsetof(struct %s_total_instance, %s.%s), 0, 4, 1,\n", 
           cl->s.s.name, cp->cargo->s.s.name, s->s.s.name);
         }
     
        fputs ("  },\n", oppout);
        ++count;
       }
     } /* inner for */
   } /* outer for */
  if (count) fputs (" };\n", oppout);
  return count;
 } /* dump_and_count_varrays */

/* count_varrays returns the total number of vla definitions that would be
   dumped into the output for a spec file. */
 int count_varrays (p_classdef)
 struct opp_class_def *p_classdef;
 {
  int count = 0;
  carrier_ptr cp;

  /* Loop for each instance field in each component class.
     Process ordinary variable length arrays and ?_to_many channels. */

  for (cp = p_classdef->component_list; cp; cp=cp->next)
   {
    identifier_ptr s;

    /*--------------------------------------------------------------------*/
    /*  Check to see if the instance data for this class was overridden.  */
    /*  If it is, don't dump any vararray stuff.                          */
    /*--------------------------------------------------------------------*/

    if (class_overridden(p_classdef->override_list,cp->cargo->s.s.name)) 
       continue;
    
    for (s=cp->cargo->classdef->instance_fields; s; s=s->link)
     {
      identifier_ptr typ;
      dcltr_ptr dlink = s->type_info.dcltr_link;
      int is_varray = dlink && dlink->type == dt_varray;
      struct hook_definition *h;
      
      if (is_varray ||
	  ((typ = s->type_info.type_link) && typ->s.tok == CHANNEL_NAME &&
	    !(((h = (struct hook_definition *)typ->field_link)->attributes & CHAN_ATT_RES) && (h->attributes & (CHAN_ATT_OO | CHAN_ATT_MO)) ) ) )
       {
        if (is_varray)
         {
         }
        else /* channel w/vla */
         {
         }
     
        ++count;
       } /* if vla or channel */
     } /* for all instance fields */
   } /* for all component classes */
  return count;
 } /* count_varrays */

static struct inherited_msg *we_inherited_it (m)
 identifier_ptr m;
 {
  struct inherited_msg *im;

  for (im = active_class->inherited_methods; im; im = im->next)
   if (im->msg == m) return im;

  return 0;
 } /* we_inherited_it */

static void dump_inherits (cl)
 identifier_ptr cl;	/* inheriting class */
 {
  carrier_ptr cp;

  for (cp = cl->classdef->component_list; cp; cp=cp->next)
   {
    char *name;
    identifier_ptr messages;
    int inherit_count = 0;
    identifier_ptr p;
    {
     identifier_ptr cargo = cp->cargo;
     name = cargo->s.s.name;
     messages = cargo->classdef->messages;
    }
    for (p = messages; p; p = p->link)
     {
      struct inherited_msg *im = we_inherited_it (p);
      if (im)
       {
        ++inherit_count;
        fprintf (oppout, "extern OMuword OPP_%s_class_id;\n\
extern OMuword %s_OPP_%s_method_index;\n", im->cls->s.s.name, name, p->s.s.name);
       }
     }
    if (inherit_count)
     {
      fprintf (oppout, "static OM_S_INHERIT OPP_%s_inherits[]=\n {\n", name);
      for (p = messages; p; p = p->link)
       {
        struct inherited_msg *im = we_inherited_it (p);
        if (im)
         fprintf (oppout, "  { &%s_OPP_%s_method_index, &OPP_%s_class_id },\n",
   	          name, p->s.s.name, im->cls->s.s.name);
       }
      fputs (" };\n", oppout);
     }
   }
 } /* dump_inherits */

static void dump_overrides (cl)
 identifier_ptr cl;	/* overriding class */
 {
  carrier_ptr cp;

  for (cp = cl->classdef->component_list; cp; cp=cp->next)
   {
    char *name;
    identifier_ptr messages;
    int override_count = 0;
    identifier_ptr p;
    {
     identifier_ptr cargo = cp->cargo;
     name = cargo->s.s.name;
     messages = cargo->classdef->messages;
    }
    for (p = messages; p; p = p->link)
     if (we_overrode_it (p))
      {
       ++override_count;
       fprintf (oppout, "extern int %s_%s_%s_method();\n\
extern OMuword %s_OPP_%s_method_index;\n",
	        cl->s.s.name, name, p->s.s.name, name, p->s.s.name);
      }
     else if (we_rejected_it (p))
      {
       ++override_count;
       fprintf (oppout, "extern OMuword %s_OPP_%s_method_index;\n",
	        name, p->s.s.name);
      }
    if (override_count)
     {
      fprintf (oppout, "static OM_S_OVERRIDE OPP_%s_overrides[]=\n {\n", name);
      for (p = messages; p; p = p->link)
       if (we_overrode_it (p))
        fprintf (oppout, "  { &%s_OPP_%s_method_index, %s_%s_%s_method },\n",
  	         name, p->s.s.name, cl->s.s.name, name, p->s.s.name);
       else if (we_rejected_it (p))
        fprintf (oppout, "  { &%s_OPP_%s_method_index, 0 },\n", name, p->s.s.name);

      fputs (" };\n", oppout);
     }
   }
 } /* dump_overrides */

static void dump_components (cl)
 identifier_ptr cl;
 {
  carrier_ptr cp;

  fputs ("static OM_S_COMPCLASSDEF OPPcomponent_list[]=\n {\n", oppout);
  for (cp=cl->classdef->component_list; cp; cp=cp->next)
   {
    int override_count = 0;
    int inherit_count = 0;
    int reject_count = 0;
    identifier_ptr cargo = cp->cargo;
    char *name;

    {
     identifier_ptr p;
     for (p = cargo->classdef->messages; p; p = p->link)
      {
       if (we_overrode_it (p)) ++override_count;
       if (we_rejected_it (p)) ++reject_count;
       if (we_inherited_it (p)) ++inherit_count;
      }
    }

    fprintf (oppout, "  {%d,%d,", override_count+reject_count, inherit_count);

    name = cargo->s.s.name;

    if (override_count+reject_count)
     fprintf (oppout, "OPP_%s_overrides,", name);
    else
     fputs ("0,", oppout);

    if (inherit_count)
     fprintf (oppout, "OPP_%s_inherits,", name);
    else
     fputs ("0,", oppout);

    fprintf (oppout, "&OPP_%s_class_id,", name);

    if ( (cargo->field_link) 
                 && 
         (! class_overridden(cl->classdef->override_list,name)) 
       )
     pp_fprintf (oppout, "(OMuint)offsetof(struct %s_total_instance, %s)",
      cl->s.s.name, name);
    else
     fputc ('0', oppout);

    fputs ("},\n", oppout);
   }
  fputs (" };\n", oppout);
 } /* dump_components */

static int class_is_taggable (classdef)
 struct opp_class_def *classdef;
 {
  carrier_ptr cp;

  if (classdef->flags & F_CLASS_NOT_TAGGABLE)
   return (0);

  if (classdef->flags & F_CLASS_TAGGABLE)
   return (1);

  for (cp=classdef->component_list; cp; cp=cp->next)
   {
    identifier_ptr cargo = cp->cargo;

    if (cargo->classdef->flags & F_CLASS_TAGGABLE)
     return (1);
   }
  return (0);
 } /* class_is_taggable */

void generate_class_init (classdef)
 struct opp_class_def *classdef;
 {
  carrier_ptr channel_list=NULL;
  int channel_count = 0;
  int varray_count = 0;
  char str[80];
  identifier_ptr cl = (identifier_ptr)lookup_symbol (classdef->sym_tab, classdef->name);

  dump_inherited_types (classdef, 1);
  dump_messages (cl, 1);
  declare_component_ids (cl);
  dump_total_instance (cl);

  /* use carriers to list channels */
  channel_count = find_channels_and_dump_types (cl, &channel_list);
  if (channel_list)
   {
    dump_channels (cl, channel_list);
    while (channel_list)
     {
      carrier_ptr p = channel_list->next;
      free (channel_list);
      channel_list = p;
     }
   }

  strcpy (str, cl->s.s.name);
  strcat (str, "_instance");
  describe_instance (cl, str); /* in odinsup.c */

  dump_overrides (cl);
  dump_inherits (cl);
  dump_components (cl);

  dump_dispatch_table (cl);

  if (classdef->parent_count)
   {
    identifier_ptr *p = (identifier_ptr *)classdef->A_parents;
    identifier_ptr *stop = (identifier_ptr *)(p + classdef->parent_count);

    /* "extern" parents' class_init structs as functions */

    for (; p < stop; ++p)
     fprintf (oppout,"extern %s_OM_class_init ();\n", (*p)->s.s.name);

    fputs ("static OM_S_ANCESTRY OPP_parents[]=\n {\n", oppout);

    for (p = (identifier_ptr *)classdef->A_parents; p < stop; ++p)
     {
      fprintf (oppout, "  {&OPP_%s_class_id, %s_OM_class_init, %d, %d},\n",
 	 (*p)->s.s.name, (*p)->s.s.name, (*p)->classdef->major_version,
	 (*p)->classdef->minor_version);
     }
    fputs (" };\n", oppout);
   }

  varray_count = dump_and_count_varrays (cl);

  /* Write the function header */
  fprintf (oppout, "int %s_OM_class_init()\n{\n",
           cl->s.s.name);
  
  
  /* build structure for create_class */
#if defined(SUNOS) || defined(IRIX) || defined(NT)
  fprintf (oppout, "   static OM_S_CREATECLASS_ARGS OPP_class_init=\n { %d,%d,%d,%d,\n\
   \"%s\", sizeof(struct %s_total_instance),\n",
	   opp_version >> 16, (opp_version >> 8) & 0xff,
	   classdef->major_version, classdef->minor_version,
	   cl->s.s.name, cl->s.s.name);
#elif defined(CLIX)
  fprintf (oppout, "   static OM_S_CREATECLASS_ARGS OPP_class_init=\n { %d,%d,%d,%d,\n\
   {\"%s\"}, sizeof(struct %s_total_instance),\n",
	   opp_version >> 16, (opp_version >> 8) & 0xff,
	   classdef->major_version, classdef->minor_version,
	   cl->s.s.name, cl->s.s.name);
#else
#error Unknown OS
#endif
  {
  static char zero_comma_nl[] = "   0,\n";

  if (cl->field_link)
   fprintf (oppout, "   sizeof(struct %s_instance),\n", cl->s.s.name);
  else
   fputs (zero_comma_nl, oppout);

  fputs (channel_count ? "   OPPchannel_index,\n" : zero_comma_nl, oppout);
  fputs (varray_count  ? "   OPPvarrays,\n"       : zero_comma_nl, oppout);

  if (cl->link)
   fprintf (oppout, "   OPP%s_method_defs,\n", cl->s.s.name);
  else
   fputs (zero_comma_nl, oppout);

  fputs (classdef->parent_count ? "   OPP_parents,\n" : zero_comma_nl, oppout);

  fputs ("   OPPcomponent_list,\n", oppout);

  fputs (cl->link ? "   OPPmethod_list,\n" : zero_comma_nl, oppout);
  }

  fprintf (oppout, "   &OPP_%s_class_id,%d,%d,%d,%d,%d,%d\n  };\n",
	   cl->s.s.name, channel_count, varray_count,
	   cl->index/* message count */, classdef->parent_count,
	   classdef->component_count,
	   class_is_taggable(classdef));

  /* class init function return pointer to create class args. */
  
  fprintf (oppout, "   return ((int)&OPP_class_init);\n}\n");
  
 } /* generate_class_init */
