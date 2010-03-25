/*
******************************************************************************
** $Id: esapi.c 1.2.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Source: esapi.c
**
** This module implements the SWES API for DELTOOLS.  The following
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
**     -D_ESNE_DECODE_ONLY      - Excludes unnecessary evaluation serial
**                                number encryption code.
**     -D_STD_C_		- Change ansi code. (with _SUNOS_)
**
** Additional compilation requirements may be imposed by dependency sources.
** Consult these files for a description of their individual requirements.
******************************************************************************
*/

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <time.h>
#include <fcntl.h>
#include <string.h>

#if defined(_SYSV_)
#    include <unistd.h>
#else
#    include <io.h>
#    include <share.h>
#endif

#include "snerr.h"
#include "esne.h"
#include "esapi.h"

/*
** Allow for a 92 day window since password generator gives the user 91 days.
*/
#define MAX_WINDOW  7948800L

#if defined(_STD_C_)
static int InitEnvironment ();
#else
static int InitEnvironment (void);
#endif

#if defined(_STD_C_)
static int StateTimeOK ();
#else
static int StateTimeOK (time_t curtime);
#endif

static char RT_STATEFILE[256];     /* Will normally be "$SWESRT/cfg/sf.dat" */

/*
==============================================================================
Function: CreateEvalSNumberRec

Parameters: none

Description:
    This function is used to dynamically allocate an EvalSNumberRec
    object.

Routines: none

Return Values:
    This routine returns a NULL pointer if an object cannot be allocated.
    Otherwise, a pointer to the allocated object is returned.
==============================================================================
*/

EvalSNumberRec *CreateEvalSNumberRec ()
{
    return (EvalSNumberRec *) calloc(1,sizeof(EvalSNumberRec));
}

/*
==============================================================================
Function: DeleteEvalSNumberRec

Parameters:
    edsrec - (OUT) - EvalSNumberRec object to deallocate.  A NULL pointer
                     is recognized and ignored.

Description:
    This function deallocates the specified EvalSNumberRec.  A NULL pointer is
    recognized and ignored.

Routines: none

Return Values: none
==============================================================================
*/

#if defined(_STD_C_)
void DeleteEvalSNumberRec (esrec)
    EvalSNumberRec *esrec;
#else
void DeleteEvalSNumberRec (EvalSNumberRec *esrec)
#endif
{
    if (esrec) free(esrec);
}

/*
==============================================================================
Function: InitEvalSNumberRec

Parameters:
    esrec - (OUT) - EvalSNumberRec structure to be initialized.
    
Description:
    This function initializes the specified EvalSNumberRec structure.
    Note that a NULL pointer is recognized and ignored.

Routines: none

Return Values: none
==============================================================================
*/

#if defined(_STD_C_)
void InitEvalSNumberRec (esrec)
    EvalSNumberRec *esrec;
#else
void InitEvalSNumberRec (EvalSNumberRec *esrec)
#endif
{
    if (esrec) memset((char *)esrec,0,sizeof(EvalSNumberRec));
}

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

Routines:
    InitErrorVariables      - snerr.c
    InitEnvironment         - ntsapi.c
    StateTimeOK             - ntsapi.c
    InitEvalSnbrRec         - esne.c
    DecryptEvalSerialNumber - esne.c

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
int EvalLicAvailable (esrec)
    EvalSNumberRec *esrec;
#else
int EvalLicAvailable (EvalSNumberRec *esrec)
#endif
{
    InitErrorVariables();
    if (InitEnvironment() == SN_OK) {
	time_t curtime;
	
	time(&curtime);
	if (StateTimeOK(curtime)) {
	    EvalSnbrRec er;
	    
	    InitEvalSnbrRec(&er);
	    strcpy(er.customer,esrec->customer);
	    strcpy(er.snbr,esrec->snbr);
	    if (DecryptEvalSerialNumber(&er) == SN_OK) {
		time_t exptime;
		struct tm timerec;
		
		memset((char *)&timerec,0,sizeof(struct tm));
		timerec.tm_mon = esrec->month = er.month;
		timerec.tm_mday = esrec->day = er.day;
		timerec.tm_year = esrec->year = (er.year + 1993) - 1900;
		exptime = mktime(&timerec);

#if defined(_TESTING_)
		printf("Current Date: %s",ctime(&curtime));
		printf("Expiration Date: %s",ctime(&exptime));
#endif

		if ((curtime > exptime) || ((exptime - curtime) > MAX_WINDOW))
		    snerrno = SN_EXPIRED;
	    }
	}
    }
    esrec->errcode = snerrno;

    InitErrorVariables();

    return !esrec->errcode;
}

/****************************************************************************/

/*
==============================================================================
Function: StateTimeOK

Parameters:
    curtime - (IN)    - The current time.
    snerrno - (G:OUT) - Global status/error variable.

Description:
    This function checks the state file to make sure that the customer is not
    fiddling with the system time in order to avoid evaluation key expiration.
    The state information in the state file is also updated.

Routines: none    

Return Values:
    This is a boolean function returning zero on failure and nonzero if
    successful.  Thestatus variable "snerrno" is also set to one of the
    following values:

    SN_OK        - State was OK.  State file updated successfully.
    SN_FOPEN_ERR - Could not open state file.
    SN_STATE_ERR - State in state file is not valid.
    SN_SEEK_ERR  - Could not seek in state file.
    SN_WRITE_ERR - Could not write new state information to state file.
==============================================================================
*/

#if defined(_STD_C_)
static int StateTimeOK (curtime)
    time_t curtime;
#else
static int StateTimeOK (time_t curtime)
#endif
{
    int sfd;

#if defined(_SYSV_)
    if ((sfd = open(RT_STATEFILE,O_RDWR)) == -1)
#else
    if ((sfd = sopen(RT_STATEFILE,O_RDWR|O_BINARY,_SH_DENYWR)) == -1)
#endif
	snerrno = SN_FOPEN_ERR;
    else {
	unsigned char buf[8];

	if (read(sfd,(char *) buf,5) != 5)
	    *buf = (curtime & 0x0ff) & ((curtime >> 8) & 0x0ff);
	else {
	    time_t tmptime;

	    buf[1] ^= *buf;
	    buf[2] ^= *buf;
	    buf[3] ^= *buf;
	    buf[4] ^= *buf;
	    tmptime = (buf[4] << 24) | (buf[3] << 16) | (buf[2] << 8) | buf[1];
	    if (tmptime > curtime)
		snerrno = SN_STATE_ERR;
	    else {
		int i;
		unsigned char sum;

		for (sum = 0, i = 1; i < 5; ++i) sum += buf[i];
		*buf ^= sum;
	    }
	}
	if (snerrno == SN_OK) {
	    buf[1] = curtime & 0x0ff;
	    buf[1] ^= *buf;
	    buf[2] = (curtime >> 8) & 0x0ff;
	    buf[2] ^= *buf;
	    buf[3] = (curtime >> 16) & 0x0ff;
	    buf[3] ^= *buf;
	    buf[4] = (curtime >> 24) & 0x0ff;
	    buf[4] ^= *buf;

	    if (lseek(sfd,0,SEEK_SET) == -1)
		snerrno = SN_SEEK_ERR;
	    else if (write(sfd,buf,5) != 5)
		snerrno = SN_WRITE_ERR;
	}

	close(sfd);
	chmod(RT_STATEFILE,0666);
    }

    return !snerrno;
}

/*
==============================================================================
Function: InitEnvironment

Parameters:
    snerrno - (G:OUT) - Global status/error variable.

Description:
    This function pulls required informaiton from the local machines
    environment to initialize internal structures.

Routines: none

Return Values:
    This function returns the value of "snerrno".  This global variable is
    set to one of the following values:

    SN_OK        - Environment information has been successfully retrieved.
    SN_ENVAR_ERR - SWESRT environment variable has not been defined.
==============================================================================
*/

static int InitEnvironment ()
{
    char *tmptr;

    if ((tmptr = getenv("SWESRT")) == NULL)
	snerrno = SN_ENVAR_ERR;
    else
#if defined(_SYSV_)
	strcat(strcpy(RT_STATEFILE,tmptr),"/cfg/sf.dat");
#else
	strcat(strcpy(RT_STATEFILE,tmptr),"\\cfg\\sf.dat");
#endif

    return snerrno;
}

#if defined(_TESTING_)

main (int argc, char *argv[])
{
    EvalSNumberRec erec;

    InitEvalSNumberRec(&erec);
    strcpy(erec.snbr,argv[1]);
    strcpy(erec.customer,argv[2]);
    if (EvalLicAvailable(&erec))
	printf("An evaluation license is available.\n");
    else
	printf("Failure with code %d\n",erec.errcode);

    exit(erec.errcode);
}

#endif /* TESTING */
