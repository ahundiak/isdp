/* $Id: VDSris_def.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDSris_def.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSris_def.h,v $
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
 * Revision 1.2  1995/12/20  15:16:16  pinnacle
 * Replaced: vdinclude/VDSris_def.h for:  by hverstee for vds.240
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

#ifndef VDSris_def_include
#define VDSris_def_include

#define         RISFAIL         -1

#define         FAILURE         0
#define         SUCCESS         1

#define		BACK_N  	'\n'
#define		BACK_SLASH  	'\\'
#define		BACK_T 		'\t'
#define		BLANK   	' '
#define		C_COMMA 	','
#define		C_QUOTE		'\''
#define		C_2QUOTE	'"'
#define		SEP_CHAR	'|'

#define		S_COMMA		","
#define		S_QUOTE		"'"
#define		SEP_STRING	"|"
#define		SEP_LENGTH	1

#define		RIS_COL_NAM	"column_name"
/*#define		RIS_COL_TAB	"riscolumn_privs"*/
/*#define		RIS_TAB_SHM	"table_schema"*/
#define		RIS_TAB_NAM	"table_name"
#define		RIS_TYP_NAM	"ris_type_string"
#define		RIS_COLUMNS	"ris5columns"
#define		RIS_COL_POS	"position"

#define		DELETE_N	0
#define		DELETE_Y	1
#define		PREPARE_N	0
#define		PRINT_Y		1
#define		PRINT_N		0
#define		PREPARE_Y	1

#define		CHAR		1
#define		NUMERIC		2
#define		DECIMAL		3
#define		INT		4
#define		SMALLINT	5
#define		REAL		7
#define		DOUBLE		8
#define		DATE		99

/*#define SGSHARED        0*/

#endif
