/* $Id: VDnfm.h,v 1.4 2001/11/08 20:21:49 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDnfm.h
 *
 * Description:	NFM Routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDnfm.h,v $
 * Revision 1.4  2001/11/08 20:21:49  jdsauby
 * JTS CR MP 4079 - jds
 *
 * Revision 1.3  2001/10/03 15:13:28  jdsauby
 * Added debug stuff, and better error checking
 *
 * Revision 1.2  2001/08/20 15:48:58  jdsauby
 * had to take out some // comments for compile errors - jds
 *
 * Revision 1.1  2001/08/14 19:42:36  jdsauby
 * Added for VDnfmZip functions and defines
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/14/01  js      Creation
 ***************************************************************************/

#ifndef VDnfm_include
#define VDnfm_include

#ifndef   VDtypedefc_include
#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif
#endif

#ifndef MEMSTRUCT_H
#include <MEMstruct.h>
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
 * Tracing of these functions
 * **/
#define VDNFM_TRACE_ZIP   70

// externs from VDnfmZip.c
/* ---------------------------------------
 * Use gzip to compress filename, and maintain original filename
 * after gzip.  By default, gzip adds a .gz extension to filename
 * **/
extern IGRstat VDnfmZipFile __((IGRchar *filename));

/* ---------------------------------------
 * Use gunzip to deCompress filename.  By design, the filename
 * will not have a .gz extension, therefore it must be added
 * before gunzip will work.  Also, it is possible that the file may have
 * been compressed on server from an outside source, therefore, it is 
 * necessary to gunzip the filename until it is no longer compressed.
 * **/
extern IGRstat VDnfmUnZipFile __((IGRchar *filename));

/* ------------------------------------------------
 * Convert the MEMptr buffer into useful data.
 * Taken from the original function PDUsetup_buffer
 * **/
/* definitions for buffer setup types */
#define        VDNFM_ROW            21
#define        VDNFM_COL            31
#define        VDNFM_FORMAT         41

extern IGRstat VDnfm_setup_buffer __((MEMptr     buffer,
                                      IGRint     type,
			              IGRchar ***data));

/* --------------------------------------------------
 * get the column number from the MEMptr bufr that contains
 * the column name.
 * Taken from the function PDUget_buffer_col
 * **/
extern IGRstat VDnfm_get_buffer_col __((MEMptr   bufr,
                                        IGRchar *col_name,
			                IGRint  *col_num));

/******************************************************************************
Abstract:
	Allocates memory and copies a string into it.

Algorithm:
		1.	If the address of the variable of which you are storing the variable is not NULL, Free the memory previously used by the variable.
		2.	If the string is not NULL, allocate the amount of memory need to store the string and copy it into the variable.

Return Status:
	1
*****************************************************************************/
extern IGRstat VDnfm_fill_in_string __((IGRchar **variable, /*I/O string copied into */
                                        IGRchar  *string )); /* I   string to copy */

/* ------------------------------------------------
 * Process the input MEMptr bufr to get a list of filenames
 * then gunzip the file.
 * This function is called from NFMfile_tr.c
 * **/
extern IGRstat VDnfmUnzipBufr __((MEMptr *bufr,
	                          IGRint logit));

/* ------------------------------------------------
 * Process the input MEMptr bufr to get a list of filenames
 * then gzip the file.
 * This function is called from NFMfile_tr.c
 * **/
extern IGRstat VDnfmZipBufr __((MEMptr *bufr));

/* ------------------------------------------------
 * Process the input MEMptr bufr to get a list of filenames
 * then determine if the file exists locally.
 * This function is called from NFMfile_tr.c
 * Added for JTSMP CR 4079, SAUBY
 * **/
extern IGRstat VDnfmCheckForLocalFiles __((MEMptr *bufr));

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
