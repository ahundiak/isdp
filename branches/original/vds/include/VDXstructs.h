/* $Id: VDXstructs.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/VDXstruct.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXstructs.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1999/04/19  14:08:00  pinnacle
 * for dynapipe
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/16/99        ylong           created
 *			
 ***************************************************************************/


typedef struct VDX_MYFILE
  {
    int cnt;
    char *file_ptr;
    char flag;
    char file;
  } MYFILE;

typedef struct VDXt_totals
  {
     int  object_count;
     int  processed;
     int  type_2;
     int  type_15;
     int  type_18;
     int  type_23;
     int  type_24;
     int  type_25;
     int  type_46;
  } VDXtype_totals;

