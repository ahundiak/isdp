/*----------------------------------------------------------------------------
   sizeof.c

   rme 04/25/1988

   Function(s) to evaluate a sizeof expression.
-----------------------------------------------------------------------------*/
#include <stdio.h>
#include "oppmalloc.h"
#include "carriers.h"
#include "identifier.h"
#include "../opp/y.tab.h"
#include "typeinfo.h"
#include "lexinput.h"
#include "char_st.h"
#include "fio.h"
#include "oppface.h"

static void zero_size_error()
{
   printerr(1);
   fprintf(stderr,"  Sizeof evaluates to zero.\n");
   file_traceback();
   exit_opp();
}


static int ceiling (a, b)
int a, b;
{
   if (! b)
      zero_size_error();

   return (b* (int)((a+b-1)/b));
}


#define size_in_bits(x) sizeof(x)<<3
#define size_in_bytes(x) (!(x)?0:((x)>>3?(x)>>3:1))


static int get_type_bit_size (ti, start_pos, p_align)
/*--------------------------------------------------------------------------
   Returns the size of the declared item. Given the starting bit position, 
   also determine the padding that is necessary before and after the item. 
----------------------------------------------------------------------------*/
struct Type_Info ti;
int              *start_pos;
int              *p_align;
{
   int            tsize,	/*  Returned size of type.  */
                  csize,	/*  Size of member of struct or union.  */
                  pos,		/*  Alignment of type ?  */
                  pad_pos;	/*  Padding after a struct or union member.  */
   int            align_size,	/*  Alignment in memory. */
                  fld_align_size,	/*  Alignment of struct of union 
					    member.  */
                  its,		/*  For bitfield alignment.  */
                  end_pos;	/*  Offset of start of next member.  */
   dcltr_ptr      dl,		/*  Ptr to member of a declarator list.  */
                  p_dcltr, 
                  p_dcltr_list;
   identifier_ptr sc;		/*  Used to examine members of struct and 
				    union.  */

   tsize = 0;
   pos = *start_pos;
   align_size = 0;

   /* re-order the declarator list */

   p_dcltr_list = NULL;
   dl = ti.dcltr_link; 
   while (dl)
   {
      p_dcltr = (dcltr_ptr) malloc (sizeof (struct dcltr));
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
	    pos = ceiling (pos, align_size = size_in_bits (long int));
	    tsize = size_in_bits (long int);
	    break;

	case STRUCT_NAME :
	    pad_pos = 0;
	    fld_align_size = 0;
	    for (sc = ti.type_link->field_link; sc; sc = sc->link)
	    {
		csize = get_type_bit_size (sc->type_info, &pad_pos, &fld_align_size);
		if (fld_align_size > align_size) align_size = fld_align_size;
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
		csize = get_type_bit_size (sc->type_info, &pad_pos, &fld_align_size);
		if (csize > tsize) tsize = csize;
		if (fld_align_size > align_size) align_size = fld_align_size;
	    }
	    pos = pad_pos;
	    tsize = ceiling (tsize, align_size);
	    break;

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
		pos = ceiling (pos, align_size = size_in_bits(char));
		tsize = size_in_bits (char);
		break;
	    case float_type : 
		pos = ceiling (pos, align_size = size_in_bits(float));
		tsize = size_in_bits (float);
		break;
	    default :
	    case int_type :
		pos = ceiling (pos, align_size = size_in_bits(int));
		tsize = size_in_bits (int);
		break;
	    }
	    break;
	case short_size :
	    switch (ti.std_type)
	    {
	    case char_type : 
		pos = ceiling (pos, align_size = size_in_bits(char));
		tsize = size_in_bits (char);
		break;
	    case float_type : 
		pos = ceiling (pos, align_size = size_in_bits(float));
		tsize = size_in_bits (float);
		break;
	    default :
	    case int_type :
		pos = ceiling (pos, align_size = size_in_bits(short int));
		tsize = size_in_bits (short int);
		break;
	    }
	    break;
	case long_size :
	    switch (ti.std_type)
	    {
	    case char_type : 
		pos = ceiling (pos, align_size = size_in_bits(char));
		tsize = size_in_bits (char);
		break;
	    case float_type : 
		pos = ceiling (pos, align_size = size_in_bits(double));
		tsize = size_in_bits (double);
		break;
	    default :
	    case int_type :
		pos = ceiling (pos, align_size = size_in_bits(long int));
		tsize = size_in_bits (long int);
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
	    pos = ceiling (*start_pos, align_size = size_in_bits (p_dcltr_list));
	    tsize = size_in_bits (p_dcltr_list);
	    break;
	case dt_array : 
	    tsize *= p_dcltr_list->size;
	    break;
	case dt_function : 
	    pos = ceiling (*start_pos, align_size = size_in_bits (p_dcltr_list));
	    tsize = size_in_bits (p_dcltr_list);
	    break;
	case dt_bitfield : 
	    its = align_size = tsize;	/* integral type size for bitfield */
	    tsize = p_dcltr_list->size;
	    if (tsize)
	    {
	        /* do not attempt to pad by integral type - so reset position */
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

int do_the_sizeof(ti)
struct Type_Info ti;
{
   int offset1, offset2;
   int size = 0;

   offset1 = offset2 = 0;

   if (ti.typedefName)
   {
      carrier_ptr c;

      for (c = ti.typedefName; c; c = c->next)
       ti = merge_type_info (ti, c->cargo->type_info, 0);
   }

   size = get_type_bit_size(ti, &offset1, &offset2);
   size = size_in_bytes(size);

   if (! size)
      zero_size_error();

   return (size);
}
