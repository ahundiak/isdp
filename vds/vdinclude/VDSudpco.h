/* $Id: VDSudpco.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDSudpco.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSudpco.h,v $
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


/****************************************************************************


		File:	VDSudpco.h
		Type:   c include file
		Use:	Defines constants for command object files 
		Date:	10 April 1993 - Genisis -
		Autr:	adz - isdc
		
***************************************************************************/

#ifndef VDSudpco_include

#define VDSudpco_include

/* comand return code */
#define		SUCCESS			1
#define		SEVERE_ERROR		4 
#define		NO_FILE			6
#define		NO_NAME			6
#define		NO_PATH			8

#define		RETURN_FORM		254
#define		VDS_LOAD_CMP		255

/* form names */
#define		MAIN			0
#define		SUB			1
#define		LIST			2


/* directory path names */
#define		MAIN_FORM_NAME		"VDDirPath"
#define		SUB_FORM_NAME		"VDSymb"
#define		COMMAND_NAME		":IGENOD:VDSpath_comm_id"
#define		LIST_FORM_NAME		"VDPathList"

#define		MAIN_FORM_REV_NAME	"VDRevPath"
#define		COMMAND_REV_NAME	":IGENOD:VDSrevpath_comm_id"

/* memory increment factor */
#define		ALLOC_INCR		5
#define		ALLOC_INCR_3		3


#endif
