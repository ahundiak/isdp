/* $Id: VDut_time.C,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDut_time.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDut_time.C,v $
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


#include <sys/types.h>
#include <time.h>

char * VDgettime()
{

  time_t ret,timinsec;
  time_t *timeptr;

  timinsec=0;
  timeptr=(&timinsec);

  ret=time(timeptr);

  if ( ret != -1 )
   {
    return(ctime(timeptr));
   }
  else
    return(0);
}

