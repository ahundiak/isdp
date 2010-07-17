/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/llinsert.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: llinsert.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:25:16  pinnacle
 * Created: vrrt/llinsert.C by r250_int for route
 *
 *
 *
 * History:
 *	01/15/98	Onay	Integration date.
 *
 *************************************************************************/

/* See separate documentation about using the linked list package. */

#include <common.h>
#include <ll.h>

/* The functions in this module deal with intelligent insertion and
deletion of objects in a list.  These are the only functions that need
the lc_cmpfunc, lc_order and lc_collapse elements of the LLCONTROL
structure associated with each list.  These are also the only functions
that increment/decrement the count associated with a given node.
(And if lc_collapse is FALSE, none of the counts ever goes above 1.) */

/* LOAD_LL converts a possible LLNODE argument into its LLIST,
then retrieves and disambiguates the control information for the list.
(If there's no comparison function, don't try to order the list or
collapse identical objects.) */

#define EL(element) element = self(element)of_ll(ll);
#define LOAD_LL \
	funcp cmpfunc; int order; int collapse; \
	LL_(ll); EL(cmpfunc) EL(order) EL(collapse) \
	ifnull (cmpfunc) order = collapse = F;

/* Shorthand macros for comparing/collapsing a given object with
the object at the current node in a list. */

#define COMPARISON ((*cmpfunc)(object,ln->ln_object))
#define COLLAPSE_CONDITIONS (collapse && cmpof_ll(ll)==0)

/*
ll_position() is the central function of the linked list
package.  Using the control information for a list, it returns
the appropriate node in the list where an object was/will be
inserted.  There are three cases:

1. No comparison function.  Return the last node in the list,
so that an insertion simply appends to the end of the list.

2. Comparison function, but no ordering.  Search the entire list for a
node with an object equal to the argument object; otherwise, just return the
last node in the list.  This sorts the input objects in order of appearance.

3. Comparison function with ordering.  Search from the beginning of the list,
as in case 2, but stop when our argument object compares as less than the
object at the current node in the list.

If more than one equal object is already in the list, cases 2 and 3
always return the node containing the LAST equal object.

ll_position() also has the important side effect of setting
cmpof_ll(ll):  later, if the calling function wants to decide
whether to collapse, it doesn't have to redo the most recent
comparison.
*/

LLNODE ll_position( object, ln0 )
pointer object;
LLNODE ln0;
{
  LLIST ll = ln0;
  LLNODE ln, prevln;
  int cmp, prevcmp;
  int appeared;

  LOAD_LL
  ifnull( cmpfunc )
  {
    cmpof_ll(ll) = CMP_GREATER;
    return ll->ll_last;
  }

  prevln = ln0,
  prevcmp = CMP_GREATER;
  appeared = F;

  traverse( ln0, ln )
  {
    cmp = COMPARISON;

    if( order && cmp <  0 ) break;

    if( appeared && cmp != 0 ) break;

    if( cmp==0 ) appeared = T;

    prevln = ln,
    prevcmp = cmp;
 }

 cmpof_ll(ll) = prevcmp;

 return prevln;
}

/* Both ll_insert() and ll_append() do the actual insertion of an
object in the same way.  If we're not collapsing, we allocate and
insert a new node for the object, making a new copy of the object
if the calling function provided a copy function.  Then we update
the count information for the object and for the entire list. */

#define INSERT \
	ifnot (COLLAPSE_CONDITIONS) { \
		if (copyfunc) object = (*copyfunc)(object); \
		ln = ln_insert(object,ln); } \
	countof_ln(ln) += count; countof_ll(ll) += count;

/* ll_insert() uses ll_position() to scan a list for the appropriate
place to insert an object.  ll_append() forces insertion at the end of
the list, but still compares and collapses, enabling applications that
work like the Unix uniq utility. */

LLNODE ll_insertf_count( count, object, ll, copyfunc )
int count;
pointer object;
LLIST ll;
pfuncp copyfunc;
{
  LLNODE ln;

   LOAD_LL
   ln = ll_position( object, ll );
   INSERT
   return ln;
}

LLNODE ll_appendf_count(count,object,ll,copyfunc)
 int count; pointer object; LLIST ll; pfuncp copyfunc; { LLNODE ln; LOAD_LL
	ln = ll->ll_last;
	cmpof_ll(ll) = cmpfunc && ln != ll ? COMPARISON : CMP_GREATER;
	INSERT  return ln; }

LLNODE ll_insertf(object,ll,copyfunc)
 pointer object; LLIST ll; pfuncp copyfunc; {
	return ll_insertf_count(1,object,ll,copyfunc); }
LLNODE ll_appendf(object,ll,copyfunc)
 pointer object; LLIST ll; pfuncp copyfunc; {
	return ll_appendf_count(1,object,ll,copyfunc); }
LLNODE ll_insert_count(count,object,ll) int count; pointer object; LLIST ll; {
	return ll_insertf_count(count,object,ll,NULL); }
LLNODE ll_append_count(count,object,ll) int count; pointer object; LLIST ll; {
	return ll_appendf_count(count,object,ll,NULL); }

LLNODE ll_insert( object, ll )
pointer object;
LLIST ll;
{
  return ll_insertf_count( 1, object, ll, NULL );
}

LLNODE ll_append(object,ll) pointer object; LLIST ll; {
	return ll_appendf_count(1,object,ll,NULL); }

/* After inserting an object in a list, the calling program
can find out whether collapse took place. */

int ll_collapsed(ll) LLIST ll; { LOAD_LL return COLLAPSE_CONDITIONS; }

/* To find an object, simply determine its proper position in the list,
then see if the object is actually at that position.  If it's there,
ll_find_ln() returns the node and ll_find_object() returns the object
itself.  Otherwise both functions return NULL. */

LLNODE ll_find_ln( object, ll )
pointer object;
LLIST ll;
{
  LLNODE ln;

  LL_(ll);
  ln = ll_position( object, ll );

  return cmpof_ll(ll)==0 ? ln : NULL;
}

pointer ll_find_object( object, ll )
pointer object;
LLIST ll;
{
  LLNODE ln;

  LL_( ll );
  ln = ll_find_ln( object, ll );

  return ln ? ln->ln_object : NULL;
}

/*
ll_delete() unconditionally deletes a node from a list, returning
the object at the node.

ll_delete_count() and ll_delete_one() decrement the count at the node.
If the count has reached zero, the node is deleted, and its object is returned.
If the count has not reached zero, the node remains, and NULL is returned.

ll_exclude(), ll_exclude_count(), and  ll_exclude_one() operate on an
object instead of a node.  They search the list for the object, returning
NULL or deleting a node depending on whether the object was found. */

pointer ll_delete(ln) LLNODE ln; { return ln_delete(ln); }

pointer ll_delete_count(count,ln) int count; LLNODE ln; {
	LLIST ll = llof_ln(ln);
	MIN_(count,countof_ln(ln));
	countof_ln(ln) -= count; countof_ll(ll) -= count;
	return countof_ln(ln)==0 ? ll_delete(ln) : NULL; }

pointer ll_delete_one(ln) LLNODE ln; { return ll_delete_count(1,ln); }

pointer ll_exclude(object,ll) pointer object; LLIST ll; {
	LLNODE ln; LL_(ll);
	return (ln = ll_find_ln(object,ll)) ? ll_delete(ln) : NULL; }

pointer ll_exclude_count(count,object,ll)
 int count; pointer object; LLIST ll; {
	LLNODE ln; LL_(ll);
	return (ln = ll_find_ln(object,ll))
	       ? ll_delete_count(count,ln) : NULL; }

pointer ll_exclude_one(object,ll) pointer object; LLIST ll; {
	return ll_exclude_count(1,object,ll); }
