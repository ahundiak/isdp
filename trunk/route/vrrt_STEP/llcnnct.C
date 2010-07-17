/* $Id:*/

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrrt_STEP/llcnnct.C
 *
 * Description:
 *      This is another copy of the vrrt/llcnnct.C file. This might've undergone
 *      some changes while compiling for MariSTEP. That's the reasin these
 *      files are placed in a different directory.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: llcnnct.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:13:08  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1998/11/07  00:50:30  pinnacle
 * Replaced: vrrt_STEP/llcnnct.C for:  by apazhani for route
 *
 * Revision 1.1  1998/11/06  19:29:56  pinnacle
 * initial revision
 *
 *
 * History:
 *       Date            Name     Description
 *      11/06/98        Alwin     Creation
 *
 *************************************************************************/

/* See separate documentation about using the linked list package. */

#include <common.h>
#include <ll.h>

/* Functions for connecting and disconnecting individual nodes
in a linked list.  Aside from ln_init() (defined in llstruct.c),
these are the only functions that modify the next/prev pointers
in LLNODEs. */

LLNODE ln_connect(ln,pln) LLNODE ln, pln; {
	LLIST ll = llof_ln(pln); LLNODE nln = pln->ln_next;
	pln->ln_next = ln; ln->ln_next = nln;
	nln->ln_prev = ln; ln->ln_prev = pln; 

	/*   llof_ln(ln) = ll; commenting this to replace the actual 
	equation. Alwin */
	ln->ln_ll = ll;

	countof_ll(ll) += countof_ln(ln); ++lengthof_ll(ll); return ln; }
LLNODE ln_disconnect(ln) LLNODE ln; { LLIST ll = llof_ln(ln);
	ln->ln_next->ln_prev = ln->ln_prev;
	ln->ln_prev->ln_next = ln->ln_next;

	/* llof_ln(ln) commenting this to replace the actual
	llof_ln(ln) = ln->ln_next = ln->ln_prev = NULL;
	equation. Alwin */

	ln->ln_ll = ln->ln_next = ln->ln_prev = NULL;

	countof_ll(ll) -= countof_ln(ln); --lengthof_ll(ll); return ln; }

LLNODE ln_reconnect(ln,toln) LLNODE ln, toln; {
	if (ln==toln) return ln; return ln_connect(ln_disconnect(ln),toln); }
LLNODE ln_insert(object,pln) pointer object; LLNODE pln; {
	return ln_connect(ln_new(object),pln); }
pointer ln_delete(ln) LLNODE ln; { return ln_free(ln_disconnect(ln)); }

void ln_swap(ln) LLNODE ln; { LLNODE pln = ln->ln_prev, nln = ln->ln_next, tmp;
	ln_disconnect(nln); ln_disconnect(ln); swap(ln,nln,tmp);
	ln_connect(ln,pln); ln_connect(nln,ln); }
