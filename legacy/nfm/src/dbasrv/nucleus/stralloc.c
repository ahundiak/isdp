/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"
#include "screrr.def"
#include "script.def"

static smm_generic_list *dba_struct_list_head;

void dba_smm_dump_struct_lists();

/*
    Function:	dba_struct_allocate
    Author:	Tim A. Thompson
    Date:	21-FEB-92

    Revisions:
	11-10-02  -- Added "file" and "line" arguments for leak detection.
*/

void *dba_struct_allocate (size, file, line)
unsigned long size;
char *file;
int line;
{
  smm_generic_list *clist;
  void *retval=0;

  for (clist=dba_struct_list_head;clist;clist=clist->next)
    if (clist->size == size)
      break;
  if (clist && clist->addr) {
    retval = clist->addr;
    clist->addr = *(void **)retval;
    if (clist != dba_struct_list_head) {
      clist->prev->next = clist->next;
      if (clist->next)
        clist->next->prev = clist->prev;
      clist->next = dba_struct_list_head;
      dba_struct_list_head->prev = clist;
      dba_struct_list_head = clist;
    }
  }
  else
    retval = (void *) dba_dmalloc (size, DM_STRUCT_ALLOC);
#if defined (MALLOC_TRACE)
  dba_struct_allocate_mark (retval, file, line);
#endif
  if (retval)
    memset (retval, 0, size);
  return (retval);
}


/*
    Function:	dba_struct_deallocate
    Author:	Tim A. Thompson
    Date:	21-FEB-92
*/

void dba_struct_deallocate (ptr, size)
void *ptr;
unsigned long size;
{
  smm_generic_list *clist;

#if defined(MALLOC_TRACE)
  dba_struct_allocate_unmark (ptr);
#endif
  for (clist=dba_struct_list_head;clist;clist=clist->next)
    if (clist->size == size)
      break;
  if (!clist) {
    clist = (smm_generic_list *) dba_dcalloc (sizeof (smm_generic_list), 1,
        DM_SMM_GENERIC_LIST);
    clist->size = size;
    clist->next = dba_struct_list_head;
    if (dba_struct_list_head)
      dba_struct_list_head->prev = clist;
    dba_struct_list_head = clist;
  }
  if (clist) {
    *(void **) ptr = clist->addr;
    clist->addr = ptr;
    if (clist != dba_struct_list_head) {
      clist->prev->next = clist->next;
      if (clist->next)
        clist->next->prev = clist->prev;
      clist->next = dba_struct_list_head;
      dba_struct_list_head->prev = clist;
      dba_struct_list_head = clist;
    }
  }
  else
    dba_dfree (ptr);
}


/*
    Function:	dba_struct_realloc
    Author:	Tim A. Thompson
    Date:	20-MAR-92
*/

void *dba_struct_realloc (oldptr, newsize, oldsize)
void *oldptr;
unsigned long newsize, oldsize;
{
  void *newptr;

  newptr = dba_struct_allocate (newsize, __FILE__, __LINE__);
  if (!newptr)
    return 0;

  memcpy (newptr, oldptr, oldsize);
  dba_struct_deallocate (oldptr, oldsize);
  return (newptr);
}


/*
    Function:	dba_exit_struct
    Author:	Tim A. Thompson
    Date:	4-19-94
*/

void dba_exit_struct()
{
  smm_generic_list *clist, *nlist;
  void *ptr1, *ptr2;

  for (clist=dba_struct_list_head;clist;clist=nlist) {
    nlist = clist->next;
    for (ptr1=clist->addr; ptr1; ptr1=ptr2) {
      ptr2 = *(void **)ptr1;
      dba_dfree (ptr1);
    }
    dba_dfree (clist);
  }
}


/*
    Function:	dba_smm_search_struct_list
    Author:	Tim A. Thompson
    Date:	24-AUG-92
*/

long dba_smm_search_struct_list (ptr)
void *ptr;
{
  smm_generic_list *clist;
  void *vptr;

  for (clist=dba_struct_list_head;clist;clist=clist->next)
    for (vptr=clist->addr;vptr;vptr= *(void **)vptr)
      if (&vptr == ptr)
        return 1;
  return 0;
}


/*
    Function:	dba_smm_dump_struct_lists
    Author:	Tim A. Thompson
    Date:	22-AUG-92
*/

void dba_smm_dump_struct_lists (flag)
long flag;
{
  smm_generic_list *clist;
  void *vptr;

  for (clist=dba_struct_list_head;clist;clist=clist->next) {
    if (flag)
      dba_printf ("Freelist:  size = %lx (%ld)\n", clist->size,
          clist->size);
    for (vptr=clist->addr;vptr;vptr= *(void **)vptr)
      if (flag)
        dba_printf ("    %lx (%ld)\n", vptr, vptr);
  }
}

