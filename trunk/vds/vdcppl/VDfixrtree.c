/* $Id: VDfixrtree.c,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl / VDfixrtree.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDfixrtree.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
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

/* NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC */

int VD_ic( i0, i1 )
int *i0, *i1;

/*

DESCRIPTION
  used for qsort, return <0 if i0 < i1
                  return >0 if i0 > i1
                  return 0 if i0 == i1

THIS FUNCTION IS USED BY THE PPL fixrtree.u to clean the range tree.
	- remove duplicated entries.
	- remove non graphic objects entries.
	- remove non existing objects entries.

HISTORY
       Author     Date          Description
       ------     ----          -----------
        pam     04/18/90        initial spec & wroteit used in fixrtree.u

NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC */
  {
  return( *i0 - *i1 );
  }
    
