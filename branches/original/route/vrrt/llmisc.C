/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/llmisc.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: llmisc.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:25:20  pinnacle
 * Created: vrrt/llmisc.C by r250_int for route
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

/* Miscellaneous high-level linked list functions. */

/* ll_arrayf() allocates and returns an array of pointers to the
objects in the list, optionally making copies of the objects.
If nullterm is TRUE, the array is terminated with a NULL pointer.
Otherwise, the calling program must remember the number of objects
using the lengthof_ll macro. */

pointer* ll_arrayf( ll, nullterm, copyfunc )
LLIST ll;
int nullterm;
pointer (*copyfunc)();
{
 int size;
 pointer* array;
 pointer* a;
 LLNODE ln;
 pointer object;
 LL_(ll);

 size = lengthof_ll( ll );

 if (nullterm) size++;

 array = pointera_new(size);
 a = array;
 traverse ( ll, ln )
 {
  object = ln->ln_object;

  if (copyfunc) object = (*copyfunc)(object);

  *a++ = object;
 }
 if (nullterm) *a++ = NULL;
  return array;
}

pointer *ll_array( ll, nullterm )
LLIST ll;
int nullterm;
{
  return ll_arrayf( ll, nullterm, NULL ); 
}

/* ll_copy() allocates and returns an exact copy of a list.
The nodes and counts of the new list can then be modified without
affecting those of the old list.  If the calling program wants
new copies of the objects themselves as well, it can call ll_copyf(). */

#define COPY(attribute) self(attribute)of_ll(ll) = self(attribute)of_ll(ll);
LLIST ll_copyf(ll,copyfunc) LLIST ll; pfuncp copyfunc; {
	LLIST newll; LLNODE ln0, ln; LL_(ll);
	newll = ll_new(controlof_ll(ll),userof_ll(ll));
	traverse (ll,ln0) {
		ln = ln_connect(ln_copy(ln0),newll->ll_last);
		if (copyfunc) ln->ln_object = (*copyfunc)(ln->ln_object); }
	return newll; }
LLIST ll_copy(ll) LLIST ll; { return ll_copyf(ll,NULL); }

/* ll_merge() does a straight insertion of all the objects in a list
into some other list.  When any object has an associated count greater
than 1, ll_insert() is simply called that many times.  The idea is 
to give predictable results even if the control structures (cmpfunc,
order, collapse) differ between the two lists.

A more efficient (and more complicated) implementation would actually
compare the control structures to see if it could copy nodes whole
from one list to the other. */

LLIST ll_mergef(ll,toll,copyfunc) LLIST ll, toll; pfuncp copyfunc; {
	LLNODE ln; int count; pointer object; LL_(ll); LL_(toll);
	traverse (ll,ln) { count = ln->ln_count; object = ln->ln_object;
		while (count-- > 0) ll_insertf(object,toll,copyfunc); }
	return ll; }
LLIST ll_merge(ll,toll) LLIST ll, toll; { return ll_mergef(ll,toll,NULL); }

/* ll_max(), ll_sum() and ll_any() call a given function for each
of the objects in a list.  ifunc is assumed to return an integer >= 0.
ll_max() returns the maximum, or 0 if the list is empty.
ll_sum() returns the sum.
ll_any() returns TRUE if ifunc returns > 0 for any of the objects in the list.
ll_sum___() and ll_any___() pass additional arguments directly to ifunc. */

int ll_max(ll,ifunc) LLIST ll; funcp ifunc; {
	LLNODE ln; int m = 0, i; LL_(ll);
	traverse (ll,ln) {
		i = ifunc ? (*ifunc)(ln->ln_object) : ln->ln_count;
		MAX_(m,i); } return m; }

#define _ ,

#define DEFINE_SUMFUNC(name,comma,args,decl) \
int name(ll,ifunc comma args) LLIST ll; funcp ifunc; decl { \
	LLNODE ln; int sum = 0; LL_(ll); \
	traverse (ll,ln) sum += (*ifunc)(ln->ln_object comma args); \
	return sum; }

DEFINE_SUMFUNC( ll_sum   , ,, )
DEFINE_SUMFUNC( ll_sum___, _,PASSARGS,PASSDECL )

#define DEFINE_ANYFUNC(name,comma,args,decl) \
int name(ll,ifunc comma args) LLIST ll; funcp ifunc; decl { \
	LLNODE ln; LL_(ll); \
	traverse (ll,ln) \
		if ((*ifunc)(ln->ln_object comma args) > 0) return T; \
	return F; }

DEFINE_ANYFUNC( ll_any   , ,, )
DEFINE_ANYFUNC( ll_any___, _,PASSARGS,PASSDECL )

/* ll_select() calls a boolean selection function on each of the
objects in a list.  Each time the function returns TRUE, ll_select()
inserts the object in a given other list, and deletes the node if
exclude is TRUE.  ll_select___() passes additional arguments
directly to selfunc. */

#define DEFINE_SELECTFUNC(name,cfcomma,cfarg,cfdecl,comma,args,decl,stmt) \
void name(ll,toll,exclude,selfunc cfcomma cfarg  comma args) \
 LLIST ll, toll; int exclude; funcp selfunc; cfdecl decl { \
	LLNODE ln; pointer o; \
	traverse_objects (ll,ln,pointer,o) { \
		ifnot ((*selfunc)(o comma args)) continue; \
		stmt if (exclude) eat_ln(ln,prev); } }

#define CFARG copyfunc
#define CFDECL pointer (*copyfunc)();
#define STMT ll_insert(o,toll);
#define CFSTMT ll_insertf(o,toll,copyfunc);

DEFINE_SELECTFUNC( ll_select    , ,,,             ,,,                  STMT )
DEFINE_SELECTFUNC( ll_select___ , ,,,             _,PASSARGS,PASSDECL, STMT )
DEFINE_SELECTFUNC( ll_selectf   , _,CFARG,CFDECL, ,,,                  CFSTMT )
DEFINE_SELECTFUNC( ll_selectf___, _,CFARG,CFDECL, _,PASSARGS,PASSDECL, CFSTMT )

/* ll_insert_args uses the standard Unix varargs package to
let you insert several objects into a list in one function call.
ll_insert_intargs does the same for integer data. */

LLIST ll_insert_args(va_alist) va_dcl { va_list ap; LLIST ll; pointer object;
	va_start(ap); ll = va_arg(ap,LLIST);
	until (null(object = va_arg(ap,pointer))) ll_insert(object,ll);
	va_end(ap); return ll; }

LLIST ll_insert_intargs(va_alist) va_dcl { va_list ap; LLIST ll; int i;
	va_start(ap); ll = va_arg(ap,LLIST);
	until (error(i = va_arg(ap,int))) ll_insert((pointer)i,ll);
	va_end(ap); return ll; }

/* ll_index_ln() and ll_index_object() return the i'th node or object in the
list, or NULL if the list isn't that long.  Note that ll_index_object() is
ambiguous for integer data, unless you know that none of your integers will
be 0, or unless you like 0 as a default. */

LLNODE ll_index_ln(ll,i) LLIST ll; int i; {
	LLNODE ln; int len = lengthof_ll(ll);
	if (i<len/2)        traversing (ll,ln,next,1,i>0,i--) ;
	else { i = len-i-1; traversing (ll,ln,prev,1,i>0,i--) ; } return ln; }
pointer ll_index_object(ll,i) LLIST ll; int i; {
	LLNODE ln = ll_index_ln(ll,i); return ln ? ln->ln_object : NULL; }

/* ln_index() and ll_object_index() return the numerical position of
a given node or object in a list;  ll_object_index() may also return ERROR
if the object is not found. */

int ln_index(ln) LLNODE ln; {
	int i = 0; while (ln = prev_ln(ln)) ++i; return i; }
int ll_object_index(object,ll) pointer object; LLIST ll; {
	LLNODE ln = ll_find_ln(object,ll); return ln ? ln_index(ln) : ERROR; }

/*
ll_compare() is for elaborate programs that actually store linked lists
in linked lists.  You can think of this function as a linked list version
of strcmp().  It scans both lists together until the corresponding objects
are different, or until one or both of the lists runs out.  ll_compare()
assumes both lists have the same control structure, just as strcmp() assumes
both strings are in ASCII.

If the lists have no comparison function, ll_compare() just returns the
difference in length between them.
*/

int ll_compare(ll1,ll2) LLIST ll1, ll2; {
	LLNODE ln1, ln2; pointer o1, o2; int cmp;
	funcp cmpfunc = cmpfuncof_ll(ll1);
	ifnull (cmpfunc) return lengthof_ll(ll2) - lengthof_ll(ll1);
	ln1 = ll1, ln2 = ll2; do {
		ln1 = next_ln(ln1), ln2 = next_ln(ln2);
		switch2 (not null(ln1),not null(ln2)) {
		case2 (F,F): cmp = 0; break;
		case2 (T,F): cmp = CMP_GREATER; break;
		case2 (F,T): cmp = CMP_LESS; break;
		case2 (T,T):
			o1 = ln1->ln_object, o2 = ln2->ln_object;
			cmp = (*cmpfunc)(o1,o2); break; }
	} until (cmp != 0 || null(ln1) || null(ln2)); return cmp; }

/* This function extracts words from a string into a linked list
using the desired set of separator characters. */

LLIST ll_strtok(str,ll,sep_chars,docopy)
 charp str; LLIST ll; charp sep_chars; int docopy; {
	int first; charp str0;
	if (docopy) str = str0 = strcopy(str);
	first = T; while (str = strtok(first?str:NULL,sep_chars)) {
		ll_insertf(str,ll,docopy?strcopy:NULL); first = F; }
	if (docopy) diag0_free(str0);
	return ll; }


LLIST ll_joinf(ll1,ll2,ll,add2,copyfunc)
 LLIST ll1, ll2, ll; int add2; funcp copyfunc; {
	funcp cmpfunc; LLNODE ln, ln1, ln2; pointer o1, o2; int cmp; int count;
	ifnot (controlof_ll(ll1)==controlof_ll(ll2)) return NULL;
	ifnull (cmpfunc = cmpfuncof_ll(ll1)) return NULL;
	ifnot (orderof_ll(ll1)) return NULL;
	ln1 = ll1; ln2 = ll2;
	ln1 = next_ln(ln1); ln2 = next_ln(ln2);
	while (ln1 && ln2) {
		o1 = ln1->ln_object, o2 = ln2->ln_object;
		cmp = (*cmpfunc)(o1,o2);
		if (cmp==0) count = countof_ln(ln1),
		            add2 && (count += countof_ln(ln2)),
		            ln = ll_appendf_count(count,o1,ll,copyfunc);
		if (cmp<=0) ln1 = next_ln(ln1);
		if (cmp>=0) ln2 = next_ln(ln2); }
	return ll; }

LLIST ll_join(ll1,ll2,ll,add2) LLIST ll1, ll2, ll; int add2; {
	return ll_joinf(ll1,ll2,ll,add2,NULL); }
