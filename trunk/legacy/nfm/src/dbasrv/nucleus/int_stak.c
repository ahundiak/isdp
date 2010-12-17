/* $Revision: 1.1 $ */
#include "dba.ext"
#include "script.def"

/*
    Function:	dba_int_push
    Author:	Tim A. Thompson

    Revisions:
	3-7-93   -- Moved from /script to /nucleus.
*/

void dba_int_push (jumpstack, jump)
jumpstacktype *jumpstack;
long jump;
{
  jumpnodetype *newtop;
     
  newtop = (jumpnodetype *) dba_struct_allocate (sizeof(jumpnodetype),
      __FILE__, __LINE__);
  newtop->jump = jump;
  newtop->next = jumpstack->top;
  jumpstack->top = newtop;
  jumpstack->size++;
}


/*
    Function:	dba_int_pop
    Author:	Tim A. Thompson

    Revisions:
	3-7-93   -- Moved from /script to /nucleus.
*/

long dba_int_pop (jumpstack)
jumpstacktype *jumpstack;
{
  jumpnodetype *oldtop;
  long result;

  if (jumpstack->size) {
    oldtop = jumpstack->top;
    result = (jumpstack->top)->jump;
    jumpstack->top = (jumpstack->top)->next;
    dba_struct_deallocate (oldtop, sizeof (jumpnodetype));
    jumpstack->size--;
    return result;
  }
/*
  dba_dprintf ("%s\n", dba_get_msg (DBA_F_SCR_EMPTY_JUMP_STACK,NP,0,NP,NP));
*/
  return (0);
}


/*
    Function:	dba_gen_push
    Author:	Tim A. Thompson
*/

void dba_gen_push (genstack, ptr)
genstacktype *genstack;
void *ptr;
{
  gennodetype *newtop;

  newtop = (gennodetype *) dba_struct_allocate (sizeof(gennodetype),
      __FILE__, __LINE__);
  newtop->ptr = ptr;
  newtop->next = genstack->top;
  genstack->top = newtop;
  genstack->size++;
}
     

/*
    Function:	dba_gen_pop
    Author:	Tim A. Thompson
*/

void *dba_gen_pop (genstack)
genstacktype *genstack;
{
  gennodetype *oldtop;
  void *result;

  if (genstack->size) {
    oldtop = genstack->top;
    result = genstack->top->ptr;
    genstack->top = genstack->top->next;
    dba_struct_deallocate (oldtop, sizeof (gennodetype));
    genstack->size--;
    return result;
  }
/*
  dba_dprintf ("%s\n", dba_get_msg (DBA_F_SCR_EMPTY_GEN_STACK, NP,0,NP,NP));
*/
  return (0);
}


/*
    Function:	dba_gen_peek
    Author:	Tim A. Thompson
    Date:	11-JAN-92
*/

void *dba_gen_peek (genstack, loc)
genstacktype *genstack;
void **loc;
{
  if (*loc)
    *loc = (void *) ((gennodetype *)*loc)->next;
  else
    *loc = (void *) genstack->top;
  return ((gennodetype *)*loc)->ptr;
}
