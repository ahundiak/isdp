/* $Id: vsweld.h,v 1.1.1.1 2001/01/04 21:09:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	source_directory_filename
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vsweld.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.3  1997/12/18  13:35:06  pinnacle
 * Replaced: include/vsweld.h for:  by svkadamb for struct
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
*/
#ifndef vsweld_include
#define	vsweld_include

struct VS_s_weldAttr {
	unsigned char	code,
			process,
			info,
			side ;
} ;

typedef struct VS_s_weldAttr VSweldAttr	;

struct VS_s_addWldAttr {
	unsigned char	fieldweld ,
			position ;
} ;

typedef struct VS_s_addWldAttr VSaddWldAttr ;

#endif
