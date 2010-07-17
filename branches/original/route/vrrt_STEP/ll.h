/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/ll.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ll.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:08  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/11/06  19:49:20  pinnacle
 * Alwin
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:25:14  pinnacle
 * Created: vrrt/ll.h by r250_int for route
 *
 *
 *
 * History:
 *	01/15/98	Onay	Integration date.
 *
 *************************************************************************/

#ifndef _LL_
#define _LL_

/* See separate documentation about using the linked list package. */

/* Basic linked list node structure.  Several functions in this package
return an LLNODE or take an LLNODE as an argument, but typical applications
won't need to allocate or modify an LLNODE. */

typedef struct ln_struct
{
  struct ln_struct* ln_ll;
  struct ln_struct* ln_next;
  struct ln_struct* ln_prev;
  int ln_count;
  pointer ln_object;
} *LLNODE;

#define ln_nexti 0
#define ln_previ 1
#define ln_otheri(index) (!(index))
#define ln_norp(ln,index) ((&((ln)->ln_next))[index])
extern LLNODE ln_new();
extern pointer ln_free();
extern LLNODE ln_copy();

/* An LLCONTROL structure is associated with each linked list.
lc_cmpfunc, lc_order and lc_collapse control the behavior of the functions
that insert and delete objects.  lc_name is not examined or modified
by any of the linked list modules; use it as you see fit. */

typedef struct lc_struct { charp lc_name;
	funcp lc_cmpfunc; unsigned lc_order:1, lc_collapse:1; }* LLCONTROL;
extern LLCONTROL lc_new();
extern charp lc_free();

/* An LLINFO structure is created automatically for each new list to store
time-dependent information about the list.  Macros are defined below for
looking at its elements, but typical applications won't have to allocate
or modify an LLINFO, except for the li_user element. */

typedef struct li_struct {
	LLCONTROL li_lc; pointer li_user;
	int li_cmp; int li_count; }* LLINFO;

/* The LLIST structure builds directly on the LLNODE structure,
without even defining a new type to the C compiler.  However, the
source code for these linked list modules always differentiates
between LLIST and LLNODE, and so should application code; see
documentation for functions that return an LLIST or take an LLIST
as an argument. */

#define ll_struct 	ln_struct
#define ll_first 	ln_next
#define ll_last 	ln_prev
#define ll_length 	ln_count
#define ll_info 	ln_object
#define LLIST LLNODE
extern LLIST ll_new();
extern LLIST ll_clearf();
extern LLIST ll_clearf___();
extern LLCONTROL ll_freef();
extern LLCONTROL ll_freef___();
extern LLIST ll_clear();
extern LLCONTROL ll_free();
extern void ll_write();
extern void ll_read();
extern void ll_aread();

/* Macros for accessing information associated with each LLNODE. */

#define countof_ln(ln) 		((ln)->ln_count)
#define llof_ln(ln) 		((LLIST)((ln)->ln_ll))
#define is_ll(ln) 		( llof_ln(ln) == (ln) )
#define follow_ln(ln,norp) 	( is_ll( (ln)->self(ln_)norp ) \
				  ? NULL : (ln)->self(ln_)norp )
#define next_ln(ln) 		follow_ln(ln,next)
#define prev_ln(ln) 		follow_ln(ln,prev)

/* Macros for accessing information associated with each LLIST. */

#define   lengthof_ll(ll) (            (ll)->ll_length  )
#define      anyof_ll(ll) ( lengthof_ll(ll) > 0         )
#define     infoof_ll(ll) (   (LLINFO)((ll)->ll_info)   )
#define     userof_ll(ll) (   infoof_ll(ll)->li_user    )
#define      cmpof_ll(ll) (   infoof_ll(ll)->li_cmp     )
#define    countof_ll(ll) (   infoof_ll(ll)->li_count   )
#define  controlof_ll(ll) (   infoof_ll(ll)->li_lc      )
#define     nameof_ll(ll) (controlof_ll(ll)->lc_name    )
#define  cmpfuncof_ll(ll) (controlof_ll(ll)->lc_cmpfunc )
#define    orderof_ll(ll) (controlof_ll(ll)->lc_order   )
#define collapseof_ll(ll) (controlof_ll(ll)->lc_collapse)

/* Convert a possible LLNODE variable into its associated LLIST. */

#define LL_(ln) ((ln) = llof_ln(ln))

/* Macros for inline linked list traversal. */

#define traversing( ln0,ln,norp,expr1,expr2,expr3 ) \
	for ( (ln) = (LLNODE)(ln0), expr1; \
	     ((ln) = follow_ln(ln,norp)) && (expr2); expr3 )

#define traversing1( ln0,ln,norp,expr1,expr2 ) \
	for ( (ln) = (LLNODE)(ln0), expr1; \
	     ((ln) = follow_ln(ln,norp)) && (expr2);  )

/* Made the last argument for the below function as "1" meaning TRUE. Alwin */
#define traverse(ln0,ln) traversing (ln0,ln,next,1,1,)
#define traverse1(ln0,ln) traversing1 (ln0,ln,next,1,1)

#define traversing_objects(ln0,ln,norp,type,var,expr1,expr2,expr3) \
	traversing (ln0,ln,norp,expr1, \
	            expr2 && ((var)=(type)((ln)->ln_object),1),expr3)
#define traverse_objects(ln0,ln,type,var) \
	traversing_objects (ln0,ln,next,type,var,1,1,)

#define traverse_shorts(ln0,ln,var) 	traverse_objects (ln0,ln,short,var)
#define traverse_ints(ln0,ln,var) 	traverse_objects (ln0,ln,int,var)
#define traverse_longs(ln0,ln,var) 	traverse_objects (ln0,ln,long,var)
#define traverse_strs(ln0,ln,var) 	traverse_objects (ln0,ln,charp,var)
#define traverse_lls(ln0,ln,var) 	traverse_objects (ln0,ln,LLIST,var)

/* Delete the current node in a linked list and move to its neighbor. */

#define eatf_ln(ln,norp,freefunc) \
	( (ln) = (ln)->self(ln_)norp, \
	  freefunc(ln_delete(ln_norp(ln,ln_otheri(self3(ln_,norp,i))))) )
#define eat_ln(ln,norp) eatf_ln(ln,norp,)

/* This type enables you to work with pointers to the
functions defined in llinsert.c. */

typedef LLNODE (*LLNODEfuncp)();

/* Declarations for functions and variables defined by
the linked list package. */

/* llstruct.c */
extern struct lc_struct LLcontrol_struct;
#define LLcontrol (&LLcontrol_struct)
extern struct lc_struct LLcontrol_ints_struct;
#define LLcontrol_ints (&LLcontrol_ints_struct)
extern struct lc_struct LLcontrol_longs_struct;
#define LLcontrol_longs (&LLcontrol_longs_struct)
extern struct lc_struct LLcontrol_strs_structa[];
#define LLcontrol_strs(order,collapse) \
	(&LLcontrol_strs_structa[bits2(order,collapse)])

/* llconnect.c */
extern LLNODE ln_connect();
extern LLNODE ln_disconnect();
extern LLNODE ln_reconnect();
extern LLNODE ln_insert();
extern pointer ln_delete();
extern void ln_swap();

/* lltrav.c */
extern void ll_traverse_next();
extern void ll_traverse_prev();
extern void ll_traverse_next___();
extern void ll_traverse_prev___();
#define ll_traverse ll_traverse_next
#define ll_traverse___ ll_traverse_next___

/* llinsert.c */
extern LLNODE ll_position();
extern LLNODE ll_insertf_count();
extern LLNODE ll_appendf_count();
extern LLNODE ll_insertf();
extern LLNODE ll_appendf();
extern LLNODE ll_insert_count();
extern LLNODE ll_append_count();
extern LLNODE ll_insert();
extern LLNODE ll_append();
#define ll_include ll_insert
extern int ll_collapsed();
extern LLNODE ll_find_ln();
extern pointer ll_find_object();
extern pointer ll_delete();
extern pointer ll_delete_count();
extern pointer ll_delete_one();
extern pointer ll_exclude();
extern pointer ll_exclude_count();
extern pointer ll_exclude_one();

/* llio.c */

/* llmisc.c */
extern pointer* ll_arrayf();
extern pointer* ll_array();
extern LLIST ll_copyf();
extern LLIST ll_copy();
extern LLIST ll_mergef();
extern LLIST ll_merge();
extern int ll_max();
extern int ll_sum();
extern int ll_count();
extern int ll_count___();
extern int ll_any();
extern int ll_any___();
extern void ll_select();
extern void ll_select___();
extern void ll_selectf();
extern void ll_selectf___();
extern LLIST ll_insert_args();
extern LLIST ll_insert_intargs();
extern LLNODE ll_index_ln();
extern pointer ll_index_object();
extern int ln_index();
extern int ll_object_index();
extern int ll_compare();
extern LLIST ll_strtok();
extern LLIST ll_joinf();
extern LLIST ll_join();

/* llstack.c */
extern pointer ll_top();
extern pointer ll_push();
extern pointer ll_pop();
extern pointer ll_swap();
extern pointer ll_dup();

#endif
