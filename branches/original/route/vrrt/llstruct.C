/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/llstruct.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: llstruct.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:25:26  pinnacle
 * Created: vrrt/llstruct.C by r250_int for route
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

/* Housekeeping for linked list structures. */

LLNODE ln_new(object) pointer object; { newstructvar(LLNODE,ln)
	llof_ln(ln) = NULL; ln->ln_next = NULL; ln->ln_prev = NULL;
	countof_ln(ln) = 0; ln->ln_object = object; return ln; }
pointer ln_free(ln) LLNODE ln; {
	pointer object = ln->ln_object; diag0_free(ln); return object; }
STRUCT_DEFINE_COPYFUNC(LLNODE,ln) { return structcopy(ln,LLNODE,ln); }

LLCONTROL lc_new(name,cmpfunc,order,collapse)
 charp name; funcp cmpfunc; int order; int collapse; {
	newstructvar(LLCONTROL,lc)
	lc->lc_name = name; lc->lc_cmpfunc = cmpfunc;
	lc->lc_order = order; lc->lc_collapse = collapse; return lc; }
charp lc_free(lc) LLCONTROL lc; {
	charp name = lc->lc_name; diag0_free(lc); return name; }

static LLINFO li_init(li) LLINFO li; { li->li_count = 0; return li; }
static LLINFO li_new(lc,user) LLCONTROL lc; pointer user; {
	newstructvar(LLINFO,li)
	li->li_lc = lc; li->li_user = user; return li_init(li); }
static LLCONTROL li_free(li) LLINFO li; {
	LLCONTROL lc = li->li_lc; diag0_free(li); return lc; }

static LLIST ll_init( ll )
LLIST ll;
{
  llof_ln(ll) = ll;
  ll->ll_first = ll->ll_last = ( LLNODE )ll;
  lengthof_ll( ll ) = 0;
  li_init( infoof_ll(ll) );
  return ll;
}

LLIST ll_new( lc, user )
LLCONTROL lc;
pointer user;
{
  newstructvar(LLIST,ll)
  infoof_ll(ll) = li_new(lc,user);
  return ll_init(ll);
}

/* Functions for clearing all the nodes from a list or
freeing the entire list structure. */

#define _,

#define DEFINE_CLEARFUNC(name,comma,args,decl) \
LLIST name(ll,freefunc comma args) LLIST ll; funcp freefunc; decl { \
	LLNODE ln, nln; LL_(ll); \
	ln = ll; nln = next_ln(ln); while (ln = nln) { \
		if (freefunc) (*freefunc)(ln->ln_object comma args); \
		nln = next_ln(ln); ln_free(ln); } \
	return ll_init(ll); }

DEFINE_CLEARFUNC( ll_clearf   , ,, )
DEFINE_CLEARFUNC( ll_clearf___, _,PASSARGS,PASSDECL )

#define DEFINE_FREEFUNC(name,clearfunc,comma,args,decl) \
LLCONTROL name(ll,freefunc comma args) LLIST ll; funcp freefunc; decl { \
	LLINFO li; LL_(ll); li = infoof_ll(ll); \
	clearfunc(ll,freefunc comma args); \
	diag0_free(ll); return li_free(li); }

DEFINE_FREEFUNC( ll_freef   , ll_clearf   , ,, )
DEFINE_FREEFUNC( ll_freef___, ll_clearf___, _,PASSARGS,PASSDECL )

LLIST ll_clear(ll) LLIST ll; { return ll_clearf(ll,NULL); }
LLCONTROL ll_free(ll) LLIST ll; { return ll_freef(ll,NULL); }

/* Default control structure with no comparison, ordering or collapsing. */

struct lc_struct LLcontrol_struct = {
	"LLcontrol", NULL, F, F, };

/* Control structures for storing integer data.  See cmp.c. */

struct lc_struct LLcontrol_ints_struct = {
	"ints", pointercmp_int, T, T, };
struct lc_struct LLcontrol_longs_struct = {
	"longs", pointercmp_long, T, T, };

/* Control structures for storing strings. */

#define STRUCT(order,collapse) \
	{ "strs(order,collapse)", strcmp, order, collapse, }
struct lc_struct LLcontrol_strs_structa[] = {
	STRUCT(F,F), STRUCT(T,F), STRUCT(F,T), STRUCT(T,T), };
