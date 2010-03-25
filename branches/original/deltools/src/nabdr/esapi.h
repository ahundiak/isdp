/*
******************************************************************************
** $Id: esapi.h 1.2.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Header: esapi.h
**
** This module implements the SWES API for the NT platform.  The following
** functions are defined:
**
**     1) CreateEvalSNumberRec
**     2) DeleteEvalSNumberRec
**     3) InitEvalSNumberRec
**     4) EvalLicAvailable
**
** A descriptions of each function is presented in a comment block preceeding
** the function's prototype.
******************************************************************************
** Build Requirements
**
** Libraries:
**
** Dependencies:
**
** Compilation Directives:
**
** Additional compilation requirements may be imposed by dependency sources.
** Consult these files for a description of their individual requirements.
**
**     _STD_C_	       - Change Ansi code. (with _SUNOS_)
**	
******************************************************************************
*/

#if !defined(_ESAPI_H_)
#define _ESAPI_H_

/*
** Structure used to pass evaluation information to/from the evaluation API.
*/
typedef struct {
    unsigned int day;                 /* Expiration day, [1-31]. */
    unsigned int month;               /* Expiration month, [0-11]. */
    unsigned int year;                /* Expiration year, [1993-2024]. */
    int   errcode;                    /* Used to return status information. */
    char  snbr[15];                   /* Evaluation serial number. */
    char  customer[65];               /* Customer's name. */
} EvalSNumberRec;

/*
==============================================================================
Function: CreateEvalSNumberRec

Parameters: none

Description:
    This function is used to dynamically allocate an EvalSNumberRec
    object.

Return Values:
    This routine returns a NULL pointer if an object cannot be allocated.
    Otherwise, a pointer to the allocated object is returned.
==============================================================================
*/

#if defined(_STD_C_)
EvalSNumberRec *CreateEvalSNumberRec ();
#else
EvalSNumberRec *CreateEvalSNumberRec (void);
#endif

/*
==============================================================================
Function: DeleteEvalSNumberRec

Parameters:
    edsrec - (OUT) - EvalSNumberRec object to deallocate.  A NULL pointer
                     is recognized and ignored.

Description:
    This function deallocates the specified EvalSNumberRec.  A NULL pointer is
    recognized and ignored.

Return Values: none
==============================================================================
*/

#if defined(_STD_C_)
void DeleteEvalSNumberRec ();
#else
void DeleteEvalSNumberRec (EvalSNumberRec *esrec);
#endif

/*
==============================================================================
Function: InitEvalSNumberRec

Parameters:
    esrec - (OUT) - EvalSNumberRec structure to be initialized.
    
Description:
    This function initializes the specified EvalSNumberRec structure.
    Note that a NULL pointer is recognized and ignored.

Return Values: none
==============================================================================
*/

#if defined(_STD_C_)
void InitEvalSNumberRec ();
#else
void InitEvalSNumberRec (EvalSNumberRec *esrec);
#endif

/*
==============================================================================
Function: EvalLicAvailable

Parameters:
    esrec        - (IN/OUT) - Structure containing evaluation serial number
                              info.  Caller MUST supply both the "snbr" and
                              "customer" fields.  All other fields will be
                              filled in by this function.
    snerrno     - (G:OUT)  - Global status/error variable.
    RT_STATEFILE - (G:OUT)  - Pathname of state file.
    MAX_WINDOW   - (G:IN)   - Maximum allowable difference between current time
                              and expiration date.

Description:
    This function determines if a valid evaluation license is hiding within
    the specified serial number.  The caller MUST fill in both the "snbr"
    and "customer" fields in "esrec".  This function will then extract the
    expiration date from the serial number and fill in the appropriate fields
    of "esrec".

    If an error occurs, all fields except "customer" and "snbr" will have
    undefined values.

Return Values:
    This function returns a bolean value.  If a valid evaluation license was
    found, then a nonzero value will be returned.  Otherwise a value of 0 will
    be returned.

    The "errcode" field of "esrec" is also assigned one of the following
    status/error codes:

    SN_OK          - Everything went well.
    SN_EXPIRED     - The specified evaluation serial number has expired.
    SN_DATA_ERR    - The data supplied in "esrec" is illformed.
    SN_BAD_CHKSUM  - Checksum over customer's name does not match the one
                      encrypted within the serial number.
    SN_BAD_ECHKSUM - The serial number checksum is incorrect.
    SN_FOPEN_ERR   - Could not open the state file.
    SN_WRITE_ERR   - Could not write new state information to state file.
    SN_SEEK_ERR    - Could not rewind state file.
    SN_STATE_ERR   - The system time precedes the time recorded in the state
                      file.
    SN_ENVAR_ERR   - Environment variable "SWESRT" is not defined.

    Note that the global status/error variable "snerrno" is also set to the
    values listed above.
==============================================================================
*/

#if defined(_STD_C_)
int EvalLicAvailable ();
#else
int EvalLicAvailable (EvalSNumberRec *esrec);
#endif

#endif /* _ESAPI_H_ */
