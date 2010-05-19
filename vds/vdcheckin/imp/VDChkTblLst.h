/* $Id: VDChkTblLst.h,v 1.1 2001/04/24 20:34:08 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDpdmCmd.h
 *
 * Description:	PDM Additional Routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDChkTblLst.h,v $
 * Revision 1.1  2001/04/24 20:34:08  jdsauby
 * Added for post tabel timestamp, CR 4474 and for Post Macros CR 5083
 *
 * Revision 1.6  2001/04/12 20:40:33  jdsauby
 * sp 11
 *
 * Revision 1.5  2001/03/29 19:35:58  jdsauby
 * Set Purpose Info command added
 *
 * Revision 1.4  2001/03/08 14:38:02  jdsauby
 * Re - organization of VDpdm.h
 *
 * Revision 1.3  2001/03/05 19:42:56  jdsauby
 * Finish Purpose Info
 *
 * Revision 1.2  2001/02/21 13:03:18  jdsauby
 * CR4088
 *
 * Revision 1.1  2001/02/05 15:48:29  jdsauby
 * JTS MP CR4088
 *
 * Revision 1.1  2000/03/09  21:42:00  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/11/00  js      Creation
 ***************************************************************************/

#ifndef VDpdmCmd_include
#define VDpdmCmd_include

#ifndef   VDpdm_include
#include "VDpdm.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* --------------------------------------------------
 * Table List data structure
 * **/
typedef struct
{
    int    init;
    int    cnt;
    char **list;
} VDTableList;

/* -------------------------------------------------
 * Table List utilities
 * **/

// initialize one
extern void VDChkInitTableList __(());

// free one
extern void VDChkFreeTableList __(());

// add a table to one
extern void VDChkAddTableToList __((char *table));

/* ------------------------------------------------
 * Returns the table list, and count
 * */
extern void VDChkGetTableList __((int     *cnt,
                                  char  ***list));


/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
