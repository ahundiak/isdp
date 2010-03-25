/*
******************************************************************************
** $Id: msne.c 1.2.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Source: msne.c
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
**     _STD_C_	      - Change Ansi code.
**
** Additional compilation requirements may be imposed by dependency sources.
** Consult these files for a description of their individual requirements.
******************************************************************************
*/

static char appl_version_id[] = "$Id: msne.c 1.2.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $";

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <string.h>
#include "snerr.h"
#include "a2b64.h"
#include "myctype.h"
#include "msne.h"

/*
==============================================================================
Function: CreateMSnbrRec

Parameters:
    snerrno  - (G:OUT) - Global status/error variable.
    snerrmsg - (G:OUT) - Global status/error message buffer.

Description:
    This function creates and initializes an MSnbrRec object.

User Routines: none

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

MSnbrRec *CreateMSnbrRec ()
{
    MSnbrRec *ms = 0;

    if ((ms = (MSnbrRec *) calloc(1,sizeof(MSnbrRec))) == NULL) {
	snerrno = SN_ALLOC_ERR;
	strcpy(snerrmsg,"Error: Could not allocate internal structures.");
    }

    return ms;
}

/*
==============================================================================
Function: DeleteMSnbrRec

Parameters:
    ms - (IN/OUT) - MSnbrRec object to be deleted.

Description:
    This function deallocates the specified MSnbrRec object.

User Routines: none

Return Values: none
==============================================================================
*/

#if defined(_STD_C_)
void DeleteMSnbrRec (ms)
    MSnbrRec *ms;
#else
void DeleteMSnbrRec (MSnbrRec *ms)
#endif
{
    if (ms) free(ms);
}

/*
==============================================================================
Function: InitMSnbrRec

Parameters:
    ms - (IN/OUT) - MSnbrRec object to be initialized.

Description:
    This function initializes the specified MSnbrRec object.

User Routines: none

Return Values: none
==============================================================================
*/

#if defined(_STD_C_)
void InitMSnbrRec (ms)
    MSnbrRec *ms;
#else
void InitMSnbrRec (MSnbrRec *ms)
#endif
{
    if (ms) memset((char *)ms,0,sizeof(MSnbrRec));
}

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

User Routines:
    Bin2Asc64 - a2b64.c

Return Values:
    This function sets the variable "snerrno" to one of the following values.
    The value of "snerrno" is also returned by this function.

    SN_OK       - Maintenance serial number successfully created.
    SN_DATA_ERR - Either the Product Index or the CustomerID was illformed.
==============================================================================
*/

#if defined(_STD_C_)
int EncryptMaintenanceSerialNumber (ms)
    MSnbrRec *ms;
#else
int EncryptMaintenanceSerialNumber (MSnbrRec *ms)
#endif
{
    if (!ms || (ms->index > MSNE_MAXIDX) || (ms->region > MSNE_MAXREG) || (ms->sequence > MSNE_MAXSEQ)) {
	snerrno = SN_DATA_ERR;
    }
    else {
	unchar chksum = 0;    /* Checksum over CustomerID and Product Index. */
	int    i;             /* Used to access data in binary buffer. */
	ulong  isum = 0;      /* Sum computed over Product Index. */
	ulong  ival = 0;      /* Used to manipulate CustomerID. */
	unchar bbuf[30];      /* Buffer in which binary data is encrypted. */
	char   abuf[30];      /* Holds ASCII chars representing binary data. */

	/*
	** Compute modified summation over product index.
	*/
	{
	    char tmpidx[10];

	    sprintf(tmpidx,"%06lu",ms->index);
	    for (i = 0; i < 6; ++i) isum = (isum + tmpidx[i] * (i+1)) & 0x0FF;
	}
	/*
	** Copy binary numeric value of the region code and sequence number
	** into scratch buffer.  Compute modified checksum over this binary
	** string and prepend it to the string.
	*/
	ival = (ulong) ms->region;
	bbuf[1]  = ((unchar) ((ival >> 6) & 0x0FF));
	bbuf[2]  = ((unchar) ((ival << 2) & 0x0FF));

	ival = ms->sequence;
	bbuf[2] |= (unchar) ((ival >> 18) & 0x03);
	bbuf[3]  = (unchar) ((ival >> 10) & 0xFF);
	bbuf[4]  = (unchar) ((ival >> 2) & 0xFF);
	bbuf[5]  = (unchar) ((ival << 6) & 0xC0);

	for (chksum = 0, i = 1; i < 6; ++i) chksum += bbuf[i];
	chksum += (unchar) (ms->index & 0x0FF);

	bbuf[0] = chksum;

	/*
	** Swap a couple of bytes around.  Finally, XOR each byte in the
	** buffer by a positionally dependent value based on the product index.
	*/

	for (i = 1; i < 6; ++i) bbuf[i] ^= chksum;

	bbuf[6] = bbuf[0];
	bbuf[0] = bbuf[2];
	bbuf[2] = bbuf[6];

	bbuf[6] = bbuf[1];
	bbuf[1] = bbuf[4];
	bbuf[4] = bbuf[6];

	for (i = 0; i < 6; ++i) bbuf[i] ^= (unchar) ((isum * (i+1)) & 0x0FF);

	/*
	** Map encrypted buffer to ASCII.  Create serial number.
	*/
        Bin2Asc64(bbuf,7,abuf);

	sprintf(ms->snbr,"M%s%06lu",abuf,ms->index);
    }

    return snerrno;
}

#endif /* !defined(_MSNE_DECONLY_) */

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

User Routines:
    Asc2Bin - a2b64.c

Return Values:
    This function sets the variable "snerrno" to one of the following values.
    The value of "snerrno" is also returned by this function.

    SN_OK       - Maintenance serial number successfully created.
    SN_DATA_ERR - Either the Product Index or the CustomerID was illformed.
==============================================================================
*/

#if defined(_STD_C_)
int DecryptMaintenanceSerialNumber (ms)
    MSnbrRec *ms;
#else
int DecryptMaintenanceSerialNumber (MSnbrRec *ms)
#endif
{
    if (!ms || (ms->snbr[0] != 'M'))
	snerrno = SN_DATA_ERR;
    else {
	int    i;
	ulong  isum = 0;
	unchar chksum = 0;
	unchar tmpsum = 0;
	unchar bbuf[30];

	/*
	** Extract Product Index from serial number.  Compute modified
	** checksum over product index.
	*/
	{
	    char *tmpidx = ms->snbr+8;

	    ms->index = (ulong) atol(ms->snbr+8);
	    for (i = 0; i < 6; ++i) isum = (isum + tmpidx[i] * (i+1)) % 256;
	}

	/*
	** Convert encrypted data in serial number from ASCII to Binary.  Be
	** sure to strip off any trailing garbage before proceeding.
	*/
	Asc2Bin64(ms->snbr+1,6,bbuf);
    
	/*
	** XOR each byte in the buffer by a positionally dependent value based
	** on the product index.  Swap bytes back into original position.
	** Extract checksum value from binary data.
	*/
	for (i = 0; i < 6; ++i) bbuf[i] ^= (unchar) ((isum * (i+1)) & 0x0FF);

	bbuf[6] = bbuf[1];
	bbuf[1] = bbuf[4];
	bbuf[4] = bbuf[6];

	bbuf[6] = bbuf[0];
	bbuf[0] = bbuf[2];
	bbuf[2] = bbuf[6];

	chksum = bbuf[0];

	for (i = 1; i < 6; ++i) bbuf[i] ^= chksum;

	bbuf[5] &= 0xC0;

	/*
	** Recompute checksum and compare the computed value with that
	** extracted from the data.  If they match, extract the region and
	** sequence number from binary data.  Otherwise, set "snerrno" to the
	** appropriate value.
	*/
	for (tmpsum = 0, i = 1; i < 6; ++i) tmpsum += bbuf[i];
	tmpsum += (unchar) (ms->index & 0x0FF);
	if (tmpsum != chksum)
	    snerrno = SN_BAD_CHKSUM;
	else {
	    ms->region = (bbuf[1] << 6) | (bbuf[2] >> 2);
	    ms->sequence = ((bbuf[2] & 0x03) << 18) | (bbuf[3] << 10) | (bbuf[4] << 2) | (bbuf[5] >> 6);
	}
    }

    return snerrno;
}

#endif /* !defined(_MSNE_ENCONLY_) */


#if defined(_MSNE_TEST_)

#include "myctype.c"
#include "a2b64.c"
#include "snerr.c"

int main (int argc, char *argv[])
{
    MSnbrRec msrec;

    InitMSnbrRec(&msrec);
    msrec.index = (ulong) atol(argv[1]);
    msrec.region = (uint) atol(argv[2]);
    msrec.sequence = (ulong) atol(argv[3]);

    EncryptMaintenanceSerialNumber(&msrec);

    if (snerrno)
	printf("%s\n",snerrmsg);
    else {
	printf("Maintenance Key = %s\n",msrec.snbr);
	msrec.index = msrec.region = msrec.sequence = 0;
	DecryptMaintenanceSerialNumber(&msrec);
	if (snerrno)
	    printf("%s\n",snerrmsg);
	else {
	    printf("Product Index   = %06lu\n",msrec.index);
	    printf("Region Code     = %04u\n",msrec.region);
	    printf("Sequence Number = %lu\n",msrec.sequence);
	}
    }

    exit(snerrno);
}

#endif
