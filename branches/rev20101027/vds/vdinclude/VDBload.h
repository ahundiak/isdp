/* $Id: VDBload.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDBload.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDBload.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.2  1997/01/30  23:57:10  pinnacle
 * ah CR179602053
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.3  1996/03/22  04:33:28  pinnacle
 * Replaced: vdinclude/VDBload.h for:  by msbraju for vds.240
 *
 * Revision 1.2  1996/02/20  12:09:38  pinnacle
 * Replaced: vdinclude/VDBload.h for:  by msbraju for vds.240
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
 *      01/30/97        ah              Added Pick Lists
 *
 * -------------------------------------------------------------------*/

/*---------------------------------------------------------------------------------
  Doc : VDBload.h
  
  Desc : Include file for VDSloaddata.
  
  History:
  11-02-93    2.2    raju    creation
---------------------------------------------------------------------------------*/
#ifndef  VDBload_include
#define  VDBload_include

/* ----- general defines ----- */

#define VDB_FIRST_LINE  2	/* line in window where text starts. Lines
				   start from 0 . This is true for all windows */
#define VDB_FIRST_COL   3	/* column no. in window where text starts. Columns
				   start from 0 . This is true for all windows */
#define VDB_GAP		2	/* no. of columns between any two fields in any type
				   of window  */
#define VDB_MAXLENGTHS  30
#define VDB_EXIT        0
#define VDB_PROCESS     1

#define HIGHLIGHT_MODE  A_REVERSE

#define VDB_MAX_NO_PROD	     5
#define VDB_PROD_MENU_STRS   5
#define VDB_MAX_PROD_LEN     6
#define VDB_MAX_PATH_LEN    41    /* max. length of path of any file */
#define VDB_MAX_FILE_LEN    50    /* max. length of any file including path  */

#define VDB_MAX_SELSTR_LEN  51    /* max. length of any of the  strings which appear
				     in a select menu. */

#define VDB_FAM           0
#define VDB_PART          1
#define VDB_PROJ          2

#define VDB_NEW_CATALOG   0
#define VDB_OLD_CATALOG   1

/* ----- for menu operations ----- */
#define CTRL_N     ( 'n' & 037 )
#define CTRL_P     ( 'p' & 037 )
#define CTRL_B     ( 'b' & 037 )
#define CTRL_F     ( 'f' & 037 )
#define CTRL_H     ( 'h' & 037 )
#define CTRL_D     ( 'd' & 037 )
#define VDB_DELETE   127


/* ------   macros ------ */

#define VDB_DELETE_WIN(A)	{ werase(A); wrefresh(A); delwin(A); A=NULL; }
#define VDB_REFRESH_WIN(A)	{ touchwin(A); wrefresh(A); }
#define VDB_DISP_PADED_MSG(A)	{ strcpy( VDBtmps, A ); \
				  VDBpadstr( VDBtmps, 81, ' ' ); \
				  mvwaddstr ( VDBmsgwin, 0, 0, VDBtmps ); \
				  wrefresh ( VDBmsgwin );\
				}

#define VDB_DISP_MSG_NOPAD(A)	{ strcpy( VDBtmps, A ); \
				  mvwaddstr ( VDBmsgwin, 0, 0, VDBtmps ); \
				  wrefresh ( VDBmsgwin );\
				}

#define VDB_GET_RETURN		{ char c; \
				  fflush( stdin ); \
				  fprintf( stdout, "\nPress <RETURN> to continue : ");\
				  fflush ( stdout ); \
				  c = getchar(); \
				  fflush( stdin ); \
				}

#define ENDWIN			{ touchwin( stdscr ); wrefresh( stdscr ); \
				  endwin(); \
				}


#define MAX(A,B)  ( A > B ) ? A : B
#define MIN(A,B)  ( A > B ) ? B : A

/* ------    defines for states  ------ */

#define VDB_MAIN_MENU        0
#define VDB_TABLES_MENU      1
#define VDB_CATALOGS_MENU    2
#define VDB_UTILITIES_MENU   3
#define VDB_CAT_MENU2        4
#define VDB_PART_MENU2       5
#define VDB_PROD_MENU        6
#define VDB_PATH_MENU        7
#define VDB_CAT_PART_LIST_MENU     8
#define VDB_DELCAT_MENU      9
#define VDB_GENFAM_MENU      10
#define VDB_DELPART_MENU     11
#define VDB_GENPART_MENU     12
#define VDB_EDIT_TBL         13
#define VDB_CONVERT_UNITS_MENU  14
#define VDB_DYN_TBL_MENU     15
#define VDB_REG_TBL_MENU     16
#define VDB_CREATE_DYN_TBL   17
#define VDB_MODIFY_DYN_TBL   18
#define VDB_CLEANUP_DYN_TBL  19
#define VDB_CREATE_REG_TBL   20
#define VDB_MODIFY_REG_TBL   21
#define VDB_DELETE_DATA      22
#define VDB_DROP_TABLE       23
#define VDB_ADD_DATA         24
#define VDB_FREE_UIDS	     25
#define VDB_MAIN_EXIT        26

#define VDB_PART_LIST        40
#define VDB_CAT_LIST         41

/* ---- for VDS support tables ---- */
#define VDB_CREATE_TABLES    0
#define VDB_LOAD_TABLES      1
#define VDB_DELETE_TABLES    2


/* ---- for attribue window ---- */
#define VDB_TABLE_ROWS       15    /* no. rows of attributes dispalyed or manipulated
				      in attribute window */
#define VDB_EDITABLE         1
#define VDB_NONEDITABLE      2

/* ---- validity of attribute type and values ---- */
#define VDB_INVALID_DATATYPE  0
#define VDB_VALID_DATATYPE    1
#define VDB_INVALID_DATAVALUE 0
#define VDB_VALID_DATAVALUE   1

#define VDB_NEW_TABLE	      0
#define VDB_OLD_TABLE	      1


#define VDB_MAX_CATALOG_LEN  19
#define VDB_MAX_TABLE_LEN    19

#define VDB_MAX_ATTRIB_LEN   19
#define VDB_MAX_DTYPE_LEN    16
#define VDB_MAX_DVAL_LEN     29

#define  VDB_DTYPE           0
#define  VDB_DVAL            1

/* ----- for set project units ----- */
#define  VDB_PROJECT_NAME_LEN   21
#define  VDB_PROJECT_REV_LEN    13
#define  VDB_PROJECT_UNITS_LEN  9

#define  VDB_COMMENT_CHAR       '#'	/* comment char in template file for dynamic
					   tables */

struct  VDBtable  {
  char   attrib[VDB_MAX_ATTRIB_LEN];
  char   dtype[VDB_MAX_DTYPE_LEN];
  char   dval[VDB_MAX_DVAL_LEN];
};

#endif
