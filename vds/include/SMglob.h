/* $Id: SMglob.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / SMglob.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMglob.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
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

/* File SMglob.h */

#ifndef SMglob_include
#define SMglob_include

#ifndef	SMdef_include
#	include	"SMdef.h"
#endif

#define NB_GLOB_ATTRIB 11

#define NO_VALUE -9.99999e+20

/* Name in the ACrg_colection of each attributes */
#define S_PROJECT_NAME   "PRJ"
#define S_TITLE          "TIT"
#define S_SHIP_NAME      "NAM"
#define S_SHIP_NUM       "NUM"
#define S_SHIP_TYPE      "TYP"
#define S_DEPART_NAME    "DPT" 
#define S_USER_NAME      "USR"
#define S_FLAG_STATE     "FLG"
#define S_YARD_NAME      "YRD"
#define S_AREA_OP        "AOO"

#define S_LPP            "LPP"
#define S_MOULD_BREADTH  "BMO"
#define S_MOULD_DEPTH    "DMO"
#define S_OVERALL_LENGTH "LOA"
#define S_DESIGN_DRAFT   "DDE"
#define S_SHELL_PLATING  "SHE"
#define S_KEEL_PLATING   "KEE"

#define S_MAIN_DIR       "MAIN_DIRECTION"
#define S_SIDE           "SIDE"

/* Structure for attributes read in a file (exemple of ship type) */
struct SMspec_attrib
{
  char name[MAX_CHAR_LINE]; /* Name of one item */
  int num;                  /* Number of item for seasafe */
};

#endif

