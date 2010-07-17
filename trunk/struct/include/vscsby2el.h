/* $Id: vscsby2el.h,v 1.1.1.1 2001/01/04 21:09:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:	struct/include/vscsby2el.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vscsby2el.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:42  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.3  1997/06/16  15:07:22  pinnacle
 * TR179701071
 *
 * Revision 1.2  1997/06/16  15:00:42  pinnacle
 * TR179701071
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      06/16/97        ah              Header Creation
 *      06/16/97        ah              TR179701071
 * -------------------------------------------------------------------*/

#ifndef	vscsby2el_include
#define	vscsby2el_include

#define MAC_CS_2EL     "CS_by2elem"
#define MAX_TEMP        7
#define MAX_FEET        3
#define MAX_CHAR_FEET   20
#define OPTIONS_NUMBER  5

       /* templates names */
#define NAM_CS_ELEM1    "elem1"
#define NAM_CS_ELEM2    "elem2"

       /* templates index */
#define IDX_CS_ELEM1    0
#define IDX_CS_ELEM2    1
#define IDX_CS_OPT      2

       /* feet names */
#define NAM_CS_CS       "cs"
#define NAM_CS_SRF      "intSrf"
#define NAM_CS_IDXSRF   "intExpr"

       /* feet index */
#define IDX_CS_CS       0
#define IDX_CS_SRF      1
#define IDX_CS_IDXSRF   2

#endif
