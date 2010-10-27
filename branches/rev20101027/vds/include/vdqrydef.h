/* $Id: vdqrydef.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / vdqrydef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdqrydef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
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
 * Revision 1.3  1995/07/07  15:59:10  pinnacle
 * Replaced: include/vdqrydef.h for:  by yzhu for vds.240
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

#ifndef vdqrydef_include
#define vdqrydef_include

/*
 * 	I/VDS
 *
 *	This file contains constants values for select criterias.
 *
 *	Dependencies:
 */

/*---------------------------------------------------------------------------*/

/*
 * Constants used in query:
 *
 */

#define		VD_qry_nmObject		"query"
#define		VD_qry_nmName		"name"
#define		VD_qry_nmComment	"comment"
#define		VD_qry_nmSelect		"select"
#define		VD_qry_nmWhere		"where"

#define		VD_qry_nmPfxName	"pfx_name"
#define		VD_qry_nmPfxIndex	"pfx_index"

/*
 * the sizes of the keywords to look after.
 */
#define		VD_qry_szComment	7
#define		VD_qry_szSelect		6
#define		VD_qry_szWhere		5

#define		VD_qry_szPfxIndex	9
#define		VD_qry_szPfxName	8

#define		VD_qry_szLine		70

/*
 * private messages constants for faster interface.
 */
#define		VD_qry_Descr		1
#define		VD_qry_Comment		2
#define		VD_qry_Select		3
#define		VD_qry_Where		4

/*---------------------------------------------------------------------------*/

#endif
