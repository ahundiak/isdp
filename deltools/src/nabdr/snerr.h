/*
******************************************************************************
** $Id: snerr.h 1.1.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Header: snerr.h
**
** This header declares all error/status codes and other definitions common
** to all parts of the Software Evaluation System modules.
******************************************************************************
*/

#if !defined(_SNERR_H_)
#define _SNERR_H_

/*
** Status codes used throughout the Software Evaluation System.
*/
#define SN_OK                0
#define SN_ALLOC_ERR         1

#define SN_DIROPEN_ERR       20
#define SN_FOPEN_ERR         21
#define SN_READ_ERR          22
#define SN_WRITE_ERR         23
#define SN_DATA_ERR          24
#define SN_SCRSIZE_ERR       25
#define SN_FLOCK_ERR         26
#define SN_SEEK_ERR          27
#define SN_USER_ABORT        28
#define SN_CDFILE_ERR        29
#define SN_CDMNT_ERR         30
#define SN_PASSWD_ERR        31
#define SN_ACCT_ERR          32
#define SN_EXIT              33

#define SN_BAD_VERSION       50
#define SN_BAD_CHKSUM        51
#define SN_BAD_ECHKSUM       52
#define SN_BAD_EID           53

#define SN_TWRITE_ERR        60
#define SN_NOMSG_ERR         61

#define SN_VERSION_MISMATCH  70
#define SN_SYSID_ERR         71

#define SN_EXPIRED           80
#define SN_STATE_ERR         81
#define SN_ENVAR_ERR         82

#define SN_NOT_FOUND         100

#define SN_DBOPEN_ERR        200
#define SN_COPEN_ERR         201
#define SN_SELECT_ERR        202
#define SN_UPDATE_ERR        203
#define SN_XACTION_ERR       204
#define SN_TABLOCK_ERR       205
#define SN_INSERT_ERR        206
#define SN_FETCH_ERR         207
#define SN_DELETE_ERR        208
#define SN_POPEN_ERR         209
#define SN_PREAD_ERR         210

#define SN_USAGE_ERR         999

/*
** Maximum length of any language, codepage, and message buffers.
*/
#define SN_MAXLANG  12
#define SN_MAXCP    12
#define SN_MAXBUF   5120

/*
** Declare global status variables.
*/
extern int snerrno;
extern char snerrmsg[];

/*
** Declare prototypes.
*/

/*
==============================================================================
Function: InitErrorVariables

Parameters: none

Description:
    This function reinitializes the error/status variables "snerrno" and
    "snerrmsg".

Return Values: none
==============================================================================
*/

void InitErrorVariables ();

#endif /* _SNERR_H_ */
