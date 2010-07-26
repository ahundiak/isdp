/*
------------------------------------------------------------------------------

	Name:			ddp_dump.c      
	Author:			R. Eade
	Creation Date:		December, 1987

	Abstract:
		Implements the routines to generate ascii class files that
		hold the data dictionary information.

	Revisions:
				
------------------------------------------------------------------------------
*/
#include <stdio.h>
#include "class.h"
#include "../opp/y.tab.h"
#include "oppydefs.h"
#include "relations.h"
#include "symtab.h"
#include "identifier.h"

#include "ddp_tcodes.h"
#include "ddp_info.h"
#include "ddp_defns.h"
#include "ddp_error.h"
#include "ddp_hash.h"
#include "ddp_om.h"

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
#define SEPARATOR_S	"/"
#define SEPARATOR_C	'/'
#elif defined(NT)
#define SEPARATOR_S	"\\"
#define SEPARATOR_C	'\\'
#else
#error Unknown OS
#endif

struct dep_decl
{
    char classname[MAX_SIZE];
    char typename[MAX_SIZE];
    struct field_info fldinfo;
    struct dep_decl *next;
} *p_dep_decl_list;


FILE *Gp_outfile;		/* file pointer for the current output file */
char *Gp_outfilename;

static int  G_fld_offset;	/* offset within field */
static struct opp_class_def 
            *Gp_classdef;	/* current class being processed. */
extern char Gp_dirname[];	/* dictionary directory. */
extern int  Gf_replace;		/* overwrite identical versions. */

static struct hash_table *Gp_types;	/* hash table of all known types. */

#ifdef DEBUG
/*----------------------------------------------------------------------------
   print_symbol

   Prints out the name and class of an opp identifier.
----------------------------------------------------------------------------*/
static void print_symbol (sym)
identifier_ptr sym;
{
	char	*class = "Root";

   if (strcmp(sym->classdef->name, class)) 
      return;

   error(INFO,"\t\t%s", sym->s.s.name); 
   error(INFO,"\t- %d -", sym->s.tok);

   switch (sym->type_info.std_class)
   {
      case noclass : error(INFO,"\t- no class\n"); break;
      case auto_class : error(INFO,"\t- auto class\n"); break;
      case extern_class : error(INFO,"\t- extern class\n"); break;
      case static_class : error(INFO,"\t- static class\n"); break;
      case typedef_class : error(INFO,"\t- typedef class\n"); break;
      case register_class : error(INFO,"\t- register class\n"); break;
      case variable_class : error(INFO,"\t- variable class\n"); break;
      default : error(INFO,"\n"); break;
   }
}/* print_symbol */
#endif

/*----------------------------------------------------------------------------
   ceiling

   Computes the mathematical ceiling function for two integers.
-----------------------------------------------------------------------------*/
static int ceiling (a, b)
int a, b;
{
   if (0 == b)
      return (0);	/* struct, enum, or union with zero size. */
   else
      return (b* (int)((a+b-1)/b));
}

/*----------------------------------------------------------------------------
   get_type_size

   Determines the size of the declared item given the starting bit
   position, also determines the padding that is necessary before
   and after the item.
-----------------------------------------------------------------------------*/
static int get_type_size (ti, start_pos, p_align)
struct Type_Info ti;
int              *start_pos;
int              *p_align;
{
   int tsize, csize, pos, pad_pos;
   int align_size, fld_align_size, its, end_pos;
   dcltr_ptr dl, p_dcltr, p_dcltr_list;
   identifier_ptr sc;

   tsize = 0;
   pos = *start_pos;
   align_size = 0;

   /* re-order the declarator list */

   p_dcltr_list = NULL;
   dl = ti.dcltr_link; 
   while (dl)
   {
      p_dcltr = (dcltr_ptr) malloc(sizeof (struct dcltr));
      *p_dcltr = *dl;
      p_dcltr->next = p_dcltr_list;
      p_dcltr_list = p_dcltr;
      if (p_dcltr->type == dt_pointer) goto proc_dcltr;
      dl = dl->next;
   }

   if (ti.type_link)
   {
      switch (ti.type_link->s.tok)
      {
         case ENUM_NAME : /* enumeration field */
            tsize = 0; break;

         case ENUM_TAG :
	    /* assuming that enumerations are always of size 'long int' */
	    pos = ceiling (pos, align_size = SIZE_IN_BITS (long int));
	    tsize = SIZE_IN_BITS (long int);
	    break;

         case STRUCT_NAME :
            pad_pos = 0;
            fld_align_size = 0;
            for (sc = ti.type_link->field_link; sc; sc = sc->link)
            {
               csize = get_type_size(sc->type_info, &pad_pos, &fld_align_size);
	       if (! csize)
	       {
	       	  fprintf (stderr, "error from class '%s'\n", ti.term->sym->classdef->name);
	          fprintf (stderr, "field type '%s' in struct '%s' has zero size.\n",
	                   sc->type_info.term->sym->s.s.name,
	                   ti.term->sym->s.s.name);
	          error(FATAL,"fatal error\n");
	       }
               if (fld_align_size > align_size) 
                  align_size = fld_align_size;
               pad_pos += csize;
	    }
	    tsize = ceiling (pad_pos, align_size);
	    pos = ceiling (pos, align_size);
	    break;

         case UNION_NAME :
	    pad_pos = pos;
	    fld_align_size = 0;
	    for (sc = ti.type_link->field_link; sc; sc = sc->link)
	    {
               csize = get_type_size(sc->type_info, &pad_pos, &fld_align_size);
	       if (! csize)
	       {
	       	  fprintf (stderr, "error from class '%s'\n", ti.term->sym->classdef->name);
	          fprintf (stderr, "field type '%s' in union '%s' has zero size.\n",
	                   sc->type_info.term->sym->s.s.name,
	                   ti.term->sym->s.s.name);
	          error(FATAL,"fatal error\n");
	       }
               if (csize > tsize) 
                  tsize = csize;
               if (fld_align_size > align_size) 
                  align_size = fld_align_size;
	    }
	    pos = pad_pos;
	    tsize = ceiling (tsize, align_size);
	    break;

         case CHANNEL_NAME :
	    pos = ceiling (pos, align_size = SIZE_IN_BITS (long int));
	    tsize = SIZE_IN_BITS (OM_p_CHANNEL_HDR);
	    break;

         case CLASS_NAME :
         default :
	    tsize = 0;
	    break;
	}
    }
    else
    {
	switch (ti.std_size)
	{
	default :
	    switch (ti.std_type)
	    {
	    case char_type : 
		pos = ceiling (pos, align_size = SIZE_IN_BITS(char));
		tsize = SIZE_IN_BITS (char);
		break;
	    case float_type : 
		pos = ceiling (pos, align_size = SIZE_IN_BITS(float));
		tsize = SIZE_IN_BITS (float);
		break;
	    default :
	    case int_type :
		pos = ceiling (pos, align_size = SIZE_IN_BITS(int));
		tsize = SIZE_IN_BITS (int);
		break;
	    }
	    break;
	case short_size :
	    switch (ti.std_type)
	    {
	    case char_type : 
		pos = ceiling (pos, align_size = SIZE_IN_BITS(char));
		tsize = SIZE_IN_BITS (char);
		break;
	    case float_type : 
		pos = ceiling (pos, align_size = SIZE_IN_BITS(float));
		tsize = SIZE_IN_BITS (float);
		break;
	    default :
	    case int_type :
		pos = ceiling (pos, align_size = SIZE_IN_BITS(short int));
		tsize = SIZE_IN_BITS (short int);
		break;
	    }
	    break;
	case long_size :
	    switch (ti.std_type)
	    {
	    case char_type : 
		pos = ceiling (pos, align_size = SIZE_IN_BITS(char));
		tsize = SIZE_IN_BITS (char);
		break;
	    case float_type : 
		pos = ceiling (pos, align_size = SIZE_IN_BITS(double));
		tsize = SIZE_IN_BITS (double);
		break;
	    default :
	    case int_type :
		pos = ceiling (pos, align_size = SIZE_IN_BITS(long int));
		tsize = SIZE_IN_BITS (long int);
		break;
	    }
	    break;
	}
    }

proc_dcltr :

    while (p_dcltr_list)
    {
	switch (p_dcltr_list->type)
	{
	case dt_pointer : 
	    pos = ceiling (*start_pos, align_size=SIZE_IN_BITS (p_dcltr_list));
	    tsize = SIZE_IN_BITS (p_dcltr_list);
	    break;
	case dt_array : 
	    tsize *= p_dcltr_list->size;
	    break;
	case dt_varray : 
	    pos = ceiling (*start_pos, align_size = SIZE_IN_BITS (int));
	    tsize = SIZE_IN_BITS (OM_S_VARLENARR_DESCR);
	    break;
	case dt_function : 
	    pos = ceiling (*start_pos, align_size=SIZE_IN_BITS (p_dcltr_list));
	    tsize = SIZE_IN_BITS (p_dcltr_list);
	    break;
	case dt_bitfield : 
	    its = align_size = tsize;	/* integral type size for bitfield */
	    tsize = p_dcltr_list->size;
	    if (tsize)
	    {
	        /* do not attempt to pad by integral type, so reset position */
	        pos = *start_pos;		
	        end_pos = its * (pos/its +1);
	        if ((end_pos - pos) < tsize) pos = end_pos;
	    }
	    break;
	default : break;
	}
	p_dcltr = p_dcltr_list;
	p_dcltr_list = p_dcltr_list->next;
	free(p_dcltr);
    }

    if (p_align) *p_align = align_size;
    *start_pos = pos;
    return (tsize);
}

/*----------------------------------------------------------------------------
   get_field_data

   Fills in a field_info structure given an OPP identifier.  The information
   describes a data field.
----------------------------------------------------------------------------*/
static void get_field_data (opp_field, ddp_field)
identifier_ptr    opp_field;
struct field_info *ddp_field;
{
   unsigned short lsize, type_code = 0;
   int unsign, fld_size;
   struct dcltr *dl;

   strncpy (ddp_field->field_name, opp_field->s.s.name, MAX_SIZE);

   lsize = 0;
   dl = opp_field->type_info.dcltr_link; 
   while (dl)
   {
      switch (dl->type)
      {
         case dt_pointer : 
            ddp_field->Ctype_list[lsize++] = POINTER_CODE; 
            break;
         case dt_array : 
            ddp_field->Ctype_list[lsize++] = ARRAY_CODE; 
            ddp_field->Ctype_list[lsize++] = dl->size;
            break;
         case dt_varray : 
            ddp_field->Ctype_list[lsize++] = VARARRAY_CODE; 
            ddp_field->Ctype_list[lsize++] = dl->size;
            break;
         case dt_function : 
            ddp_field->Ctype_list[lsize++] = FUNCTION_CODE; 
            break;
         case dt_bitfield : 
            ddp_field->Ctype_list[lsize++] = BITFIELD_CODE; 
            break;
	 default : 
            ddp_field->Ctype_list[lsize++] = NULL_CODE; 
            break;
      }
      
      dl = dl->next;
   }

   if (opp_field->type_info.type_link)
   {
      switch (opp_field->type_info.type_link->s.tok)
      {
         case ENUM_NAME :
            type_code = ENUM_FIELD_CODE;
            break;
         case ENUM_TAG :
            type_code = ENUMERATION_CODE;
            break;
         case STRUCT_NAME :
            type_code = STRUCT_CODE;
            break;
	 case UNION_NAME :
	    type_code = UNION_CODE;
	    break;
	 case CHANNEL_NAME :
            type_code = CHANNEL_CODE;
            break;
	 case CLASS_NAME :
            type_code = CLASS_CODE;
	    break;
      }

      strncpy (ddp_field->type_name, 
	       opp_field->type_info.type_link->s.s.name, 
               MAX_SIZE);
   }
   else
   {
      unsign = (int) opp_field->type_info.unsigned_attribute;

      switch (opp_field->type_info.std_size)
      {
         default :
            switch (opp_field->type_info.std_type)
	    {
	       case char_type : 
	          type_code = (unsign) ? UCHAR_CODE : CHAR_CODE;
		  break;
	       case float_type : 
		  type_code = FLOAT_CODE;
		  break;
	       case int_type :
	          type_code = (unsign) ? UINT_CODE : INT_CODE;
		  break;
	       default :
                  switch(opp_field->s.tok)
                  {
                     case ENUM_NAME:
                        type_code = ENUM_FIELD_CODE;
                        break;
                  }
                  break;
            }
            break;
	 case short_size :
            switch (opp_field->type_info.std_type)
	    {
	       case char_type : 
	          type_code = (unsign) ? UCHAR_CODE : CHAR_CODE;
		  break;
	       case float_type : 
	          type_code = FLOAT_CODE;
		  break;
	       default :
	       case int_type :
	          type_code = (unsign) ? USHORT_CODE : SHORT_CODE;
		  break;
	     }
	     break;
	  case long_size :
	     switch (opp_field->type_info.std_type)
	     {
		case char_type : 
		   type_code = (unsign) ? UCHAR_CODE : CHAR_CODE;
		   break;
		case float_type : 
		   type_code = DOUBLE_CODE;
		   break;
		default :
		case int_type :
		   type_code = (unsign) ? ULONG_CODE : LONG_CODE;
		   break;
            }
	    break;
      }
      strcpy (ddp_field->type_name, "");
   }

   ddp_field->Ctype_list[lsize++] = type_code;

   ddp_field->list_size = lsize;
   fld_size = get_type_size (opp_field->type_info, &G_fld_offset, (int *)0);
   if (! fld_size)
   {
      fprintf (stderr, "error from class '%s'\n", opp_field->classdef->name);
      fprintf (stderr, "field '%s' has zero size.\n", opp_field->s.s.name);
      error(FATAL,"fatal error\n");
   }
   if (ddp_field->Ctype_list[0] == BITFIELD_CODE)
   {
      ddp_field->offset = G_fld_offset;
      ddp_field->size = ddp_field->Ctype_list[1] = fld_size;
      ddp_field->Ctype_list[2] = NULL;
      ddp_field->list_size = 2;
   }
   else if (ddp_field->Ctype_list[0] == ENUM_FIELD_CODE)
   {
      ddp_field->size = ddp_field->offset = NULL;
      ddp_field->Ctype_list[1] = opp_field->index;
      ddp_field->Ctype_list[2] = NULL;
      ddp_field->size = sizeof(long int);
      ddp_field->list_size = 2; 
   }
   else	/* offset and size for non-bit fields goes as bytes */
   {
      ddp_field->offset = G_fld_offset >> 3;
      ddp_field->size = fld_size >> 3;
   }

   G_fld_offset += fld_size;

   ddp_field->dynamic_flag = NULL;

   return;
}

#ifdef DEBUG
/*---------------------------------------------------------------------------
   print_fld_info

   Used in debugging to display the contents of a field_info structure.
----------------------------------------------------------------------------*/
static void print_fld_info (fld)
struct field_info *fld;
{
    int i;

    error(INFO, "\t\t\tfield_name=%s,\n", fld->field_name);
    error(INFO, "\t\t\t\tdynamic_flag=%d,\n", fld->dynamic_flag);
    error(INFO, "\t\t\t\tlist_size=%d,\n", fld->list_size);
    for (i=0; i<fld->list_size; i++)
       error(INFO, "\t\t\t\tCtype_list[%d]=%d,\n", i, fld->Ctype_list[i]);

    error(INFO, "\t\t\t\toffset=%d,\n", fld->offset);
    error(INFO, "\t\t\t\tsize=%d,\n", fld->size);
    error(INFO, "\t\t\t\ttype_name=");
    if (fld->type_name[0])
	error(INFO, "%s\n", fld->type_name);
    else
	error(INFO, "NULL\n");
}
#endif

/*---------------------------------------------------------------------------
   dump_field_info

   Used to print a field info structure to the current dictionary output
   file.
----------------------------------------------------------------------------*/
static void dump_field_info (fld, dynamic_flag)
struct field_info *fld;	/* Pointer to the field to be added */
int dynamic_flag;	/* If true, then dump the dynamic flag as well. */
{
   unsigned short ii;

   fprintf (Gp_outfile, "%s ", fld->field_name);
   if (dynamic_flag)
      fprintf (Gp_outfile, "%d ", fld->dynamic_flag);
   fprintf (Gp_outfile, "%d ", fld->list_size);

   for (ii=0; ii<fld->list_size; ii++)
   {
      fprintf (Gp_outfile,"%s ",ddp_GA_code_names[fld->Ctype_list[ii]]);

      switch (fld->Ctype_list[ii])
      {
         /*------------------------------------------------------------*/
         /*  All of these types expect a value to follow them.   This  */
         /*  value is just printed as a number.                        */
         /*------------------------------------------------------------*/

         case ARRAY_CODE:	/* array size follows */
         case VARARRAY_CODE:	/* array size follows */
         case BITFIELD_CODE:	/* field size follows */
         case ENUM_FIELD_CODE:	/* index of enum follows */

            fprintf (Gp_outfile,"%d ",fld->Ctype_list[++ii]);
            break;
      }
   }

   fprintf (Gp_outfile, "%d ", fld->offset);
   fprintf (Gp_outfile, "%d ", fld->size);
   if (fld->type_name[0])
      fprintf (Gp_outfile, "%s\n", fld->type_name);
   else
      fprintf (Gp_outfile, "|||\n");
   
   return;
}

/*----------------------------------------------------------------------------
   add_tagnames

   Called from process_local_symbols for each identifier in a specified
   symbol table.  Puts information about each symbol in the dictionary.
----------------------------------------------------------------------------*/
static void add_tagnames (tagid)
identifier_ptr tagid;
{
   struct type_info typ;
   struct chantype_info chntyp;
   struct field_info fld;
   identifier_ptr comp;
   int t_code, add_field, comp_size, i;
   struct dep_decl *dep_ptr;
   char t_name[MAX_SIZE];

   /* if the declaration was not made in the class being processed,
      do not put the tag information in here */

#ifdef DEBUG
    error(INFO,"type '%s' declared in class '%s'\n", 
            tagid->s.s.name, tagid->classdef->name);
#endif

    if (strcmp(tagid->classdef->name, Gp_classdef->name)) 
       return;

    strncpy (t_name, tagid->s.s.name, MAX_SIZE);
    strncpy (typ.type_name, t_name, MAX_SIZE);
    switch (tagid->s.tok)
    {
       case ENUM_TAG : t_code = ENUMERATION_CODE; break;
       case STRUCT_NAME : t_code = STRUCT_CODE; break;
       case UNION_NAME : t_code = UNION_CODE; break;
       case CHANNEL_NAME : t_code = CHANNEL_CODE; break;
       case CLASS_NAME : 
       default : return;
    }

    typ.type_code = t_code;

#ifdef  DEBUG
    error(INFO,"\t\tTag name is '%s' (%d) and fields are \n",
					typ.type_name, typ.type_code);
#endif

    if (t_code == CHANNEL_CODE)
    {
	struct hook_definition *p_hookdefn;
	unsigned short opp_chanbits, ddp_chanbits;

	strcpy (chntyp.type_name, t_name);
	p_hookdefn = (struct hook_definition *) tagid->field_link;

        /*--------------------------------------------------------------*/
        /*  Get the channel attributes as filled in by opp.  Clear any  */
        /*  unused bits.                                                */
        /*--------------------------------------------------------------*/

	opp_chanbits = (unsigned short) 
           p_hookdefn->attributes & CHAN_ATT_OM_BITS;

        ddp_chanbits = 0;

        chntyp.size = sizeof(OM_p_CHANNEL_HDR);

        /*-----------------------------------------------*/
        /*  Convert the opp set fanout bits to seq bits. */
        /*-----------------------------------------------*/

	switch (opp_chanbits & CHAN_ATT_SIDES)
	{
 	   case CHAN_ATT_OO :
              ddp_chanbits |= DDP_CHAN_ATT_OO;
              break;
  	   case CHAN_ATT_MO :
              ddp_chanbits |= DDP_CHAN_ATT_MO;
              break;
	   case CHAN_ATT_OM :
              ddp_chanbits |= DDP_CHAN_ATT_OM;
              break;
	   case CHAN_ATT_MM :
              ddp_chanbits |= DDP_CHAN_ATT_MM;
              break;
           default :
              chntyp.size = 0;
              break;
	}

        /*-------------------------------------------------*/
        /* Set the bits for ordering and/or restrictions.  */
        /*-------------------------------------------------*/

        switch (opp_chanbits & (CHAN_ATT_REL | CHAN_ATT_ABS))
        {
           case CHAN_ATT_REL:
              ddp_chanbits |= DDP_CHAN_ATT_REL;
              break;
           case CHAN_ATT_ABS:
              ddp_chanbits |= DDP_CHAN_ATT_ABS;
              break;
        }

        if (opp_chanbits & CHAN_ATT_RES)
           ddp_chanbits |= DDP_CHAN_ATT_RES;

	chntyp.channel_flags = ddp_chanbits;
	chntyp.initial_size = p_hookdefn->initial_count;
	chntyp.increment_size= p_hookdefn->incremental_count;

        fprintf(Gp_outfile,"CHANTYPE\n%s %d %d %d %d\n",
                           chntyp.type_name,
                           chntyp.channel_flags,
                           chntyp.initial_size,
                           chntyp.increment_size,
                           chntyp.size);

        /*---------------------------------------------------------------*/
        /*  This next loop makes sure that all classes which are listed  */
        /*  as restrictions on this channel are represented in the       */
        /*  dictionary.							 */
        /*---------------------------------------------------------------*/

	for (i=0; i < p_hookdefn->class_count; i++)
	{

           char              *p_chan;   /* points to a channel name */ 

           /*  If a channel name is specified as part of the restriction,  */
           /*  get a pointer to the channel name and NULL terminate the    */
           /*  class name.                                                 */

           if (p_chan = (char *)strchr(p_hookdefn->class_list[i],'.'))
           {
              *p_chan = '\0';
              ++p_chan;
           }
              
           {/* begin block to get class from class list. */

              char                 *tmp_classname;
              struct opp_class_def *p_tmpclassdef;

              char                 *saved_outfile_name;
              struct opp_class_def *saved_classdef;
              int                  saved_fld_offset;
              struct hash_table    *saved_types;

              if (NULL != (tmp_classname = (char *)strrchr(p_hookdefn->class_list[i],SEPARATOR_C)))
                 ++tmp_classname;
              else
                 tmp_classname = p_hookdefn->class_list[i];

              /*--------------------------------------------------------*/
              /*  This call can cause recursion.  Save any globals.     */
              /*--------------------------------------------------------*/

              saved_outfile_name = Gp_outfilename;
              fclose(Gp_outfile);

              saved_classdef = Gp_classdef;
              saved_fld_offset = G_fld_offset;
              saved_types = Gp_types;

              lookup_class(tmp_classname, &p_tmpclassdef);

              Gp_outfilename = saved_outfile_name;
              Gp_classdef = saved_classdef;
              G_fld_offset = saved_fld_offset;
              Gp_types = saved_types;

              if (NULL == (Gp_outfile = (FILE *) fopen(Gp_outfilename,"a+")))
                 error(FATAL,"unable to reopen '%s'\n",Gp_outfilename);

              fprintf(Gp_outfile,"OMREST\n%s %s %d %d ",
                      chntyp.type_name,
                      tmp_classname,
                      p_tmpclassdef->major_version,
                      p_tmpclassdef->minor_version);

           }/* end block to get class from class list */
     
           if (p_chan)
           {
              /* Write the channel name */

              fprintf(Gp_outfile,"%s\n",p_chan);
              --p_chan;
              *p_chan = '.';
           }
           else
           {
              fprintf(Gp_outfile,"|||\n");
           }
	}/* for all channel restrictions */
 
	return;
    }/* if it is a channel */
    else
    {
        /*------------------------------------------------------------*/
        /* For each field in the type definition, calculate its size. */
        /* The align_size of composite types is the size of the       */
        /* largest member of that type.                               */
        /*------------------------------------------------------------*/

	identifier_ptr sc;
	int align_size, fld_align_size, pad_pos;

	pad_pos = fld_align_size = 0;
	align_size = 8;

	for (sc = tagid->field_link; sc; sc = sc->link)
	{
            int size;
	    size = get_type_size (sc->type_info, &pad_pos,&fld_align_size);
            if (! size)
            {
               fprintf (stderr, "error from class '%s'\n", tagid->classdef->name);
               fprintf (stderr, "field '%s' ", sc->s.s.name);
               if (sc->type_info.term->sym)
                  fprintf (stderr, "type '%s' ", sc->type_info.term->sym->s.s.name);
               if (ENUMERATION_CODE == typ.type_code)
                  fprintf (stderr, "in enum ");
               else if (UNION_CODE == typ.type_code)
                  fprintf (stderr, "in union ");
               else
                  fprintf (stderr, "in struct ");
               fprintf (stderr, "'%s' has zero size\n", tagid->s.s.name);
               error (FATAL, "fatal error\n");
            }
            if (fld_align_size > align_size) align_size = fld_align_size;

            /*-------------------------------------------------------*/
            /* Unions and enumerations do not accumulate the size of */
            /* their members.                                        */
            /*-------------------------------------------------------*/

            if ((typ.type_code != ENUMERATION_CODE) 
                               &&
                (typ.type_code != UNION_CODE))
               pad_pos += size;
            else
               if (size > pad_pos) 
                  pad_pos = size;
	}

	comp_size = ceiling (pad_pos, align_size);
	typ.size = (comp_size+7)>>3;
	typ.alignment = (align_size+7)>>3;

        fprintf(Gp_outfile,"CTYPE\n%s %s %d\n",
                typ.type_name,
                ddp_GA_code_names[typ.type_code],
                typ.size);

        /* Put the typename into the global typename table for this class.
           This is a hash table of all the types that have been added to
           to this class.  It is used to resolve forward references.  */

        DDP_hash_add(Gp_types, tagid->s.s.name);
    }

    G_fld_offset = 0;
    comp = tagid->field_link;

    while (comp)
    {
	get_field_data (comp, &fld);

#ifdef DEBUG
	print_fld_info (&fld);
#endif

	add_field = TRUE;

        /*  There are two components to be dealt with here:  fld.field_name
            and fld.type_name.  If the field has a type, and the type is
            not yet known.   Defer adding this field until the type is
            known.  (Just stick it on a list for later.) */

	if (strlen(fld.type_name))
	{
           /* If this type is not yet known, defer adding it.  */

           if (! DDP_hash_lookup(Gp_types, fld.type_name))
           {
#ifdef DEBUG
              error(INFO,"deferred adding field '%s' due to reference to '%s'\n",
                       fld.field_name, fld.type_name);
#endif
		/* save all the field information so that the field can be 
		   added in when its dependency has been resolved */

               dep_ptr = (struct dep_decl *) malloc(sizeof(struct dep_decl));
               strcpy (dep_ptr->typename, t_name);
               dep_ptr->fldinfo = fld;

               dep_ptr->next = p_dep_decl_list;
               p_dep_decl_list = dep_ptr;

               add_field = FALSE;
         }/* if type not yet defined */
      }/* if field has a type */

      if (add_field)
      {
         fprintf(Gp_outfile,"TYPEFIELD\n%s ",tagid->s.s.name);
         dump_field_info(&fld, 0);
      }

      comp = comp->link;	
   }/* while another component of this type */

   return;
}

/*---------------------------------------------------------------------------
   add_dep_decl

   Add all the types that were defered because of a forward reference or
   inheritance from an ancestor.
----------------------------------------------------------------------------*/
static void add_dep_decl ()
{

   struct dep_decl *dep_ptr, *last_dep_ptr;

   dep_ptr = last_dep_ptr = p_dep_decl_list;
   while (dep_ptr)
   {
#     ifdef DEBUG
      error(INFO,"adding field '%s' of type '%s' dependent on type '%s'\n", 
		dep_ptr->fldinfo.field_name, dep_ptr->typename, 
			dep_ptr->fldinfo.type_name);
#     endif
      fprintf(Gp_outfile, "TYPEFIELD\n%s ",dep_ptr->typename);
      dump_field_info(&dep_ptr->fldinfo, 0);

      last_dep_ptr->next = dep_ptr->next;
      if (p_dep_decl_list == dep_ptr) p_dep_decl_list = dep_ptr->next;
      if (last_dep_ptr == dep_ptr) last_dep_ptr = dep_ptr->next;
      free(dep_ptr);

      dep_ptr = dep_ptr->next;
   }
}

/*----------------------------------------------------------------------------
   add_parents

   Records class inheritance information from the class defn. in the 
   dictionary. 
-----------------------------------------------------------------------------*/
static void add_parents (parent_count, ancestors)
int parent_count;
identifier_ptr ancestors[];
{
   int ii;

   for (ii=0; ii < parent_count; ii++)
      fprintf (Gp_outfile, "PARENT\n%s %d %d\n", 
               ancestors[ii]->s.s.name, 
	       ancestors[ii]->classdef->major_version, 
	       ancestors[ii]->classdef->minor_version);
   return;
}

/*---------------------------------------------------------------------------
   class_overriden

   Returns TRUE if class's instance data was overridden.  Otherwise
   returns FALSE.
---------------------------------------------------------------------------*/
static int class_overridden (override_list, classname)
carrier_ptr override_list;
char *classname;
{
   register carrier_ptr cur = override_list;
   for (; cur; cur=cur->next)
      if (! strcmp(cur->cargo->s.s.name, classname))
         return 1;

   return 0;
}

/*---------------------------------------------------------------------------
   add_rejected_instance_data

   Adds records for any instance data that was rejected.
---------------------------------------------------------------------------*/
static void add_rejected_instance_data (classdef)
struct opp_class_def *classdef;
{
  carrier_ptr cp; /* for traversal of component_list */
  carrier_ptr comp = classdef->component_list;
  carrier_ptr over = classdef->override_list;

  for (cp = comp; cp; cp=cp->next)
     if (class_overridden(over, cp->cargo->s.s.name))
        fprintf (Gp_outfile, "REJECTED_INSTANCE\n%s %d %d\n", 
           cp->cargo->s.s.name,
           cp->cargo->classdef->major_version,
           cp->cargo->classdef->minor_version); 
}

/*----------------------------------------------------------------------------
   add_message

   Adds all info about a single message to the dictionary.  This routine
   should not be called until after all the CTYPE records have been written.
   The types for message parameters should already exist in the file.
-----------------------------------------------------------------------------*/
static void add_message(p_msg)
identifier_ptr p_msg;
{
   unsigned short    param_cnt;
   identifier_ptr    pp;
   struct field_info attr_info;

#ifdef  DEBUG
   error(INFO,"\t\t%s\n", p_msg->s.s.name);	
#endif

   for (param_cnt=0, pp=p_msg->field_link; pp; param_cnt++, pp=pp->link);

   fprintf(Gp_outfile, "MESSAGE\n%s %d\n",p_msg->s.s.name, param_cnt);

   /*  add an entry for each parameter of this message  */

   G_fld_offset = 0;
   for (pp = p_msg->field_link; pp; pp=pp->link)
   {
      get_field_data (pp, &attr_info);

      fprintf(Gp_outfile,"MSGPARM\n%s ",p_msg->s.s.name);
      dump_field_info(&attr_info, 0);

   }/* for all parameters to this message */

   return;
}

/*-----------------------------------------------------------------------------
   DDP_create_class_info

   Takes the opp parser output and creates the ascii dictionary files.
-----------------------------------------------------------------------------*/
void DDP_create_class_info (class_info)
struct opp_class_def *class_info;	/* opp parser output */
{
   identifier_ptr    idptr;
   struct class_info *p_cls_info;
   struct field_info attr_info;
   int               replaced = 0;
   char              last_sequence_num[3];

   /*----------------------------------------------------------------------*/
   /*  Attempt to get a list of versions for this class from the current   */
   /*  dictionary directory.                                               */
   /*----------------------------------------------------------------------*/

   p_cls_info = (struct class_info *) 
                   DDP_get_class_version_list(class_info->name, Gp_dirname);

   if (p_cls_info)
   {
      /*------------------------------------------------------------------*/
      /*  This class is represented in the current dictionary.  If this   */
      /*  version of the class is already in the dictionary, do nothing   */
      /*  unless the replace flag is set.                                 */
      /*------------------------------------------------------------------*/

      struct class_info *p_tmp, *p_prev;

      strncpy(last_sequence_num, p_cls_info->sequence_num, 3);

      for (p_tmp = p_cls_info, p_prev = NULL; p_tmp; p_tmp = p_tmp->next)
      {
         if ((p_tmp->major_version_num == class_info->major_version) 
                                  && 
             (p_tmp->minor_version_num == class_info->minor_version))
         {
            if (! Gf_replace)
               return; 
            else
            {
               /*  Delete the file corresponding to this version.  */

               char *filename;

               filename = (char *)calloc(14+strlen(Gp_dirname)+2,sizeof(char));
               strcpy(filename, Gp_dirname);
               strcat(filename, SEPARATOR_S);
               strcat(filename, class_info->name);
               strcat(filename, p_tmp->sequence_num);
               unlink(filename);
               free(filename);

               /*  Remove this version from the list.  */

               if (p_prev)
                  p_prev->next = p_tmp->next;
               else
                  p_cls_info = p_tmp->next;

               free(p_tmp);

               replaced = 1;
               break;

            }/* else replace this version anyway */
         }/* if this version is already in the dictionary */

         p_prev = p_tmp;

      }/* for all versions that exist in the dictionary */

      /*-------------------------------------------------------*/
      /*  Put a new link in the list to insert a new version.  */
      /*-------------------------------------------------------*/

      p_tmp = (struct class_info *) calloc(1,sizeof(struct class_info));

      if (! DDP_get_next_sequence_num(last_sequence_num, p_tmp->sequence_num))
         error(FATAL,"too many versions of %s\n",class_info->name);
         
      p_tmp->next = p_cls_info;
      p_cls_info = p_tmp;

   }/* if class is in the dictionary */
   else
   {
      /*  We are adding a new class that did not previously  */
      /*  exist in this dictionary.                          */

      struct class_info *p_tmp;

      p_tmp = (struct class_info *) calloc(1,sizeof(struct class_info));
      p_tmp->next = p_cls_info;
      p_cls_info = p_tmp;

      /*  Set the sequence number to zero. (base 64) */

      p_cls_info->sequence_num[0] = '.';        
      p_cls_info->sequence_num[1] = '\0';        
   }

   p_cls_info->major_version_num = class_info->major_version;
   p_cls_info->minor_version_num = class_info->minor_version;

   /* create a new file to store the class information for the version
      being inserted. */
 
   Gp_outfilename = (char *)malloc(strlen(Gp_dirname)+strlen(class_info->name)+4);
   strcpy(Gp_outfilename, Gp_dirname);
   strcat(Gp_outfilename,SEPARATOR_S);
   strcat(Gp_outfilename, class_info->name);
   strcat(Gp_outfilename, p_cls_info->sequence_num);
   
   if (NULL == (Gp_outfile = (FILE *)fopen(Gp_outfilename,"w")))
      error(FATAL,"could not create file '%s'\n",Gp_outfilename);
 

   /* add the parent-child relationship information */

   add_parents (class_info->parent_count, (identifier_ptr *)class_info->A_parents);

   /* add a record for any rejected instance data. */

   add_rejected_instance_data (class_info);

   /* Add all the C declarations to the dictionary.  This is a two
      pass process.  In pass 1, enter all variables that are of known
      types.  The unknown types are put in the dep_decl_list.  In pass 2,
      attempt to resolve any declarations of (previously) unknown types. */

   p_dep_decl_list = NULL;
   Gp_types = NULL;
   Gp_classdef = class_info;

   if (class_info->tag_tab)
   {
      Gp_types = (struct hash_table *) DDP_new_hash_table(100, 0, 0);
      process_local_symbols (class_info->tag_tab, add_tagnames);
   }

   /* add the dependent declarations into the dictionary.  These 
      are a linked list of fields which could not be added because
      they depended on an unknown type.  At this time some (or all)
      of these types may be known.  */

   if (p_dep_decl_list) 
      add_dep_decl ();

#ifdef  DEBUG
   error(INFO,"\tINSTANCE FIELDS\n");
#endif

   G_fld_offset = 0;
   idptr = class_info->instance_fields;

   while (idptr)
   {
      /* given the OPP format instance field, extract and reformat the 
         necessary information into DDP format */

      get_field_data (idptr, &attr_info);

#ifdef  DEBUG
      print_fld_info (&attr_info);
#endif

      /* check if channel code to do things differently */

      if (attr_info.Ctype_list[0] == CHANNEL_CODE)
      {
         fprintf(Gp_outfile,"CHANNEL\n%s %s %d %d\n",
                 attr_info.field_name,
                 attr_info.type_name,
                 attr_info.offset,
                 attr_info.size);
      }
      else
      {
         fprintf(Gp_outfile, "ATTRIBUTE\n");
         dump_field_info(&attr_info, 1);

         /* el-kludgo #N+1 -- skip the field with 'name'_descr wrt VLAs */
         if (idptr->flags & F_IDENTIFIER_DUMMY) idptr = idptr->link;
      }

      if (idptr) idptr = idptr->link;
   }

   /* save the instance size, so that you could replace the class_info */

   p_cls_info->instance_size = G_fld_offset >> 3;

#ifdef  DEBUG
   error(INFO,"\tMESSAGES\n", class_info->message_count);
#endif

   for (idptr = class_info->messages; idptr; idptr = idptr->link)
      add_message(idptr);

   if (Gp_types)
   {
      DDP_delete_hash_table(Gp_types);
      Gp_types = NULL;
   }

   fclose(Gp_outfile);
   free(Gp_outfilename);

   DDP_write_class_version_list(class_info->name, Gp_dirname, p_cls_info);

   if (replaced)
      error(INFO,"\t\treplaced ");
   else
      error(INFO,"\t\tadded ");

   error(INFO,"%s (%d:%d)\n",class_info->name,p_cls_info->major_version_num,
              p_cls_info->minor_version_num);

   DDP_free_version_list(&p_cls_info);

   return;
}



#ifdef DEBUG
void dump_defnames (defsym)
identifier_ptr defsym;
{
   char *dump_macro ();
   char *defstr;

   defstr = dump_macro (defsym);
   if (defstr)
   {
      error(INFO,"MACRO '%s' - %s\n", defsym->s.s.name, defstr);
      free(defstr);
   }
}


void dump_omdefnames (omdefsym)
identifier_ptr omdefsym;
{
   char *dump_omdef ();
   char *defstr;

   defstr = dump_omdef (omdefsym);
   if (defstr)
   {
      error(INFO,"OMDEF '%s' - %s\n", omdefsym->s.s.name, defstr);
      free(defstr);
   }
}
#endif


