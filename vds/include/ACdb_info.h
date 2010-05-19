/* $Id: ACdb_info.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	include/ACdb_info.h
 *
 * Description: Copied from GRNUC at the request of TS to support some
 *              Customer ppl's
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACdb_info.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1998/02/08  16:19:52  pinnacle
 * ah
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      02/08/98        ah              Created
 * -------------------------------------------------------------------*/

#ifndef db_info_def
#define db_info_def

struct db_info
{
 int    	quantity;
 int    	serial_no;
 short  	s_catalog;	/* catalog's length */
 short		s_part_num;
 short		s_revision;
 short		s_usage;
};


struct ACdb_info
{
 int    quantity;
 int    serial_no;
 char  	catalog[15];	
 char	part_num[/*15*/64];
 char	revision[/*15*/64];
 char	usage[26];
};

struct ACobj_info
{ 
 struct GRid obj;
 int    serial_no;
};

struct ACobj_info_1
{ 
 struct GRid obj;
 int    serial_no;
 int    quantity;
};

#endif

