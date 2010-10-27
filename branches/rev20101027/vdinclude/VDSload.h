/* $Id: VDSload.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDSload.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSload.h,v $
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

#ifndef VDSload_include

#define VDSload_include

#define		CREATE_TABLE_FILE	"vds.ddl"
#define		CREATE_TABLE_ORDER	"create table"
#define		BEFORE_DATA		"("
#define		AFTER_DATA		");"
#define		CHAR_NAME		"char"

struct MFline
{
        char    table[MAXWORD];
        char    file[MAXWORD];
};

struct MFload
{
        struct  MFline  data[MAXWORD];
        int             num;
};

#endif
