/* $Id: VDSdbmsg.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDSdbmsg.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbmsg.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
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

					/**************************************/
					/*				      */
					/*	VDSdbmsg.h		      */
					/*				      */
					/**************************************/

/* error messages */
#define	VDS_E1	"Cannot fopen the file : "
#define	VDS_E2	"Uncoherent string : "
#define	VDS_E3	"Null attribute name"
#define	VDS_E4	"attribute : <%s> don't exist\n"
#define	VDS_E6	"Not enough arguments for create_family"
#define	VDS_E7	"Too much arguments for create_family"
#define	VDS_E8	"Unknown prefix : <%s>, continue execution\n"

/* Status messages */
#define	VDS_S1	"\tBegining of the part description"
#define	VDS_S2	"\tEnd of the part description\n"
#define	VDS_S3	">> enter into "
#define	VDS_S4	"<< exit from  "
#define	VDS_S5	"Error = "
#define	VDS_S6	"CONNECT to <%s>\n"
#define	VDS_S8	"Enter in  VDSinit_db"
#define	VDS_S9	"Read data from /tmp/family"
#define	VDS_S10	"Connect to I/VDS server"
#define	VDS_S11	"Creating family : <%s>\n"
#define	VDS_S12	"family <%s> already created\n"
#define	VDS_S13	"End of family generation"
