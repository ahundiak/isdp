/*
Name
	TOmemory.c

Abstract
	allocation of memory
        Declaration of routines for memory allocation
	
Synopsis
	
        pointer = TOnew_memory(int size)

	surface = TOnew_surface()
	point = TOnew_point()
	top_point = TOnew_top_point()
	top_edge = TOnew_top_edge()
	

Description
 
	Input:

	Output:

Return Values

	pointer to newly malloc'ed memory or NULL, if
        no memory available.

Notes

     Currently always newly malloced memory is returned.
     There should be corresponding TOfree_xxx routines,
     which place the free'd elements into an empty list.

Index

Keywords

History
	B. Burkhardt	11/11/93	Creation date.
*/

#include <stdio.h>
#include "TOtopology.h"
#include "TOstruct1.h"
#include "TOproto_ta.h"
#include "TOnumbers.h"

struct list { struct list *next;};

/* empty lists */


#define TOnew(name) \
  struct name *TOnew_##name(struct topology *topo) \
  { \
     if(topo->fl.free_##name != NULL) \
     { \
	struct name *res = topo->fl.free_##name; \
	topo->fl.free_##name = \
	    (struct name *) ((struct list *) topo->fl.free_##name)->next; \
        return res; \
     } \
     return (struct name *) TOnew_memory(topo, sizeof(struct name)); \
  }

#define TOfree(name) \
  void TOfree_##name(struct topology *topo, struct name *p) \
  { \
    ((struct list *) p)->next = (struct list *) topo->fl.free_##name;\
    topo->fl.free_##name = p;\
  }

#define TOall_proc(name)  TOnew(name) TOfree(name)

TOall_proc(surface)
TOall_proc(edge)
TOall_proc(point)
TOall_proc(top_point)
TOall_proc(top_edge)

TOall_proc(elist)
TOall_proc(plist)
TOall_proc(telist)


#define TOfree_list(name)  void TOfree_list_##name(struct topology *topo, \
	struct name *head, struct name *tail) \
  { \
    struct name *l; \
    while( head != tail) \
    { \
	l = head; \
        head=head->next; \
        TOfree_##name(topo,l); \
    } \
    TOfree_##name(topo,tail); \
  }

TOfree_list(elist)
TOfree_list(plist)
TOfree_list(telist)
TOfree_list(point)

char *TOnew_memory(struct topology *topo,int size)
{
   char *result;
   int sts;
   struct memory *memo = NULL;
   memo = topo->mo.motail->next;
   
   /* adjust to double word boundaries */
   if(size % 8 != 0) size += 8 - size % 8;

/* preliminary, as long as memory is pulled out without this routine:*/
   /* adjust pointer to double word boundaries */
   if(((int) memo->current) %8 != 0)
	memo->current += 8 - ((int)memo->current) %8;

   if((BASIC_SIZE - (memo->current - memo->p)) <= size)
   {
      sts  = TOadd_mo(topo);
      if(sts)
      {
         return(NULL);
      }   
      memo = topo->mo.motail->next;

      if(BASIC_SIZE <= size)
      {
#ifdef DBG
        printf("Trying allocation of too much memory: %d (max=%d)\n",
			size, BASIC_SIZE);
#endif
	return NULL;
      }
   }

   result = memo->current;
   memo->current += size;
   return result;
}
