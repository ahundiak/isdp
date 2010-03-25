/*
******************************************************************************
** $Id: msne.h 1.2.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Header: msne.h
**
** This module defines the Maintenance Serial Number Encryption library.
******************************************************************************
** Build Requirements
**
** Libraries:
**
** Dependencies:
**
** Compilation Directives:
**     _MSNE_DECONLY_ - Excludes all encryption code from build.
**     _MSNE_ENCONLY_ - Excludes all decryption code from build.
**     _STD_C_	       - Change Ansi code.
**
** Additional compilation requirements may be imposed by dependency sources.
** Consult these files for a description of their individual requirements.
******************************************************************************
*/

#if !defined(_MSNE_H_)
#define _MSNE_H_

#include "mytypes.h"

#define MSNE_MAXIDX   9999999
#define MSNE_MAXREG   9999
#define MSNE_MAXSEQ   1048575

/*
** This structure is used when working with maintenance serial numbers.
**
** Note that "index" must contain 6 digits, "region" must contain 4 digits, and
** sequence must contain 7 digits.  The user is expected to left pad with
** zeroes when necessary.
*/
typedef struct {
    uint  region;                 /* Region Code: Range 0 -> 9,999. */
    ulong sequence;               /* Sequence Number: Range 0 -> 1,048,575. */
    ulong index;                  /* Product Index: Range 0 -> 9,999,999. */
    char  snbr[15];               /* Maintenance serial number. */
} MSnbrRec;

/*
==============================================================================
Function: CreateMSnbrRec

Parameters:
    snerrno  - (G:OUT) - Global status/error variable.
    snerrmsg - (G:OUT) - Global status/error message buffer.

Description:
    This function creates and initializes an MSnbrRec object.

Return Values:
    If successful, this function returns a pointer to the newly allocated
    MSnbrRec object.  If the object could not be created, then a NULL pointer
    is returned.

    This function also set the variable "snerrno" to one of the following
    values:

    SN_OK        - MSnbrRec object successfully allocated.
    SN_ALLOC_ERR - Could nto allocate object.

    If an error occurs, an appropriate error message is also placed in the
    global message buffer "snerrmsg".
==============================================================================
*/

#if defined(_STD_C_)
MSnbrRec *CreateMSnbrRec ();
#else
MSnbrRec *CreateMSnbrRec (void);
#endif

/*
==============================================================================
Function: DeleteMSnbrRec

Parameters:
    ms - (IN/OUT) - MSnbrRec object to be deleted.

Description:
    This function deallocates the specified MSnbrRec object.

Return Values: none
==============================================================================
*/

#if defined(_STD_C_)
void DeleteMSnbrRec ();
#else
void DeleteMSnbrRec (MSnbrRec *ms);
#endif

/*
==============================================================================
Function: InitMSnbrRec

Parameters:
    ms - (IN/OUT) - MSnbrRec object to be initialized.

Description:
    This function initializes the specified MSnbrRec object.

Return Values: none
==============================================================================
*/

#if defined(_STD_C_)
void InitMSnbrRec ();
#else
void InitMSnbrRec (MSnbrRec *ms);
#endif

#if !defined(_MSNE_DECONLY_)

/*
==============================================================================
Function: EncryptMaintenanceSerialNumber

Parameters:
    ms      - (IN/OUT) - MSnbrRec object with "index", "region", and
                         "sequence" filled in appropriately.
    snerrno - (G:OUT)  - Global status/error variable.

Description:
    This routine produces a maintenance serial number given the "index",
    "region", and "sequence" values supplied by the user in the MSnbrRec
    structure, "ms".

Return Values:
    This function sets the variable "snerrno" to one of the following values.
    The value of "snerrno" is also returned by this function.

    SN_OK       - Maintenance serial number successfully created.
    SN_DATA_ERR - Either the Product Index or the CustomerID was illformed.
==============================================================================
*/

#if defined(_STD_C_)
int EncryptMaintenanceSerialNumber ();
#else
int EncryptMaintenanceSerialNumber (MSnbrRec *ms);
#endif

#endif /* !defined(_MSNE_DEC_ONLY_) */

#if !defined(_MSNE_ENCONLY_)

/*
==============================================================================
Function: DecryptMaintenanceSerialNumber

Parameters:
    ms      - (IN/OUT) - MSnbrRec object containing maintenance serial number
                         to be decrypted.
    snerrno - (G:OUT)  - Global status/error variable.

Description:
    This routine validates the maintenance serial number supplied.  If the
    serial number is valid, the region code, sequence number, and product
    index are extracted from the serial numbe and placed in ms->region, 
    ms->sequence, and ms->index, respectively.

Return Values:
    This function sets the variable "snerrno" to one of the following values.
    The value of "snerrno" is also returned by this function.

    SN_OK       - Maintenance serial number successfully created.
    SN_DATA_ERR - Either the Product Index or the CustomerID was illformed.
==============================================================================
*/

#if defined(_STD_C_)
int DecryptMaintenanceSerialNumber ();
#else
int DecryptMaintenanceSerialNumber (MSnbrRec *ms);
#endif

#endif /* !defined(_MSNE_ENCONLY_) */

#endif /* !defined(_MSNE_H_) */
