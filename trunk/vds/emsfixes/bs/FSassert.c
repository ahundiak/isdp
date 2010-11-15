/* $Id: FSassert.c,v 1.1.1.1 2001/01/04 21:07:26 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        emsfixes/bs/FSassert.c
 *
 * Description:
 *
 * Override RESOURCE fontserver assert function to prevent it from
 * killing the product.  Place under bs so it gets loaded as soon as
 * practical.
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: FSassert.c,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:26  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1999/04/05  20:08:14  pinnacle
 * fontserver assert problem
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/05/99  ah      Creation
 ***************************************************************************/

/* --------------------------------------------------------------------
 * In general, assertions are used to debug code before shipping.
 * Running code should not throw an assert.
 *
 * For reasons still unkwnown, fontserver is starting to throw assertions
 * for certain files when creating certain fonts.  
 *
 * Short term work around to to simply accept the assertions and not exit the progeam.
 * This was actuallt the intent.  If you compile with NDEBUG then assertions fail silently.
 *
 * But for some reason, the shipping code has NDEBUG off.
 *
 * So just override this function and have it do nothing
 */
/* =====================================================
 * SOL10 15 Nov 2010
 * Remove from product now that we have control over font server
 */
_FSAssertion (expr, file, line)
char	*expr;
char	*file;
int	line;
{
  /*
    printf ("Assertion Failure: (%s) in \"%s\" at line %d\n", expr, file, line);
    */

    /*    kill (getpid (), 3);*/	/* make a core file */
}
