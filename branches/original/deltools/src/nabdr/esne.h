/*
******************************************************************************
** $Id: esne.h 1.1.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Header: esne.h
**
** This module implements the Evaluation Serial Number Encryption algorithms.
******************************************************************************
*/

#if !defined(_ESNE_H_)
#define _ESNE_H_

#include "mytypes.h"

#define ESNE_VERSION  0

typedef struct {
    uint day;              /* [1-31] */
    uint month;            /* [0-11] */
    uint year;             /* [0-31] */
    char  prodindex[7];
    char  snbr[15];
    char  customer[65];
} EvalSnbrRec;

/*
==============================================================================
Function: CreateEvalSnbrRec

Parameters: none

Description:
    This function is used to dynamically allocate an EvalSnbrRec
    object.

Return Values:
    This routine returns a NULL pointer if an object cannot be allocated.
    Otherwise, a pointer to the allocated object is returned.
==============================================================================
*/

EvalSnbrRec *CreateEvalSnbrRec OF((void));


/*
==============================================================================
Function: DeleteEvalSnbrRec

Parameters:
    edsrec - (OUT) - EvalSnbrRec object to deallocate.  A NULL pointer
                     is recognized and ignored.

Description:
    This function deallocates the specified EvalSnbrRec.

Return Values: none
==============================================================================
*/

void DeleteEvalSnbrRec OF((EvalSnbrRec *esrec));


/*
==============================================================================
Function: InitEvalSnbrRec

Parameters:
    esrec - (OUT) - EvalSnbrRec structure to be initialized.
    
Description:
    This function initializes the specified EvalSnbrRec structure.
    Note that a NULL pointer is recognized and ignored.

Return Values: none
==============================================================================
*/

void InitEvalSnbrRec OF((EvalSnbrRec *esrec));

#if !defined(_ESNE_DECODE_ONLY_)

/*
==============================================================================
Function: EncryptEvalSerialNumber

Parameters:

Description:

Routines:

Return Values:

==============================================================================
*/

int EncryptEvalSerialNumber OF((EvalSnbrRec *esrec));

#endif /* !defined(_ESNE_DECODE_ONLY_) */

#if !defined(_ESNE_ENCODE_ONLY_)

/*
==============================================================================
Function: DecryptEvalSerialNumber

Parameters:

Description:

Routines:

Return Values:

==============================================================================
*/

int DecryptEvalSerialNumber OF((EvalSnbrRec *esrec));

#endif /* !defined(_ESNE_ENCODE_ONLY_) */

#endif /* !defined(_ESNE_H_) */
