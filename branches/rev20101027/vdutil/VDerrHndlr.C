/* $Id: VDerrHndlr.C,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDerrHndlr.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDerrHndlr.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#include	<stdio.h>
#include	"OMprimitives.h"

/****************************************************************************

   Doc: VDerrHndlr

   Abstract:  Called after a message send ( or function call ), this
	will check for the status of 'status', and 'msg'.  If either status
	is fatal, the description is printed to stderr and a zero is
	returned.
	
   History:

	Date		Who		Why
	---------	------		----------------------------------
	08-30-1994	raju		Adopted from I/FEM


   Return Status:  1 :  If status and msg are OK
   		   0 :	If status or msg is not OK

 ****************************************************************************/

int VDerrHndlr (
 char	desc[],		/* i - description for aid to debug */
 long	status,		/* i - OM return status		*/
 long	msg,		/* i - Message/function ret status */
 char	verbose,	/* i -  1 : Print description always
				0 : Print only if error	*/
 char	*file,		/* i - file name where error occured */
 int	line		/* i - line number where error occurred */
)
{

  if (!(status&1))
  {
	fprintf(stderr,"%-14s [%-3d] - %s : OM handle ERROR\n",file,line,desc);
		om$report_error(sts = status);
  }

  if (!(msg&1)) fprintf(stderr,"%-14s [%-3d] - %s : Return [%d] ERROR : \n",
							file,line,desc,msg);

  if ((status&1) && (msg&1) && verbose)
	fprintf(stderr,"%-14s [%-3d] - %s : OK\n", file, line, desc);

  if (((status&7) == 2) || ((status&7) == 4) || !(msg&1)) return(0);
  else							  return(1);
}
